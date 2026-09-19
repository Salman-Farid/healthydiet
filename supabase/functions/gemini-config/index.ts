import "jsr:@supabase/functions-js/edge-runtime.d.ts";

// Coach Gemini key — served from Supabase Secrets, not packaged in the app.
// Auth: valid Supabase JWT (anon allowed) OR project apikey header.
Deno.serve(async (req: Request) => {
  const cors = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET, OPTIONS",
    "Access-Control-Allow-Headers":
      "authorization, x-client-info, apikey, content-type",
  };
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: cors });
  }

  const auth = req.headers.get("Authorization") ?? "";
  const apikey = req.headers.get("apikey") ?? "";
  const hasBearer = auth.toLowerCase().startsWith("bearer ") && auth.length > 20;
  const hasApikey = apikey.length > 20;
  if (!hasBearer && !hasApikey) {
    return new Response(
      JSON.stringify({ error: "missing_auth", detail: "Need Authorization or apikey" }),
      { status: 401, headers: { ...cors, "Content-Type": "application/json" } },
    );
  }

  const apiKey = Deno.env.get("GEMINI_API_KEY");
  if (!apiKey) {
    return new Response(
      JSON.stringify({ error: "gemini_key_not_configured" }),
      { status: 500, headers: { ...cors, "Content-Type": "application/json" } },
    );
  }

  return new Response(
    JSON.stringify({
      apiKey,
      model: "gemini-3.1-flash-live-preview",
      wsBaseUrl:
        "wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateContent",
    }),
    { status: 200, headers: { ...cors, "Content-Type": "application/json" } },
  );
});
