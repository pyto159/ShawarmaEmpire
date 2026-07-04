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

| Upgrade | Cost | Effect |
| --- | ---: | --- |
| Better Counter | 120 coins | +5% customer patience |
| New Sign | 180 coins | +10% customer spawn rate |
| Better Lighting | 260 coins | +5% rare order chance |
| Decorations | 340 coins | +10% tip chance |

Kiosk upgrades are one-time purchases and are independent from Grill progression. The tip chance currently rolls a 20% bonus tip on served-order rewards when Decorations succeeds.

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
| Decorations Upgrade | +10% tip chance |
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
