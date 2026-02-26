-- Clean up raw player data

with source as (
    select * from {{ ref('raw_players') }}
),

cleaned as (
    select
        player_id,
        cast(signup_date as date) as signup_date,
        upper(trim(country)) as country_code,
        lower(trim(platform)) as platform,
        lower(trim(email)) as email,
        trim(age_group) as age_group,
        
        -- group countries into regions
        case 
            when upper(trim(country)) in ('US', 'CA') then 'NA'
            when upper(trim(country)) in ('JP', 'KR', 'TW') then 'APAC'
            when upper(trim(country)) in ('UK', 'DE', 'FR') then 'EMEA'
            when upper(trim(country)) in ('BR') then 'LATAM'
            else 'OTHER'
        end as region,
        
        current_timestamp as _loaded_at
        
    from source
)

select * from cleaned
