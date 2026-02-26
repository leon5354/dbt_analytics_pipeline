-- Custom test: Ensure all revenue values are non-negative
-- This catches data quality issues in upstream systems

select player_id, total_revenue
from {{ ref('mart_player_360') }}
where total_revenue < 0
