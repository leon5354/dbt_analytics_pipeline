-- Intermediate model: Player revenue aggregation
-- Aggregates transaction data to player level

with transactions as (
    select * from {{ ref('stg_transactions') }}
),

player_revenue as (
    select
        player_id,
        
        -- Revenue metrics
        count(distinct transaction_id) as total_transactions,
        sum(amount) as total_revenue,
        avg(amount) as avg_transaction_value,
        max(amount) as max_transaction_value,
        
        -- Product metrics
        count(distinct product_id) as unique_products_purchased,
        
        -- Date metrics
        min(transaction_date) as first_purchase_date,
        max(transaction_date) as last_purchase_date,
        count(distinct transaction_date) as purchase_days,
        
        -- Category breakdown
        sum(case when product_category = 'Virtual Currency' then amount else 0 end) as virtual_currency_revenue,
        sum(case when product_category = 'Battle Pass' then amount else 0 end) as battle_pass_revenue,
        sum(case when product_category = 'Event Ticket' then amount else 0 end) as event_ticket_revenue,
        
        -- Derived metrics
        sum(amount) / nullif(count(distinct transaction_date), 0) as revenue_per_purchase_day
        
    from transactions
    group by player_id
)

select * from player_revenue
