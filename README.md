# dbt Analytics Pipeline

A dbt project showing how I'd structure a data pipeline - raw data to clean analytics tables.

## Setup

```bash
pip install dbt-duckdb
dbt seed
dbt run
dbt test
```

## Structure

```
seeds/          # Raw CSV data (players, transactions, sessions)
models/
  staging/      # Clean up the raw data
  intermediate/ # Join and aggregate
  marts/        # Final tables for dashboards
tests/          # Data quality checks
macros/         # Reusable SQL
```

## What it does

**Staging** - Cleans raw data, standardizes formats, adds useful columns

**Intermediate** - Aggregates by player (activity metrics, revenue metrics)

**Marts** - Final tables:
- `mart_player_360` - everything about a player in one row
- `mart_daily_metrics` - daily KPIs
- `mart_regional_performance` - by country/region

## Tests

- Primary keys are unique and not null
- Platform values are valid (ios, android, switch)
- Revenue is never negative
- Engagement scores make sense

## Why dbt

I use dbt at work to transform raw data into analytics tables. This project shows the pattern: source → staging → intermediate → marts, with tests at each layer.

---

Leo | [github.com/leon5354](https://github.com/leon5354)
