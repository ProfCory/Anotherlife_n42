-- aln_hostilezones/shared/constants.lua
Constants = {}

Constants.Incident = {
    GUNSHOT = "gunshot",
    HIT = "hit",
    KILL = "kill",
    EXPLOSION = "explosion",
    VEHICLE_RAM = "vehicleRamming",
    AIM_THREAT = "aimingThreat",
    OPS_LINGER = "opsLingering",
}

Constants.Events = {
    ZoneEntered = "aln_hostiles:zoneEntered",
    ZoneLeft = "aln_hostiles:zoneLeft",
    TierChanged = "aln_hostiles:tierChanged",
    Incident = "aln_hostiles:incident",
    WaveSpawned = "aln_hostiles:waveSpawned",
    ZoneCleared = "aln_hostiles:zoneCleared",
    Jurisdiction = "aln_hostiles:jurisdiction",
    OpsPressure = "aln_hostiles:opsPressure",

    InteriorAvailable = "aln_hostiles:interiorAvailable",
    InteriorEntered = "aln_hostiles:interiorEntered",
    InteriorCleared = "aln_hostiles:interiorCleared",

    BossSpawned = "aln_hostiles:bossSpawned",
    BossKilled = "aln_hostiles:bossKilled",
    BossCalledBackup = "aln_hostiles:bossCalledBackup",
    BossVehicleKey = "aln_hostiles:bossVehicleKey",

    VehicleArmed = "aln_hostiles:vehicleArmed",         -- advisory (plate, factionId, rigged)
    VehicleAuthorized = "aln_hostiles:vehicleAuthorized",-- plate authorized for player
    LootHint = "aln_hostiles:lootHint",                 -- advisory (zoneId, shellId, tier, pos)
}

return Constants
