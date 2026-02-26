-- Macro: Generate player segment summary
-- Usage: {{ generate_segment_summary('mart_player_360') }}

{% macro generate_segment_summary(model_name) %}

select
    player_segment,
    count(*) as player_count,
    sum(total_revenue) as total_revenue,
    avg(total_revenue) as avg_revenue,
    avg(total_sessions) as avg_sessions,
    avg(active_days) as avg_active_days,
    cast(sum(case when is_payer then 1 else 0 end) as float) / count(*) * 100 as payer_rate
from {{ ref(model_name) }}
group by player_segment
order by total_revenue desc

{% endmacro %}
