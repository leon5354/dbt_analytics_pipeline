-- Staging model for transaction data
-- Cleans and standardizes raw transaction data

with source as (
    select * from {{ ref('raw_transactions') }}
),

cleaned as (
    select
        -- Primary key
        transaction_id,
        
        -- Foreign keys
        player_id,
        
        -- Date fields
        cast(transaction_date as date) as transaction_date,
        
        -- Dimension fields
        product_id,
        trim(product_name) as product_name,
        
        -- Measures
        cast(amount as decimal(10,2)) as amount,
        upper(trim(currency)) as currency,
        
        -- Derived fields
        extract(year from transaction_date) as transaction_year,
        extract(month from transaction_date) as transaction_month,
        extract(day of week from transaction_date) as day_of_week,
        
        -- Product categorization
        case 
            when product_name like 'PokeCoins%' then 'Virtual Currency'
            when product_name = 'Battle_Pass' then 'Battle Pass'
            when product_name = 'Event_Ticket' then 'Event Ticket'
            else 'Other'
        end as product_category,
        
        -- Metadata
        current_timestamp as _loaded_at
        
    from source
)

select * from cleaned
