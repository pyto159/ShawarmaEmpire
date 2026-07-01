# Shawarma Empire Roadmap

## Purpose of this Document

This roadmap tracks the intended production path for **Shawarma Empire** from the current foundation through live operations. It should be maintained as milestones evolve, tasks are completed, and priorities change.

Milestones should remain small enough to review and validate, with documentation updated alongside gameplay, UI, technical, and production changes.

## Vertical Slice

The Vertical Slice proves that the core game can be fun, readable, performant, and technically maintainable.

Primary goals:

- Establish the core customer arrival, queue, service, and reward loop.
- Show a playable shawarma stand scene with clear customer behavior.
- Display primary currency in the UI.
- Save and load essential player state.
- Provide at least one meaningful upgrade path.
- Validate mobile screen layout and touch readability.
- Confirm the project can run without parser errors.
- Keep systems small, typed, and easy to extend.

Exit criteria:

- A player can understand the objective without developer explanation.
- Customers can be served repeatedly.
- Currency changes are visible and persisted.
- One upgrade changes gameplay in a noticeable way.
- The experience is stable enough for internal review.

## MVP

The MVP proves that the game has enough progression and structure for broader testing.

Primary goals:

- Complete the basic idle/tycoon loop.
- Add data-driven recipes.
- Add multiple upgrade categories.
- Add basic employee automation.
- Add customer spawning tuned for early progression.
- Expand save data to cover progression state.
- Add basic onboarding or tutorial guidance.
- Improve UI navigation for upgrades, recipes, and employees.
- Add placeholder audio and visual feedback where needed.
- Establish performance targets for low-end Android devices.

Exit criteria:

- A new player can progress for multiple short sessions.
- The player has several clear spend goals.
- Automation reduces manual repetition.
- Save/load covers all MVP progression systems.
- Core UI is usable on target mobile resolutions.

## Beta

Beta focuses on polish, balance, content depth, device coverage, and production readiness.

Primary goals:

- Balance early, mid, and late MVP progression.
- Add additional recipes, upgrades, employees, and visual improvements.
- Add analytics events for key funnel and progression points.
- Add error reporting or diagnostic support where appropriate.
- Test on representative Android hardware.
- Optimize scene, UI, and script performance.
- Add monetization prototypes only after the core loop is healthy.
- Improve onboarding based on playtest feedback.
- Lock down naming conventions and data formats for launch content.

Exit criteria:

- Playtesters understand goals and return incentives.
- Progression pacing is measurable and tunable.
- Performance remains stable on low-end Android devices.
- Critical bugs are tracked and resolved.
- Monetization, if present, is optional and clearly communicated.

## Release

Release prepares the game for public launch.

Primary goals:

- Finalize launch content.
- Complete store-ready branding, icon, screenshots, and descriptions.
- Complete privacy, consent, monetization, and platform requirements.
- Finalize save compatibility strategy.
- Complete Android build configuration and signing process.
- Run regression testing for core systems.
- Verify no parser errors or blocking runtime errors.
- Confirm launch analytics and crash diagnostics.
- Prepare support and issue triage process.

Exit criteria:

- The launch build is stable and signed.
- The core loop, progression, saves, and UI pass release checks.
- Store assets and compliance requirements are complete.
- Known issues are documented with severity and mitigation plans.

## Live Updates

Live Updates extend the game after release while protecting save compatibility and player trust.

Primary goals:

- Add new recipes, upgrades, events, and expansion content.
- Run limited-time events and seasonal themes.
- Improve balancing based on analytics and feedback.
- Add quality-of-life improvements.
- Expand monetization carefully and transparently.
- Maintain performance across supported Android devices.
- Preserve compatibility with existing save data.
- Keep documentation current as systems evolve.

Exit criteria for each update:

- New content is additive or safely migrated.
- Save data remains compatible.
- Performance remains within target limits.
- Player-facing changes are documented.
- Regression checks pass before release.
