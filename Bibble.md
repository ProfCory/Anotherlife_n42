# ALN42 Project Ruleset
**AnotherLifeNumber42 – Clean Code FiveM Project**

> **Theme & Mood Anchor**  
> ALN42 is a rain-soaked, neon-lit, hostile-city sandbox.  
> Think: damp concrete, flickering streetlights, umbrellas in alleyways, and survival as a daily tax.  
> The world is not fair, not dry, and not safe — and it is *always watching*.

Project visual anchor: `myLogo.png` (root directory, canonical branding reference).

If a design decision ever conflicts with tone, **tone wins**.

---

## 0. World Theme & Environmental Baseline

This section defines the *feel* of the world. All systems must respect it.

### Core Atmosphere
- Persistent overcast / rain bias
- Low sunlight, muted colors
- Frequent storms, fog, smog
- Rare “nice” weather is notable, not normal
- City feels oppressive, wet, and alive

### Time Philosophy
- Day/night cycles matter, but are not rushed
- Morning is grey, night is dangerous
- Time should feel continuous, not arcade-fast

---

## 0.1 Weather & Time Baseline (Canonical Defaults)

The following configuration represents the **intended starting feel** and should be replicated when weather/time systems are implemented or replaced.

lua
Config = {}

-- Weather behavior
Config.DynamicWeather   = true
Config.StartWeather     = 'RAIN'
Config.NewWeatherTimer  = 10 -- minutes

-- Time behavior
Config.BaseTime         = 8
Config.TimeOffset       = 0
Config.FreezeTime       = false
Config.RealTimeSync     = false

-- World state
Config.Blackout         = false
Config.BlackoutVehicle  = false
Config.Disabled         = false

-- Weather pool (intentionally biased)
Config.AvailableWeatherTypes = {
    'NEUTRAL',
    'SMOG',
    'FOGGY',
    'OVERCAST',
    'FOGGY',
    'OVERCAST',
    'CLOUDS',
    'CLEARING',
    'RAIN',
    'RAIN',
    'RAIN',
    'RAIN',
    'THUNDER',
    'THUNDER',
    'SNOW',
    'BLIZZARD',
    'SNOWLIGHT',
    'XMAS',
    'HALLOWEEN',
}


### Design Notes

* Duplicates are intentional (weighted probability).
* RAIN / THUNDER are *default states*, not events.
* Clear weather should feel like a break, not the norm.
* Any future weather controller must preserve this bias unless explicitly overridden.

---

## 0.2 Visual Consistency Rules

* UI colors should favor dark neutrals, cyan/green highlights, muted reds.
* Avoid bright whites or “sunny” palettes unless contextually justified.
* Phone UI, shop UI, and contract UI should feel like tools, not apps.

---

## 0.3 Icon Pack Usage Policy (400+ Icons)

a large icon pack with a text index. This is a **content acceleration asset**, not a requirement to use everything.

---

## 1. Scope and Assumptions

*(unchanged from previous version)*

* Frameworkless FiveM project
* Only approved core dependencies:

  * `ox_lib`
  * `ox_target`
  * `oxmysql`
  * `bg3_dice`
  * `red-hitman`
  * txAdmin default CFX resources

---

## 2. Resource Architecture

* All custom resources live in `[ALN42]`
* Prefix: `aln42_`
* `aln42_core` is the single source of truth


