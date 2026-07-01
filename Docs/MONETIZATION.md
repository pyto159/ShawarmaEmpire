# Monetization

## Purpose of this Document

This document is the long-term monetization reference for **Shawarma Empire**. It should be updated whenever monetization systems, economy rules, ad placements, purchases, events, or platform requirements change.

The goal is to keep monetization fair, transparent, mobile-first, and compatible with a commercial idle/tycoon game. Monetization should support continued development without weakening player trust, damaging progression clarity, or making the game feel like it is designed around interruptions.

## Monetization Philosophy

Monetization should never interrupt gameplay.

Players should always feel that they are choosing optional value, not being forced away from the shawarma stand, customer queue, upgrade flow, or reward loop. A player who never watches ads and never makes purchases should still be able to understand the game, make steady progress, unlock meaningful upgrades, and enjoy the full core experience.

Rewarded ads should always provide value. Each rewarded ad placement must clearly describe the reward before the player opts in, deliver the reward immediately after successful completion, and avoid creating confusion about whether the reward is temporary, permanent, limited, or one-time.

Interstitial ads should be rare and should never appear during active gameplay. They must not appear while customers are being served, while the player is interacting with upgrades, while rewards are being collected, during onboarding, or at moments where the player is likely to feel punished for engaging with the game.

Long-term principles:

- Monetization must be optional, predictable, and respectful.
- Ads should accelerate progress but never replace gameplay.
- Purchases should provide convenience, value, cosmetics, or clearly bounded bonuses.
- No monetization feature should make non-paying players feel blocked from core progression.
- Monetization should be added only when the core loop is satisfying without it.
- Player trust is more valuable than short-term revenue from aggressive placements.

## Currencies

### Coins

Coins are the primary earned currency and should represent regular business income from serving customers, offline progress, missions, achievements, and other normal gameplay rewards.

Coins should be used for frequent progression actions such as:

- Stand upgrades.
- Recipe improvements.
- Employee hiring and upgrades.
- Queue, service, speed, and profit improvements.
- Early and mid-game expansion costs.

Coins should be earned often and spent often. Coin rewards should make the player feel that the shawarma business is constantly moving forward, even during short mobile sessions.

### Premium Gems

Premium Gems are the premium or high-value currency. They may be earned in limited quantities through achievements, daily rewards, special events, login streaks, or other retention systems, and may also be sold through future in-app purchases.

Premium Gems should be used for optional, high-value actions such as:

- Speeding up timers where appropriate.
- Buying special bundles.
- Unlocking cosmetics or convenience features.
- Claiming premium event rewards.
- Purchasing limited but fair accelerators.

Premium Gems should never be required to understand the game, complete core progression, or access essential systems. If gems are used for accelerators, those accelerators should shorten waiting or increase rewards without becoming the only practical way to progress.

### Future Event Currency

Future Event Currency is reserved for limited-time events, seasonal content, food festivals, or special live operations campaigns.

Event currency should have a specific purpose and should not duplicate Coins or Premium Gems. It may be used for:

- Event-specific upgrades.
- Seasonal reward tracks.
- Limited-time cosmetics.
- Special recipes.
- Temporary festival progression.

Event currency should be clearly labeled, time-bounded, and easy to understand. If unused event currency expires, converts, or carries forward, the rule must be communicated clearly before the event ends.

## Rewarded Ads

Rewarded ads are opt-in ads where the player chooses to watch an ad in exchange for a clear benefit. They should be the primary ad format because they respect player choice and fit naturally into idle/tycoon progression.

General rewarded ad rules:

- The reward must be shown before the ad begins.
- The reward must be delivered immediately after successful completion.
- The game should never imply that an ad is mandatory.
- Rewarded ads should not appear as surprise popups during active play.
- Reward values should be useful without making normal progression feel worthless.
- Rewarded ad buttons should be easy to dismiss or ignore.
- Failed ads, unavailable inventory, or connection problems should not punish the player.

Potential rewarded ad placements:

### Double Offline Income

When the player returns after being away, they may watch a rewarded ad to double eligible offline earnings.

This placement is highly suitable for idle gameplay because it appears at a natural return moment and directly improves a reward the player already earned.

Rules:

- Show the base offline earnings first.
- Make the doubled total clear before the player opts in.
- Allow the player to claim the base reward without watching an ad.
- Apply any maximum offline duration before the ad multiplier.

### Instant Cooking Boost

The player may watch a rewarded ad to temporarily increase cooking or preparation speed.

Rules:

- The boost duration must be visible.
- The effect should be noticeable but temporary.
- The boost should not break balance or remove the value of permanent upgrades.
- The boost should not stack infinitely unless a specific capped stacking rule is defined.

### Free Ingredient Refill

The player may watch a rewarded ad to refill ingredients for free when ingredient systems are added.

Rules:

- The refill should solve a short-term shortage.
- It should not replace long-term ingredient management.
- The player should always have a non-ad path to refill, restock, or continue progressing.

### Double Customer Payment

The player may watch a rewarded ad to temporarily double payments from served customers.

Rules:

