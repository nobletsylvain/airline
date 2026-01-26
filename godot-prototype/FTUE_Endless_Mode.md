# Airline Tycoon - FTUE Design for Endless/Sandbox Mode

**Document Type:** First-Time User Experience Design  
**Mode:** Endless/Sandbox (Region-based start)  
**Last Updated:** January 25, 2026  
**Version:** 0.2

---

## Executive Summary

Based on analysis of successful tycoon games (OpenTTD, Cities: Skylines, Airlines Manager, Game Dev Tycoon, Airline Club), we propose **three FTUE approaches** for endless mode, each with different tradeoffs between player agency and guided onboarding.

The screenshot shows a **region selection screen** with 6 regions: North America, Europe, Orient & Asia, South America, Africa, and Oceania. This is the player's first major decision—it should feel meaningful but not overwhelming.

---

## Competitive Analysis Summary

| Game | FTUE Approach | Progression Driver | What Works | What Doesn't |
|------|---------------|-------------------|------------|--------------|
| **OpenTTD** | Optional tutorial scenario | Company value, year | Freedom, depth | Steep learning curve |
| **Cities: Skylines 2** | Milestone-based unlocks | XP → Milestones → Development Points | Clear goals, choices matter | Can feel arbitrary |
| **Airlines Manager** | Guided tours + rewards | Routes → Fleet → Research | Rewards learning | Tutorial-heavy |
| **Airline Club** | Profile selection (3 difficulty starts) | Awareness, loyalty, routes | Flexible starts | Complex for newbies |
| **Game Dev Tycoon** | Single playthrough IS the tutorial | Score → Fans → Unlocks | Elegant, replayable | Can bankrupt early |

---

## Three FTUE Solutions

### Solution A: "Guided Freedom" (Recommended)

**Philosophy:** Let player choose region and hub, but provide a contextual "advisor" that suggests first actions without forcing them.

**Flow:**

```
┌─────────────────────────────────────────────────────────────────────┐
│ 1. REGION SELECT (your screenshot)                                   │
│    • 6 regions displayed with visual appeal                         │
│    • Hover/click shows: difficulty rating, description, signature   │
│      airports, starter aircraft available                           │
│    • No "wrong" choice, but hints guide toward Europe (balanced)    │
│      or North America (familiar) for beginners                      │
└───────────────────────────┬─────────────────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────────────────┐
│ 2. HUB CITY SELECT (within region)                                   │
│    • Map zooms to selected region                                   │
│    • 3-6 recommended "starter" airports highlighted (green)         │
│    • Other airports available but grayed with "Advanced" label      │
│    • Each starter shows: demand level, competition, starter bonus   │
│    • Player picks ONE as home base                                  │
└───────────────────────────┬─────────────────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────────────────┐
│ 3. STARTER PROFILE (à la Airline Club)                               │
│    Three choices:                                                   │
│                                                                     │
│    🛫 "Fresh Start" (Easy)                                          │
│       • 2 starter planes (gifted)                                   │
│       • $2M cash, no debt                                           │
│       • First route pre-suggested                                   │
│       • Advisor ON by default                                       │
│                                                                     │
│    🛬 "Entrepreneur" (Medium)                                        │
│       • 1 starter plane + $3M cash                                  │
│       • Must buy/lease second plane                                 │
│       • Advisor available but optional                              │
│                                                                     │
│    ✈️ "Turnaround Specialist" (Hard)                                │
│       • 3 aging planes (high maintenance)                           │
│       • $5M cash but $2M debt                                       │
│       • Higher starting awareness                                   │
│       • Advisor OFF by default                                      │
└───────────────────────────┬─────────────────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────────────────┐
│ 4. FIRST FLIGHT (Core Loop Introduction) - ~90 seconds              │
│    • Advisor highlights your plane and an ideal first route         │
│    • "Let's get your first plane in the air!"                       │
│    • One-click to schedule (or manual if player wants)              │
│    • Watch plane take off (satisfying visual)                       │
│    • Time skip to see first revenue                                 │
│    • "Congratulations! You're an airline CEO."                      │
└───────────────────────────┬─────────────────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────────────────┐
│ 5. SOFT GOALS INTRODUCED (Not forced, but visible)                   │
│    • "Suggested Next Steps" panel appears (can dismiss)             │
│    • Goals like: "Open 3 more routes" / "Buy a second plane"        │
│    • Completing them awards small bonuses (cash, XP, cosmetics)     │
│    • Player can ignore and explore freely                           │
└─────────────────────────────────────────────────────────────────────┘
```

