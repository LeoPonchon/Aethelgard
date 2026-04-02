# Guide d'Installation Roblox Studio - Aethelgard

## 🚨 PROBLÈME FRÉQUENT

**Si vous avez des erreurs "Infinite yield"**, c'est que les scripts ne sont pas au bon endroit!

```
❌ ERREUR: "Infinite yield possible on 'ServerScriptService:WaitForChild("QuestSystem")'"
✅ SOLUTION: Les scripts doivent être dans ServerScriptService!
```

---

## 📋 Étapes à suivre dans Roblox Studio

### 1. Structure des Folders REQUISE

```
game/
├── ReplicatedStorage/
│   ├── Shared/ ← Folder (créer si n'existe pas)
│   │   ├── ActionBasedProgressionSystem ← ModuleScript
│   │   ├── EmoteSystem ← ModuleScript
│   │   ├── RaceSystem ← ModuleScript
│   │   ├── RaceData ← ModuleScript
│   │   ├── ClassData ← ModuleScript
│   │   └── TeamData ← ModuleScript
│   │
│   ├── NPCInteraction ← RemoteFunction
│   ├── PlayerAction ← RemoteEvent
│   ├── PlayEmote ← RemoteEvent
│   └── GetPlayerInfo ← RemoteFunction
│
├── ServerScriptService/
│   ├── init.server ← Script (pas ModuleScript!)
│   ├── QuestSystem ← ModuleScript
│   ├── NPCInteractionSystem ← ModuleScript
│   ├── PlayerDisplaySystem ← ModuleScript
│   └── ProximityPromptSystem ← ModuleScript
│
├── StarterPlayerScripts/
│   └── init.client ← LocalScript
│
└── Workspace/
    ├── NPCs/ ← Folder
    │   └── Village_Elder/ ← Model (NPC)
    │       ├── Humanoid
    │       └── HumanoidRootPart
    └── Locations/ ← Folder (optionnel)
        ├── Academy_Entrance ← Part
        └── Demon_Portal ← Part
```

---

### 2. CRÉER LES SCRIPTS SERVEUR (ServerScriptService)

**⚠️ C'EST LA PARTIE LA PLUS IMPORTANTE!**

#### A. Créer le script principal (init.server)

1. Dans l'Explorer, clic droit sur `ServerScriptService`
2. **Insert Object → Script** (PAS ModuleScript!)
3. Renommer en `init.server`
4. Copier le contenu de `src/server/init.server.luau` dans ce script

#### B. Créer les modules serveur

Pour CHACUN de ces modules:
- `QuestSystem`
- `NPCInteractionSystem`
- `PlayerDisplaySystem`
- `ProximityPromptSystem`

1. Dans l'Explorer, clic droit sur `ServerScriptService`
2. **Insert Object → ModuleScript** (PAS Script!)
3. Renommer (ex: `QuestSystem`)
4. Copier le contenu du fichier `.luau` correspondant

---

### 3. CRÉER LES MODULES PARTAGÉS (ReplicatedStorage/Shared)

1. Dans l'Explorer, clic droit sur `ReplicatedStorage`
2. **Insert Object → Folder**
3. Renommer en `Shared`

Pour CHACUN de ces modules:
- `ActionBasedProgressionSystem`
- `EmoteSystem`
- `RaceSystem`
- `RaceData`
- `ClassData`
- `TeamData`
- `WorldData`

1. Clic droit sur le folder `Shared`
2. **Insert Object → ModuleScript**
3. Renommer (ex: `ActionBasedProgressionSystem`)
4. Copier le contenu du fichier `.luau` correspondant

---

### 4. CRÉER LES REMOTEEVENTS/FUNCTIONS

Dans `ReplicatedStorage`, créer:

1. **RemoteFunction** nommé `NPCInteraction`
2. **RemoteEvent** nommé `PlayerAction`
3. **RemoteEvent** nommé `PlayEmote`
4. **RemoteFunction** nommé `GetPlayerInfo`

*(Ces remotes sont aussi créés automatiquement par le script serveur)*

---

### 5. CRÉER LE SCRIPT CLIENT (StarterPlayerScripts)