- The duration or customer count must be clearly defined.
- The boost should affect future served customers, not retroactively change unclear rewards.
- The boost should not trigger during forced tutorials or first-time confusion.

### Temporary Profit Boost

The player may watch a rewarded ad to activate a broad profit multiplier for a limited time.

Rules:

- The multiplier and duration must be displayed before the ad.
- The boost should interact predictably with other multipliers.
- The boost should not become the default expected state for balanced progression.

### Extra Daily Reward

After claiming a daily reward, the player may watch a rewarded ad for an additional bonus.

Rules:

- The base daily reward must remain claimable without an ad.
- The extra reward should feel generous but not mandatory.
- The offer should be limited to avoid repeated ad pressure in the same session.

### Emergency Cash

If the player is just short of an affordable upgrade or key action, the game may offer an optional rewarded ad for a small amount of emergency Coins.

Rules:

- This should be used sparingly.
- The reward should help with a near-term goal, not replace earning income.
- The placement should not appear repeatedly after every failed purchase.
- The game should avoid creating artificial shortages just to trigger this offer.

## Interstitial Ads

Interstitial ads are full-screen ads that do not provide a direct opt-in reward. Because they interrupt the player, they should be used rarely and conservatively.

### When They May Appear

Interstitial ads may only appear at natural breaks where the player has completed an action and is not actively managing the stand.

Potential acceptable moments:

- After closing a completed summary screen.
- After returning from a long inactive period, but only after offline rewards are claimed.
- After completing a level, milestone, or event screen when no active gameplay is happening.
- After leaving a menu, if enough time and gameplay actions have passed since the last interstitial.

Interstitial ads should never appear:

- During active customer service.
- While the player is tapping upgrades or purchases.
- During onboarding or the first gameplay moments.
- Immediately after a rewarded ad.
- Immediately after an in-app purchase.
- Before delivering a reward.
- On app launch before the player reaches the game.
- During critical error, save, consent, privacy, or platform flows.

### Maximum Frequency

Interstitial frequency should be capped aggressively.

Recommended maximums:

- No interstitial ads during the first several minutes of a new player session.
- No more than one interstitial within a long cooldown window.
- No more than a small number of interstitials per day.
- No interstitial if the player recently watched a rewarded ad.
- No interstitial if the player recently made a purchase.

Exact cooldowns should be tuned during testing, but the default design stance should be conservative. If analytics show that interstitials reduce retention, session length, store rating, or purchase trust, placements should be reduced or removed.

### Rules to Avoid Annoying Players

- Use interstitials only at clean transition points.
- Preserve all rewards and progress before showing an ad.
- Never chain interstitials back-to-back.
- Do not show interstitials after every menu close or repeated action.
- Respect platform consent, age, privacy, and ad personalization rules.
- Disable or suppress interstitials for players who buy Remove Ads, if that product is implemented.
- Prefer rewarded ads over interstitial ads whenever possible.

## Future In-App Purchases

In-app purchases should provide clear value without making free players feel blocked. Purchase screens should be transparent about contents, duration, limits, and whether an item is permanent or consumable.

### Remove Ads

Remove Ads should be a permanent purchase that removes forced interstitial ads and other non-rewarded ad interruptions.

Design notes:

- Rewarded ads may remain available as optional value exchanges unless the product explicitly grants equivalent rewards.
- The product description must clearly explain what ad formats are removed.
- If interstitial ads are extremely rare or absent, the value proposition should remain honest.

### Starter Pack

The Starter Pack should be a one-time early purchase that helps new players begin faster without skipping the core learning curve.

Potential contents:

- A modest amount of Premium Gems.
- A useful Coin bonus.
- A temporary profit boost.
- A cosmetic or profile badge if cosmetics are added.

Design notes:

- The pack should be useful but not required.
- It should not unlock systems before the player understands them.
- It should not invalidate early upgrades.

### Premium Gems

Premium Gem packs may be sold as consumable purchases.

Design notes:

- Pack sizes should be easy to compare.
- Bonus gems should be displayed clearly.
- Gem spending options should be fair and understandable.
- Gems should not be required for essential progression.

### Special Bundles

Special Bundles may combine currencies, boosts, cosmetics, event items, or convenience rewards.

Design notes:

- Bundle contents must be listed clearly.
- Limited-time messaging must be accurate.
- Bundles should not pressure players with misleading urgency.
- Event bundles should remain connected to the event theme and value.

### VIP Membership

VIP Membership may be considered as a subscription or long-duration premium feature after the core economy is stable.

Potential benefits:

- Daily Premium Gems.
- Small persistent profit bonus.
- Extra daily reward slot.
- Cosmetic VIP indicator.
- Quality-of-life perks.

Design notes:

- Benefits must be sustainable for long-term balance.
- The subscription must not be required for competitive or core progression.
- Expiration, renewal, cancellation, and restoration behavior must be clear.

## Offline Progress

Offline progress is central to an idle/tycoon game. Players should feel rewarded for returning without feeling that they must be offline to progress efficiently.

### Offline Earnings

Offline earnings represent Coins generated while the player is away.

