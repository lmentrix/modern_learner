-- ─────────────────────────────────────────────────────────────────────────────
-- stripe_transactions
-- Immutable audit log of every Stripe webhook event per user.
-- Written exclusively by the stripe-webhook Edge Function (service role).
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS stripe_transactions (
  id                      UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id                 UUID        REFERENCES auth.users(id) ON DELETE SET NULL,

  -- Stripe event identifiers (idempotency key)
  stripe_event_id         TEXT        UNIQUE,
  stripe_event_type       TEXT        NOT NULL,

  -- Related Stripe objects
  stripe_customer_id      TEXT,
  stripe_subscription_id  TEXT,
  stripe_session_id       TEXT,

  -- Payment details (in minor currency units, e.g. cents)
  amount_total            BIGINT,
  currency                TEXT,

  -- Outcome: succeeded | failed | pending | active | canceled
  status                  TEXT,

  -- Freeform metadata from the Stripe event
  metadata                JSONB,

  created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── Indexes ───────────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_stripe_tx_user_id
  ON stripe_transactions (user_id);

CREATE INDEX IF NOT EXISTS idx_stripe_tx_event_type
  ON stripe_transactions (stripe_event_type);

CREATE INDEX IF NOT EXISTS idx_stripe_tx_customer_id
  ON stripe_transactions (stripe_customer_id)
  WHERE stripe_customer_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_stripe_tx_subscription_id
  ON stripe_transactions (stripe_subscription_id)
  WHERE stripe_subscription_id IS NOT NULL;

-- ── Row Level Security ────────────────────────────────────────────────────────
ALTER TABLE stripe_transactions ENABLE ROW LEVEL SECURITY;

-- Users can read only their own transaction rows
CREATE POLICY "Users can view own transactions"
  ON stripe_transactions FOR SELECT
  TO authenticated
  USING ((select auth.uid()) = user_id);

-- Only service role (Edge Functions / webhook) can insert
CREATE POLICY "Service role can insert transactions"
  ON stripe_transactions FOR INSERT
  USING (auth.role() = 'service_role');
