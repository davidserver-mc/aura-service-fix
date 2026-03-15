-- AuraService.lua - FIXED VERSION
-- ModuleScript (place in ServerScriptService or ReplicatedStorage)
-- Provides simple, copy-paste friendly functions to give auras from any script.
-- Updated: added support for one-time-only behavior (oneTimeOnly / OneTimeOnly).
--
-- FIXES APPLIED:
-- ✅ Fixed tryAutoEquip to use InvokeClient instead of Invoke for RemoteFunction
-- ✅ Fixed duplicate aura check to send warning to player
-- ✅ Fixed inventory full check to send warning to player
-- ✅ Fixed cooldown ordering - checks validity before consuming cooldown
-- ✅ Fixed oneTimeOnly to properly return early without consuming cooldown
--
-- Key API:
--   AuraService:GiveAuraToPlayer(auraId, player, options) -> (bool, message/orAuraInfo)
--     options keys:
--       cooldown (number)        - seconds (default DEFAULT_COOLDOWN)
--       autoEquip (bool)         - try auto-equip (default DEFAULT_AUTO_EQUIP)
--       announce (bool)          - announce to all players (default false)
--       visualDuration (number)  - seconds for visual feedback (default DEFAULT_VISUAL_DURATION)
--       deletePart (Instance)    - optional part to destroy after giving
--       oneTimeOnly (bool)       - if true, silently ignore players who already had the aura (default DEFAULT_ONE_TIME_ONLY)
--
--   AuraService:GiveAura(auraId, targetOrPlayer, options) -> convenience (resolves target to player)
--   AuraService:BindClick(clickDetector, auraId, options) -> binds ClickDetector.Activated
--   AuraService:MakeHandler(auraId, options) -> returns function(player) you can Connect directly
--   AuraService:BindProximity(prompt, auraId, options)
--   AuraService:BindBindable(part, auraId, options)
--
-- Usage examples:
--   AuraService:GiveAuraToPlayer(43, player, { oneTimeOnly = true })
--   AuraService:BindClick(clickDetector, 43, { oneTimeOnly = true })
--   clickDetector.Activated:Connect(AuraService:MakeHandler(43, { oneTimeOnly = true }))
--

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local AuraService = {}
AuraService.__index = AuraService

-- CONFIG: adjust defaults here if you want
local DEFAULT_COOLDOWN = 5
local DEFAULT_VISUAL_DURATION = 2
local DEFAULT_AUTO_EQUIP = false
local DEFAULT_ONE_TIME_ONLY = false

-- Internal state
local touchCooldowns = {} -- map userId -> lastGiveTime

-- Optional resources (lookups). The module tries to load these automatically.
local AurasLookup
do
	local folder = ReplicatedStorage:FindFirstChild("AurasFolder")
	if folder and folder:FindFirstChild("Auras") then
		local ok, tbl = pcall(function() return require(folder.Auras) end)
		if ok and type(tbl) == "table" then
			AurasLookup = tbl
		end
	end
end

local AuraTemplateFunction
do
	local auraModule = ReplicatedStorage:FindFirstChild("AuraModule")
	if auraModule then
		local ok, mod = pcall(function() return require(auraModule) end)
		if ok and type(mod) == "table" and type(mod.CreateTemplate) == "function" then
			-- default visual template; callers can ignore if they don't have AuraModule
			AuraTemplateFunction = mod.CreateTemplate({
				color = Color3.fromRGB(170,255,255),
				size = Vector2.new(120,120),
				offset = Vector3.new(0,2,0),
				fadeTime = 0.5
			})
		end
	end
end

-- Optional remotes (Warning, ServerMessages, EquipAura)
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
local WarningRemote = Remotes and Remotes:FindFirstChild("Warning")
local ServerMessagesRemote = Remotes and Remotes:FindFirstChild("ServerMessages")
local EquipAuraRemote = Remotes and Remotes:FindFirstChild("EquipAura")

-- Helpers
local function sendWarning(player, message)
	if WarningRemote and WarningRemote:IsA("RemoteEvent") then
		pcall(function() WarningRemote:FireClient(player, message) end)
	else
		warn("[AuraService] to", player.Name .. ":", message)
	end
end

