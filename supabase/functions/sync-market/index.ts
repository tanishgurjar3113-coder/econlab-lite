import "@supabase/functions-js/edge-runtime.d.ts";
import { withSupabase } from "@supabase/server";

const API_BASE = "https://www.alphavantage.co/query";

export default {
  fetch: withSupabase(
    { auth: "none" },

    async (_req, ctx) => {
      try {
        console.log("Starting market sync...");

        const apiKey = Deno.env.get(
          "ALPHA_VANTAGE_API_KEY",
        );

        if (!apiKey) {
          throw new Error(
            "ALPHA_VANTAGE_API_KEY is not configured.",
          );
        }

        const url =
          `${API_BASE}?function=TIME_SERIES_DAILY` +
          `&symbol=RELIANCE.BSE` +
          `&outputsize=compact` +
          `&apikey=${encodeURIComponent(apiKey)}`;

        console.log(
          "Fetching RELIANCE.BSE daily data...",
        );

        const response = await fetch(url);

        const body = await response.text();

        console.log(
          "Alpha Vantage status:",
          response.status,
        );

        if (!response.ok) {
          throw new Error(
            `Alpha Vantage request failed (${response.status}): ${body}`,
          );
        }

        let data: {
          "Time Series (Daily)"?: Record<
            string,
            {
              "1. open": string;
              "2. high": string;
              "3. low": string;
              "4. close": string;
              "5. volume": string;
            }
          >;
          "Error Message"?: string;
          Note?: string;
        };

        try {
          data = JSON.parse(body);
        } catch {
          throw new Error(
            "Alpha Vantage returned invalid JSON.",
          );
        }

        if (data["Error Message"]) {
          throw new Error(
            `Alpha Vantage error: ${data["Error Message"]}`,
          );
        }

        if (data.Note) {
          throw new Error(
            `Alpha Vantage rate limit: ${data.Note}`,
          );
        }

        const timeSeries =
          data["Time Series (Daily)"];

        if (!timeSeries) {
          throw new Error(
            "Alpha Vantage returned no daily time series.",
          );
        }

        const dates = Object.keys(timeSeries)
          .sort()
          .reverse();

        if (dates.length < 2) {
          throw new Error(
            "At least two trading days are required.",
          );
        }

        const latestDate = dates[0];
        const previousDate = dates[1];

        const latest =
          timeSeries[latestDate];

        const previous =
          timeSeries[previousDate];

        const latestClose =
          Number(latest["4. close"]);

        const previousClose =
          Number(previous["4. close"]);

        const dayHigh =
          Number(latest["2. high"]);

        const dayLow =
          Number(latest["3. low"]);

        if (
          !Number.isFinite(latestClose) ||
          !Number.isFinite(previousClose) ||
          !Number.isFinite(dayHigh) ||
          !Number.isFinite(dayLow)
        ) {
          throw new Error(
            "Invalid numeric data returned by Alpha Vantage.",
          );
        }

        const change =
          latestClose - previousClose;

        const changePercent =
          previousClose !== 0
            ? (change / previousClose) * 100
            : null;

        /*
         * Latest market record
         */

        const marketRow = {
          symbol: "RELIANCE.BSE",
          name: "Reliance Industries",
          exchange: "BSE",
          category: "MARKETS",

          price: latestClose,
          previous_close: previousClose,

          change,
          change_percent: changePercent,

          day_low: dayLow,
          day_high: dayHigh,

          currency: "INR",

          market_status: "CLOSED",
          freshness: "EOD",

          data_timestamp: new Date(
            `${latestDate}T16:00:00+05:30`,
          ).toISOString(),

          fetched_at:
            new Date().toISOString(),

          source: "Alpha Vantage",
        };

        const {
          error: marketError,
        } = await ctx.supabaseAdmin
          .from("market_data")
          .upsert(
            [marketRow] as never[],
            {
              onConflict:
                "source,symbol,exchange",
            },
          );

        if (marketError) {
          throw new Error(
            `market_data insert failed: ${marketError.message}`,
          );
        }

        console.log(
          "Successfully upserted market_data.",
        );

        /*
         * Historical records
         */

        const historyRows = dates
          .map((date) => {
            const day =
              timeSeries[date];

            const close =
              Number(day["4. close"]);

            if (!Number.isFinite(close)) {
              return null;
            }

            return {
              symbol: "RELIANCE.BSE",
              exchange: "BSE",
              price: close,

              data_timestamp:
                new Date(
                  `${date}T16:00:00+05:30`,
                ).toISOString(),

              source: "Alpha Vantage",

              fetched_at:
                new Date().toISOString(),
            };
          })
          .filter(
            (
              row,
            ): row is {
              symbol: string;
              exchange: string;
              price: number;
              data_timestamp: string;
              source: string;
              fetched_at: string;
            } => row !== null,
          );

        const {
          error: historyError,
        } = await ctx.supabaseAdmin
          .from("market_history")
          .upsert(
            historyRows as never[],
            {
              onConflict:
                "source,symbol,exchange,data_timestamp",
            },
          );

        if (historyError) {
          throw new Error(
            `market_history insert failed: ${historyError.message}`,
          );
        }

        console.log(
          "Successfully upserted market_history.",
        );

        return Response.json({
          success: true,

          source: "Alpha Vantage",

          symbol: "RELIANCE.BSE",

          latestDate,
          previousDate,

          price: latestClose,
          previousClose,

          change,
          changePercent,

          dayLow,
          dayHigh,

          recordsUpserted: 1,

          historyRecordsUpserted:
            historyRows.length,
        });
      } catch (error) {
        console.error(
          "Market sync failed:",
          error,
        );

        return Response.json(
          {
            success: false,
            error: String(error),
          },
          {
            status: 500,
          },
        );
      }
    },
  ),
};