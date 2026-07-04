# Shawarma Empire Game Design

## Purpose of this Document

This document is the long-term game design reference for **Shawarma Empire**. It should be updated whenever core design decisions change, new systems are added, or production priorities shift.

The goal is to keep the game design clear, maintainable, and aligned with a mobile-first commercial idle/tycoon game built in Godot 4.

## High Level Vision

**Shawarma Empire** is a friendly, fast-readable idle/tycoon game about growing a humble shawarma stand into a thriving food empire.

The player should feel constant forward momentum through short sessions, satisfying upgrades, visible customer flow, and clear business growth. The experience should be approachable for casual players while offering enough optimization, collection, and long-term goals to support repeat play.

Design priorities:

- Immediate clarity on what the player can do next.
- Short, rewarding interactions suitable for mobile play.
- Visible changes as the business grows.
- Progression that feels generous, understandable, and sustainable.
- Systems that can expand without requiring rewrites.

## Genre

- **Primary genre:** Idle tycoon.
- **Secondary genre:** Light restaurant management.
- **Platform focus:** Android mobile.
- **Session style:** Short active sessions with passive progression hooks planned for later production.

## Target Audience

The target audience is casual and mid-core mobile players who enjoy:

- Food business themes.
- Incremental progress.
- Unlocking upgrades and new content.
- Watching automated systems improve over time.
- Short check-ins throughout the day.

The game should avoid requiring high mechanical skill, long uninterrupted sessions, or complex menus to make meaningful progress.

## Core Gameplay Loop

The core loop is intended to be simple and highly repeatable:

1. Customers arrive at the stand.
2. Customers enter a queue.
3. The stand serves customers.
4. Served customers generate currency.
5. The player spends currency on upgrades, recipes, employees, and expansion.
6. Upgrades improve service speed, value, capacity, automation, or variety.
7. Improved operations attract more customers and increase earnings.

The current project foundation already represents the queue and service portions of this loop. Currency, rewards, recipe value, employees, and upgrade effects should build on this foundation without duplicating the existing queue and spawning responsibilities.

## Progression

Progression should be structured around increasingly ambitious business goals:

- Start with a single shawarma stand.
- Improve service speed and customer handling.
- Unlock new recipes and ingredients.
- Hire employees to automate repetitive tasks.
- Upgrade the stand visually and mechanically.
- Expand to larger shops, districts, or themed locations.
- Support live updates with new recipes, events, and expansion content.

Progression should be visible in both numbers and presentation. When a milestone is reached, the player should understand what improved and why it matters.

## Currency

The current currency model contains:

- **Coins:** Primary earned currency used for regular upgrades and progression.
- **Gems:** Premium or special currency reserved for high-value actions, accelerators, cosmetics, or monetization-linked systems.

Currency principles:

- Coins should be earned through normal play and spent frequently.
- Gems should be valuable, limited, and never required to understand the game.
- Currency changes should be routed through centralized game state systems so UI and save data remain consistent.
- Future currencies should only be added when they support a distinct gameplay purpose.

## Recipes

Recipes represent sellable shawarma products and future menu variety.

Planned recipe attributes may include:

- Recipe name.
- Ingredient requirements.
- Base sale value.
- Preparation time modifier.
- Customer preference or demand category.
- Unlock cost.
- Upgrade level.

Current starter menu and ingredient progression:

- Players start with **Lavash**, **Chicken**, **Garlic Sauce**, **Tomato**, and **Cucumber** unlocked.
- **Classic Shawarma:** Lavash, Chicken, Garlic Sauce, Tomato, Cucumber. Available from the start, sells for 15 coins, and takes 3.0 seconds to prepare.
- **Spicy Shawarma:** Lavash, Chicken, Jalapeño, Spicy Sauce. Requires Jalapeño and Spicy Sauce, sells for 24 coins, and takes 3.6 seconds to prepare.
- **Cheese Shawarma:** Lavash, Chicken, Cheese, Garlic Sauce. Requires Cheese, sells for 35 coins, and takes 4.0 seconds to prepare.
- **BBQ Shawarma:** Lavash, Chicken, BBQ Sauce, Onion. Requires BBQ Sauce and Onion, sells for 50 coins, and takes 4.5 seconds to prepare.
- **Double Meat Shawarma:** Lavash, Double Chicken, Garlic Sauce, Tomato. Requires Double Chicken, sells for 65 coins, and takes 5.0 seconds to prepare.
- **Veggie Shawarma:** Lavash, Lettuce, Tomato, Cucumber, Cheese. Requires Lettuce and Cheese, sells for 45 coins, and takes 4.2 seconds to prepare.
- **Mega Shawarma:** Lavash, Double Chicken, Cheese, Tomato, Cucumber, Jalapeño, Garlic Sauce, BBQ Sauce. Requires every listed ingredient, sells for 90 coins, and takes 6.0 seconds to prepare.
- Unlockable ingredients are Jalapeño for 100 coins, Spicy Sauce for 150 coins, Cheese for 250 coins, Lettuce for 300 coins, Onion for 350 coins, BBQ Sauce for 450 coins, and Double Chicken for 600 coins.

Recipe principles:

- Recipes should be data-driven where possible.
- New recipes should add strategic variety instead of only increasing numbers.
- Recipe unlocks should be clear milestone rewards.
- Recipe UI should emphasize value, unlock requirements, and upgrade impact.
- Preparation visuals should be generated from each recipe ingredient sequence rather than hardcoded per recipe.

## Employees

Employees are planned as automation and efficiency systems.

