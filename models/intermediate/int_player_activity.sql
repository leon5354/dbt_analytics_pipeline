-- Aggregate sessions to player level

with sessions as (
    select * from {{ ref('stg_sessions') }}
),

players as (
    select * from {{ ref('stg_players') }}
),

player_activity as (
    select
        player_id,
        count(distinct session_id) as total_sessions,
        sum(duration_minutes) as total_playtime_minutes,
        avg(duration_minutes) as avg_session_duration,
        max(duration_minutes) as max_session_duration,
        sum(event_count) as total_events,
        min(session_date) as first_session,
        max(session_date) as last_session,
        count(distinct session_date) as active_days,
        
        -- made up engagement score
        (count(distinct session_id) * 0.3 + 
         avg(duration_minutes) * 0.4 + 
         count(distinct session_date) * 0.3) as engagement_score
        
    from sessions
    group by player_id
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
        coalesce(pa.first_session, p.signup_date) as first_session,
        coalesce(pa.last_session, p.signup_date) as last_session,
        coalesce(pa.active_days, 0) as active_days,
        coalesce(pa.engagement_score, 0) as engagement_score,
        
        cast(current_date - coalesce(pa.last_session, p.signup_date) as integer) as days_since_last_active,
        
        -- churned if no activity in 30 days
        case 
            when cast(current_date - coalesce(pa.last_session, p.signup_date) as integer) > 30
            then true else false 
        end as is_churned
        
    from players p
    left join player_activity pa on p.player_id = pa.player_id
)

select * from final
