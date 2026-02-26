-- Staging model for session data
-- Cleans and standardizes raw session data

with source as (
    select * from {{ ref('raw_sessions') }}
),

cleaned as (
    select
        -- Primary key
        session_id,
        
        -- Foreign keys
        player_id,
        
        -- Date fields
        cast(session_date as date) as session_date,
        
        -- Measures
        cast(duration_minutes as integer) as duration_minutes,
        cast(event_count as integer) as event_count,
        
        -- Dimension fields
        upper(trim(country)) as country_code,
        lower(trim(platform)) as platform,
        
        -- Derived fields
        case
            when duration_minutes < 15 then 'Short'
            when duration_minutes < 30 then 'Medium'
            when duration_minutes < 45 then 'Long'
            else 'Extended'
        end as session_length_bucket,
        
        extract(hour from current_timestamp) as _extracted_hour,
        
        -- Metadata
        current_timestamp as _loaded_at
        
    from source
)

select * from cleaned
