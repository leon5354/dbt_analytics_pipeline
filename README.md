# dbt Analytics Pipeline

A small, complete dbt project for a mobile game: raw CSVs in, tested
analytics marts out. It runs locally on DuckDB in about two seconds, with no
warehouse or credentials needed.

```bash
pip install dbt-duckdb
dbt build --profiles-dir .
```

`dbt build` loads the seeds, builds every model and runs every test in
dependency order. Expected result: `PASS=41 ERROR=0`.

## Lineage

```
seeds (raw CSV)          staging                 intermediate             marts
---------------          -------                 ------------             -----
raw_players      ->  stg_players       --+-> int_player_activity --+-> mart_player_360 --> mart_regional_performance
raw_sessions     ->  stg_sessions      --+                          |
raw_transactions ->  stg_transactions  ----> int_player_revenue  --+
                     stg_sessions + stg_transactions -------------------> mart_daily_metrics
```

| Layer | What it does |
|---|---|
| **Staging** | One model per source. Type casting, trimming, consistent casing, region mapping, product categories. No joins. |
| **Intermediate** | Player-level aggregates: activity (sessions, playtime, engagement score, churn) and revenue (spend by category, first/last purchase). |
| **Marts** | `mart_player_360`: one row per player with segment and lifecycle stage. `mart_daily_metrics`: DAU, revenue, payers, ARPDAU per day from event-level data. `mart_regional_performance`: conversion and retention by country. |

## Data quality

41 checks run on every build:

- **Keys**: unique and not null at every grain (players, sessions, transactions, days).
- **Referential integrity**: every session and transaction belongs to a known player.
- **Accepted values**: platform, player segment, lifecycle stage.
- **Reconciliation**: total revenue ties out across staging, player 360 and the daily mart, so no transaction is dropped or double-counted on the way through.
- **Business rules**: revenue is never negative; heavy players get a sensible engagement score.

## Design choices

- **Reproducible dates.** Recency and churn are measured against an `as_of_date`
  variable, not `current_date`, so the same data always gives the same answer.
  Run as of another date with `dbt build --vars '{as_of_date: 2025-02-28}'`.
- **Thresholds are config, not magic numbers.** Whale / Dolphin spend levels
  and the churn window live in `dbt_project.yml` vars.
- **Daily metrics come from events, not from player summaries**, so a day's
  revenue is what was actually spent that day.

## Why this project

I use dbt at work to build transaction monitoring and fraud detection models
over payment data. This repo shows the same pattern on public-safe sample data:
layered models, tests at every layer, and numbers that reconcile.

---

Leo | [github.com/leon5354](https://github.com/leon5354)
