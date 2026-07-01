# Shawarma Empire

Shawarma Empire is a commercial idle/tycoon Android game built with Godot 4.

## Project root

Open the Godot project from `shawarma-empire/project.godot`.

## Architecture

The project uses a small, explicit folder layout so gameplay, UI, data, and shared services stay separate as the game grows:

- `Scenes/` — composed Godot scenes.
- `Scripts/` — reusable GDScript gameplay/domain code.
- `Assets/` — imported visual assets.
- `Resources/` — Godot resources and static game data.
- `Audio/` — music, ambience, and sound effects.
- `UI/` — UI scenes, controls, and presentation scripts.
- `Managers/` — app-level services and coordination code.

## Maintainability rules

- Keep UI presentation separate from gameplay logic.
- Prefer typed GDScript and descriptive names.
- Keep functions short and extract reusable components instead of duplicating code.
- Use constants or resources for tunable values; avoid magic numbers.
- Optimize for mobile-first performance and maintain 60 FPS on low-end Android devices.

## Validation

Before committing code changes, run the Godot parser/check command available in your environment. If Godot is not installed, document that limitation in the change summary.