```markdown
# ALN42 Project Ruleset
**AnotherLifeNumber42 – Clean Code FiveM Project**

This document defines the permanent architectural, coding, and design rules for the ALN42 project.  
All current and future resources must conform to these rules so that code remains readable, predictable, and compatible across time, contributors, and chat sessions.

---

## Scope and Assumptions

- This is a **frameworkless** FiveM (CFX) project.
- No assumptions about QB, Qbox, ESX, or similar frameworks are allowed.
- Only the following core dependencies are assumed to exist:

  - `ox_lib`
  - `ox_target`
  - `oxmysql`
  - `bg3_dice`
  - `red-hitman`
  - Default CFX resources installed by txAdmin (`mapmanager`, `spawnmanager`, `sessionmanager`, `player-data`, `playernames`)

- Any system not explicitly listed above must be added intentionally.

---

## Resource Architecture

- All custom resources live in the `[ALN42]` folder.
- All custom resources must be prefixed with `aln42_`.

### Single Source of Truth
- `aln42_core` is the **only** resource allowed to:
  - Write to the database
  - Own player identity and “lives”
  - Manage money and bank balances
  - Manage player stats and needs
  - Manage vehicle ownership and state
  - Resolve dice checks and outcomes

All other resources are **systems**, not authorities.  
They must communicate with `aln42_core` via exports or events.

---

## Standard Resource Layout

Every `aln42_*` resource must follow this structure:

aln42_x/
fxmanifest.lua
README.md
shared/
config.lua
locales.lua        # optional
types.lua          # optional
server/
main.lua
db.lua             # only if needed
client/
main.lua
ui/                 # only if NUI is used
index.html
app.js
style.css


### Dice-First Gameplay Rule

All chance-based outcomes must route through a single API in `aln42_core`.

### Conceptual API

SkillCheck(action, context)
→ { success, critical, roll, dc, reason }


### DC is determined by:
- Player stats and skills
- Tools used
- Target difficulty
- Environmental modifiers

Failures must return structured consequences (heat, noise, injury, escalation).

---

## Config-Driven Content

The following must be data-driven:
- Jobs
- Stores and item categories
- Contracts
- Vehicle tiers
- Skill definitions

Adding content should require **config changes only**, not logic edits.

---

## 9. Security and Validation

Even in solo play:
- Money changes are server-only.
- Inventory changes are server-only.
- Lives and identity changes are server-only.
- Vehicle ownership changes are server-only.

All client requests must be validated.

---

## 10. Logging and Debugging

- `Config.Debug = true/false` in `aln42_core`
- Use `ox_lib` logging helpers when available.
- When debug is enabled, systems must log:
  - Player spawns
  - Purchases
  - Contract acceptance/completion
  - Dice roll results

Logs should be short, structured, and readable.

---

## 11. Versioning and Compatibility

- Every resource must define a version in `fxmanifest.lua`.
- Breaking changes require a major version bump.
- Vendor resources must never be edited directly.
- All integrations with vendor resources must be wrapped.

---

## 12. Chat-Split and Continuity Rule

All generated code must be delivered as:
- Complete replacement files **or**
- Explicit, clearly bounded patch instructions

No ambiguous “insert somewhere” guidance.

---

## 13. Guiding Principles

- Explicit over implicit
- Data over logic
- One owner per responsibility
- Dice before certainty
- Phone before world interaction
- Broke is the default state

---

## Guiding Mood Summary

If someone asked *“what does ALN42 feel like?”* the answer should be:

> Wet streets. Bad odds. A cheap phone in your hand.
> Dice decide your fate.
> Being broke is normal.
> Surviving the night is a win.

If code, content, or systems drift from that — bring them back.

---

**This document is canonical.**
If implementation contradicts theme or rules, implementation is wrong.

### **Core World Mechanics (The "War" & Engine)**

| Feature | Priority | Do-ability | Notes |
| :--- | :---: | :---: | :--- |
| **Hyper-Vigilant Police AI** | ⭐⭐⭐⭐⭐ | 8/10 | Essential for "War Mode." Adjusting `Dispatch` & `CombatAttributes`. |
| **Aggressive Gang Zones** | ⭐⭐⭐⭐⭐ | 8/10 | Essential for "World at War." Setting Relationship Groups (Hate/Hate). |
| **Population Density Max** | ⭐⭐⭐⭐ | 9/10 | High density for witnesses/victims. Simple Native command. |


### **II. **


| Feature | Priority | Do-ability | Notes |
| :--- | :---: | :---: | :--- |
| **Dice Roll Integration (Lockpick/hotwire/stick up/safe crack/)** | ⭐⭐⭐⭐⭐ | 7/10 | Replacing progress bars with `bg3_dice` rolls for theft. |
| **Dice Roll Integration (Hack)** | ⭐⭐⭐⭐ | 7/10 | Replacing hacking minigames with dice rolls + Int bonus. |
| **Skill Tracker (XP System)** | ⭐⭐⭐ | 4/10 | This is just xp tracking for unlock and better performance like stock GTA not stats tied to D&D/dice. More attempts just mean better at the task at hand - run=get more stamina; fight=get stronger; and so on. |
| **"Fake ID" Revive Logic** | ⭐⭐⭐⭐⭐ | 6/10 | The core loop. Needs custom logic on the "PlayerDied" event. |
| **Airport Spawn Point** | ⭐⭐⭐⭐⭐ | 10/10 | Setting the default spawn coordinates. |

### **III. **

| Feature | Priority | Do-ability | Notes |
| :--- | :---: | :---: | :--- |
| **Burner Phone Item (Tier 1)** | ⭐⭐⭐⭐⭐ | 7/10 | Limited function item. Needs to open a simple menu, not full phone. just gps and needs.|
| **Smartphone Item (Tier 2)** | ⭐⭐⭐⭐ | 6/10 | Full features (Bank/GPS). Contracts, shops, but Needs to be an item that can be lost. |
| **Payphone "Job Giver" System** | ⭐⭐⭐⭐⭐ | 8/10 | Using `ox_target` on world props to trigger random missions. |
| **Banking/ATM Interaction** | ⭐⭐⭐ | 7/10 | banking on t2 phone with ATM and bank still working but mapped more for robbery than function as it is always on the t2 phones. |
| **Minimap GPS** | ⭐⭐⭐⭐ | 9/10 | Circle radar on t1 phone and square on t2. |
| **Food & Drink Items** | ⭐⭐⭐⭐⭐ | 10/10 | Water, Whiskey, Burgers, MREs. |
| **Vehicle Damage/Fuel System** | ⭐⭐⭐⭐ | 7/10 | Cars need to break/run out of gas to force walking/danger. |
| **Medical Items** | ⭐⭐⭐⭐⭐ | 10/10 | Bandages (slow heal), Medkits (fast heal). |
| **Tools** | ⭐⭐⭐⭐⭐ | 10/10 | Lockpicks, Slimjims, Drill, Thermite. |
| **Weapon Attachments** | ⭐⭐ | 9/10 | Silencers/Scopes (Expensive items). |
| **Phone-Based "Shopping App"** | ⭐⭐⭐ | 5/10 | A menu to find items, set GPS, and spawn a pickup zone. |
| **The Black Market (Chop Shop)** | ⭐⭐⭐⭐ | 6/10 | Rotating location for selling stolen cars. |
| **Realistic Pricing Config** | ⭐⭐⭐⭐⭐ | 10/10 | Tedious data entry, but easy. (Burgers $12, Guns $600). |
| **Physical Cash Drops** | ⭐⭐⭐⭐ | 8/10 | Money should be an item, not just a UI number, so it can be stolen. |



### **Content & Activities**
*Things to do besides survive.*

| Feature | Priority | Do-ability | Notes |
| :--- | :---: | :---: | :--- |
| **Taxi/Delivery Jobs (Legal)** | ⭐⭐⭐ | 8/10 | Standard "go here, get paid" loops. |
| **Contract Work (Illegal)** | ⭐⭐⭐⭐ | 7/10 | Spawning a specific task to pickup, drop off, or even an NPC target with guards. |
| **House Robbery System** | ⭐⭐⭐ | 6/10 | Teleporting into interiors to steal items. |
| **Motel System (Rent)** | ⭐⭐⭐ | 5/10 | Simple room rental for saving gear/logging out safely. |

### **VII. Assets & Items (The Wish List)**
*Things you want to add to the database down the road.*

| Feature | Priority | Do-ability | Notes |
| :--- | :---: | :---: | :--- |
| **Chevy/Car Pack Vehicles (Mod Pack)** | ⭐⭐⭐ | 8/10 | Adding your preferred 2003+ Chevys. |

# ALN42 Project Ruleset
**AnotherLifeNumber42 – Clean Code FiveM Project**

This document defines the permanent architectural, coding, and design rules for the ALN42 project.  
All current and future resources must conform to these rules so that code remains readable, predictable, and compatible across time, contributors, and chat sessions.
