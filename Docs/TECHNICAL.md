# Shawarma Empire Technical Documentation

## Purpose of this Document

This document describes the current and planned technical structure of **Shawarma Empire**. It should be maintained throughout the lifetime of the project so future contributors can understand how systems are organized, how they interact, and where new functionality belongs.

The project is a Godot 4 Android-focused idle/tycoon game. Technical decisions should prioritize clean architecture, maintainability, small reviewable changes, and stable 60 FPS performance on low-end Android devices.

## Current Architecture

The current architecture is organized around Godot scenes, autoload managers, reusable gameplay scripts, UI scenes, and data resources.

High-level responsibilities:

- **Managers** hold global state and cross-scene services.
- **Scenes** compose gameplay and UI into runnable Godot scenes.
- **Scripts** contain reusable gameplay components such as customers, queues, stands, and spawning.
- **UI** contains presentation-focused controls.
- **Resources** are reserved for reusable data assets.
- **Assets** and **Audio** hold production content.

The current main scene is `res://Scenes/Main.tscn`. It creates the initial UI and world composition, including the currency display, a customer queue, queue points, and the shawarma stand.

The project currently uses autoload singletons for:

- `GameManager`
- `SaveManager`
- `SceneManager`

These managers should remain small and focused. New global services should only be added when scene-owned composition or dependency injection would be less maintainable.

## Existing Systems

### Game State and Currency

`GameManager` owns the current currency values and emits `currency_changed` whenever coins or gems are updated.

Responsibilities:

- Store coins and gems.
- Clamp currency values to non-negative numbers.
- Provide save data.
- Apply loaded save data.
- Notify UI and other listeners when currency changes.

### Save System

`SaveManager` persists game state to `user://shawarma_empire_save.json`.

Responsibilities:

- Request save data from `GameManager`.
- Write save data as JSON.
- Load JSON save data when available.
- Restore starting currency when no save file exists.
- Handle file and parse failures with Godot errors.

Future save changes should preserve compatibility where possible. New systems that require persistence should expose explicit save/apply methods instead of allowing `SaveManager` to inspect scene internals directly.

### Scene Management

`SceneManager` centralizes scene transitions through Godot's scene tree.

Responsibilities:

- Change scenes by path.
- Report scene change failures.

Scene changes should continue to be routed through this service when transitions become more complex.

### Main Scene

`Main.tscn` is the current runtime entry scene.

Responsibilities:

- Host the root `Control` layout.
- Display the currency UI.
- Create the gameplay world container.
- Define the current queue points.
- Place the shawarma stand.
- Load save data when ready.
- Save game data on window close.

The main scene should remain a composition point, not a large gameplay logic container.

### Currency UI

`CurrencyDisplay` is a UI component that listens to `GameManager.currency_changed` and renders coins and gems.

Responsibilities:

- Display current coins.
- Display current gems.
- Update when currency changes.

UI code should not own gameplay rules. It should display state and forward player intent to gameplay systems or managers.

### Queue System

The queue system is a reusable reservation-based customer flow system.

Primary classes:

- `QueueSystem`
- `QueuePoint2D`
- `QueueReservation`
- `QueueRequest`

Responsibilities:

- Collect and sort queue points.
- Accept reservation requests.
- Prevent duplicate reservations per requester.
- Track waiting requests.
- Assign requesters to available queue points by priority and sequence.
- Cancel or complete reservations.
- Compact active reservations when queue points change.
- Emit signals when requests or reservations change.

This system should remain generic. It should not contain shawarma-specific economic rules.

### Customer System

`Customer` is a `CharacterBody2D` that can move, wait, leave, and interact with a configured queue system.

Responsibilities:

- Track customer state.
- Move toward target positions.
- Join and leave queues.
- React to queue reservation changes.
- Complete queue service when served.

Customer-specific behavior should communicate with queues and stands through public methods and signals rather than directly modifying unrelated systems.

### Stand Service System

`ShawarmaStand` serves the front ready queue reservation after a configurable service duration.

Responsibilities:

- Resolve the configured queue system.
- Start service for the front ready reservation.
- Count down service duration.
- Complete the active reservation.
- Emit service start and completion signals.

Future economy rewards should listen to service completion or be triggered by a dedicated service/reward system instead of hard-coding currency logic directly into queue internals.

### Order System

The order system defines reusable architecture for future customer requests without connecting it to customers, queues, UI, cooking, payments, or the main scene yet.

Primary classes:

- `Order`
- `OrderGenerator`

Responsibilities:

- Store the selected `Recipe` for an order.
- Copy recipe-derived total price and preparation time onto the order at creation time.
- Track order creation time and completion state.
- Generate new orders by randomly selecting from available recipe resources.

Order data lives in `res://Scripts/Orders/`, with reserved order resources under `res://Resources/Orders/`. Future systems should consume orders through clear APIs instead of coupling order creation directly to customers, queues, UI, cooking, or payments.

### Spawning System

The spawning system provides reusable scene spawning with weighted definitions and spawn point reservations.

Primary classes:

- `Spawner2D`
- `SpawnPoint2D`
- `SpawnPool`
- `SpawnDefinition`

Responsibilities:

- Collect available spawn points.
- Select spawn definitions by weight.
- Respect max active instance limits.
- Instantiate scenes under a configured parent.
- Reserve and release spawn points.
- Track active counts per definition.
- Emit spawn success or failure signals.

Spawning should remain data-driven and reusable for customers or future entities.

## Folder Structure

Current project folders:

```text
shawarma-empire/
  Assets/        Art and visual production assets.
  Audio/         Music, sound effects, and audio assets.
  Managers/      Autoload services and global systems.
  Resources/     Data resources and reusable Godot assets.
  Scenes/        Runnable scenes and scene-specific scripts.
  Scripts/       Reusable gameplay scripts grouped by domain.
  UI/            UI scenes and presentation scripts.
```

Documentation lives at the repository root:

```text
Docs/
  GAME_DESIGN.md
  ROADMAP.md
  TECHNICAL.md
```

Future folders should follow the existing top-level structure unless there is a clear architectural reason to add a new one.

## Naming Conventions

Current conventions:

- GDScript files use `PascalCase.gd` when defining a named class or scene component.
- Godot classes use `class_name` for reusable systems that should be referenced across scenes.
- Constants use `UPPER_SNAKE_CASE`.
- Signals use `snake_case` and describe completed events or state changes.
- Exported variables use descriptive `snake_case` names.
- Private implementation details use a leading underscore.
- Scene and node names use descriptive PascalCase names.
- Resource and system names should describe their responsibility, not their current implementation detail.

New code should use static typing whenever possible and keep UI, gameplay rules, data, and persistence responsibilities separate.

## Planned Systems

Planned systems should build on existing foundations rather than replace them.

### Economy and Rewards

Planned responsibilities:

- Award coins when customers are served.
- Apply recipe values and upgrade modifiers.
- Emit economy events for UI feedback.
- Keep reward calculation separate from queue mechanics.

### Recipe System

The first gameplay-facing recipe system is implemented as data-only Godot resources under `res://Resources/Recipes/` and `res://Resources/Ingredients/`.
Reusable resource scripts live in `res://Scripts/Recipes/`.

Current responsibilities:

- Define `Recipe` resources with display name, base price, preparation time, and required ingredients.
- Define `Ingredient` resources with display name, optional icon placeholder, and unlock level.
- Keep recipe and ingredient data separate from customers, orders, cooking, and UI so future systems can consume the same data without scene coupling.

Planned responsibilities:

- Define recipes as data resources.
- Track recipe unlocks and levels.
- Provide recipe sale values and preparation modifiers.
- Support future recipe-specific customer demand.

### Upgrade System

Planned responsibilities:

- Define upgrade data.
- Track purchased upgrade levels.
- Apply modifiers to service speed, queue size, recipe value, customer arrival, and automation.
- Expose upgrade state to UI without placing purchase logic in UI scripts.

### Employee System

Planned responsibilities:

- Define employee roles and levels.
- Automate or improve parts of the gameplay loop.
- Apply clear modifiers through existing systems.
- Persist employee ownership and levels.

### Customer Spawning and Demand

Planned responsibilities:

- Use the existing spawning system to create customers.
- Tune arrival rate based on upgrades, demand, and progression.
- Respect active customer limits for mobile performance.
- Integrate with queue capacity and service throughput.

### Offline Progression

Planned responsibilities:

- Store last save timestamp.
- Estimate offline earnings from current production rate.
- Cap offline rewards to protect balance.
- Present return rewards clearly in UI.

### Analytics and Diagnostics

Planned responsibilities:

- Track progression milestones.
- Track tutorial and funnel events.
- Track economy spend and earn events.
- Support crash or error diagnostics where appropriate.

Analytics should be added only after event names and privacy requirements are defined.

## How Systems Interact

The intended interaction pattern is signal-driven and responsibility-focused:

1. A spawner creates a customer from a spawn definition.
2. The customer joins a queue through `QueueSystem`.
3. `QueueSystem` assigns a `QueueReservation` to an available `QueuePoint2D`.
4. The customer moves to the reserved queue point.
5. The customer enters a waiting state when ready for service.
6. `ShawarmaStand` observes queue changes and starts service for the front ready reservation.
7. When service completes, the reservation is completed and the customer is released from the queue.
8. Future reward logic awards currency based on recipe, upgrade, and employee modifiers.
9. `GameManager` updates currency and emits `currency_changed`.
10. `CurrencyDisplay` updates the UI.
11. `SaveManager` persists manager-owned state when saving.

Design constraints:

- Queue systems should not know about currency.
- UI should not calculate gameplay rewards.
- Save systems should not depend on fragile scene traversal.
- Spawning should not assume customers are the only spawnable entities.
- Upgrades and employees should apply modifiers through explicit system interfaces.
- New systems should be data-driven where practical.

## Maintenance Notes

When adding or changing systems:

- Keep changes small and reviewable.
- Prefer extending existing reusable components over duplicating behavior.
- Add documentation for new persistent data.
- Update this document when architecture changes.
- Preserve save compatibility or document migration requirements.
- Validate the project for parser errors after code changes.
- Profile and simplify before adding expensive visual or simulation features.
