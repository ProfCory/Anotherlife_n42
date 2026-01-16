ALN = ALN or {}
ALN.Tags = ALN.Tags or {}

-- These are "known tag conventions" (not enforced; used for consistency).
ALN.Tags.Items = {
  -- Sources
  'src.shop.convenience',
  'src.shop.food',
  'src.shop.gas',
  'src.shop.pharmacy',
  'src.shop.hardware',
  'src.shop.mechanic',
  'src.shop.pawn',
  'src.shop.blackmarket',

  'src.loot.npc',
  'src.loot.crate',

  -- Sinks / endpoints
  'sink.shop.pawn',
  'sink.launder',
  'sink.service.ems',

  -- Flags
  'legal',
  'illegal',
  'loot_only',
  'not_for_sale',
  'consumable',
  'tool',
  'medical',
  'vehicle_service',
  'weaponwheel',
}