**Progression System (Post-FTUE):**

| Milestone | Trigger | Unlock |
|-----------|---------|--------|
| First Flight | Complete first route | Fleet management panel |
| Growing Pains | 5 routes | Competition view, pricing tools |
| Regional Player | 10 routes | Hub bonuses, larger aircraft |
| Going National | 25 routes + 2nd hub | Alliances, codeshares |
| International Ambitions | Routes to 2nd region | Long-haul aircraft, cargo |
| Major Carrier | 100 routes | Prestige features, airline ranking |

---

### Solution B: "Mission-Driven Sandbox"

**Philosophy:** Provide a loose narrative structure with optional missions that teach mechanics while allowing sandbox freedom.

**Flow:**

```
Region Select → Hub Select → "Your Story Begins" intro cutscene
                                    ↓
              ┌─────────────────────────────────────────┐
              │  MISSION BOARD (Always visible sidebar) │
              │                                         │
              │  📋 Chapter 1: "First Wings"            │
              │     ☐ Establish your first route        │
              │     ☐ Achieve $50K profit               │
              │     ☐ Buy or lease a second aircraft    │
              │     Reward: Unlock Route Planner Pro    │
              │                                         │
              │  🔒 Chapter 2: "Building Momentum"      │
              │     (Unlocks after Chapter 1)           │
              │                                         │
              │  ⏭️ [Skip Tutorial] (available anytime) │
              └─────────────────────────────────────────┘
```

**Key Features:**
- Missions are **never mandatory** (skip button always visible)
- Completing missions awards **Development Points** (à la Cities: Skylines 2)
- Development Points unlock features/aircraft/tools
- Player who skips can still unlock everything through play, just slower

**Chapter Structure:**

| Chapter | Theme | Mechanics Taught | Playtime |
|---------|-------|------------------|----------|
| 1 | First Wings | Routes, scheduling, revenue | 15 min |
| 2 | Building Momentum | Fleet expansion, pricing | 30 min |
| 3 | Competitive Skies | Competition, undercutting | 45 min |
| 4 | Network Effects | Hubs, connections | 1 hr |
| 5 | Going Global | International routes, alliances | 1.5 hr |
| ∞ | Endless | All unlocked, sandbox | Forever |

---

### Solution C: "Pure Sandbox with Contextual Tips"

**Philosophy:** Minimal hand-holding. Player learns by doing. Tips appear only when relevant.

**Flow:**

```
Region Select → Hub Select → Airline Name → DROP INTO GAME
                                                   ↓
                              ┌────────────────────────────────┐
                              │  💡 Contextual tip appears:    │
                              │  "Click your plane to assign   │
                              │   it to a route"               │
                              │                    [Got it]    │
                              └────────────────────────────────┘
                                                   ↓
                              Player explores freely
                                                   ↓
                              Tips appear based on context:
                              • First time opening fleet → fleet tip
                              • Plane sitting idle → "assign route" tip
                              • Low cash → "check pricing" tip
                              • Route unprofitable → "optimize" tip
```

**Key Features:**
- No tutorial, no missions
- **Smart tip system** detects player actions and offers help
- Tips can be permanently dismissed
- "Help" button always available for manual lookup
- **Achievements** provide soft goals (no unlock gating)

**Tip Trigger Examples:**

| Player State | Tip |
|--------------|-----|
| Plane idle > 5 minutes | "Your [Plane] is waiting for orders. Assign a route?" |
| Negative cash flow | "Your airline is losing money. Try adjusting ticket prices or cutting costs." |
| High load factor, low profit | "Your flights are full but margins are thin. Consider raising prices." |
| First route to new region | "International routes have higher potential but need longer-range aircraft." |
| Competitor enters route | "A competitor has entered your route. Check the Competition panel." |

---

## Recommended Approach: Solution A ("Guided Freedom")

**Why:**

1. **Respects player time** - Flying within 90 seconds
2. **Provides meaningful choice** - Region, hub, and profile matter
3. **Scalable difficulty** - Three profiles for different player types
4. **Non-intrusive** - Advisor can be dismissed; goals are suggestions
5. **Proven pattern** - Combines best of Airline Club (profiles) + Cities: Skylines (milestones) + Airlines Manager (guided tours)