Rules:

- Offline earnings should be based on current business capacity and upgrade state.
- The return screen should show how long the player was away and how much was earned.
- The base offline reward should be claimable without an ad.
- The player should understand why the reward amount changed over time.

### Offline Cooking

Offline cooking may represent prepared food, completed batches, or simulated customer service while away.

Rules:

- Offline cooking should use simplified simulation rather than expensive real-time processing.
- Results should be deterministic enough to explain and balance.
- Ingredient limits, employee effects, and recipe values should be applied consistently if those systems exist.
- Offline cooking should support the fantasy that the shawarma business keeps operating while the player is away.

### Maximum Offline Duration

Maximum offline duration limits how much progress can accumulate while the player is away.

Design goals:

- Encourage players to return regularly.
- Protect economy balance.
- Keep rewards readable and predictable.
- Provide upgrade opportunities that increase the cap over time.

Possible cap structure:

- Short cap for very early players.
- Longer cap through manager, storage, or business upgrades.
- Event-specific caps if needed for seasonal balance.

### Reward Multipliers

Reward multipliers may come from upgrades, employees, events, VIP benefits, temporary boosts, or rewarded ads.

Rules:

- Multipliers should have clear names and sources.
- The order of operations should be consistent.
- Temporary multipliers should show remaining duration.
- Rewarded ad multipliers should apply after the base eligible reward is calculated.
- Multipliers should not stack into confusing or unbalanceable values without caps.

## Retention

Retention systems should give players positive reasons to return. They should support the core shawarma business fantasy rather than becoming disconnected chores.

### Daily Rewards

Daily rewards provide a simple return incentive.

Rules:

- Rewards should be easy to claim.
- Missing a day should not feel devastating.
- Reward value should scale with progression where appropriate.
- Optional ad bonuses may add value but should not replace the base reward.

### Daily Missions

Daily missions give players short-term goals for each session.

Potential mission examples:

- Serve a number of customers.
- Earn a target amount of Coins.
- Upgrade a recipe or station.
- Claim offline earnings.
- Complete an event action.

Rules:

- Missions should be achievable in short mobile sessions.
- Mission requirements should be clear and track visibly.
- Rewards should support current progression.

### Achievements

Achievements reward long-term milestones and mastery.

Potential achievement categories:

- Lifetime customers served.
- Total Coins earned.
- Recipes unlocked.
- Employees hired.
- Offline hours accumulated.
- Events completed.

Rules:

- Achievement rewards should feel meaningful.
- Achievements should reinforce the main progression path.
- Premium Gems may be used sparingly as high-value achievement rewards.

### Login Streak

Login streaks reward consistent return behavior.

Rules:

- Streak rewards should improve over time without becoming punitive.
- The game may include a grace period or streak protection item if appropriate.
- The player should know what reward comes next.
- Streak systems should avoid making players feel punished for normal life interruptions.

### Special Events

Special events provide limited-time goals and variety.

Rules:

- Events should be understandable without external explanation.
- Event rewards should be themed and desirable.
- Event progress should be achievable for free players.
- Monetization may accelerate event progress but should not be the only realistic way to participate.

### Seasonal Content

Seasonal content can refresh the game around holidays, food festivals, regional themes, or limited-time recipes.

Rules:

- Seasonal content should be additive.
- Returning seasonal content should preserve or fairly migrate prior player progress.
- Seasonal offers should follow the same fairness standards as permanent monetization.

## Economy Principles

The economy should remain fair, readable, and satisfying over long-term play.

Core principles:

- No pay-to-win.
- Ads should accelerate progress but never replace gameplay.
- Upgrades should always feel meaningful.
- Every major spend should have a clear benefit.
- Progression should include frequent short-term goals and longer-term aspirations.
- Free players should always have a path forward.
- Purchases and ads should reduce friction, add convenience, or create optional excitement without becoming mandatory.
- Economy tuning should be data-driven once analytics are available.
- New currencies, boosts, and offers should be added only when they solve a real design need.

Upgrade principles:

- Early upgrades should be frequent and easy to understand.
- Mid-game upgrades should create planning decisions.
- Late-game upgrades should provide meaningful milestones rather than tiny invisible changes.
- Permanent upgrades should remain valuable even when temporary boosts are active.
- Monetized accelerators should never make permanent progression feel irrelevant.

Maintenance principles:

- Document every new monetization placement before implementation.
- Track each ad placement with its trigger, cooldown, reward, and suppression rules.
- Track each purchase with its contents, price tier, availability, and restore behavior.
- Review monetization alongside retention, ratings, support feedback, and player sentiment.
- Remove or revise monetization that harms the player experience.

## Expansion Notes

This document should remain easy to maintain and expand. Future updates may add dedicated sections for:

- Regional pricing.
- Consent and privacy requirements.
- Ad network configuration.
- Analytics events.
- A/B testing rules.
- Store compliance checklists.
- Event economy templates.
- Purchase restoration behavior.
- Refund and support handling.

Any future monetization implementation should reference this document before code, UI, economy data, or platform configuration is changed.
