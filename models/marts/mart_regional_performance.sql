-- Metrics by region

with players as (
    select * from {{ ref('mart_player_360') }}
)

select
    region,
    country_code,
    count(*) as total_players,
    sum(case when not is_churned then 1 else 0 end) as active_players,
    sum(case when is_payer then 1 else 0 end) as payers,
    sum(case when player_segment = 'Whale' then 1 else 0 end) as whales,
    sum(case when player_segment = 'Dolphin' then 1 else 0 end) as dolphins,
    sum(total_revenue) as total_revenue,
    avg(total_revenue) as avg_revenue,
    avg(total_sessions) as avg_sessions,
    avg(total_playtime_minutes) as avg_playtime,
    avg(engagement_score) as avg_engagement,
    cast(sum(case when is_payer then 1 else 0 end) as float) / count(*) * 100 as conversion_rate,
    sum(case when days_since_last_active <= 7 then 1 else 0 end) as retained_7d,
    cast(sum(case when days_since_last_active <= 7 then 1 else 0 end) as float) / count(*) * 100 as retention_7d
from players
group by region, country_code
order by total_revenue desc