1. Dans l'Explorer, clic droit sur `StarterPlayerScripts`
2. **Insert Object → LocalScript** (PAS Script ou ModuleScript!)
3. Renommer en `init.client`
4. Copier le contenu de `src/client/init.client.luau`

---

### 6. CRÉER LES NPCs

Pour tester le système NPC, créer des Models dans le folder `NPCs`:

**Structure:**
```
workspace/
└── NPCs/ ← Créer ce folder
    └── Village_Elder/ ← Model (renommer votre NPC existant)
        ├── Humanoid
        ├── HumanoidRootPart (ou Torso)
        └── ... (autres parts)
```

**Noms des NPCs à créer:**
- `Village_Elder` - Ancien du Village
- `Guild_Master` - Maître de Guilde
- `Academy_Headmaster` - Directeur de l'Académie
- `Combat_Instructor` - Instructeur de Combat
- `Magic_Instructor` - Instructeur de Magie
- `Demon_Portal_Keeper` - Gardien du Portail
- `Elven_Elder` - Ancien Elfe
- `Castle_Captain` - Capitaine du Château
- `High_Priest` - Grand Prêtre

**Les ProximityPrompts sont créés automatiquement!** Pas besoin de les ajouter manuellement.

---

### 7. CRÉER LES LOCATIONS (Optionnel)

Créer des Parts dans le folder `Locations`:

**Structure:**
```
workspace/
└── Locations/ ← Créer ce folder
    ├── Academy_Entrance ← Part
    ├── Demon_Portal ← Part
    └── ... (autres locations)
```

**Noms des locations à créer:**
- `Academy_Entrance` - Entrée de l'Académie
- `Training_Arena` - Arène d'Entraînement
- `Mage_Tower` - Tour des Mages
- `Demon_Portal` - Portail Démoniaque
- `Elven_Forest` - Forêt Elfique
- `Sacred_Tree` - Arbre Sacré
- `Castle_Gates` - Portes du Château
- `Throne_Room` - Salle du Trône
- `Village_Square` - Place du Village
- `Guild_Hall` - Hall de la Guilde
- `Temple` - Temple

---

### 8. CRÉER LES TEAMS (Optionnel)

Dans `Teams` service, créer les teams avec ces noms EXACTS:

**Monarchie:**
- King (or: RGB 255, 215, 0)
- Queen (rose: RGB 255, 182, 193)
- Princes (bleu acier: RGB 70, 130, 180)
- Princesses (rose vif: RGB 255, 105, 180)

**Noblesse:**
- Dukes (violet: RGB 128, 0, 128)
- Counts (violet foncé: RGB 148, 0, 211)
- Minor Houses (orchidée: RGB 186, 85, 211)

**Démons:**
- Demon King (rouge foncé: RGB 139, 0, 0)
- Demon Queen (brique: RGB 178, 34, 34)
- Demon Generals (cramoisi: RGB 220, 20, 60)
- Demon Servants (orange rouge: RGB 255, 69, 0)

**Académie:**
- Academy Externals (argent: RGB 192, 192, 192)
- Academy Professors (blanc: RGB 255, 255, 255)
- Academy Year 1 (bleu clair: RGB 173, 216, 230)
- Academy Year 2 (bleu ciel: RGB 135, 206, 235)
- Academy Year 3 (bleu profond: RGB 0, 191, 255)

**Héros & Saints:**
- Hero (or: RGB 255, 215, 0)
- Saint (jaune clair: RGB 255, 255, 224)

**Autres groupes:**
- Elves Faction (vert forêt: RGB 34, 139, 34)
- Event Teams (indigo: RGB 75, 0, 130)
- Free Lineages (gris: RGB 128, 128, 128)
- Commoners (bleu bleuet: RGB 100, 149, 237)

---

## 🎮 Comment Tester

1. Cliquer sur **Play** dans Roblox Studio
2. Vérifier la console (View → Output) pour les messages:
   - `[Server] Aethelgard server initialized with action-based progression system`
   - `[ProximityPromptSystem] Initialized with NPC and location prompts`
   - `[PlayerDisplaySystem] Initialized`
3. Approchez d'un NPC (Village_Elder)
4. Vous devriez voir un ProximityPrompt avec "Appuyez sur E pour parler"
5. Appuyez sur E pour interagir

---

## 🔧 Comment Changer de Team

