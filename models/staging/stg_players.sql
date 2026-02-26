-- Staging model for player data
-- Cleans and standardizes raw player data

with source as (
    select * from {{ ref('raw_players') }}
),

cleaned as (
    select
        -- Primary key
        player_id,
        
        -- Date fields
        cast(signup_date as date) as signup_date,
        
        -- Dimension fields (standardized)
        upper(trim(country)) as country_code,
        lower(trim(platform)) as platform,
        lower(trim(email)) as email,
        trim(age_group) as age_group,
        
        -- Derived fields
        case 
            when country_code in ('US', 'CA') then 'NA'
            when country_code in ('JP', 'KR', 'TW') then 'APAC'
            when country_code in ('UK', 'DE', 'FR') then 'EMEA'
            when country_code in ('BR') then 'LATAM'
            else 'OTHER'
        end as region,
        
        -- Metadata
        current_timestamp as _loaded_at
        
    from source
)

select * from cleaned
