# Red-Hitman

A professional hitman contract system for FiveM. Players can place hits on other players or claim AI-generated contracts through a broker NPC.

## Features

- **Player Contracts** - Place hits on other players with custom rewards
- **AI Contracts** - System-generated contracts with NPC targets
- **Modern UI** - Clean tablet-style interface with real-time updates
- **Broker NPC** - Interact with an NPC to access the hitman menu
- **GPS Tracking** - Waypoint tracking for your active target
- **Cooldown System** - Prevents spam and abuse
- **Multi-Framework** - Works with ESX, QBCore, QBX, and Standalone

## Dependencies

- **Required**: None (standalone compatible)
- **Optional**: ox_lib, ox_target, qb-target (auto-detected)

## Installation

1. Extract `red-hitman` to your resources folder
2. Add `ensure red-hitman` to your server.cfg
3. Configure the settings below to your liking
4. Restart your server

## Configuration

### Server Config (`config/sv_config.lua`)

| Option | Default | Description |
|--------|---------|-------------|
| MinHitPrice | 5000 | Minimum reward for placing a hit |
| MaxHitPrice | 500000 | Maximum reward for placing a hit |
| ContractExpiry | 120 | Minutes until unclaimed contracts expire |
| ClaimLockDuration | 30 | Minutes to complete a claimed contract |
| PlaceHitCooldown | 15 | Minutes between placing hits |
| ClaimCooldown | 15 | Minutes between claiming contracts |
| AbandonPenalty | 15 | Cooldown after abandoning a contract |
| MaxActiveContracts | 1 | Max contracts a player can claim at once |
| AIContracts | true | Enable AI-generated contracts |
| AIMinContracts | 6 | Minimum AI contracts in the pool |
| AIMaxContracts | 6 | Maximum AI contracts in the pool |
| AIMinReward | 5000 | Min reward for AI contracts |
| AIMaxReward | 20000 | Max reward for AI contracts |
| RefundPercent | 50 | Refund % when cancelling your placed hit |
| RestrictedToJob | false | Restrict to job (e.g. 'hitman' or false) |
| RestrictedToItem | false | Require item (e.g. 'hitman_phone' or false) |

### Client Config (`config/cl_config.lua`)

| Option | Default | Description |
|--------|---------|-------------|
| BrokerLocations | See file | Broker NPC spawn location(s) |
| BrokerModel | 'csb_agent' | Ped model for the broker |
| BrokerScenario | 'WORLD_HUMAN_STAND_IMPATIENT' | Broker idle animation |
| ShowBlip | true | Show broker location on map |
| ProximityDistance | 2.5 | Distance to interact with broker |

## Adding More Broker Locations

```lua
ClientConfig.BrokerLocations = {
    vector4(1166.59, -1640.89, 36.96, 190.61),
    vector4(x, y, z, heading), -- Add more locations here
}
```

## Support

Need help? Join our Discord: https://discord.gg/3d3EYu6WJk

---

Made by RedX Development
