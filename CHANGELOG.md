# Changelog

All notable changes to **Shawarma Empire** will be documented in this file.

The format is based on milestone releases for the current Godot 4 Android prototype.

## [0.1.0] - First Playable

### Overview

First playable prototype for the mobile-first shawarma idle/tycoon foundation. This milestone establishes a runnable Godot 4 project with a simple end-to-end cooking loop: a customer has an order, the player starts preparation from the HUD, cooking progress is displayed, the order completes, coins are awarded, and lightweight feedback is shown.

### Project Architecture

- Established the main Godot project under `shawarma-empire/` with production-oriented top-level folders for scenes, scripts, resources, UI, audio, managers, and assets.
- Added global manager foundations for game state, saving, scene transitions, and audio playback.
- Kept reusable gameplay systems in `Scripts/` and scene composition in `Scenes/` to support clean separation between UI, gameplay logic, and data resources.
- Configured the main scene as the current composition point for the first playable prototype, including the gameplay world, HUD, queue points, customer, stand, cooking stand, and reward feedback layer.

### Documentation

- Added project documentation covering the game vision, technical architecture, roadmap, game design, and monetization direction.
- Documented current responsibilities for managers, UI components, queue systems, customers, stands, orders, recipes, and cooking systems.
- Added repository-level overview documentation describing project goals, folder structure, and initial systems.

### Customer Spawning

- Added reusable spawning foundations with spawn definitions, spawn pools, spawn points, and a 2D spawner.
- Supports weighted/random spawn selection, active spawn counts, spawn-point collection, spawn-point reservation, and spawn success/failure signals.
- Designed spawning to stay generic so future customer waves and tycoon flow can build on it without embedding shawarma-specific logic.

### Queue System

- Added a reusable reservation-based queue system with queue points, queue requests, and queue reservations.
- Supports request priority, sequence ordering, queue capacity, duplicate-request prevention, reservation cancellation, reservation completion, and automatic queue compaction.
- Keeps queue flow independent from cooking, economy, and customer-specific gameplay rules.

### Recipe System

- Added data-driven recipe and ingredient resources.
- Added the initial Classic Shawarma recipe backed by ingredient resources for lavash, chicken, and garlic sauce.
- Recipes define reusable order data such as display name, preparation time, base price, and required ingredients.

### Order System

- Added order resources with selected recipe, total price, preparation time, creation time, completion time, and completion state.
- Added order generation from available recipes.
- Added order completion signaling so cooking, customer, reward, and UI systems can react without owning each other's responsibilities.

### Cooking Stand

- Added a reusable cooking station that starts orders, advances cooking over time, emits progress, supports cancellation, and completes orders.
- Added a shawarma cooking stand specialization that accepts an order, starts cooking, tracks completed orders, and can deliver completed orders to a customer.
- Maintains cooking logic separately from HUD presentation and currency rewards.

### HUD

- Added the first gameplay HUD for the playable cooking interaction.
- Displays current coins, active customer order text, and a Prepare button.
- Resolves the active customer and cooking stand through exported paths, forwards prepare input to the cooking stand, and disables actions when no order can be cooked.
- Emits order-ready flow from cooking completion while keeping reward ownership outside the HUD.

### Cooking Progress Bar

- Added a reusable cooking progress bar UI component.
- Listens to cooking stand signals, appears during active cooking, updates progress percentage, and hides shortly after completion.
- Keeps progress display presentation-only and independent from order ownership, rewards, and customer behavior.

### Floating Coin Feedback

- Added floating coin reward feedback scenes and scripts.
- Displays positive coin rewards, animates them upward, scales/fades them out, and frees the feedback node when complete.
- Composed by the main scene after rewards are awarded so feedback remains presentation-only.

### Customer Emotions

- Added customer emotion feedback with lightweight emoji-based states.
- Shows thinking feedback when an order is created, waiting feedback while queued/waiting, and happy feedback when food is received.
- Uses short animations and ignores UI input so emotions do not block gameplay interactions.

### Audio Foundation

- Added an autoloaded audio manager scene and script as the single global entry point for UI and gameplay sound effects.
- Exposes assignable sound slots for button, coin, cooking start, cooking complete, customer arrival, customer leaving, queue movement, and errors.
- Safely ignores playback requests when no stream is assigned, allowing the prototype to run without placeholder audio files.

### Notes

- This milestone documents the current prototype state only.
- No gameplay changes are included in this changelog entry.
