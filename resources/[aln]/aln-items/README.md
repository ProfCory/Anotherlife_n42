# aln-items (ALN3)

Data-first item registry with stable IDs.

## Icons
Put PNGs here:
`resources/[aln3]/aln-items/icons/*.png`

Item definitions use:
`icon = "<iconId>"` -> loads `icons/<iconId>.png`

UI should call:
`exports['aln-items']:IconUrl(iconId)` which returns:
`nui://aln-items/icons/<iconId>.png`

## Adding new items
- Add items to an existing module in `shared/modules/`, OR create a new module file.
- If you create a new module file, add it to `shared_scripts` in `fxmanifest.lua`.
- Never rename an item key once persisted. Change `label` freely.

## Weapon wheel
Weapons/ammo are "virtual" catalog entries:
- `domain="weapon"` or `domain="ammo"`
- `storage="weaponwheel"`
- `inventoryVisible=false`

They are used by shops/unlocks to grant via GTA natives; they are not stored as normal item stacks.