---

## Detailed Flow: Solution A Implementation

### Screen 1: Region Select (Your Screenshot)

**UI Elements:**
- 6 region cards in 2x3 grid
- Each card shows:
  - Region name
  - Satellite-style map image
  - Difficulty indicator (1-3 planes icon)
  - Tagline (e.g., "The birthplace of aviation")

**On Hover/Select:**
```
┌─────────────────────────────────────────────────────────┐
│  EUROPE                                        ⚡⚡☆    │
│  ─────────────────────────────────────────────────────  │
│  "Dense markets, fierce competition"                   │
│                                                        │
│  ✓ Many short-haul opportunities                      │
│  ✓ High passenger demand                              │
│  ✓ Modern infrastructure                              │
│  ⚠ Established competitors (Lufthansa, AF, BA)        │
│                                                        │
│  Recommended for: Beginners seeking variety            │
│  Starter Airports: London, Paris, Amsterdam, Frankfurt │
│                                                        │
│               [ SELECT EUROPE ]                        │
└─────────────────────────────────────────────────────────┘
```

**Region Characteristics:**

| Region | Difficulty | Characteristics | Recommended For |
|--------|------------|-----------------|-----------------|
| **North America** | ⚡☆☆ | Large distances, hub-centric, familiar | True beginners |
| **Europe** | ⚡⚡☆ | Dense, competitive, many routes | Most players |
| **Orient & Asia** | ⚡⚡☆ | Growing markets, long-haul potential | Intermediate |
| **South America** | ⚡⚡⚡ | Developing markets, terrain challenges | Adventurous |
| **Africa** | ⚡⚡⚡ | Untapped potential, infrastructure limits | Challenge seekers |
| **Oceania** | ⚡⚡☆ | Island hopping, tourism focus | Niche players |

### Screen 2: Hub Selection

**After region select, zoom to regional map:**

```
┌─────────────────────────────────────────────────────────────────┐
│  Choose Your Headquarters                                       │
│  ─────────────────────────────────────────────────────────────  │
│                                                                 │
│  [Map of Europe with airports marked]                           │
│                                                                 │
│  🟢 Recommended Starters:                                       │
│     • London (LHR) - High demand, central location              │
│     • Paris (CDG) - Tourism + business mix                      │
│     • Amsterdam (AMS) - Excellent connections                   │
│     • Frankfurt (FRA) - Cargo potential                         │
│                                                                 │
│  ⚪ Other Options: (click to see more)                          │
│     Madrid, Rome, Munich, Vienna, Zurich...                     │
│                                                                 │
│  Selected: AMSTERDAM (AMS)                                      │
│  ├─ Demand: ████████░░ High                                    │
│  ├─ Competition: ████░░░░░░ Moderate                           │
│  ├─ Starter Bonus: +$200K cash                                 │
│  └─ Signature Routes: London, Paris, Frankfurt                  │
│                                                                 │
│               [ CONFIRM HEADQUARTERS ]                          │
└─────────────────────────────────────────────────────────────────┘
```

### Screen 3: Starter Profile

```
┌─────────────────────────────────────────────────────────────────┐
│  How Would You Like to Begin?                                   │
│  ─────────────────────────────────────────────────────────────  │
│                                                                 │
│  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐   │
│  │   🛫 FRESH      │ │   🛬 ENTRE-     │ │   ✈️ TURNAROUND │   │
│  │     START       │ │     PRENEUR     │ │    SPECIALIST   │   │
│  │                 │ │                 │ │                 │   │
│  │  Recommended    │ │  Balanced       │ │  Challenge      │   │
│  │  for new CEOs   │ │  start          │ │  mode           │   │
│  │                 │ │                 │ │                 │   │
│  │  • 2 planes     │ │  • 1 plane      │ │  • 3 old planes │   │
│  │  • $2M cash     │ │  • $3M cash     │ │  • $5M cash     │   │
│  │  • No debt      │ │  • No debt      │ │  • $2M debt     │   │
│  │  • Guided start │ │  • Some tips    │ │  • No hand-hold │   │
│  │                 │ │                 │ │                 │   │
│  │   [SELECT]      │ │    [SELECT]     │ │   [SELECT]      │   │
│  └─────────────────┘ └─────────────────┘ └─────────────────┘   │
│                                                                 │
│  ℹ️ All profiles can achieve the same success.                  │
│     Harder starts earn bonus reputation.                        │
└─────────────────────────────────────────────────────────────────┘
```

