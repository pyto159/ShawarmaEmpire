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

The current main scene is `res://Scenes/Main.tscn`. It creates the initial UI and world composition, including layered visual market-square presentation, the game HUD, a customer queue, queue points, the shawarma stand, a cooking stand, and spawned customers for the first playable cooking interaction.

The project currently uses autoload singletons for:

- `GameManager`
- `SaveManager`
- `SceneManager`
- `AudioManager`

These managers should remain small and focused. New global services should only be added when scene-owned composition or dependency injection would be less maintainable.

## Existing Systems

### Game State and Currency

`GameManager` owns the current currency values and emits `currency_changed` whenever coins or gems are updated.

Responsibilities:

- Store coins and gems.
- Clamp currency values to non-negative numbers.
- Add completed cooking rewards through public currency APIs.
- Provide save data.
- Apply loaded save data.
- Own purchased upgrade ids, the current grill level, and the current cooking speed multiplier.
- Notify UI and other listeners when currency changes.



### Audio Management

`AudioManager` is the single global entry point for gameplay and UI sound effects. Other systems should never access `AudioStreamPlayer` nodes directly; they should request sound playback through the public AudioManager methods instead.

Responsibilities:

- Expose assignable `AudioStream` slots for button, coin, cooking start, cooking complete, customer arrival, customer leave, queue movement, upgrade, and error sounds.
- Provide focused playback methods such as `play_button()`, `play_coin()`, `play_cooking_start()`, `play_cooking_complete()`, `play_customer_arrive()`, `play_customer_leave()`, `play_queue_move()`, and `play_upgrade()`.
- Safely ignore playback requests when a sound slot has no assigned stream, so the game remains playable before final `.wav` or `.ogg` assets are assigned.
- Apply simple per-sound debounce windows to prevent button, reward, customer, and queue sound spam during repeated or clustered events.
- Keep audio player implementation details internal so future audio routing, pooling, buses, or volume controls can be added without changing gameplay systems.

The autoload is backed by `res://Managers/AudioManager.tscn` with logic in `res://Scripts/Managers/AudioManager.gd`. No placeholder audio files are required and no fallback tones are generated. Future sounds can be added by assigning streams to the exported fields on the AudioManager scene in the Inspector.

### Game HUD

`GameHUD` is the first simple gameplay HUD for the playable cooking interaction. It displays placeholder coin text, the active customer order recipe name, a Prepare button, and the first simple upgrade button.

Responsibilities:

- Resolve a configured `Customer` and `CookingStand` from exported node paths.
- Display current coins from `GameManager`.
- Display the active order recipe name when the configured customer owns an incomplete order.
- Forward player intent by calling `CookingStand.start_cooking()` when Prepare is pressed.
- Request AudioManager button feedback when the Prepare or upgrade button is pressed.
- Request AudioManager cooking feedback when cooking starts and completes.
- Show the next grill upgrade or `Max Grill` when the grill is fully upgraded.
- Forward grill upgrade purchase intent to `GameManager.purchase_next_grill_level()` when the upgrade button is pressed.
- Request AudioManager upgrade feedback when a grill level is purchased successfully.
- Disable the Prepare button while the stand is cooking or when no cookable order is available.
- Emit `order_ready(order)` when the cooking stand finishes the active order.
- Show short text-only coin feedback when another system reports an earned coin amount.

The HUD lives in `res://Scenes/UI/GameHUD.tscn` with presentation logic in `res://Scripts/UI/GameHUD.gd`. It intentionally does not implement customer leaving, ads, reward calculation, or reward ownership. Sound feedback is limited to AudioManager requests for UI button, cooking, and successful upgrade events. Economy systems should listen to cooking stand signals and then ask the HUD to display presentation-only feedback when needed.

### Upgrade System

Upgrade definitions still support the reusable `UpgradeData` resource type in `res://Scripts/Upgrades/UpgradeData.gd` for future upgrade categories. The active grill progression is currently owned by `GameManager` as a compact multi-level table so the HUD can show the next grill upgrade without adding a shop screen.

