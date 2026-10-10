-- Reconciliation: revenue must tie out across layers.
-- Staging, the player 360 and the daily mart must all report the same total;
-- any row returned is a mismatch (dropped or double-counted transactions).

with totals as (
    select
        (select sum(amount) from {{ ref('stg_transactions') }}) as staging_total,
        (select sum(total_revenue) from {{ ref('mart_player_360') }}) as player_total,
        (select sum(revenue) from {{ ref('mart_daily_metrics') }}) as daily_total
)

select *
from totals
where staging_total != player_total
   or staging_total != daily_total
