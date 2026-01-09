ALN = ALN or {}
ALN.Inventory = ALN.Inventory or {}

-- Item instance shape in a slot:
-- { item="water", count=1, meta={...} }
ALN.Inventory.Schema = {
  slot = { 'item', 'count' }
}