Possible employee roles:

- Cashier: improves queue throughput or payment handling.
- Cook: reduces preparation time.
- Server: moves customers through service faster.
- Manager: improves passive income or offline rewards.
- Cleaner or helper: supports customer satisfaction in future systems.

Employee principles:

- Employees should reduce repetitive player actions.
- Employee benefits should be understandable at a glance.
- Hiring and upgrading employees should feel like a major business milestone.
- Employee systems should interact with existing gameplay systems through clear APIs rather than direct scene coupling.

## Upgrades

Upgrades are the primary spend target and should create frequent goals.

Planned upgrade categories:

- Service speed.
- Queue capacity.
- Customer arrival rate.
- Recipe value.
- Employee efficiency.
- Stand appearance.
- Offline earnings.
- Special event boosts.


### Grill Progression

The active grill upgrade path is a complete five-level service-speed progression:

1. **Basic Grill**
2. **Better Grill**
3. **Fast Grill**
4. **Professional Grill**
5. **Master Grill**

The upgrade button should always communicate the current grill level, current grill name, next grill name, and coin cost before purchase. At Level 5 it should clearly show **MAX LEVEL** and stop accepting purchases. Successful grill upgrades provide immediate feedback with a short floating notification: “🔥 Grill Upgraded!”, the new level, and the cooking speed increase percentage. Grill upgrades should immediately make active future cooking attempts faster, persist after restart, and reset to Level 1 on New Game. Visual flame intensity should increase per level whenever supported by available stand assets; otherwise the hook remains ready for future art.

Upgrade principles:

- Each upgrade should communicate its exact benefit.
- Early upgrades should be inexpensive and frequent.
- Later upgrades should support longer-term planning.
- Upgrade logic should be separate from UI presentation.
- Upgrade values should be data-driven to support balancing.

## Monetization

Monetization should support the game without damaging trust or progression fairness.

Potential monetization features:

- Rewarded ads for temporary boosts.
- Rewarded ads for bonus currency.
- Optional premium currency purchases.
- Cosmetic stand themes.
- Convenience bundles.
- Limited-time event offers.

Monetization principles:

- The game must remain playable without purchases.
- Rewarded ads should be opt-in and clearly described.
- Purchases should not create confusing progression dependencies.
- Monetization should be added only after the core loop is satisfying.


Ingredient progression now has two lightweight HUD menus. The Recipe Menu lists every recipe resource, its EconomyConfig reward and preparation time, whether the recipe is currently unlocked, and each required ingredient with unlocked or locked status. The Ingredient Shop lists every unlockable ingredient from IngredientManager/EconomyConfig with emoji label, cost, unlock status, and an individual purchase button, so players can buy any affordable ingredient instead of only the next fixed progression item. Ingredient purchases still flow through IngredientManager, save through existing unlocked ingredient ids, refresh recipe availability immediately, and unlocked recipes remain derived from ingredient requirements.

## UI Principles

The UI must be mobile-first and readable on small Android screens.

Principles:

- Prioritize large touch targets.
- Show the most important resources persistently.
- Keep menus shallow and focused.
- Avoid blocking the customer/service view unnecessarily.
- Use consistent placement for currency, upgrades, and navigation.
- Make upgrade outcomes explicit before purchase.
- Use animation and feedback to confirm rewards and progress.
- Maintain performance by avoiding excessive UI updates or expensive visual effects.

## Future Expansion Ideas

Potential long-term expansion directions:

- Multiple stands or branches.
- City map progression.
- Regional recipes and ingredients.
- Limited-time food festivals.
- Customer types with unique preferences.
- Reputation, satisfaction, or review systems.
- Delivery orders.
- Catering contracts.
- Cosmetic stand customization.
- Seasonal content.
- Offline income and return rewards.
- Cloud save and account progression.

Future expansion should be implemented as additive systems whenever possible. Existing queue, spawning, currency, and save systems should be extended through clean interfaces rather than rewritten.

## Rare Orders and Customer Favorites

Rare orders add lightweight reward variety to the normal customer loop without changing queue behavior, ingredient unlocks, or cooking flow. A rare order is generated from the same currently unlocked recipe pool as a normal order, appears with a default 10% chance, displays the simple HUD label “Rare Order!”, and pays a x2 reward multiplier when delivered.

Customer favorite recipes add a small satisfaction bonus. Each spawned customer may receive one favorite recipe with a default 25% chance, selected only from currently unlocked recipes. If that customer receives the matching recipe, the reward gains an additional +25%, the HUD feedback shows “Favorite!”, and the existing happy customer emotion is used.

Rare and favorite bonuses can stack safely because the final delivery reward is calculated once through the game/economy layer after cooking completes.

### Business Expansion: Kiosk Upgrades

Kiosk Upgrades are the first Business Expansion progression track and are independent from Grill upgrades. Each kiosk upgrade is purchased once from the Business panel, uses coin costs from `EconomyConfig`, persists through saves, and resets on New Game.

Current kiosk upgrades:

- **Better Counter:** improves customer comfort with **+5% customer patience**. Current patience behavior is exposed as a gameplay multiplier for customer systems and uses placeholder visuals until the patience loop receives final presentation.
- **New Sign:** improves storefront visibility with **+10% customer spawn rate**.
- **Better Lighting:** improves order presentation with **+5% rare order chance**.
- **Decorations:** improves atmosphere with **+10% tip chance**.

The Business panel displays purchased kiosk upgrades, available kiosk upgrades, descriptions, and upgrade costs so players can plan expansion separately from cooking speed progression.
