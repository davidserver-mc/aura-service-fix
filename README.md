# Aura Service - Fixed and Improved

A robust, copy-paste friendly Roblox module for giving auras to players with comprehensive features including cooldowns, one-time-only behavior, auto-equip, and more.

## 📁 Project Structure

```
src/
├── ServerScriptService/
│   ├── AuraService.lua              # Main module - place in ServerScriptService or ReplicatedStorage
│   ├── TouchPartLogic.lua           # Example: Touch a part to get an aura
│   ├── ClickDetectorExample.lua    # Example: Click to get an aura
│   └── ProximityPromptExample.lua  # Example: Proximity prompt to get an aura
```

## 🚀 Quick Start

### 1. Install AuraService

Copy `AuraService.lua` to `ServerScriptService` or `ReplicatedStorage` in your Roblox game.

### 2. Basic Usage - Touch Part

```lua
local AuraService = require(game.ServerScriptService.AuraService)

-- Simple one-liner to give an aura when a part is touched
part.Touched:Connect(function(hit)
    local player = game.Players:GetPlayerFromCharacter(hit.Parent)
    if player then
        AuraService:GiveAuraToPlayer(35, player, { oneTimeOnly = true })
    end
end)
```

### 3. Using with ClickDetector

```lua
local AuraService = require(game.ServerScriptService.AuraService)

-- Even simpler - AuraService handles everything!
AuraService:BindClick(clickDetector, 43, {
    cooldown = 10,
    autoEquip = true,
    oneTimeOnly = true,
    announce = true
})
```

## 📖 Key API Reference

### `AuraService:GiveAuraToPlayer(auraId, player, options)`

Main function to give an aura to a player.

**Parameters:**
- `auraId` (number): The ID of the aura to give
- `player` (Player): The player to give the aura to
- `options` (table, optional): Configuration options

**Options:**
- `cooldown` (number): Cooldown in seconds (default: 5)
- `autoEquip` (bool): Auto-equip the aura (default: false)
- `announce` (bool): Announce to all players (default: false)
- `visualDuration` (number): Visual feedback duration (default: 2)
- `deletePart` (Instance): Part to destroy after giving
- `oneTimeOnly` (bool): Silently ignore if player already has aura (default: false)

**Returns:**
- `success` (bool): True if aura was given successfully
- `result` (string/table): Error message or aura info table

**Example:**
```lua
local success, result = AuraService:GiveAuraToPlayer(35, player, {
    cooldown = 5,
    autoEquip = false,
    oneTimeOnly = true
})

if success then
    print("Gave aura:", result.Name)
else
    print("Failed:", result)
end
```

### `AuraService:GiveAura(auraId, target, options)`

Convenience function that automatically resolves the target to a player.

**Accepts:** Player, Model (character), Humanoid, or BasePart

**Example:**
```lua
-- Works with any of these:
AuraService:GiveAura(35, player, options)
AuraService:GiveAura(35, character, options)
AuraService:GiveAura(35, humanoid, options)
AuraService:GiveAura(35, hitPart, options)
```

### `AuraService:BindClick(clickDetector, auraId, options)`

Binds a ClickDetector to give an aura when clicked.

**Example:**
```lua
AuraService:BindClick(clickDetector, 43, { oneTimeOnly = true })
```

### `AuraService:MakeHandler(auraId, options)`

Returns a handler function you can connect to any event.

**Example:**
```lua
clickDetector.Activated:Connect(AuraService:MakeHandler(43, { oneTimeOnly = true }))
```

### `AuraService:BindProximity(prompt, auraId, options)`

Binds a ProximityPrompt to give an aura when triggered.

**Example:**
```lua
AuraService:BindProximity(proximityPrompt, 50, { autoEquip = true })
```

### `AuraService:BindBindable(part, auraId, options)`

Creates/binds a BindableEvent for server-side triggering.

**Example:**
```lua
AuraService:BindBindable(part, 60, options)
-- Later, trigger it:
part.GiveAuraBindable:Fire(player)
```

## 🎯 Features

### ✅ Automatic Validation
- Player data loaded check
- Aura ID validation
- Duplicate prevention
- Inventory limit check

### ⏱️ Cooldown System
- Per-player cooldown tracking
- Configurable cooldown duration
- Automatic cleanup on player leave

### 🎁 One-Time-Only Behavior
- Silently ignores players who already have the aura
- Perfect for limited-time events or unique collectibles
- No spam warnings for players

### 🎨 Visual & Audio Feedback
- Success sound effect
- Optional visual effects (if AuraModule exists)
- Player notifications via RemoteEvents

### 🔧 Auto-Equip Support
- Optionally equips the aura immediately
- Works with RemoteEvent or RemoteFunction

### 📢 Server Announcements
- Optional server-wide announcements
- Lets everyone know when someone gets a rare aura

## 📝 Example Configurations

### Rare Collectible Aura
```lua
AuraService:GiveAuraToPlayer(100, player, {
    oneTimeOnly = true,     -- Can only get once
    autoEquip = true,       -- Equip immediately
    announce = true,        -- Tell everyone!
    cooldown = 0            -- No cooldown needed (one-time only handles it)
})
```

### Daily Reward Aura
```lua
AuraService:GiveAuraToPlayer(200, player, {
    oneTimeOnly = false,    -- Can get multiple times
    cooldown = 86400,       -- 24 hour cooldown
    autoEquip = false,
    announce = false
})
```

### Touch Part That Deletes Itself
```lua
part.Touched:Connect(function(hit)
    local player = game.Players:GetPlayerFromCharacter(hit.Parent)
    if player then
        AuraService:GiveAuraToPlayer(35, player, {
            deletePart = part,      -- Part will be destroyed after giving
            oneTimeOnly = true,
            cooldown = 0
        })
    end
end)
```

## 🔌 Dependencies

AuraService works standalone but integrates with these optional resources:

- `ReplicatedStorage.AurasFolder.Auras` - Aura definitions lookup table
- `ReplicatedStorage.AuraModule` - Visual effects module
- `ReplicatedStorage.Remotes.Warning` - Player notification RemoteEvent
- `ReplicatedStorage.Remotes.ServerMessages` - Server announcements RemoteEvent
- `ReplicatedStorage.Remotes.EquipAura` - Auto-equip RemoteEvent/Function
- `player.PlayerSaveData` - Player save data ModuleScript
- `player.PlayerStats.InventoryLimit` - Inventory limit IntValue

If any dependency is missing, AuraService gracefully handles it and continues to work.

## 🐛 Error Handling

AuraService returns clear error messages:
- `"Missing player or auraId"` - Invalid parameters
- `"Player data not loaded yet!"` - Save data not ready
- `"Failed to load player save data!"` - Error requiring save module
- `"Server aura definitions missing!"` - AurasFolder/Auras not found
- `"Invalid aura ID!"` - Aura ID doesn't exist
- `"You already have [aura name]!"` - Player has duplicate
- `"Your inventory is full!"` - Hit inventory limit
- `"Cooldown active"` - Cooldown not expired
- `"Already had aura (one-time only)"` - OneTimeOnly behavior

## 💡 Tips

1. **Use `oneTimeOnly = true`** for collectibles to avoid spam
2. **Set `cooldown = 0`** when using `oneTimeOnly` (redundant otherwise)
3. **Use `announce = true`** sparingly for rare/special auras only
4. **Use BindClick/BindProximity** for cleaner code instead of manual connects
5. **Check return values** if you need custom behavior on failure

## 📄 License

Free to use and modify for your Roblox projects!