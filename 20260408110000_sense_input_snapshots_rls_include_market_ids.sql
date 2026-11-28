-- Fix RLS on sense_input_snapshots: include market_ids (multi-market) not just market_id
-- Without this, workspaces with Lexington/Frankfort in market_ids could not see their snapshots

DROP POLICY IF EXISTS sense_input_snapshots_select_by_market ON readvise.sense_input_snapshots;

CREATE POLICY sense_input_snapshots_select_by_market
  ON readvise.sense_input_snapshots
  FOR SELECT
  USING (
    market_id IN (
      SELECT m FROM (
        SELECT ss.market_id AS m FROM readvise.sense_settings ss
        INNER JOIN core.workspace_members wm ON wm.workspace_id = ss.workspace_id
        WHERE wm.user_id = auth.uid() AND ss.market_id IS NOT NULL
        UNION
        SELECT unnest(ss.market_ids) FROM readvise.sense_settings ss
        INNER JOIN core.workspace_members wm ON wm.workspace_id = ss.workspace_id
        WHERE wm.user_id = auth.uid() AND ss.market_ids IS NOT NULL
      ) allowed
    )
  );
