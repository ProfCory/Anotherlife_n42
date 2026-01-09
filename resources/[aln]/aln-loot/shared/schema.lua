ALN = ALN or {}
ALN.Loot = ALN.Loot or {}

-- Pool schema notes:
-- pool = {
--   label = string,
--   rolls = { min=int, max=int },  -- how many draws to make from the weighted table
--   entries = {
--     { item='water', w=35, count={min=1,max=1}, meta={...}, variant={...} },
--     { item=nil, w=20 }  -- represents “nothing”
--   }
-- }

ALN.Loot.Schema = {
  requiredPool = { 'label', 'rolls', 'entries' }
}
