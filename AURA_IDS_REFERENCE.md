# Aura IDs Quick Reference

Your aura IDs are based on the array index (1-50). Use these IDs when calling `AuraService:GiveAuraToPlayer()`.

## Complete List

| ID | Aura Name | Rarity (1 in) |
|----|-----------|---------------|
| 1 | Normal | 3 |
| 2 | Celestial | 6,144 |
| 3 | Nature | 6 |
| 4 | Toad | 6 |
| 5 | Twilight Champion | 12 |
| 6 | Glisten | 12 |
| 7 | Extreme Shine | 12 |
| 8 | Inferus | 24 |
| 9 | InfiniShield | 48 |
| 10 | Divine | 48 |
| 11 | Divide | 96 |
| 12 | Eternal | 192 |
| 13 | Spidey | 384 |
| 14 | Trapped | 768 |
| 15 | Dark Knight | 1,536 |
| 16 | Infinity | 3,072 |
| 17 | Devil | 6,144 |
| 18 | Fractal | 12,288 |
| 19 | Fractal {Evolution} | 24,576 |
| 20 | Overlord | 49,152 |
| 21 | Imbalance | 98,304 |
| 22 | Eternal {Evolved} | 196,608 |
| 23 | Fractal {Eternal} | 393,216 |
| 24 | Bounded | 786,432 |
| 25 | Model | 786,432 |
| 26 | Expance | 1,572,864 |
| 27 | Evade | 3,145,728 |
| 28 | Captain | 6,291,456 |
| 29 | Placeholder | 25,165,824 |
| 30 | Placeholder | 50,331,648 |
| 31 | Black Hole | 50,331,648 |
| 32 | Void | 50,331,648 |
| 33 | Storm | 100,663,296 |
| 34 | Black Holes | 100,663,296 |
| 35 | Neon | 3 (NEON PARKOUR) |
| 36 | Matrix | 786,432 |
| 37 | Eclipse Core | 98,304 |
| 38 | Virtuality | 98,304 |
| 39 | The Fallen Memory | 98,304 |
| 40 | Secret | 98,304 |
| 41 | Galaxy | 2 |
| 42 | Magnetic | 12,288 |
| 43 | Controller | 12,288 |
| 44 | 404 | 49,152 |
| 45 | Eternal Rotation | 24,576 |
| 46 | Voidlight | 49,152 |
| 47 | Dark Agression | 24,576 |
| 48 | Oblivion Nova | 98,304 |
| 49 | Supernova | 196,608 |
| 50 | Ethereal Harmony | 786,432 |

## Example Usage

```lua
-- Give aura ID 1 (Normal) to a player
AuraService:GiveAuraToPlayer(1, player)

-- Give aura ID 17 (Devil) with cutscene
AuraService:GiveAuraToPlayer(17, player, { announce = true })

-- Give aura ID 41 (Galaxy) one-time only
AuraService:GiveAuraToPlayer(41, player, { oneTimeOnly = true })

-- Bind a click detector to give aura ID 9 (InfiniShield)
AuraService:BindClick(clickDetector, 9, { oneTimeOnly = true })
```

## Notes

- **Unrollable auras**: IDs 35, 36, 39, 40, 41 cannot be obtained through normal rolling
- **Cutscene auras**: Some auras have associated cutscene numbers (see Auras.lua for details)
- **Special displays**: Aura #35 (Neon) and #44 (404) have custom OneInDisplay values
