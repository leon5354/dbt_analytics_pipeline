-- Intermediate model: Player activity aggregation
-- Aggregates session data to player level

with sessions as (
    select * from {{ ref('stg_sessions') }}
),

players as (
    select * from {{ ref('stg_players') }}
),

player_activity as (
    select
        s.player_id,
        
        -- Session metrics
        count(distinct s.session_id) as total_sessions,
        sum(s.duration_minutes) as total_playtime_minutes,
        avg(s.duration_minutes) as avg_session_duration,
        max(s.duration_minutes) as max_session_duration,
        sum(s.event_count) as total_events,
        
        -- Date metrics
        min(s.session_date) as first_session_date,
        max(s.session_date) as last_session_date,
        count(distinct s.session_date) as active_days,
        
        -- Engagement score (custom metric)
        (count(distinct s.session_id) * 0.3 + 
         avg(s.duration_minutes) * 0.4 + 
         count(distinct s.session_date) * 0.3) as engagement_score
        
    from sessions s
    group by s.player_id
),

final as (
    select
        p.player_id,
        p.signup_date,
        p.country_code,
        p.region,
        p.platform,
        p.age_group,
        
        coalesce(pa.total_sessions, 0) as total_sessions,
        coalesce(pa.total_playtime_minutes, 0) as total_playtime_minutes,
        coalesce(pa.avg_session_duration, 0) as avg_session_duration,
        coalesce(pa.max_session_duration, 0) as max_session_duration,
        coalesce(pa.total_events, 0) as total_events,
        coalesce(pa.first_session_date, p.signup_date) as first_session_date,
        coalesce(pa.last_session_date, p.signup_date) as last_session_date,
        coalesce(pa.active_days, 0) as active_days,
        coalesce(pa.engagement_score, 0) as engagement_score,
        
        -- Days since last activity
        cast(current_date - coalesce(pa.last_session_date, p.signup_date) as integer) as days_since_last_activity,
        
        -- Is churned (no activity in 30 days)
        case 
            when cast(current_date - coalesce(pa.last_session_date, p.signup_date) as integer) > {{ var('churn_days') }}
            then true 
            else false 
        end as is_churned
        
    from players p
    left join player_activity pa on p.player_id = pa.player_id
)

select * from final