local function announceAll(player, auraId)
	if ServerMessagesRemote and ServerMessagesRemote:IsA("RemoteEvent") then
		pcall(function() ServerMessagesRemote:FireAllClients(player.Name, auraId) end)
	else
		print(("%s received aura %d"):format(player.Name, auraId))
	end
end

-- FIX: Changed from Invoke to InvokeClient for RemoteFunction
local function tryAutoEquip(player, auraId)
	if not EquipAuraRemote then return end
	if EquipAuraRemote:IsA("RemoteEvent") then
		pcall(function() EquipAuraRemote:FireClient(player, auraId, false) end)
	elseif EquipAuraRemote:IsA("RemoteFunction") then
		pcall(function() EquipAuraRemote:InvokeClient(player, auraId, false) end)
	end
end

local function playSuccessSound(parent)
	local s = Instance.new("Sound")
	s.SoundId = "rbxassetid://6518811702"
	s.Volume = 0.5
	s.Parent = parent or workspace
	s:Play()
	Debris:AddItem(s, 3)
end

local function resolvePlayerFromTarget(target)
	if not target then return nil end
	if typeof(target) == "Instance" then
		if target:IsA("Player") then
			return target
		elseif target:IsA("Model") then
			return Players:GetPlayerFromCharacter(target)
		elseif target:IsA("Humanoid") then
			local parent = target.Parent
			if parent then return Players:GetPlayerFromCharacter(parent) end
		elseif target:IsA("BasePart") then
			local model = target:FindFirstAncestorWhichIsA("Model")
			if model then return Players:GetPlayerFromCharacter(model) end
		end
	end
	return nil
end

