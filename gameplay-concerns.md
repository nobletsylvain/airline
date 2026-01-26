# Gameplay Concerns — Review Needed

**Date:** January 2026  
**Status:** TRIAGED  
**Purpose:** Identify gameplay-level questions to address before prototyping

---

## Context

Documentation is complete (96% health score, prototype-ready). Before building, we should validate that the designed systems will actually be *fun*.

This document captures gameplay concerns that documentation alone cannot answer — questions that require design thinking, playtesting intuition, or explicit decisions.

---

## Status Summary

| # | Concern | Status | Resolution |
|---|---------|--------|------------|
| 1 | Core Loop Engagement | Deferred to playtesting | Requires playable prototype |
| 2 | Pacing & Time Model | Deferred to playtesting | Requires playable prototype |
| 3 | Decision Density | **Addressed by spec** | `decision-density-spec.md` |
| 4 | Difficulty Curve | **Addressed by spec** | `difficulty-curve-spec.md` |
| 5 | Feedback Clarity | Deferred to playtesting | Requires player observation |
| 6 | Endgame Content | **Addressed by spec** | `endgame-content-spec.md` |
| 7 | Tutorial Effectiveness | Deferred to playtesting | Requires player observation |
| 8 | Living Flight Value | Deferred to playtesting | Requires cost/benefit analysis |
| 9 | Compromise System Impact | **Addressed by spec** | `compromise-system-spec.md` |
| 10 | AI Competitor Believability | Deferred to playtesting | Requires AI implementation |
| 11 | Sandbox vs Campaign Balance | Deferred to playtesting | Requires both modes playable |
| 12 | Economic Authenticity vs Fun | Deferred to playtesting | Requires tuning with real numbers |

**Blocking concerns resolved:** 4 of 4  
**Remaining concerns:** 8 (all require playtesting)

---

## 1. Core Loop Engagement

### The Question
Is "pick route → set price → watch revenue" engaging enough to sustain 100+ hours?

### Concerns
- Route economics may be too passive (set and forget)
- Price adjustments may feel like minor tweaks, not meaningful decisions
- Competition response may be too slow to feel interactive

### Questions to Resolve
- How often should players need to revisit route decisions?
- What makes a route decision feel "solved" vs "ongoing"?
- Is there enough tension in the core loop without events?

### Resolution
**Status:** Deferred to playtesting  
**Rationale:** Core loop feel cannot be evaluated without a playable prototype — requires real player sessions to measure engagement and session length.

---

## 2. Pacing & Time Model

### The Question
Are the time speeds (1hr = 1sec at Normal) correctly calibrated?

### Concerns
- At Normal speed, 1 year = 2.5 hours — is that too fast for strategic play?
- At Slow speed, watching a transatlantic flight takes 8 minutes — is that too slow?
- Skip-to may be overused, making continuous time feel pointless

### Questions to Resolve
- What's the ideal session length for meaningful progress?
- How much "dead time" (nothing happening) is acceptable?
- Should certain game phases (startup vs empire) have different pacing?

### Resolution
**Status:** Deferred to playtesting  
**Rationale:** Time calibration requires real player feedback — make speeds adjustable in prototype and collect telemetry on usage patterns.

---

## 3. Decision Density

### The Question
Are there enough meaningful decisions per play session?

### Concerns
- Early game may be too simple (one plane, one route)
- Mid game may have "waiting periods" with nothing to do
- Late game may automate away too much (delegation)

### Questions to Resolve
- Target decisions per 30-minute session at each phase?
- What decisions remain engaging even at large scale?
- How do we avoid "spreadsheet simulator" syndrome?

### Resolution
**Status:** Addressed by spec  
**Document:** `decision-density-spec.md`  
**Remaining work:** Playtest to validate hypothesis numbers (8-12 decisions/session Founder, 5-8 Manager, 3-5 Executive, 1-3 Chairman)

---

## 4. Difficulty Curve

### The Question
How does challenge scale from hour 1 to hour 100?

### Concerns
- Early game may be too easy (no competition, simple economics)
- Mid game may have a cliff (sudden complexity spike)
- Late game may be solved (optimal strategies become obvious)

### Questions to Resolve
- What makes the game harder as you grow?
- How do we prevent "solved" states?
- Is failure sufficiently possible throughout?

### Resolution
**Status:** Addressed by spec  
**Document:** `difficulty-curve-spec.md`  
**Remaining work:** Playtest to validate four difficulty vectors (capital scarcity, competition intensity, market saturation, operational complexity) and phase scaling

---

## 5. Feedback Clarity

### The Question
Can players understand why they succeeded or failed?

### Concerns
- Route profitability has many hidden factors
- AI competitor behavior may feel random
- Brand/reputation effects are subtle and delayed

### Questions to Resolve
- How do we surface cause-and-effect relationships?
- What post-mortems help players learn from failure?
- How do we avoid "I don't know why I'm losing" frustration?

### Resolution
**Status:** Deferred to playtesting  
**Rationale:** Feedback clarity requires player observation — include diagnostic panels in prototype and watch for confusion patterns during playtests.

---

## 6. Endgame Content

### The Question
What keeps players engaged after 50+ hours?

### Concerns
- Empire-building may plateau (nowhere left to grow)
- Delegation may remove too much player agency
- Self-imposed challenges may not be enough

