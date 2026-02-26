-- Mart model: Regional Performance
-- Geographic breakdown of key metrics

with player_360 as (
    select * from {{ ref('mart_player_360') }}
),

regional as (
    select
        region,
        country_code,
        
        -- Player counts
        count(*) as total_players,
        sum(case when not is_churned then 1 else 0 end) as active_players,
        sum(case when is_payer then 1 else 0 end) as paying_players,
        sum(case when player_segment = 'Whale' then 1 else 0 end) as whale_count,
        sum(case when player_segment = 'Dolphin' then 1 else 0 end) as dolphin_count,
        
        -- Revenue
        sum(total_revenue) as total_revenue,
        avg(total_revenue) as avg_revenue_per_player,
        
        -- Engagement
        avg(total_sessions) as avg_sessions,
        avg(total_playtime_minutes) as avg_playtime_minutes,
        avg(engagement_score) as avg_engagement_score,
        
        -- Conversion
        cast(sum(case when is_payer then 1 else 0 end) as float) / count(*) * 100 as conversion_rate,
        
        -- Retention (players active in last 7 days)
        sum(case when days_since_last_activity <= 7 then 1 else 0 end) as retained_7d,
        cast(sum(case when days_since_last_activity <= 7 then 1 else 0 end) as float) / count(*) * 100 as retention_rate_7d
        
    from player_360
    group by region, country_code
)

select * from regional
order by total_revenue desc
