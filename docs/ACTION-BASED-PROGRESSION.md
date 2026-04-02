# Aethelgard - Action-Based Progression System

## Overview

Aethelgard now uses an **action-based progression system** where players advance through in-game actions rather than UI selection. This creates a more immersive RP experience where:

- **Teams/Factions** are joined by visiting locations and completing actions
- **Classes** are unlocked by practicing relevant skills at the Academy
- **Guild Ranks** increase by completing quests
- **The only UI** is the billboard above each player showing their info

---

## Core Systems

### 1. ActionBasedProgressionSystem (`src/shared/ActionBasedProgressionSystem.luau`)

The central system that tracks all player actions and progression.

#### Action Types
- `VisitLocation` - Visit a named location
- `TalkToNPC` - Interact with NPCs
- `CompleteQuest` - Finish a quest
- `DefeatEnemy` - Defeat enemies
- `EscortPlayer` - Escort another player
- `CraftItem` - Craft items
- `CastSpell` - Cast magic spells
- `MeleeAttack` - Perform melee attacks
- `DefendLocation` - Defend a location
- `JoinEvent` - Participate in events
- `BetrayFaction` - Betray your faction
- `Diplomacy` - Diplomatic actions
- `TrainAtAcademy` - Training sessions
- `Meditate` - Meditation
- `Pray` - Prayer
- `Explore` - Exploration
- `Socialize` - Social interactions

#### Team Progression (by Category)

**Monarchie** (Special - Admin/Event)
- King 👑 - Roi du royaume
- Queen 👸 - Reine du royaume
- Princes 👦 - Héritiers du trône
- Princesses 👧 - Héritières du trône

**Noblesse**
- Dukes 🏰 - 15 Diplomacy + 10 Quests + 5 Defend
- Counts ⚔️ - 10 Diplomacy + 5 Quests
- Minor Houses 🛡️ - 5 Diplomacy + 3 Quests

**Démons**
- Demon King 😈 - Special (Admin/Event)
- Demon Queen 👹 - Special (Admin/Event)
- Demon Generals 👿 - Visit Demon Portal + 10 Meditations + 5 Quests
- Demon Servants 💀 - Visit Demon Portal + 3 Meditations

**Académie**
- Academy Externals 🌍 - Visit Academy
- Academy Professors 📚 - 30 Training + 20 Quests
- Academy Year 1 🎒 - Visit Academy + Talk to Headmaster
- Academy Year 2 📖 - 10 Training + 5 Quests (requires Year 1)
- Academy Year 3 🎓 - 25 Training + 15 Quests (requires Year 2)

**Héros & Saints** (Special)
- Hero ⚡ - Special (Appointed/Quest)
- Saint ✨ - Special (Appointed/Quest)

**Autres groupes**
- Elves Faction 🧝 - Visit Elven Forest + 5 Meditations at Sacred Tree
- Event Teams 🎭 - Event only
- Free Lineages 🗡️ - Complete 5 Quests
- Commoners 👤 - Default (spawn)

#### Class Unlocks

| Class | Requirements |
|-------|--------------|
| Guerrier | 50 Melee Attacks + 5 Training Sessions |
| Mage | 30 Spells + 10 Training + 5 Meditations |
| Voleur | 20 Explorations + 5 Training |
| Archer | 30 Ranged Defeats + 5 Training |
| Prêtre | 20 Prayers + 10 Training |
| Paladin | Guerrier + Prêtre + 15 Training |
| Nécromancien | 50 Spells + Visit Demon Portal + 10 Meditations |
| Barde | 50 Socialize + 5 Training |
| Druide | 20 Nature Meditations + Visit Elven Forest + 10 Training |
| Chevalier | 10 Defend + 40 Melee + 10 Training |
| Invocateur | 60 Spells + 15 Meditations + 20 Training |
| Moine | 100 Melee + 30 Meditations |

---

### 2. QuestSystem (`src/server/QuestSystem.luau`)

Handles guild quests that are RP-based.

#### Quest Types
- **Escort** - Escort a player/NPC from A to B
- **Defeat** - Defeat enemies in a location
- **Explore** - Explore and discover locations
- **Diplomacy** - Talk to NPCs from other factions
- **Defend** - Defend a location for a duration
- **Gather** - Gather items
- **Deliver** - Deliver items to NPCs
- **Rescue** - Rescue prisoners
- **Assassinate** - Eliminate targets (Demon Faction)
- **Corrupt** - Corrupt sacred locations (Demon Faction)
- **Purify** - Purify corrupted locations (Hero/Saint)
- **Train** - Complete training at Academy
- **Socialize** - Interact with other players

#### Example Quests
- `escort_merchant_1` - Escort a merchant to the village
- `explore_forest_1` - Explore the mystic forest
- `defeat_wolves_1` - Eliminate wolves threatening the village
- `train_combat_1` - Combat training at Academy
- `corrupt_shrine_1` - Corrupt a sacred shrine (Demon)
- `purify_corruption_1` - Purify a corrupted zone (Hero)

