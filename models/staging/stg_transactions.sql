-- Clean up transaction data

with source as (
    select * from {{ ref('raw_transactions') }}
),

cleaned as (
    select
        transaction_id,
        player_id,
        cast(transaction_date as date) as transaction_date,
        product_id,
        trim(product_name) as product_name,
        cast(amount as decimal(10,2)) as amount,
        upper(trim(currency)) as currency,
        
        -- useful date parts
        extract(year from transaction_date) as year,
        extract(month from transaction_date) as month,
        extract(day of week from transaction_date) as day_of_week,
        
        -- categorize products
        case 
            when product_name like 'PokeCoins%' then 'Virtual Currency'
            when product_name = 'Battle_Pass' then 'Battle Pass'
            when product_name = 'Event_Ticket' then 'Event Ticket'
            else 'Other'
        end as product_category,
        
        current_timestamp as _loaded_at
        
    from source
)

select * from cleaned
