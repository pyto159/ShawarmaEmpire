# Shawarma Empire Balance

## Ingredient Unlock Costs

Ingredient unlock costs live in `res://Resources/Economy/EconomyConfig.tres` and should be changed there first, with fallback values mirrored in `res://Scripts/Economy/EconomyConfig.gd`.

| Ingredient | Cost |
| --- | ---: |
| Jalapeño | 100 coins |
| Spicy Sauce | 150 coins |
| Cheese | 250 coins |
| Lettuce | 300 coins |
| Onion | 350 coins |
| BBQ Sauce | 450 coins |
| Double Chicken | 600 coins |

## Premium Recipe Requirements

| Recipe | Required Ingredients |
| --- | --- |
| BBQ Shawarma | Lavash, Chicken, BBQ Sauce, Onion |
| Double Meat Shawarma | Lavash, Double Chicken, Garlic Sauce, Tomato |
| Veggie Shawarma | Lavash, Lettuce, Tomato, Cucumber, Cheese |
| Mega Shawarma | Lavash, Double Chicken, Cheese, Tomato, Cucumber, Jalapeño, Garlic Sauce, BBQ Sauce |

Recipe availability is derived from unlocked ingredients. Customers should only request recipes whose full ingredient list is unlocked.

## Progression Planning UI

The Recipe Menu and Ingredient Shop expose the existing balance data without changing it. Recipe rewards and preparation times still come from `EconomyConfig`, and ingredient costs remain the same; the shop only lets players choose any currently affordable locked ingredient rather than forcing a single next unlock.

## Order Bonus Balance

| Bonus | Default Chance | Reward Effect | Notes |
| --- | ---: | ---: | --- |
| Rare Order | 10% per generated order | x2 order reward | Rolls only after selecting from currently unlocked recipes. |
| Customer Favorite | 25% per customer | x1.25 final reward when matched | Favorite recipe is selected only from currently unlocked recipes. |

Rare and favorite bonuses multiply together. A rare order that also matches the customer's favorite pays `base recipe reward × 2.0 × 1.25`, rounded to the nearest coin, and is awarded once on delivery.