---

### 3. NPCInteractionSystem (`src/server/NPCInteractionSystem.luau`)

Manages NPC dialogues and interactions.

#### Key NPCs
- **Village Elder** - Starting guide, explains factions and progression
- **Guild Master** - Distributes quests, checks progress
- **Academy Headmaster** - Enrollment and training info
- **Combat Instructor** - Combat training
- **Magic Instructor** - Magic training
- **Demon Portal Keeper** - Demon faction recruitment
- **Elven Elder** - Elf faction recruitment
- **Castle Captain** - Noble/defense missions
- **High Priest** - Holy missions and prayer

#### Dialogue System
NPCs have branching dialogues with:
- Information about factions/classes
- Quest offerings
- Faction joining options
- Training initiation

---

### 4. EmoteSystem (`src/shared/EmoteSystem.luau`)

RP animations triggered via chat commands.

#### Emote Categories
- **Greeting**: `/wave`, `/bow`, `/curtsy`, `/salute`
- **Combat**: `/draw`, `/threaten`, `/victory`, `/defeat`
- **Magic**: `/castfire`, `/castice`, `/heal`, `/pray`, `/meditate`
- **Social**: `/cheer`, `/clap`, `/laugh`, `/cry`, `/hug`
- **Dance**: `/dance`, `/dance2`
- **Gesture**: `/point`, `/nod`, `/no`, `/shrug`, `/think`
- **Reaction**: `/sneeze`, `/cough`, `/yawn`, `/stretch`
- **Roleplay**: `/kneel`, `/sit`, `/sleep`, `/inspect`, `/write`, `/read`, `/drink`, `/eat`

#### Class-Restricted Emotes
- Fire/Ice spells: Mage only
- Heal: Prêtre only
- Some emotes require specific factions

---

### 5. PlayerDisplaySystem (`src/server/PlayerDisplaySystem.luau`)

The ONLY UI element - billboard above players.

#### Display Information
- Player Name
- Faction + Rank
- Class with emoji
- Guild Rank
- Progression level badge

---

## How Progression Works

### Phase 1: Spawn (0-5 min)
1. Player spawns as Commoner (default)
2. Village Elder provides guidance
3. Free exploration begins
4. Emotes available for RP

### Phase 2: Faction Discovery (5-15 min)
1. Visit key locations (Castle, Academy, Demon Portal)
2. Talk to NPCs about factions
3. Begin accumulating actions

### Phase 3: Class Discovery (15-30 min)
1. Visit Academy
2. Talk to instructors
3. Begin training quests
4. Practice skills (combat, magic, etc.)

### Phase 4: RP Immersion (30-60 min)
1. Complete quests for guild rank
2. Join factions through actions
3. Unlock classes through training
4. Participate in faction activities

### Phase 5: Advanced Progression (1-3 h)
1. Unlock advanced classes
2. Rise in faction ranks
3. Take on leadership roles
4. Participate in events

### Phase 6: Social Loop (3h+)
1. Create stories with other players
2. Form alliances/relationships
3. Participate in world events
4. Build reputation

---

## Technical Architecture

```
src/
├── client/
│   └── init.client.luau      # Minimal client (emotes, action recording)
├── server/
│   ├── init.server.luau      # Main server initialization
│   ├── QuestSystem.luau      # Quest management
│   ├── NPCInteractionSystem.luau  # NPC dialogues
│   └── PlayerDisplaySystem.luau   # Billboard display
└── shared/
    ├── ActionBasedProgressionSystem.luau  # Core progression
    └── EmoteSystem.luau      # Emote definitions
```

---

## Remote Events/Functions

| Remote | Type | Purpose |
|--------|------|---------|
| `NPCInteraction` | RemoteFunction | NPC dialogues and quests |
| `PlayerAction` | RemoteEvent | Record player actions |
| `PlayEmote` | RemoteEvent | Play emote animations |
| `GetPlayerInfo` | RemoteFunction | Get progression data |

---

## Migration Notes

### Removed Systems
- RoleSelectionMenu (UI)
- CharacterCreationMenu (UI)
- RoleManager (replaced by ActionBasedProgressionSystem)
- TeamData (replaced by faction data in ActionBasedProgressionSystem)

### Changed Systems
- PlayerDisplaySystem now pulls from ActionBasedProgressionSystem
- No more UI-based team/class selection
- All progression through in-game actions

---

## Future Enhancements

1. **Location Triggers** - Add physical locations that trigger actions
2. **NPC Models** - Add NPC models with proximity detection
3. **Visual Effects** - Add particle effects for progression unlocks
4. **Sound Effects** - Add audio feedback for actions
5. **Leaderboard** - Optional leaderboard for guild ranks
6. **Events** - Dynamic world events that affect progression
