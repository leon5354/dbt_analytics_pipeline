-- Daily KPIs for dashboards

with players as (
    select * from {{ ref('mart_player_360') }}
),

signups as (
    select signup_date as date, count(*) as new_players
    from players group by signup_date
),

active as (
    select last_session as date, count(*) as active_players
    from players where not is_churned group by last_session
),

revenue as (
    select last_purchase as date, sum(total_revenue) as revenue, count(*) as payers
    from players where is_payer group by last_purchase
),

dates as (
    select distinct signup_date as date from players
    union
    select distinct last_session from players where last_session is not null
    union
    select distinct last_purchase from players where last_purchase is not null
)

select
    d.date,
    coalesce(s.new_players, 0) as new_players,
    coalesce(a.active_players, 0) as active_players,
    coalesce(r.revenue, 0) as revenue,
    coalesce(r.payers, 0) as payers,
    case when coalesce(a.active_players, 0) > 0 
         then coalesce(r.revenue, 0) / a.active_players else 0 end as arpu,
    case when coalesce(a.active_players, 0) > 0 
         then coalesce(r.payers, 0)::float / a.active_players * 100 else 0 end as payer_rate
from dates d
left join signups s on d.date = s.date
left join active a on d.date = a.date
left join revenue r on d.date = r.date
where d.date is not null
order by d.date
