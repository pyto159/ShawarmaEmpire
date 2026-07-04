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

- Players start with **Lavash**, **Chicken**, and **Garlic Sauce** unlocked.
- **Classic Shawarma:** Lavash, Chicken, Garlic Sauce. Available from the start, sells for 15 coins, and takes 3 seconds to prepare.
- **Spicy Shawarma:** Lavash, Chicken, Jalapeño, Spicy Sauce. Requires Jalapeño and Spicy Sauce, sells for 22 coins, and takes 3.5 seconds to prepare.
- **Cheese Shawarma:** Lavash, Chicken, Cheese, Garlic Sauce. Requires Cheese, sells for 30 coins, and takes 4 seconds to prepare.
- Unlockable ingredients are Tomato for 75 coins, Cucumber for 100 coins, Jalapeño for 150 coins, Spicy Sauce for 200 coins, and Cheese for 300 coins.

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
