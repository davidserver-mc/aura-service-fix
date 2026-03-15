# YOUR AURA LOGIC EXPLAINED

## Core System: Array-Based Aura IDs

Your aura system uses **array indices as aura IDs**. This is the core logic:

```lua
-- Your Aura Module Structure:
local module = {
    {Name = "Normal", OneIn = 3, ...},      -- This is Aura ID 1
    {Name = "Celestial", OneIn = 6144, ...},-- This is Aura ID 2
    {Name = "Nature", OneIn = 6, ...},      -- This is Aura ID 3
    -- ... and so on up to ID 50
}
```

### How It Works

1. **Aura Position = Aura ID**
   - First aura in the array (position 1) = Aura ID 1
   - Second aura in the array (position 2) = Aura ID 2
   - 50th aura in the array (position 50) = Aura ID 50

2. **AuraService Uses Your Logic**
   ```lua
   local auraInfo = AurasLookup[auraId]  -- Array indexing!
   ```
   - When you call `GiveAuraToPlayer(1, player)`, it accesses `module[1]` → "Normal"
   - When you call `GiveAuraToPlayer(17, player)`, it accesses `module[17]` → "Devil"
   - When you call `GiveAuraToPlayer(50, player)`, it accesses `module[50]` → "Ethereal Harmony"

3. **Why This Is Perfect**
   - ✅ Direct array access is FAST (O(1) lookup)
   - ✅ IDs are simple numbers (1, 2, 3, ..., 50)
   - ✅ Easy to add new auras (just add to end of array)
   - ✅ No complex dictionary/mapping needed

## Your 50 Auras

```
ID  │ Aura Name              │ Rarity (1 in X)
────┼────────────────────────┼─────────────────
1   │ Normal                 │ 3
2   │ Celestial              │ 6,144
3   │ Nature                 │ 6
4   │ Toad                   │ 6
5   │ Twilight Champion      │ 12
6   │ Glisten                │ 12
7   │ Extreme Shine          │ 12
8   │ Inferus                │ 24
9   │ InfiniShield           │ 48
10  │ Divine                 │ 48
... │ (see AURA_IDS_REFERENCE.md for complete list)
50  │ Ethereal Harmony       │ 786,432
```

## How AuraService Supports Your Logic

### Loading Your Module
```lua
-- AuraService automatically loads your module:
local AurasLookup
local folder = ReplicatedStorage:FindFirstChild("AurasFolder")
if folder and folder:FindFirstChild("Auras") then
    local ok, tbl = pcall(function() return require(folder.Auras) end)
    if ok and type(tbl) == "table" then
        AurasLookup = tbl  -- This is YOUR array!
    end
end
```

### Accessing Auras
```lua
-- When you give an aura:
local auraInfo = AurasLookup[auraId]  -- Direct array access!

-- This gets ALL your aura properties:
-- - auraInfo.Name
-- - auraInfo.OneIn
-- - auraInfo.TextColor
-- - auraInfo.RarityGradient (if exists)
-- - auraInfo.Cutscene (if exists)
-- - auraInfo.AuraFont (if exists)
-- - auraInfo.Unrollable (if exists)
-- - auraInfo.OneInDisplay (if exists)
-- - auraInfo.RarityColor (if exists)
-- - auraInfo.CostInSeconds (if exists)
```

### Using Your Aura Properties
```lua
-- The service uses your exact properties:
sendWarning(player, "✨ You received: " .. auraInfo.Name .. "!")
-- Uses OneIn for rarity calculations (if you implement rolling)
-- Uses TextColor for display
-- Uses Cutscene to trigger cutscenes
-- Uses Unrollable to prevent rolling
-- etc.
```

## Examples

```lua
-- Give Normal aura (ID 1 = first in array)
AuraService:GiveAuraToPlayer(1, player)
-- Accesses: module[1] → {Name = "Normal", OneIn = 3, ...}

-- Give Devil aura (ID 17 = 17th in array)  
AuraService:GiveAuraToPlayer(17, player)
-- Accesses: module[17] → {Name = "Devil", OneIn = 6144, Cutscene = 2, ...}

-- Give Galaxy aura (ID 41 = 41st in array)
AuraService:GiveAuraToPlayer(41, player)
-- Accesses: module[41] → {Name = "Galaxy", OneIn = 2, Unrollable = true, ...}
```

## Why Your Logic is the Core System

✅ **It's simple**: ID = position in array
✅ **It's fast**: Direct array indexing
✅ **It's flexible**: All your custom properties work
✅ **It's yours**: This is YOUR system, YOUR way

The AuraService is built to use this exact logic!
