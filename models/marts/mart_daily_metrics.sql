-- Mart model: Daily KPI Summary
-- Aggregated metrics for daily business reporting

with player_360 as (
    select * from {{ ref('mart_player_360') }}
),

daily_signups as (
    select 
        signup_date as metric_date,
        count(*) as new_players
    from player_360
    group by signup_date
),

daily_active as (
    select 
        last_session_date as metric_date,
        count(*) as active_players
    from player_360
    where not is_churned
    group by last_session_date
),

daily_revenue as (
    select 
        last_purchase_date as metric_date,
        sum(total_revenue) as revenue,
        count(*) as paying_players
    from player_360
    where is_payer
    group by last_purchase_date
),

date_spine as (
    select distinct signup_date as metric_date from player_360
    union
    select distinct last_session_date from player_360 where last_session_date is not null
    union  
    select distinct last_purchase_date from player_360 where last_purchase_date is not null
),

final as (
    select
        d.metric_date,
        
        -- Player metrics
        coalesce(s.new_players, 0) as new_players,
        coalesce(a.active_players, 0) as active_players,
        
        -- Revenue metrics
        coalesce(r.revenue, 0) as daily_revenue,
        coalesce(r.paying_players, 0) as paying_players,
        
        -- Calculated KPIs
        case 
            when coalesce(a.active_players, 0) > 0 
            then coalesce(r.revenue, 0) / a.active_players 
            else 0 
        end as arpu,
        
        case 
            when coalesce(a.active_players, 0) > 0 
            then coalesce(r.paying_players, 0)::float / a.active_players * 100 
            else 0 
        end as payer_rate
        
    from date_spine d
    left join daily_signups s on d.metric_date = s.metric_date
    left join daily_active a on d.metric_date = a.metric_date
    left join daily_revenue r on d.metric_date = r.metric_date
    where d.metric_date is not null
)

select * from final
order by metric_date
