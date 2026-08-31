# EconLab Lite

EconLab Lite is an educational finance application that was developed to make economic and financial concepts easier to understand using calculators, educational explanations and real-world market data.

## Features

- Compound Interest Calculator
- EMI Calculator
- Inflation Calculator
- Educational content for each calculator
- Responsive calculator navigation
- Market Snapshot with real market data
- Historical market-price visualization
- Supabase-backed data storage
- Alpha Vantage market-data integration

## Technologies Used

- Flutter
- Dart
- Supabase
- PostgreSQL
- Alpha Vantage API
- fl_chart

## How It Works

The calculators are built in Flutter and use reusable widgets and services to separate the interface, calculations and data access.

Educational content is stored in Supabase and loaded separately for each calculator.

Market data is fetched through a Supabase Edge Function, which gathers market data from Alpha Vantage and stores the resulting data in Supabase before it is displayed in the Flutter application.

## Market Data

The application currently uses Alpha Vantage for market information.

The market section displays the latest available data together with historical price information used to create the price-history chart.

The data availability depends on the data provider and the
limitations of the selected API plan.

## Project Structure

```text
lib/
├── models/
├── screens/
├── service/
├── widgets/
└── theme/

supabase/
└── functions/
    └── sync-market/