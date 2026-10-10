-- Daily KPIs for dashboards, built from event-level data so each day
-- counts what actually happened that day (DAU, revenue, payers).

with players as (
    select * from {{ ref('stg_players') }}
),

sessions as (
    select * from {{ ref('stg_sessions') }}
),

transactions as (
    select * from {{ ref('stg_transactions') }}
),

signups as (
    select signup_date as date, count(*) as new_players
    from players
    group by 1
),

active as (
    select session_date as date, count(distinct player_id) as active_players
    from sessions
    group by 1
),

revenue as (
    select
        transaction_date as date,
        sum(amount) as revenue,
        count(distinct player_id) as payers
    from transactions
    group by 1
),

dates as (
    select date from signups
    union
    select date from active
    union
    select date from revenue
)

select
    d.date,
    coalesce(s.new_players, 0) as new_players,
    coalesce(a.active_players, 0) as active_players,
    coalesce(r.revenue, 0) as revenue,
    coalesce(r.payers, 0) as payers,
    -- per active user; null when nobody played that day (not a fake 0)
    r.revenue / nullif(a.active_players, 0) as arpdau
from dates d
left join signups s on d.date = s.date
left join active a on d.date = a.date
left join revenue r on d.date = r.date
order by d.date
