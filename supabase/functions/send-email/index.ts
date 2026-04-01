// Follow the setup instructions here:
// https://supabase.com/docs/guides/functions/set-up-ai

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { Resend } from "https://esm.sh/resend@2.0.0";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface EmailRequest {
  email: string;
  token: string;
  type: string;
  siteUrl: string;
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { email, token, type, siteUrl }: EmailRequest = await req.json();

    if (!email || !token || !type || !siteUrl) {
      throw new Error("Missing required parameters: email, token, type, siteUrl");
    }

    // Initialize Resend with API key from environment
    const resend = new Resend(Deno.env.get("RESEND_API_KEY"));

    // Construct the confirmation link
    // For mobile apps, we use the deep link scheme
    const confirmationUrl = `${siteUrl}?token=${encodeURIComponent(token)}&type=${encodeURIComponent(type)}`;

    // Send email using Resend
    const data = await resend.emails.send({
      from: Deno.env.get("FROM_EMAIL") || "onboarding@resend.dev",
      to: email,
      subject: "Confirm your email - ModernLearner",
      html: `
        <!DOCTYPE html>
        <html>
          <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Confirm your email</title>
          </head>
          <body style="margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; background-color: #0C0E17;">
            <table role="presentation" style="width: 100%; border-collapse: collapse;">
              <tr>
                <td style="padding: 40px 20px;">
                  <table role="presentation" style="max-width: 600px; margin: 0 auto; background-color: #171924; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);">
                    <!-- Header -->
                    <tr>
                      <td style="background: linear-gradient(135deg, #7E51FF 0%, #B1A0FF 100%); padding: 40px 30px; text-align: center;">
                        <h1 style="margin: 0; color: #ffffff; font-size: 28px; font-weight: 600;">Welcome to ModernLearner!</h1>
                      </td>
                    </tr>
                    
                    <!-- Content -->
                    <tr>
                      <td style="padding: 40px 30px;">
                        <p style="margin: 0 0 20px; color: #F0F0FD; font-size: 16px; line-height: 1.6;">
                          Thanks for signing up! We're excited to have you on board.
                        </p>
                        <p style="margin: 0 0 30px; color: #F0F0FD; font-size: 16px; line-height: 1.6;">
                          To get started, please confirm your email address by clicking the button below:
                        </p>
                        
                        <!-- CTA Button -->
                        <table role="presentation" style="margin: 30px 0; border-collapse: collapse;">
                          <tr>
                            <td style="border-radius: 12px; background: linear-gradient(135deg, #7E51FF 0%, #B1A0FF 100%);">
                              <a href="${confirmationUrl}" 
                                 style="display: inline-block; padding: 16px 40px; color: #ffffff; text-decoration: none; font-size: 16px; font-weight: 600; border-radius: 12px;">
                                Confirm Email Address
                              </a>
                            </td>
                          </tr>
                        </table>
                        
                        <p style="margin: 0 0 20px; color: #AAAAB7; font-size: 14px; line-height: 1.6;">
                          Or copy and paste this link into your browser:
                        </p>
                        <p style="margin: 0 0 30px;">
                          <a href="${confirmationUrl}" 
                             style="color: #B1A0FF; font-size: 14px; word-break: break-all;">
                            ${confirmationUrl}
                          </a>
                        </p>
                        
                        <!-- Info Box -->
                        <table role="presentation" style="width: 100%; border-collapse: collapse; background-color: #1C1F2B; border-radius: 12px; margin: 30px 0;">
                          <tr>
                            <td style="padding: 20px;">
                              <p style="margin: 0 0 10px; color: #B1A0FF; font-size: 14px; font-weight: 600;">
                                💡 Tip: Can't click the button?
                              </p>
                              <p style="margin: 0; color: #AAAAB7; font-size: 13px; line-height: 1.5;">
                                If you're on mobile, make sure you have the ModernLearner app installed. The link will automatically open the app and confirm your email.
                              </p>
                            </td>
                          </tr>
                        </table>
                        
                        <p style="margin: 0 0 10px; color: #AAAAB7; font-size: 13px; line-height: 1.6;">
                          This confirmation link will expire in 24 hours.
                        </p>
                        <p style="margin: 0; color: #AAAAB7; font-size: 13px; line-height: 1.6;">
                          If you didn't create this account, you can safely ignore this email.
                        </p>
                      </td>
                    </tr>
                    
                    <!-- Footer -->
                    <tr>
                      <td style="padding: 30px; background-color: #11131D; text-align: center;">
                        <p style="margin: 0 0 10px; color: #666670; font-size: 13px;">
                          ModernLearner
                        </p>
                        <p style="margin: 0; color: #4A4B55; font-size: 12px;">
                          © ${new Date().getFullYear()} ModernLearner. All rights reserved.
                        </p>
                      </td>
                    </tr>
                  </table>
                </td>
              </tr>
            </table>
          </body>
        </html>
      `,
      text: `
Welcome to ModernLearner!

Thanks for signing up! To get started, please confirm your email address by visiting the following link:

${confirmationUrl}

This confirmation link will expire in 24 hours.

If you didn't create this account, you can safely ignore this email.

© ${new Date().getFullYear()} ModernLearner. All rights reserved.
      `,
      tags: {
        event_type: "email_confirmation",
        user_email: email,
      },
    });

    return new Response(
      JSON.stringify({
        success: true,
        data: data,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    console.error("Error sending email:", error);
    return new Response(
      JSON.stringify({
        success: false,
        error: error.message || "Failed to send email",
      }),
      {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
