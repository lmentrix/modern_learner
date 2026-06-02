import Stripe from "https://esm.sh/stripe@14.21.0?target=deno";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const stripeSecret =
  Deno.env.get("STRIPE_SECRET") ?? Deno.env.get("STRIPE_SECRET_KEY");

if (!stripeSecret) {
  throw new Error(
    "Missing required Edge Function secret: STRIPE_SECRET or STRIPE_SECRET_KEY",
  );
}

const stripe = new Stripe(stripeSecret, {
  apiVersion: "2024-06-20",
  httpClient: Stripe.createFetchHttpClient(),
});

const supabase = createClient(
  Deno.env.get("SUPABASE_URL") ?? "",
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
);

// ── helpers ──────────────────────────────────────────────────────────────────

async function logTransaction(opts: {
  userId?: string | null;
  stripeEventId?: string;
  stripeEventType: string;
  stripeCustomerId?: string | null;
  stripeSubscriptionId?: string | null;
  stripeSessionId?: string | null;
  amountTotal?: number | null;
  currency?: string | null;
  status?: string | null;
  metadata?: Record<string, unknown> | null;
}) {
  await supabase.from("stripe_transactions").insert({
    user_id: opts.userId ?? null,
    stripe_event_id: opts.stripeEventId ?? null,
    stripe_event_type: opts.stripeEventType,
    stripe_customer_id: opts.stripeCustomerId ?? null,
    stripe_subscription_id: opts.stripeSubscriptionId ?? null,
    stripe_session_id: opts.stripeSessionId ?? null,
    amount_total: opts.amountTotal ?? null,
    currency: opts.currency ?? null,
    status: opts.status ?? null,
    metadata: opts.metadata ?? null,
  });
}

// ── handler ──────────────────────────────────────────────────────────────────

