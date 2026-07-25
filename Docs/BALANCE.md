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

Rare and favorite bonuses are calculated as separate additive bonus coin amounts so they stack cleanly with tips and combo bonuses. A rare order that also matches the customer's favorite pays `base recipe reward + rare bonus + favorite bonus`, before adding any rolled tip and combo bonus.

## Kiosk Upgrade Balance

Kiosk upgrade costs and effects live in `res://Resources/Economy/EconomyConfig.tres` and should be changed there first, with fallback values mirrored in `res://Scripts/Economy/EconomyConfig.gd`.

| Better Counter Level | Cost | Order Income Multiplier |
| --- | ---: | ---: |
| 1 | 0 coins | 1.00x |
| 2 | 300 coins | 1.05x |
| 3 | 900 coins | 1.10x |
| 4 | 2,500 coins | 1.18x |
| 5 | 6,500 coins | 1.28x |

Better Counter multiplies normal order income. Tips, combos, rare bonuses, and favorite bonuses remain independently based on the recipe reward.

| New Sign Level | Cost | Customer Arrival Interval Multiplier |
| --- | ---: | ---: |
| 1 | 0 coins | 1.00x |
| 2 | 450 coins | 0.94x |
| 3 | 1,300 coins | 0.87x |
| 4 | 3,600 coins | 0.78x |
| 5 | 9,000 coins | 0.68x |

New Sign multiplies the normal customer spawn interval, so lower multipliers make spawn attempts more frequent while all queue limits remain unchanged. Better Lighting and Decorations are planned but not implemented.

## Business Reputation Balance

Reputation is a permanent progression value independent from coins. Players start at 0 Reputation and there is no maximum cap.

| Source | Reputation |
| --- | ---: |
| Successfully served customer | +1 |
| Rare Order completed | +2 bonus |
| Favorite Recipe served | +2 bonus |

Business Level thresholds and bonuses:

| Business Level | Reputation Required | Bonus |
| --- | ---: | --- |
| Level 1 | 0 | Starting level |
| Level 2 | 25 | +1 Queue Slot |
| Level 3 | 75 | +5% Rare Order Chance |
| Level 4 | 150 | +10% Customer Spawn Rate |
| Level 5 | 300 | Future content hook; no gameplay bonus yet |

## Tips and Combo Reward Balance

Tips and combo bonuses live in `res://Resources/Economy/EconomyConfig.tres` and should be changed there first, with fallback values mirrored in `res://Scripts/Economy/EconomyConfig.gd`.

| Value | Default |
| --- | ---: |
| Base Tip Chance | 20% per completed order |
| Tip Amount | 5%–25% of base recipe reward, rounded, minimum 1 coin when a tip rolls |
| Maximum Combo | x10 |

Combo bonuses are additive coin bonuses based on the base recipe reward. The first successful order in a streak is Combo x1 and grants no combo bonus; each consecutive successful order increases the combo by one until Combo x10.

| Combo | Bonus |
| --- | ---: |
| x1 | +0% |
| x2 | +5% |
| x3 | +10% |
| x4 | +15% |
| x5 | +20% |
| x6 | +25% |
| x7 | +30% |
| x8 | +35% |
| x9 | +40% |
| x10 | +50% |

Final served-order coins are calculated modularly as base recipe reward plus tip coins plus combo bonus coins plus rare order bonus coins plus favorite bonus coins. Rare and favorite rewards now stack additively with tip and combo bonuses so each reward source can be tuned independently.
