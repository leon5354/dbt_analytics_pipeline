-- Custom test: Verify engagement score is calculated correctly
-- Players with high sessions should have reasonable engagement scores

select player_id, total_sessions, engagement_score
from {{ ref('int_player_activity') }}
where total_sessions > 10 and engagement_score < 5
