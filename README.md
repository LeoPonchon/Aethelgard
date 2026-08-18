# Aethelgard

Aethelgard est un prototype de jeu Roblox développé en **Luau** et structuré avec **Rojo**. Le dépôt regroupe plusieurs briques d'un RPG : progression joueur, économie, boutique, gacha, interactions avec les PNJ, personnalisation et systèmes d'ambiance.

> **Statut :** en développement. Les systèmes présents dans le dépôt sont fonctionnels à différents niveaux de maturité ; ce README décrit le code versionné, pas une version finale du jeu.

## Fonctionnalités présentes

- données et progression joueur côté serveur ;
- monnaies et boutique ;
- système de gacha avec bannières et données partagées ;
- dialogues et interactions de proximité avec les PNJ ;
- classes, races et équipes configurées dans des modules de données ;
- auras, emotes et effets visuels côté client ;
- cycle jour/nuit ;
- notifications et affichage des joueurs ;
- interface de debug pour faciliter le développement.

## Stack

- Roblox Studio
- Luau
- Rojo 7.5.x
- Wally
- React / ReactRoblox 17.1 via Wally

## Installation

### Prérequis

Installez **Roblox Studio**, **Rojo** et **Wally**, puis clonez le dépôt.

```bash
git clone https://github.com/LeoPonchon/Aethelgard.git
cd Aethelgard
wally install
```

### Développement avec Rojo

```bash
rojo serve
```

Dans Roblox Studio, connectez le plugin Rojo au projet local pour synchroniser les fichiers de `src/`.

### Générer une place Roblox

```bash
rojo build -o Aethelgard.rbxl
```

Pour produire un sourcemap :

```bash
rojo sourcemap -o sourcemap.json
```

## Structure

```text
src/
├── client/            # UI, gacha, boutique, dialogues, auras, emotes, VFX
├── server/            # données joueur, monnaies, gacha, PNJ, notifications, boutique
├── shared/            # classes, races, équipes, bannières et dialogues
└── startercharacter/  # logique liée au personnage joueur
```

`default.project.json` définit le mapping Rojo et `wally.toml` les dépendances partagées.

## Notes de développement

Les systèmes client et serveur communiquent via des remotes centralisés. Lors de l'ajout d'une fonctionnalité, privilégiez les modules de données partagées afin d'éviter de dupliquer les constantes entre client et serveur.