Grill progression starts at Level 1 `Basic Grill` with a 1.00 cooking speed multiplier. The next levels are Level 2 `Better Grill` for 50 coins with a 0.90 multiplier, Level 3 `Fast Grill` for 150 coins with a 0.75 multiplier, and Level 4 `Pro Grill` for 400 coins with a 0.60 multiplier. `GameManager.purchase_next_grill_level()` rejects purchases past the max level, rejects purchases when coins are insufficient, subtracts coins through the central currency API, applies the new grill level, updates the cooking speed multiplier, and emits `upgrades_changed`. The HUD displays the next grill upgrade and switches to `Max Grill` when Level 4 is reached.

`GameManager` includes `grill_level` in save data. Older saves that only contain purchased upgrade ids are migrated by treating any saved legacy upgrade as Level 2, preserving the original one-time Better Grill purchase as closely as possible. `CookingStand` listens for upgrade changes and applies the current `GameManager.cooking_speed_multiplier` to active cooking progression. `CookingStation` treats the multiplier as a duration multiplier, so lower grill multipliers complete cooking faster without changing recipe data.



### Cooking Progress UI

`CookingProgressBar` is a reusable presentation component for active cooking progress. It listens only to `CookingStand` cooking signals and does not know about customers, currency, rewards, or order ownership.

Responsibilities:

- Stay hidden while no order is actively cooking.
- Show when the configured cooking stand emits `cooking_started(order)`.
- Update its displayed percentage from `cooking_progress_changed(order, remaining_seconds, progress)` every frame while cooking advances.
- Display a green filled Godot `ProgressBar` with a dark rounded background sized for mobile readability.
- Hide itself 0.25 seconds after cooking completes so players can briefly see 100% completion.

The reusable scene lives in `res://Scenes/UI/CookingProgressBar.tscn` with presentation logic in `res://Scripts/UI/CookingProgressBar.gd`. The current `GameHUD` instances it and passes the composed `CookingStand` reference into the component; gameplay rules remain in the cooking stand and station systems.

### Preparation Table

`PreparationTable` is a lightweight visual-only cooking presentation component that shows the shawarma being assembled while an order is cooking. It listens to `CookingStand` cooking signals, displays warm-colored Godot placeholder shapes for lavash, meat, garlic sauce, rolling, and the completed shawarma, then hides shortly after cooking completes.

Responsibilities:

- Stay hidden while no order is actively cooking.
- Show when `CookingStand.cooking_started(order)` is emitted.
- Split the visible assembly sequence evenly across `cooking_progress_changed(order, remaining_seconds, progress)` so upgrade-modified cooking speed remains synchronized with the active order timing.
- Briefly show the completed shawarma when `CookingStand.cooking_completed(order)` is emitted.
- Avoid changing cooking, economy, customer, queue, or upgrade logic.

The reusable scene lives in `res://Scenes/Stand/PreparationTable.tscn` with presentation logic in `res://Scripts/Stand/PreparationTable.gd`. `Main.tscn` places it near the shawarma stand and points it at the composed `CookingStand` instance.

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
- Display the game HUD.
- Create the gameplay world container.
- Separate the scene into lightweight visual layers for background, ground, decorative market props, gameplay objects, foreground decorations, and HUD.
- Define the current queue points.
- Place the shawarma stand and cooking stand.
- Provide a placeholder customer order for the first playable cooking interaction.
- Load save data when ready.
- Award `order.total_price` coins when the cooking stand completes an order.
- Request AudioManager feedback for spawned customers, customers leaving, queue changes, and earned coins.
- Ask the HUD to show text-only coin feedback for completed cooking rewards.
- Save game data on window close.

The main scene should remain a composition point, not a large gameplay logic container.

### Currency UI

`CurrencyDisplay` is a UI component that listens to `GameManager.currency_changed` and renders coins and gems.

Responsibilities:

- Display current coins.
- Display current gems.
- Update when currency changes.

UI code should not own gameplay rules. It should display state and forward player intent to gameplay systems or managers.

### Floating Coin Feedback

`FloatingCoinLabel` is a reusable presentation-only reward feedback component. It displays the coin amount passed to it, animates upward, scales in briefly, fades out, and frees itself when complete.

Responsibilities:

