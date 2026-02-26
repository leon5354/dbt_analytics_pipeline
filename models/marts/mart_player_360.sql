-- Mart model: Player 360 View
-- Combines all player data into a single source of truth for analytics

with players as (
    select * from {{ ref('int_player_activity') }}
),

revenue as (
    select * from {{ ref('int_player_revenue') }}
),

final as (
    select
        -- Player dimensions
        p.player_id,
        p.signup_date,
        p.country_code,
        p.region,
        p.platform,
        p.age_group,
        
        -- Activity metrics
        p.total_sessions,
        p.total_playtime_minutes,
        p.avg_session_duration,
        p.max_session_duration,
        p.total_events,
        p.active_days,
        p.engagement_score,
        p.first_session_date,
        p.last_session_date,
        p.days_since_last_activity,
        p.is_churned,
        
        -- Revenue metrics
        coalesce(r.total_transactions, 0) as total_transactions,
        coalesce(r.total_revenue, 0) as total_revenue,
        coalesce(r.avg_transaction_value, 0) as avg_transaction_value,
        coalesce(r.max_transaction_value, 0) as max_transaction_value,
        coalesce(r.unique_products_purchased, 0) as unique_products_purchased,
        coalesce(r.first_purchase_date, null) as first_purchase_date,
        coalesce(r.last_purchase_date, null) as last_purchase_date,
        coalesce(r.purchase_days, 0) as purchase_days,
        coalesce(r.virtual_currency_revenue, 0) as virtual_currency_revenue,
        coalesce(r.battle_pass_revenue, 0) as battle_pass_revenue,
        coalesce(r.event_ticket_revenue, 0) as event_ticket_revenue,
        
        -- Player segment (key business logic)
        case
            when coalesce(r.total_revenue, 0) >= {{ var('whale_threshold') }} then 'Whale'
            when coalesce(r.total_revenue, 0) >= {{ var('dolphin_threshold') }} then 'Dolphin'
            when p.total_sessions >= 10 then 'Active Free'
            else 'Casual'
        end as player_segment,
        
        -- Conversion flags
        case when r.total_transactions > 0 then true else false end as is_payer,
        case when r.total_transactions > 1 then true else false end as is_repeat_payer,
        
        -- Lifecycle stage
        case
            when p.is_churned then 'Churned'
            when r.first_purchase_date is null and p.total_sessions >= 5 then 'Potential Converter'
            when r.first_purchase_date is not null and r.last_purchase_date < current_date - 30 then 'At Risk'
            when r.first_purchase_date is not null then 'Active Payer'
            else 'New Player'
        end as lifecycle_stage,
        
        -- Tenure
        cast(current_date - p.signup_date as integer) as player_tenure_days,
        
        -- ARPU (for this player)
        case 
            when p.active_days > 0 
            then coalesce(r.total_revenue, 0) / p.active_days 
            else 0 
        end as daily_arpu
        
    from players p
    left join revenue r on p.player_id = r.player_id
)

select * from final