### Screen 4: Airline Identity

```
┌─────────────────────────────────────────────────────────────────┐
│  Name Your Airline                                              │
│  ─────────────────────────────────────────────────────────────  │
│                                                                 │
│  Airline Name: [________________________]                       │
│                                                                 │
│  CEO Name: [________________________] (optional)                │
│                                                                 │
│  Primary Color: [🔴][🟠][🟡][🟢][🔵][🟣][⚫][⚪]               │
│                                                                 │
│  Logo Style:  ◉ Classic  ○ Modern  ○ Minimal                   │
│                                                                 │
│  Preview:  [Plane livery preview]                               │
│                                                                 │
│               [ LAUNCH YOUR AIRLINE → ]                         │
└─────────────────────────────────────────────────────────────────┘
```

### Screen 5: First Flight (Core Loop)

**Game loads, camera focuses on player's plane at hub airport:**

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   [3D/2D view of airport with player's plane highlighted]       │
│                                                                 │
│   ┌───────────────────────────────────────────────────────┐    │
│   │  👋 ADVISOR: "Welcome, CEO! Let's get your first      │    │
│   │     plane in the air. I've identified a great route:  │    │
│   │                                                       │    │
│   │     Amsterdam → London                                │    │
│   │     ├─ Distance: 230 mi                               │    │
│   │     ├─ Demand: Very High                              │    │
│   │     ├─ Competition: Moderate                          │    │
│   │     └─ Est. Daily Profit: $12,000                     │    │
│   │                                                       │    │
│   │     [ OPEN THIS ROUTE ✓ ]  or  [ I'll choose myself ] │    │
│   └───────────────────────────────────────────────────────┘    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**If player accepts:**
- Route opens automatically
- Flight schedules
- Camera follows plane taxiing and taking off
- Satisfying audio/visual feedback
- Time accelerates to show first landing and revenue

**If player declines:**
- Advisor says "No problem! Click any destination on the map to see route options."
- Tutorial markers show clickable airports
- Player explores freely

### Screen 6: Post-First-Flight

```
┌─────────────────────────────────────────────────────────────────┐
│  🎉 First Flight Complete!                                      │
│  ─────────────────────────────────────────────────────────────  │
│                                                                 │
│  Your flight earned: $8,420                                     │
│  Load factor: 78%                                               │
│  Passenger rating: ★★★★☆                                       │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  📋 SUGGESTED NEXT STEPS          (dismiss with X)      │   │
│  │                                                         │   │
│  │  ☐ Open 2 more routes            Reward: $50K bonus    │   │
│  │  ☐ Achieve 85% load factor       Reward: Reputation +  │   │
│  │  ☐ Buy a second aircraft         Reward: New aircraft  │   │
│  │                                         unlocked       │   │
│  │                                                         │   │
│  │  These are optional goals to help guide your growth.    │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│               [ CONTINUE TO GAME ]                              │
└─────────────────────────────────────────────────────────────────┘
```

---

## Progression System for Endless Mode

### Milestone-Based Unlocks

Rather than time-gating or arbitrary unlocks, features unlock based on **player achievement**:

| Milestone | Requirement | Unlocks |
|-----------|-------------|---------|
| **Fledgling** | First flight completed | Basic UI, route planner |
| **Operator** | 5 routes, $100K profit | Fleet view, used aircraft market |
| **Regional** | 10 routes, 3 aircraft | Competition panel, pricing tools |
| **Established** | 25 routes, $1M cash | Second hub, larger aircraft |
| **National** | 50 routes, 2 hubs | Alliances, cargo operations |
| **International** | Routes to 2+ regions | Long-haul aircraft, codeshares |
| **Major** | 100 routes, $10M cash | Premium features, custom liveries |
| **Global** | All 6 regions served | Prestige mode, leaderboards |

### XP System (Optional Layer)

Like Cities: Skylines 2, actions generate XP:

| Action | XP |
|--------|-----|
| Open new route | 100 XP |
| Complete 100 flights | 50 XP |
| Achieve profitable month | 200 XP |
| Buy new aircraft | 150 XP |
| Open new hub | 500 XP |
| Form alliance | 300 XP |

XP accumulates toward milestones, providing an alternative path for players who don't hit specific requirements.

---

## Key Design Principles

1. **Flying in 90 seconds** - The core satisfaction of seeing your plane fly should happen almost immediately.

2. **No dead ends** - Every profile, region, and hub can succeed. No "trap" choices.

3. **Optional depth** - Advanced features exist but don't overwhelm beginners.

4. **Celebrate wins** - Every milestone gets a popup, sound, visual flourish.

5. **Fail forward** - If player goes bankrupt, offer "rescue package" (loan) rather than game over.

6. **Advisor is helpful, not annoying** - Provides suggestions, not instructions. Can be dismissed permanently.

7. **Progression feels earned** - Unlocks tied to player achievement, not arbitrary timers.

---

## Returning Player Summary

*Reference: Edge-Case Report 5 (Confused Newbie Returning)*

Players who return after an extended break (7+ days) face significant friction: they've forgotten their strategy, active obligations, pending decisions, and fleet orders. Without a recap mechanism, returning players often:
- Make decisions that contradict their previous strategy
- Miss critical pending items (expiring deals, due obligations)
- Feel lost in their own airline, leading to abandonment

### Trigger Conditions

The "Welcome Back" screen appears when:

| Condition | Threshold | Note |
|-----------|-----------|------|
| Days since last session | ≥7 days | Hypothesis — may tune to 5 or 14 based on playtesting |
| Session length before break | >30 minutes | Don't show for abandoned quick-starts |
| Game phase | Manager+ | Founders have simpler state to recall |

> **⚠️ Note:** All thresholds are hypotheses requiring playtesting.

### Welcome Back Screen

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  WELCOME BACK, CEO                                       Last played: 12d ago│
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  YOUR AIRLINE AT A GLANCE                                                   │
│  ─────────────────────────────────────────────────────────────────────────  │
│  Fleet: 23 aircraft  │  Routes: 47  │  Cash: $4.2M  │  Phase: Executive    │
│  Monthly P/L: +$312K │  Trend: ▲ Improving                                 │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│  RECENT MAJOR DECISIONS (last 30 in-game days)                              │
│  ─────────────────────────────────────────────────────────────────────────  │
│  • Opened Chicago hub (Day 847)                                             │
│  • Acquired 3x Boeing 737 MAX 8 (Day 842)                                   │
│  • Rejected merger offer from Continental (Day 839)                         │
│  • Accepted government route subsidy: Denver-Aspen (Day 836)               │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│  ACTIVE OBLIGATIONS                                          [View ledger →]│
│  ─────────────────────────────────────────────────────────────────────────  │
│  3 obligations active                                                       │
│  • Oldest: Investment group board seat (142 days dormant)                  │
│  • Most recent: Regional authority flight guarantee (12 days)              │
│  • ⚠ 1 obligation showing activity signals                                 │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│  PENDING DECISIONS                                                    [4]   │
│  ─────────────────────────────────────────────────────────────────────────  │
│  ⚠ EXPIRING SOON                                                           │
│    • Slot offer at JFK expires in 3 days                                   │
│    • Aircraft lease renewal due in 8 days (2x A320)                        │
│  ○ CAN WAIT                                                                │
│    • Crew contract negotiation (union proposal pending)                    │
│    • Alliance invitation from Star Alliance                                │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│  FLEET ORDERS IN PROGRESS                                                   │
│  ─────────────────────────────────────────────────────────────────────────  │
│  • 2x Boeing 787-9 arriving in 45 days (factory order)                     │
│  • 1x Airbus A321neo in maintenance, ready in 6 days                       │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│  YOUR NOTES                                               [Edit notes →]    │
│  ─────────────────────────────────────────────────────────────────────────  │
│  "Focus on building transatlantic presence before Q4. Watch fuel           │
│   hedging — contract expires soon. Consider selling the 757s."             │
│                                                                             │
│  Last updated: 12 days ago                                                 │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  [Jump to urgent items]    [Review full state]    [Dismiss & play]         │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Information Sections

#### 1. Airline at a Glance
Quick vital stats to orient the player:
- Fleet size, route count, cash position
- Current game phase
- Monthly profit/loss with trend indicator
- Days since last session

#### 2. Recent Major Decisions
The 3-5 most significant decisions from the last 30 in-game days:

| Decision Type | Included | Example |
|---------------|----------|---------|
| Hub operations | Open/close hub | "Opened Chicago hub" |
| Fleet changes | Purchase, sale, lease | "Acquired 3x 737 MAX" |
| Alliance/merger | Accept/reject | "Rejected Continental merger" |
| Major contracts | Government, corporate | "Accepted route subsidy" |
| Obligations created | New debts | "Accepted investment from..." |

Minor decisions (route pricing tweaks, schedule adjustments) are excluded.

#### 3. Active Obligations
Summary from the Obligations Ledger (see `compromise-system-spec.md`):
- Total count of active obligations
- Oldest obligation (may be most likely to be called soon)
- Most recent obligation
- Warning count if any show activity signals

#### 4. Pending Decisions
Decisions waiting for player input, sorted by urgency:
- **Expiring Soon** — time-sensitive items that will auto-resolve or expire
- **Can Wait** — important but not time-critical

#### 5. Fleet Orders
Aircraft in transit, on order, or in maintenance:
- Factory orders with delivery dates
- Lease deliveries
- Aircraft in maintenance with return dates

#### 6. Player Notes (Optional Feature)
Self-annotation system for strategy reminders:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  PLAYER NOTES                                                    [Save]     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ Focus on building transatlantic presence before Q4. Watch fuel      │   │
│  │ hedging — contract expires soon. Consider selling the 757s.         │   │
│  │                                                                     │   │
│  │ TODO:                                                               │   │
│  │ - Check if Paris slot becomes available                             │   │
│  │ - Renegotiate catering contract (current one is expensive)          │   │
│  │ _                                                                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Character limit: 847/1000                                                 │
│                                                                             │
│  💡 Tip: Notes appear on the Welcome Back screen when you return.          │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Player Notes Features:**
- Free-form text field (1000 character limit)
- Accessible anytime from pause menu or dashboard
- Persists with save file
- Shown prominently on Welcome Back screen
- Optional — empty notes section shows "No notes saved. Add notes to remind yourself of your strategy."

### Dismissal Behavior

| Action | Effect |
|--------|--------|
| **Dismiss & play** | Closes screen, proceeds to game |
| **Jump to urgent items** | Opens first expiring decision directly |
| **Review full state** | Opens dashboard with all panels expanded |
| **Don't show again** | Checkbox to disable Welcome Back (reversible in settings) |

Screen is always dismissible with ESC. Never blocks gameplay.

### Edge Cases

| Scenario | Handling |
|----------|----------|
| No major decisions in period | Section shows "No major decisions in last 30 days" |
| No active obligations | Section shows "No active obligations" with ✓ |
| No pending decisions | Section shows "All caught up" with ✓ |
| No player notes | Shows "Add notes to remind yourself of your strategy" |
| Very long break (30+ days) | Extended summary with era context if in-game time passed |
| Multiple sessions in one day | Only show once per calendar day |

### Integration Points

| Spec | Integration |
|------|-------------|
| `compromise-system-spec.md` | Obligation summary pulls from Obligations Ledger |
| `decision-density-spec.md` | Pending decisions count aligns with decision queue |
| `executive-delegation-spec.md` | Delegated functions shown in "at a glance" if relevant |
| `tutorial-spec.md` | First-time Welcome Back includes explanation of purpose |

---

## Appendix: Competitor Deep Dive

### Airlines Manager Approach
- **Guided tours** for each feature (fleet, routes, finances)
- **Cash rewards** for completing tutorials
- **Two modes**: PRO (real-time) and TYCOON (7x speed)
- **Works because**: Rewards learning, lets player choose pace
- **Doesn't work**: Too many popups can feel overwhelming

### Airline Club Approach
- **Three starter profiles** with different difficulty/debt
- **Hub choice** determines home country bonuses
- **Wiki/Discord** expected for learning
- **Works because**: Flexible, respects player agency
- **Doesn't work**: Too complex for true beginners

### OpenTTD Approach
- **Optional tutorial scenario** (separate from main game)
- **Tooltips** on every button
- **No progression gating** - all features available
- **Works because**: Maximum freedom, community resources
- **Doesn't work**: Steep learning curve, easy to fail early

### Cities: Skylines 2 Approach
- **Milestone system** tied to XP
- **Development Points** for choosing upgrades
- **Population/happiness** generate passive XP
- **Works because**: Clear goals, player choice in upgrades
- **Doesn't work**: Can feel arbitrary what unlocks when

---

**Document End**
