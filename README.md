# ShrineBattles

A Backpack Battles style Godot game built for B1TJam2026.


### Structure

| File | Description |
|---|---|
| `Main Scene.tscn` | Holds all other scenes |
| `d6.tres` | An example `Dice` resource. |

### Gameplay/
Right now just manager scripts

| File | Description |
|---|---|
| `Gamemanager.gd` | Script will manage score, scene state, transitions, inventory, and other major mechanics |
| `ShrineManager.gd` | Script for managing shrines, including which items are on them and how their effects are handled |

### Resources/
Resources will hold data about objects that are held on shrines

`ShrineObjects/Dice/` — Resources that hold data about dice
`ShrineObjects/Items/` — Resources that hold data about items that go on shrines

### UI/

| File | Description |
|---|---|
| `Menu.tscn` | The game's main menu screen. |
| `Shop.tscn` | The in-game shop screen |
| `ShrineBattleScreen.tscn` | The screen that displays an active shrine battle |
| `ShrineGrid.tscn` | The grid UI for placing items on shrines |
| `autobattle_scene.gd` | Script with the autobattler logic for shrine battle screen |
| `default_theme.tres` | Theme resources make sure the whole UI has a consistent look |

### Sound/
Audio assets for the game.