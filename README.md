# Shawarma Empire

Shawarma Empire is a mobile-first Android idle/tycoon game built with Godot 4. The project is being structured around a clean, maintainable architecture before gameplay systems are added.

## Project Goals

- Keep code production-quality, typed, and easy to review.
- Separate gameplay state, persistence, scene flow, and UI.
- Target smooth 60 FPS performance on low-end Android devices.
- Build small milestones before adding full idle/tycoon gameplay.

## Current Architecture

The initial Godot project lives in `shawarma-empire/` and includes these top-level folders:

- `Scenes/` - main scenes and scene-specific scripts.
- `Managers/` - autoloaded managers for global game services.
- `UI/` - reusable UI scenes and scripts.
- `Scripts/` - shared gameplay scripts and components.
- `Resources/` - Godot resources and data assets.
- `Assets/` - imported art and visual assets.
- `Audio/` - music and sound effects.

## Initial Systems

- `GameManager` owns the basic currency state for coins and gems.
- `SaveManager` saves and loads currency data from Godot `user://` storage.
- `SceneManager` provides a shared scene transition entry point.
- `Main` displays a placeholder mobile-friendly currency UI.
