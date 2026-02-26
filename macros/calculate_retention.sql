-- Macro: Calculate retention rate for a given cohort period
-- Usage: {{ calculate_retention('mart_player_360', 7) }}

{% macro calculate_retention(model_name, days) %}

with base as (
    select 
        player_id,
        signup_date,
        last_session_date,
        cast(last_session_date - signup_date as integer) as days_active
    from {{ ref(model_name) }}
),

retained as (
    select 
        count(*) as total_players,
        sum(case when days_active >= {{ days }} then 1 else 0 end) as retained_players
    from base
)

select 
    total_players,
    retained_players,
    cast(retained_players as float) / nullif(total_players, 0) * 100 as retention_rate_percent
from retained

{% endmacro %}
