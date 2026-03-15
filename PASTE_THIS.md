# 📋 EXACTLY WHAT TO PASTE

## Step 1: Create Script in ServerScriptService
**Name it:** `SetupPlayerData`

**Paste this:**
```lua
local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Wait()
    
    local saveData = Instance.new("ModuleScript")
    saveData.Name = "PlayerSaveData"
    saveData.Source = [[return { Auras = {}, Index = {} }]]
    saveData.Parent = player
    
    print("✅ PlayerSaveData created for", player.Name)
end)
```

---

## Step 2: Create Folder in ReplicatedStorage
1. In **ReplicatedStorage**, create a **Folder** named `AurasFolder`
2. Inside `AurasFolder`, create a **ModuleScript** named `Auras`
3. **Paste the entire `Auras.lua` file from this repo into it** (50 auras, array with indices 1-50)

---

## Step 3: Create Remotes Folder in ReplicatedStorage
1. In **ReplicatedStorage**, create another **Folder** named `Remotes`
2. Inside `Remotes`, create a **RemoteEvent** named `Warning`

---

## Step 4: Your Part Setup (for ClickDetector)
Make sure your part has:
- **ClickDetector** (as a child of the part)
- **ClickDetectorExample script** (as a child of the part - already in the repo)

Example ClickDetectorExample script:
```lua
local AuraService = require(game.ServerScriptService.AuraService)
local clickDetector = script.Parent:FindFirstChildOfClass("ClickDetector")

if clickDetector then
    AuraService:BindClick(clickDetector, 1, { oneTimeOnly = false, cooldown = 5 })
    print("✅ ClickDetector bound to give aura ID 1 (Normal)")
end
```

Change the `1` to whatever aura ID you want (see AURA_IDS_REFERENCE.md for the full list).

---

## Step 5: Test It!
1. Press **Play** in Roblox Studio
2. Click your part
3. Check the **Output** window - you should see:
   ```
   [AuraService] GiveAuraToPlayer called: auraId=1, player=YourName
   [AuraService] Found PlayerSaveData module for YourName
   [AuraService] ✅ SUCCESS! Gave aura 1 (Normal) to YourName
   ```

---

## That's It! 🎉

If you see errors, check the Output window and compare the error messages with TROUBLESHOOTING.md.

**Quick Aura ID Reference:**
- ID 1 = Normal (1 in 3)
- ID 17 = Devil (1 in 6,144, has cutscene)
- ID 41 = Galaxy (1 in 2)
- ID 50 = Ethereal Harmony (1 in 786,432)

See `AURA_IDS_REFERENCE.md` for the complete list of all 50 auras!
