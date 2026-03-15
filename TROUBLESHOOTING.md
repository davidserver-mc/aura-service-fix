# AuraService Troubleshooting Guide

## Problem: Player Doesn't Receive Aura from ClickDetector

### Debug Logging Enabled
The AuraService and ClickDetectorExample now have comprehensive debug logging. Check the **Server Output** in Roblox Studio for messages starting with `[AuraService]` or `[ClickDetectorExample]`.

### Common Issues and Solutions

#### 1. **PlayerSaveData Module Not Found**
**Error:** `PlayerSaveData module not found for [PlayerName]`

**Cause:** The AuraService expects each player to have a ModuleScript called `PlayerSaveData` as a child of the Player object.

**Solution:**
- Create a ModuleScript named `PlayerSaveData` under each player when they join
- This should contain a table with `Auras` and `Index` arrays:
```lua
-- PlayerSaveData ModuleScript
return {
    Auras = {},  -- List of aura IDs player owns
    Index = {}   -- Index for fast lookup
}
```

**Example PlayerAdded Script:**
```lua
-- ServerScriptService script
game.Players.PlayerAdded:Connect(function(player)
    local saveData = Instance.new("ModuleScript")
    saveData.Name = "PlayerSaveData"
    saveData.Source = [[
        return {
            Auras = {},
            Index = {}
        }
    ]]
    saveData.Parent = player
end)
```

---

#### 2. **AurasLookup Table Missing**
**Error:** `AurasLookup table is nil! Make sure ReplicatedStorage.AurasFolder.Auras exists`

**Cause:** The AuraService can't find the aura definitions.

**Solution:**
- Create a folder named `AurasFolder` in ReplicatedStorage
- Inside `AurasFolder`, create a ModuleScript named `Auras`
- This module should return a table mapping aura IDs to aura data:
```lua
-- ReplicatedStorage.AurasFolder.Auras
return {
    [43] = {
        Name = "Galaxy Aura",
        Rarity = "Legendary",
        -- other properties...
    },
    [35] = {
        Name = "Fire Aura",
        Rarity = "Epic",
        -- other properties...
    },
    -- Add more auras...
}
```

---

#### 3. **OneTimeOnly Blocking Subsequent Clicks**
**Log:** `Player [Name] already has aura [ID] (one-time only, silently ignoring)`

**Cause:** The ClickDetectorExample has `oneTimeOnly = true` by default. After the first click, all subsequent clicks are silently ignored.

**Solution:**
If you want players to be able to click multiple times:
```lua
-- In ClickDetectorExample.lua, change:
local OPTIONS = {
    cooldown = 10,
    autoEquip = true,
    announce = true,
    oneTimeOnly = false  -- Change this to false
}
```

---

#### 4. **Cooldown Preventing Rapid Clicks**
**Log:** `Cooldown active for [Name] ([X] seconds remaining)`

**Cause:** The script has a 10-second cooldown between aura gives.

**Solution:**
If you want no cooldown (for testing):
```lua
local OPTIONS = {
    cooldown = 0,  -- Set to 0 for no cooldown
    autoEquip = true,
    announce = true,
    oneTimeOnly = false
}
```

---

#### 5. **Invalid Aura ID**
**Error:** `Invalid aura ID [ID] - not found in AurasLookup`

**Cause:** The aura ID (43 by default) doesn't exist in your AurasLookup table.

**Solution:**
- Check what aura IDs you have defined in `ReplicatedStorage.AurasFolder.Auras`
- Update the `AURA_ID` in ClickDetectorExample.lua to match an existing aura:
```lua
local AURA_ID = 1  -- Change to an aura ID that exists in your game
```

---

#### 6. **Inventory Full**
**Error:** `Inventory full for [Name] ([X]/[Limit])`

**Cause:** The player has reached their inventory limit.

**Solution:**
- Increase the player's inventory limit: `player.PlayerStats.InventoryLimit.Value = 100`
- Or remove the limit check temporarily for testing

---

#### 7. **ClickDetector Not Working At All**
**No logs appear when clicking**

**Possible causes:**
1. **Script location:** ClickDetectorExample.lua must be a **direct child** of the Part with the ClickDetector
2. **ClickDetector missing:** The part must have a ClickDetector as a child
3. **Script disabled:** Make sure the script is enabled
4. **FilteringEnabled:** Make sure you're testing in a real server/client environment, not just command bar

**Solution:**
- Verify hierarchy: `Part > ClickDetector` and `Part > ClickDetectorExample`
- Add a ClickDetector to your part if missing
- Check that the part is visible and not too far away (ClickDetectors have a MaxActivationDistance)

---

### Testing Checklist

Before reporting an issue, verify these are all present:

- [ ] **PlayerSaveData ModuleScript** exists under the player when they join
- [ ] **ReplicatedStorage.AurasFolder.Auras** ModuleScript exists with aura definitions
- [ ] **Aura ID in script** matches an aura in your AurasLookup table
- [ ] **ClickDetector** exists as a child of the part
- [ ] **ClickDetectorExample script** is a child of the same part
- [ ] **Part is in Workspace** and visible
- [ ] You're testing in **Play mode**, not command bar
- [ ] Check the **Server Output** window for debug messages

---

### Debug Output Example

When everything is working correctly, you should see:
```
[ClickDetectorExample] Binding click detector on Part to give aura 43
[ClickDetectorExample] Options: cooldown=10, autoEquip=true, announce=true, oneTimeOnly=true
[ClickDetectorExample] ✅ Setup complete - ready to give aura 43
[ClickDetectorExample] Click detected! Player: PlayerName
[AuraService] GiveAuraToPlayer called: auraId=43, player=PlayerName
[AuraService] Options: cooldown=10, autoEquip=true, announce=true, oneTimeOnly=true
[AuraService] Found PlayerSaveData module for PlayerName
[AuraService] Successfully loaded save data for PlayerName
[AuraService] Found aura info: Galaxy Aura
[AuraService] Player currently has 0 auras
[AuraService] Cooldown set for PlayerName
[AuraService] Adding aura 43 to PlayerName's inventory
[AuraService] ✅ SUCCESS! Gave aura 43 (Galaxy Aura) to PlayerName
[ClickDetectorExample] ✅ Successfully gave aura to PlayerName
```

---

### Still Having Issues?

If you've checked everything above and it still doesn't work:

1. **Copy the entire debug output** from the Server window
2. **Take a screenshot** of your Explorer hierarchy showing:
   - The part with ClickDetector and script
   - ReplicatedStorage.AurasFolder.Auras
   - A player with PlayerSaveData
3. **Share both** for more specific help

The debug messages will tell us exactly where the problem is!
