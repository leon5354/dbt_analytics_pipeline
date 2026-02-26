-- Player 360 - everything about a player in one row

with players as (
    select * from {{ ref('int_player_activity') }}
),

revenue as (
    select * from {{ ref('int_player_revenue') }}
),

final as (
    select
        p.player_id,
        p.signup_date,
        p.country_code,
        p.region,
        p.platform,
        p.age_group,
        
        -- activity
        p.total_sessions,
        p.total_playtime_minutes,
        p.avg_session_duration,
        p.max_session_duration,
        p.total_events,
        p.active_days,
        p.engagement_score,
        p.first_session,
        p.last_session,
        p.days_since_last_active,
        p.is_churned,
        
        -- revenue
        coalesce(r.total_transactions, 0) as total_transactions,
        coalesce(r.total_revenue, 0) as total_revenue,
        coalesce(r.avg_transaction, 0) as avg_transaction,
        coalesce(r.max_transaction, 0) as max_transaction,
        coalesce(r.products_bought, 0) as products_bought,
        coalesce(r.first_purchase, null) as first_purchase,
        coalesce(r.last_purchase, null) as last_purchase,
        coalesce(r.purchase_days, 0) as purchase_days,
        coalesce(r.currency_revenue, 0) as currency_revenue,
        coalesce(r.battle_pass_revenue, 0) as battle_pass_revenue,
        coalesce(r.event_revenue, 0) as event_revenue,
        
        -- segment
        case
            when coalesce(r.total_revenue, 0) >= 50 then 'Whale'
            when coalesce(r.total_revenue, 0) >= 10 then 'Dolphin'
            when p.total_sessions >= 10 then 'Active Free'
            else 'Casual'
        end as player_segment,
        
        -- flags
        case when r.total_transactions > 0 then true else false end as is_payer,
        case when r.total_transactions > 1 then true else false end as is_repeat_payer,
        
        -- lifecycle
        case
            when p.is_churned then 'Churned'
            when r.first_purchase is null and p.total_sessions >= 5 then 'Potential Converter'
            when r.first_purchase is not null and r.last_purchase < current_date - 30 then 'At Risk'
            when r.first_purchase is not null then 'Active Payer'
            else 'New Player'
        end as lifecycle_stage,
        
        cast(current_date - p.signup_date as integer) as tenure_days,
        
        case 
            when p.active_days > 0 then coalesce(r.total_revenue, 0) / p.active_days 
            else 0 
        end as daily_arpu
        
    from players p
    left join revenue r on p.player_id = r.player_id
)

select * from final
