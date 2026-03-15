-- TouchPartLogic.lua
-- Example script showing how to use AuraService to give auras from a touched part
-- Place this script as a child of the Part you want to make touchable
-- Make sure AuraService module is available in ServerScriptService or ReplicatedStorage

local part = script.Parent
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ============================================
-- CONFIGURATION
-- ============================================
local AURA_ID = 35 -- Change this to the aura ID you want
local AUTO_EQUIP = false -- Automatically equip the aura when received
local COOLDOWN = 5 -- Cooldown in seconds before same player can touch again
local ONE_TIME_ONLY = false -- Players can only get this aura once
local SHOW_HIGHLIGHT = false -- Add visual highlight to the part
local DELETE_AFTER_TOUCH = false -- Delete the part after being touched once
local ANNOUNCE_TO_SERVER = false -- Announce to all players when someone gets the aura

-- ============================================
-- LOAD AURA SERVICE
-- ============================================
local AuraService
do
	-- Try ServerScriptService first
	local auraModule = ServerScriptService:FindFirstChild("AuraService")
	if not auraModule then
		-- Try ReplicatedStorage
		auraModule = ReplicatedStorage:FindFirstChild("AuraService")
	end
	
	if auraModule then
		local ok, mod = pcall(function() return require(auraModule) end)
		if ok then
			AuraService = mod
		else
			error("[TouchPartLogic] Failed to load AuraService: " .. tostring(mod))
		end
	else
		error("[TouchPartLogic] AuraService module not found! Place it in ServerScriptService or ReplicatedStorage")
	end
end

-- ============================================
-- VISUAL SETUP
-- ============================================
if SHOW_HIGHLIGHT then
	local highlight = Instance.new("Highlight")
	highlight.Parent = part
	highlight.FillColor = Color3.fromRGB(255, 215, 0)
	highlight.OutlineColor = Color3.fromRGB(255, 165, 0)
	highlight.FillTransparency = 0.5
end

-- ============================================
-- MAIN SCRIPT - Using AuraService API
-- ============================================
local hasBeenTouched = false

part.Touched:Connect(function(hit)
	-- Basic validation - check if it's a character with a humanoid
	local character = hit.Parent
	local humanoid = character and character:FindFirstChild("Humanoid")
	if not humanoid then return end

	-- Get the player from the character
	local player = game:GetService("Players"):GetPlayerFromCharacter(character)
	if not player then return end

	-- Check if part should be deleted after first touch
	if DELETE_AFTER_TOUCH and hasBeenTouched then
		return
	end

	-- Build options table for AuraService
	local options = {
		cooldown = COOLDOWN,
		autoEquip = AUTO_EQUIP,
		announce = ANNOUNCE_TO_SERVER,
		oneTimeOnly = ONE_TIME_ONLY,
		deletePart = DELETE_AFTER_TOUCH and part or nil
	}

	-- Use AuraService to give the aura (handles all logic: cooldowns, duplicates, inventory, etc.)
	local success, result = AuraService:GiveAuraToPlayer(AURA_ID, player, options)

	if success then
		-- Success! AuraService handled everything (notification, sound, auto-equip, etc.)
		print(("[TouchPartLogic] Successfully gave aura %d to %s"):format(AURA_ID, player.Name))
		
		-- Mark as touched if delete after touch is enabled
		if DELETE_AFTER_TOUCH then
			hasBeenTouched = true
		end
	else
		-- Failed (e.g., cooldown, already has aura, inventory full, etc.)
		-- AuraService already sent appropriate warnings to the player if needed
		-- For oneTimeOnly, it silently fails which is expected behavior
		if result ~= "Already had aura (one-time only)" and result ~= "Cooldown active" then
			warn(("[TouchPartLogic] Failed to give aura to %s: %s"):format(player.Name, tostring(result)))
		end
	end
end)

print(("[TouchPartLogic] Initialized on part %s with aura ID %d"):format(part.Name, AURA_ID))
