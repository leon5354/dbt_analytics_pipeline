-- Clean up session data

with source as (
    select * from {{ ref('raw_sessions') }}
),

cleaned as (
    select
        session_id,
        player_id,
        cast(session_date as date) as session_date,
        cast(duration_minutes as integer) as duration_minutes,
        cast(event_count as integer) as event_count,
        upper(trim(country)) as country_code,
        lower(trim(platform)) as platform,
        
        -- bucket session lengths
        case
            when duration_minutes < 15 then 'short'
            when duration_minutes < 30 then 'medium'
            when duration_minutes < 45 then 'long'
            else 'extended'
        end as session_length,
        
        current_timestamp as _loaded_at
        
    from source
)

select * from cleaned