- Display positive coin rewards as `+<amount>` text.
- Animate upward by about 50 pixels over 0.8 seconds.
- Scale from 0.8 to 1.0 during the first 0.15 seconds.
- Fade opacity to zero and automatically free itself.
- Ignore mouse input so feedback labels never block gameplay interactions.

The reusable scene lives in `res://Scenes/UI/FloatingCoinLabel.tscn` with presentation logic in `res://Scripts/UI/FloatingCoinLabel.gd`. It does not know about `GameManager`, customers, queues, or reward ownership. The current main scene composes instances into a dedicated `FloatingCoinLayer` after coins are awarded.

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

The order system defines reusable architecture for customer requests while keeping recipe selection, customer ownership, cooking, payments, UI, and queueing separated.

Primary classes:

- `Order`
- `OrderGenerator`

Responsibilities:

- Store the selected `Recipe` for an order.
- Copy recipe-derived total price and preparation time onto the order at creation time.
- Track order creation time and completion state.
- Complete orders once, capture completion time, and emit completion signals for consumers.
- Generate new orders by randomly selecting from available recipe resources.

`Customer` owns exactly one active order during its lifecycle. When a customer enters the world, it requests an order from `OrderGenerator` using its configured available recipes, stores that order, and exposes it through `get_order()`, `has_order()`, and `complete_order()`. Customer order lifecycle events are emitted through `order_created(order)` and `order_completed(order)`.

Customers must not implement UI, payment, or cooking behavior. They only own and expose their order so dedicated cooking, reward, payment, and presentation systems can consume customer order state through public APIs and signals.

Order data lives in `res://Scripts/Orders/`, with reserved order resources under `res://Resources/Orders/`. Future systems should consume orders through clear APIs instead of coupling order creation directly to queues, UI, cooking, payments, or the main scene.


### Cooking Station System

`CookingStation` prepares one active order at a time using the order preparation duration.

Responsibilities:

- Accept an incomplete `Order` when idle.
- Track cooking progress over time with a configurable speed multiplier.
- Complete the order when preparation reaches zero remaining time.
- Emit start, progress, completion, and cancellation signals for future UI, audio, and economy systems.

Cooking logic lives in `res://Scripts/Cooking/`, with the reusable station scene in `res://Scenes/Cooking/`. The station owns preparation timing only; customer flow, rewards, and payments should stay in dedicated systems that consume its public API and signals.


### Cooking Stand System

`CookingStand` is a reusable stand-level cooking component built on the shared `CookingStation` timing behavior. It accepts one `Order` at a time, starts preparation through an explicit API call, tracks the order preparation time, and completes the order when the timer finishes.

Responsibilities:

- Accept one incomplete `Order` while idle.
- Expose simple state checks through `has_active_order()` and `can_cook()`.
- Start cooking through `start_cooking()` without knowing about player input.
- Complete active cooking through `complete_cooking()` after timing finishes or when called by another gameplay system.
- Emit `cooking_started(order)` and `cooking_completed(order)` so future UI, audio, reward, and payment systems can react without coupling those concerns to the stand.

Cooking stand logic lives in `res://Scripts/Stand/CookingStand.gd`, with the reusable scene in `res://Scenes/Stand/CookingStand.tscn`. It should remain focused on cooking state and timing only; customer flow, input, UI, payments, coins, and rewards belong in dedicated systems.


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

Current responsibilities:

- `Main.gd` connects to `CookingStand.cooking_completed(order)` for the first playable cooking loop.
- Completed orders are marked complete if needed, then `order.total_price` is added to `GameManager` coins.
- `GameManager.currency_changed` refreshes the HUD coin display.
- `GameHUD.show_coin_feedback(amount)` displays simple text-only `+X Coins` feedback.

Planned responsibilities:

- Move broader reward orchestration into a dedicated economy service when the loop grows beyond the initial cooking interaction.
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

### Sprint 4 Visual Polish Note

Visual Polish sprint has started. Technical work in this sprint should remain presentation-only, use lightweight Godot 2D nodes and tweens, avoid external assets, and keep all economy, queue, cooking, order, upgrade, and HUD behavior unchanged.