Deno.serve(async (req) => {
  const signature = req.headers.get("stripe-signature");
  if (!signature) {
    return new Response("Missing signature", { status: 400 });
  }

  const body = await req.text();
  let event: Stripe.Event;

  try {
    event = await stripe.webhooks.constructEventAsync(
      body,
      signature,
      Deno.env.get("STRIPE_WEBHOOK_SECRET") ?? ""
    );
  } catch (err) {
    return new Response(`Webhook verification failed: ${err}`, { status: 400 });
  }

  try {
    switch (event.type) {
      // ── New subscription from Checkout ─────────────────────────────────────
      case "checkout.session.completed": {
        const session = event.data.object as Stripe.Checkout.Session;
        const userId = session.metadata?.user_id;
        if (!userId || session.payment_status !== "paid") break;

        const sub = session.subscription
          ? await stripe.subscriptions.retrieve(session.subscription as string)
          : null;

        await Promise.all([
          supabase
            .from("profiles")
            .update({
              role: "vip",
              subscription_status: "active",
              stripe_customer_id: session.customer as string,
            })
            .eq("id", userId),

          supabase.from("subscriptions").upsert(
            {
              user_id: userId,
              stripe_subscription_id: sub?.id ?? null,
              stripe_customer_id: session.customer as string,
              stripe_price_id: sub?.items.data[0]?.price.id ?? null,
              status: "active",
              current_period_start: sub
                ? new Date(sub.current_period_start * 1000).toISOString()
                : null,
              current_period_end: sub
                ? new Date(sub.current_period_end * 1000).toISOString()
                : null,
              cancel_at_period_end: sub?.cancel_at_period_end ?? false,
              updated_at: new Date().toISOString(),
            },
            { onConflict: "user_id" }
          ),

          logTransaction({
            userId,
            stripeEventId: event.id,
            stripeEventType: event.type,
            stripeCustomerId: session.customer as string,
            stripeSubscriptionId: sub?.id ?? null,
            stripeSessionId: session.id,
            amountTotal: session.amount_total,
            currency: session.currency,
            status: "succeeded",
            metadata: session.metadata as Record<string, unknown>,
          }),
        ]);
        break;
      }

      // ── Subscription changed (renewal, cancel toggle, etc.) ────────────────
      case "customer.subscription.updated": {
        const subscription = event.data.object as Stripe.Subscription;
        const userId = subscription.metadata?.user_id;
        if (!userId) break;

        const isActive = ["active", "trialing"].includes(subscription.status);

        await Promise.all([
          supabase
            .from("profiles")
            .update({
              role: isActive ? "vip" : "normal",
              subscription_status: subscription.status,
            })
            .eq("id", userId),

          supabase.from("subscriptions").upsert(
            {
              user_id: userId,
              stripe_subscription_id: subscription.id,
              stripe_customer_id: subscription.customer as string,
              stripe_price_id: subscription.items.data[0]?.price.id ?? null,
              status: subscription.status,
              current_period_start: new Date(
                subscription.current_period_start * 1000
              ).toISOString(),
              current_period_end: new Date(
                subscription.current_period_end * 1000
              ).toISOString(),
              cancel_at_period_end: subscription.cancel_at_period_end,
              trial_end: subscription.trial_end
                ? new Date(subscription.trial_end * 1000).toISOString()
                : null,
              updated_at: new Date().toISOString(),
            },
            { onConflict: "user_id" }
          ),

          logTransaction({
            userId,
            stripeEventId: event.id,
            stripeEventType: event.type,
            stripeCustomerId: subscription.customer as string,
            stripeSubscriptionId: subscription.id,
            status: subscription.status,
            metadata: subscription.metadata as Record<string, unknown>,
          }),
        ]);
        break;
      }

      // ── Subscription deleted / expired ─────────────────────────────────────
      case "customer.subscription.deleted": {
        const subscription = event.data.object as Stripe.Subscription;
        const userId = subscription.metadata?.user_id;
        if (!userId) break;

        await Promise.all([
          supabase
            .from("profiles")
            .update({ role: "normal", subscription_status: "canceled" })
            .eq("id", userId),

          supabase.from("subscriptions").upsert(
            {
              user_id: userId,
              stripe_subscription_id: subscription.id,
              stripe_customer_id: subscription.customer as string,
              status: "canceled",
              canceled_at: new Date().toISOString(),
              cancel_at_period_end: false,
              updated_at: new Date().toISOString(),
            },
            { onConflict: "user_id" }
          ),

          logTransaction({
            userId,
            stripeEventId: event.id,
            stripeEventType: event.type,
            stripeCustomerId: subscription.customer as string,
            stripeSubscriptionId: subscription.id,
            status: "canceled",
            metadata: subscription.metadata as Record<string, unknown>,
          }),
        ]);
        break;
      }

      // ── Invoice payment succeeded ──────────────────────────────────────────
      case "invoice.payment_succeeded": {
        const invoice = event.data.object as Stripe.Invoice;
        if (!invoice.subscription) break;

        const sub = await stripe.subscriptions.retrieve(
          invoice.subscription as string
        );
        const userId = sub.metadata?.user_id;
        if (!userId) break;

        await logTransaction({
          userId,
          stripeEventId: event.id,
          stripeEventType: event.type,
          stripeCustomerId: invoice.customer as string,
          stripeSubscriptionId: sub.id,
          amountTotal: invoice.amount_paid,
          currency: invoice.currency,
          status: "succeeded",
        });
        break;
      }

      // ── Invoice payment failed ─────────────────────────────────────────────
      case "invoice.payment_failed": {
        const invoice = event.data.object as Stripe.Invoice;
        if (!invoice.subscription) break;

        const sub = await stripe.subscriptions.retrieve(
          invoice.subscription as string
        );
        const userId = sub.metadata?.user_id;
        if (!userId) break;

        await Promise.all([
          supabase
            .from("profiles")
            .update({ role: "normal", subscription_status: "past_due" })
            .eq("id", userId),

          supabase.from("subscriptions").upsert(
            {
              user_id: userId,
              stripe_subscription_id: sub.id,
              stripe_customer_id: sub.customer as string,
              status: "past_due",
              updated_at: new Date().toISOString(),
            },
            { onConflict: "user_id" }
          ),

          logTransaction({
            userId,
            stripeEventId: event.id,
            stripeEventType: event.type,
            stripeCustomerId: invoice.customer as string,
            stripeSubscriptionId: sub.id,
            amountTotal: invoice.amount_due,
            currency: invoice.currency,
            status: "failed",
          }),
        ]);
        break;
      }
    }

    return new Response(JSON.stringify({ received: true }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (err) {
    return new Response(`Handler error: ${err}`, { status: 500 });
  }
});