-- Core: give aura to player's save table (mutates table returned by PlayerSaveData module)
-- Options table (optional): { autoEquip = bool, announce = bool, cooldown = number, visualDuration = number, deletePart = instance (or nil), oneTimeOnly = bool }
-- Returns: true, auraInfo or false, errorMessage
function AuraService:GiveAuraToPlayer(auraId, player, options)
	if not player or not auraId then
		return false, "Missing player or auraId"
	end

	options = options or {}
	local cooldown = options.cooldown or DEFAULT_COOLDOWN
	local autoEquip = (options.autoEquip == nil) and DEFAULT_AUTO_EQUIP or options.autoEquip
	local announce = options.announce or false
	local visualDuration = options.visualDuration or DEFAULT_VISUAL_DURATION
	local deletePart = options.deletePart -- optional part to destroy after giving
	local oneTimeOnly = (options.oneTimeOnly == nil) and DEFAULT_ONE_TIME_ONLY or options.oneTimeOnly

	-- load player save data module (expected under player.PlayerSaveData)
	local saveModule = player:FindFirstChild("PlayerSaveData")
	if not saveModule then
		-- If oneTimeOnly is true, behave silently like earlier scripts might (but return false)
		return false, "Player data not loaded yet!"
	end
	local ok, saveData = pcall(function() return require(saveModule) end)
	if not ok or type(saveData) ~= "table" then
		return false, "Failed to load player save data!"
	end

	-- aura lookup validation
	if not AurasLookup then
		return false, "Server aura definitions missing!"
	end
	local auraInfo = AurasLookup[auraId]
	if not auraInfo then
		return false, "Invalid aura ID!"
	end

	saveData.Auras = saveData.Auras or {}
	saveData.Index = saveData.Index or {}

	-- ONE-TIME-ONLY behavior: if set, silently ignore players who already had the aura
	if oneTimeOnly and table.find(saveData.Auras, auraId) then
		-- return false with a clear message; caller can choose to ignore this
		return false, "Already had aura (one-time only)"
	end

	-- Prevent duplicate gives normally as well
	-- FIX: Added sendWarning so player gets notified
	if table.find(saveData.Auras, auraId) then
		sendWarning(player, "You already have " .. (auraInfo.Name or "this aura") .. "!")
		return false, "You already have " .. (auraInfo.Name or "this aura") .. "!"
	end

	-- inventory limit check (optional)
	-- FIX: Added sendWarning so player gets notified
	if player:FindFirstChild("PlayerStats") and player.PlayerStats:FindFirstChild("InventoryLimit") then
		local limit = player.PlayerStats.InventoryLimit.Value
		if #saveData.Auras >= limit then
			sendWarning(player, "Your inventory is full!")
			return false, "Your inventory is full!"
		end
	end

	-- FIX: Cooldown check moved AFTER validation checks so cooldown is not wasted on invalid attempts
	-- cooldown check (do this after duplicate/oneTime checks so we don't waste cooldowns)
	local last = touchCooldowns[player.UserId]
	if last and (os.clock() - last) < cooldown then
		return false, "Cooldown active"
	end
	-- reserve the timestamp immediately
	touchCooldowns[player.UserId] = os.clock()

	-- give the aura
	table.insert(saveData.Auras, auraId)
	if not table.find(saveData.Index, auraId) then
		table.insert(saveData.Index, auraId)
	end

	-- notify player + server
	sendWarning(player, "✨ You received: " .. (auraInfo.Name or "an aura") .. "!")
	if announce then announceAll(player, auraId) end
	playSuccessSound(player.Character and player.Character:FindFirstChildWhichIsA("BasePart") or workspace)

	-- auto-equip
	if autoEquip then
		tryAutoEquip(player, auraId)
	end

	-- visual feedback if AuraModule exists
	if AuraTemplateFunction then
		pcall(function() AuraTemplateFunction(player, visualDuration) end)
	end

	-- optional deletePart (safe)
	if deletePart and deletePart:IsA("Instance") then
		task.delay(1, function()
			if deletePart and deletePart.Parent then
				pcall(function() deletePart:Destroy() end)
			end
		end)
	end

	return true, auraInfo
end

-- Convenience: accepts Player | Model | Humanoid | BasePart and resolves player automatically
function AuraService:GiveAura(auraId, targetOrPlayer, options)
	local player = resolvePlayerFromTarget(targetOrPlayer)
	if not player then
		return false, "Could not find player from target"
	end
	return self:GiveAuraToPlayer(auraId, player, options)
end

-- Helper to return a Connectable function for events that pass player as first param
-- Example: clickDetector.Activated:Connect(AuraService:MakeHandler(43))
function AuraService:MakeHandler(auraId, options)
	options = options or {}
	-- returns a function(player, ...)
	return function(player, ...)
		-- if called from client/other events with extra args, ignore them
		AuraService:GiveAuraToPlayer(auraId, player, options)
	end
end

-- Convenience binder: auto-connect a ClickDetector so you don't have to write the Connect code each time
-- clickDetector: ClickDetector instance; auraId: number; options: see GiveAuraToPlayer
-- returns connection object
function AuraService:BindClick(clickDetector, auraId, options)
	assert(clickDetector and clickDetector:IsA("ClickDetector"), "BindClick expects a ClickDetector")
	local conn = clickDetector.Activated:Connect(function(player)
		AuraService:GiveAuraToPlayer(auraId, player, options)
	end)
	return conn
end

-- Convenience binder for ProximityPrompt (Triggered)
function AuraService:BindProximity(prompt, auraId, options)
	assert(prompt and prompt:IsA("ProximityPrompt"), "BindProximity expects a ProximityPrompt")
	local conn = prompt.Triggered:Connect(function(player)
		AuraService:GiveAuraToPlayer(auraId, player, options)
	end)
	return conn
end

-- Convenience binder for BindableEvent on a part (server-only)
-- Example: part.GiveAuraBindable:Fire(player)  OR pass a BasePart to resolve player from touched part/target
function AuraService:BindBindable(part, auraId, options)
	assert(part and typeof(part) == "Instance", "BindBindable expects a Part/Instance")
	local bindable = part:FindFirstChild("GiveAuraBindable")
	if not bindable then
		bindable = Instance.new("BindableEvent")
		bindable.Name = "GiveAuraBindable"
		bindable.Parent = part
	end
	local conn = bindable.Event:Connect(function(target)
		-- Accept either a player or some target to resolve to a player
		if typeof(target) == "Instance" and target:IsA("Player") then
			AuraService:GiveAuraToPlayer(auraId, target, options)
		else
			AuraService:GiveAura(auraId, target, options)
		end
	end)
	return conn
end

-- Cleanup cooldown entries when player leaves
Players.PlayerRemoving:Connect(function(player)
	if player and player.UserId then
		touchCooldowns[player.UserId] = nil
	end
end)

return AuraService
