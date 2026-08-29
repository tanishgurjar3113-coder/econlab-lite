import "@supabase/functions-js/edge-runtime.d.ts";
import {withSupabase} from "@supabase/server";

export default {
  fetch: withSupabase(
    { auth: ["publishable", "secret"] },
    async (_req, _ctx) => {
      return Response.json({
        success: true,
        service: "EconLab CPI backend",
      });
    },
  ),
};