**Pour les joueurs:**
1. Approchez d'un NPC ou d'une location
2. Appuyez sur **E** pour interagir
3. L'action est enregistrée automatiquement
4. Après avoir accompli les actions requises, vous rejoignez la team

**Exemple - Rejoindre les Demon Servants:**
1. Aller au `Demon_Portal`
2. Appuyer sur E pour visiter le portail
3. Méditer 3 fois devant le portail (E sur `Demon_Portal`)
4. Vous rejoignez automatiquement la team `Demon Servants`

**Exemple - Rejoindre Academy Year 1:**
1. Aller à `Academy_Entrance`
2. Appuyer sur E pour visiter l'Académie
3. Parler au `Academy_Headmaster` (E sur le NPC)
4. Vous rejoignez automatiquement la team `Academy Year 1`

---

## 📁 Résumé des Fichiers à Importer

### ServerScriptService/ (TOUS ces scripts DOIVENT être là!)
| Fichier source | Nom dans Roblox | Type |
|----------------|-----------------|------|
| `src/server/init.server.luau` | `init.server` | **Script** |
| `src/server/QuestSystem.luau` | `QuestSystem` | **ModuleScript** |
| `src/server/NPCInteractionSystem.luau` | `NPCInteractionSystem` | **ModuleScript** |
| `src/server/PlayerDisplaySystem.luau` | `PlayerDisplaySystem` | **ModuleScript** |
| `src/server/ProximityPromptSystem.luau` | `ProximityPromptSystem` | **ModuleScript** |

### ReplicatedStorage/Shared/
| Fichier source | Nom dans Roblox | Type |
|----------------|-----------------|------|
| `src/shared/ActionBasedProgressionSystem.luau` | `ActionBasedProgressionSystem` | ModuleScript |
| `src/shared/EmoteSystem.luau` | `EmoteSystem` | ModuleScript |
| `src/shared/RaceSystem.luau` | `RaceSystem` | ModuleScript |
| `src/shared/RaceData.luau` | `RaceData` | ModuleScript |
| `src/shared/ClassData.luau` | `ClassData` | ModuleScript |
| `src/shared/TeamData.luau` | `TeamData` | ModuleScript |
| `src/shared/WorldData.luau` | `WorldData` | ModuleScript |

### StarterPlayerScripts/
| Fichier source | Nom dans Roblox | Type |
|----------------|-----------------|------|
| `src/client/init.client.luau` | `init.client` | **LocalScript** |

---

## ⚠️ ERREURS COURANTES

### "Infinite yield possible on 'ServerScriptService:WaitForChild("QuestSystem")'"
**Cause:** Le module `QuestSystem` n'est pas dans `ServerScriptService`
**Solution:** Créer le ModuleScript `QuestSystem` dans `ServerScriptService`

### "Infinite yield possible on 'ReplicatedStorage:WaitForChild("PlayerAction")'"
**Cause:** Le RemoteEvent `PlayerAction` n'existe pas
**Solution:** Créer le RemoteEvent ou attendre que le script serveur le crée

### Pas de ProximityPrompt sur les NPCs
**Cause:** Le script `ProximityPromptSystem` n'est pas chargé
**Solution:** Vérifier que `ProximityPromptSystem` est un **ModuleScript** dans `ServerScriptService`

### Le script serveur ne se lance pas
**Cause:** `init.server` est un ModuleScript au lieu d'un Script
**Solution:** Supprimer et recréer en tant que **Script** (pas ModuleScript)

---

## 🔧 Utiliser Rojo (Recommandé)

Si vous avez Rojo installé, vous pouvez synchroniser automatiquement:

1. Installer l'extension Rojo pour VSCode
2. Installer le plugin Rojo dans Roblox Studio
3. Dans VSCode, ouvrir la palette de commandes (Ctrl+Shift+P)
4. Taper `Rojo: Open in Roblox Studio`
5. Les fichiers se synchronisent automatiquement

---

## 🎮 Prochaines Étapes

Après l'installation de base:

1. Créer les NPCs avec ProximityPrompts
2. Créer les locations (Demon Portal, Academy, etc.)
3. Ajouter des outils pour le combat
4. Configurer les animations pour les emotes
5. Tester le système de quêtes
