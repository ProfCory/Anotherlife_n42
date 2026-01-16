# bridge-gabz (solo-friendly ambience for Gabz interiors)

## What it does
- Spawns **staff** + **visitors** in configured locations when you are nearby.
- Visitors come in waves, idle, then leave.
- Detects violence inside a location zone and marks it **closed for cleanup** (despawns visitors, disables targets).
- Optional `qb-target` zones for simple Talk/Rob interactions.
- Optional persistence (oxmysql) for "closed until" state across restarts.

## Dependencies
- Required: `ox_lib`
- Optional: `qb-target`
- Optional: `oxmysql`

## Install
1) Drop `bridge-gabz` into `resources/[standalone]/bridge-gabz`
2) In `server.cfg`:
```
ensure ox_lib
ensure bridge-gabz
```
3) (Optional) If using qb-target:
```
ensure qb-target
```

## Out of the box
- The script includes **example presets** (Pillbox/MRPD/Benny's) but they are **disabled** by default.
- Most Gabz packs require calibration of spawn points for best results.

## Builder (recommended for solo)
Grant yourself permission:
```
add_ace group.admin bridgegabz.builder allow
```
Then use:
- `/bg_newloc <id> <label>`
- Stand where you want the zone center: `/bg_here_zone <id> <radius>`
- Stand where a staff member should idle: `/bg_addstaff <id> [model] [scenario]`
- `/bg_setentry <id>` and `/bg_setexit <id>`
- Add visitor idle points: `/bg_addroam <id> [scenario]`
- `/bg_save` writes to `data/locations.json`

## Optional DB persistence
Enable in `shared/config.lua`:
```
BG_CFG.Integrations.UseOxMySQL = true
```
Create table:
```
CREATE TABLE IF NOT EXISTS bridge_gabz_state (
  id VARCHAR(64) NOT NULL PRIMARY KEY,
  closed_until BIGINT NOT NULL DEFAULT 0
);
```