### Questions to Resolve
- What's the "endgame loop" for experienced players?
- Are historical scenarios enough variety?
- Do we need competitive/leaderboard elements?

### Resolution
**Status:** Addressed by spec  
**Document:** `endgame-content-spec.md`  
**Remaining work:** Playtest to validate three content tracks (Legacy/Prestige, Industry Politics, Competitive Rankings) and Hall of Fame progression

---

## 7. Tutorial Effectiveness

### The Question
Will the "flying in 90 seconds" goal actually work?

### Concerns
- First route suggestion may feel railroaded
- New players may still feel overwhelmed
- Advisor may be ignored or annoying

### Questions to Resolve
- What's the minimum viable first session?
- How do we test tutorial flow without full prototype?
- What metrics indicate tutorial success?

### Resolution
**Status:** Deferred to playtesting  
**Rationale:** Tutorial effectiveness requires new player observation — existing FTUE design (`FTUE_Endless_Mode.md`) is solid but needs validation with real first-time users.

---

## 8. Living Flight Value

### The Question
Is the cabin observation mode worth the development cost?

### Concerns
- Pure observation, no gameplay — may feel shallow
- Performance cost for rendering 200+ passengers
- Players may never use it after initial novelty

### Questions to Resolve
- Is this core to the experience or a nice-to-have?
- Can we prototype this cheaply to test appeal?
- Should cabin view influence gameplay (not just observation)?

### Resolution
**Status:** Deferred to playtesting  
**Rationale:** Living Flight is immersion/reward, not core gameplay — defer to post-MVP. Static cabin preview in Cabin Designer can test appeal cheaply first.

---

## 9. Compromise System Impact

### The Question
Will the obligation system feel meaningful or annoying?

### Concerns
- Hidden debts may feel unfair ("where did this come from?")
- Too many obligations may feel like debt trap
- Too few may make compromises feel costless

### Questions to Resolve
- How visible should outstanding obligations be?
- What's the right frequency of obligation calls?
- Can players ever be "free" of past compromises?

### Resolution
**Status:** Addressed by spec  
**Document:** `compromise-system-spec.md`  
**Remaining work:** Playtest to validate visibility rules ("visible presence, invisible timing") and frequency targets (2-4 active obligations Manager phase, 1-2 calls/year)

---

## 10. AI Competitor Believability

### The Question
Will AI airlines feel like real competitors or mechanical obstacles?

### Concerns
- Behavior may be too predictable (always price match)
- Behavior may be too random (no apparent strategy)
- Players may not notice AI personality differences

### Questions to Resolve
- What behaviors make AI feel "alive"?
- How much AI transparency is desirable?
- Should AI have visible "personalities"?

### Resolution
**Status:** Deferred to playtesting  
**Rationale:** AI believability requires implemented AI — prototype 2-3 personality archetypes (aggressive LCC, defensive legacy, opportunistic startup) and test whether players perceive differences.

---

## 11. Sandbox vs Campaign Balance

### The Question
Can the same systems serve both sandbox and scenario players?

### Concerns
- Sandbox may lack direction
- Campaigns may feel too scripted
- Scenario difficulty may not scale to player skill

### Questions to Resolve
- How do sandbox objectives provide enough structure?
- How do campaigns provide enough freedom?
- Is there a unified difficulty system?

### Resolution
**Status:** Deferred to playtesting  
**Rationale:** Mode balance requires both modes implemented — existing structure (sandbox with optional objectives, campaigns with fixed starts + victory conditions) is sound but needs tuning.

---

## 12. Economic Authenticity vs Fun

### The Question
Where should we deviate from realism for fun?

### Concerns
- Real margins (2%) are boring
- Real timelines (3-5 year deliveries) are frustrating
- Real complexity (regulatory, unions) may be tedious

### Already Decided
- Compressed timelines ✓
- Amplified margins ✓
- Simplified regulations ✓

### Questions to Resolve
- Are the compressions calibrated correctly?
- What realistic details add depth without tedium?
- Where does "plausible" beat "accurate"?

### Resolution
**Status:** Deferred to playtesting  
**Rationale:** Economic calibration requires real numbers in a playable system — design stance is clear (`economic-parameters.md`), but tuning is empirical work.

---

## Next Steps

~~1. **Review each concern** — Decide if it needs design work, playtesting, or is already addressed~~  
~~2. **Prioritize** — Which concerns are blocking vs nice-to-know?~~  
~~3. **Design sessions** — Deep dive on priority items~~  

**Completed:** All blocking concerns (3, 4, 6, 9) now have detailed specs.

**Remaining:**
1. **Prototype build** — Implement core systems to enable playtesting
2. **Playtest sessions** — Validate the 8 deferred concerns with real players
3. **Iterate** — Adjust specs based on playtest findings

---

## Notes

This is not an exhaustive list. Add concerns as they arise during design discussions.

~~Some concerns may be resolved by existing documentation — check specs before designing new solutions.~~

All remaining concerns require playtesting — paper design has reached its limit.

---

## Document History

| Version | Date | Changes |
|---------|------|---------|
| 0.1 | January 2026 | Initial concerns list |
| 0.2 | January 2026 | Triaged all concerns. Added resolution status to each. Four addressed by new specs, eight deferred to playtesting. |
