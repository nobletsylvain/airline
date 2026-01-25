# Endgame Content — Detailed Specification

**Version:** 0.2  
**Date:** January 2026  
**Companion to:** GDD v0.7 Section 9, decision-density-spec.md, difficulty-curve-spec.md  
**Addresses:** gameplay-concerns.md Section 6

---

## Overview

This document specifies what keeps players engaged after 50+ hours — the "endgame loop" for Chairman-phase players who have built successful airlines and need reasons to continue playing.

**Design Philosophy:** Endgame content should feel like a *graduation*, not an *afterthought*. Players who reach Chairman phase have invested significant time; the game should reward that investment with content that feels qualitatively different from earlier phases, not just "more of the same but bigger."

**Core Problem:**
- Empire-building may plateau (nowhere left to grow)
- Delegation may remove too much player agency
- Self-imposed challenges may not be enough

> **⚠️ Note on Numbers:** All thresholds and values in this document are *hypotheses*, not validated targets. They represent design intent and require prototype testing to confirm.

---

## 1. Endgame Design Principles

### 1.1 What Works in Other Tycoons

| Game | Endgame Approach | What Works | What Fails |
|------|------------------|------------|------------|
| **Transport Tycoon** | Endless sandbox | Freedom, self-goals | No direction, can feel pointless |
| **Cities: Skylines** | Population milestones + DLC scenarios | Clear goals, variety | Milestones become trivial |
| **Planet Coaster/Zoo** | Sandbox + challenge scenarios | Creative expression | Limited management depth |
| **RimWorld** | Ship escape OR endless survival | Player-chosen goals | Escape can feel like "winning" ends game |
| **Factorio** | Rocket launch → expansion | Scaling complexity | Can become spreadsheet |
| **Game Dev Tycoon** | Hall of Fame + achievements | Completionist hooks | Short playtime limits depth |

### 1.2 Airliner Endgame Principles

1. **No "winning"** — The game doesn't end when you're successful. Chairman phase is a different game, not the conclusion.
2. **Optionality** — Multiple valid paths for different player types (builders, optimizers, collectors, competitors).
3. **Earned variety** — Historical scenarios and challenges unlock through sandbox success.
4. **Meaningful reflection** — Your airline's history matters and creates unique situations.
5. **Competitive context** — Even in sandbox, other airlines provide measuring sticks.

---

## 2. The Chairman Endgame Loop

### 2.1 Core Loop Definition

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  CHAIRMAN PHASE · Core Loop                                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│        ┌──────────────┐     ┌──────────────┐     ┌──────────────┐         │
│        │   SHAPE      │────→│   OBSERVE    │────→│   REFLECT    │         │
│        │   INDUSTRY   │     │   RIPPLES    │     │   ON LEGACY  │         │
│        └──────────────┘     └──────────────┘     └──────────────┘         │
│              ↑                                          │                  │
│              │                                          ↓                  │
│        ┌──────────────┐     ┌──────────────┐     ┌──────────────┐         │
│        │   RESPOND TO │←────│   FACE       │←────│   SET NEW    │         │
│        │   CHALLENGES │     │   SUCCESSION │     │   AMBITIONS  │         │
│        └──────────────┘     └──────────────┘     └──────────────┘         │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2.2 Chairman Mechanical Identity

Unlike earlier phases, Chairman play emphasizes:

| Founder/Manager | Executive | Chairman |
|-----------------|-----------|----------|
| Direct action | Delegation + oversight | Vision + legacy |
| Immediate feedback | Medium-term results | Long-term consequences |
| Operational decisions | Strategic decisions | Industry decisions |
| Building the airline | Optimizing the airline | Defining the airline's meaning |

### 2.3 What Chairman Players Actually Do

*Reference: decision-density-spec.md Section 3.4*

| Activity | Frequency | Player Feel |
|----------|-----------|-------------|
| Major M&A decisions | 1-2 per month (game time) | "Am I building an empire or diluting my identity?" |
| Alliance/industry politics | Ongoing | "Who are my allies, who are my rivals?" |
| Succession planning | Quarterly consideration | "Who will carry on what I built?" |
| Legacy investments | As opportunities arise | "What do I want to be remembered for?" |
| Crisis intervention | When executives fail | "I'm still the one who saves us" |
| Scenario exploration | Optional, self-directed | "What if I had done things differently?" |

---

## 3. Endgame Content Tracks

Three distinct tracks provide reasons to continue playing:

### 3.1 Track 1: Legacy & Prestige

**Player Type:** The Builder. Wants to create something lasting.

**Core Mechanic:** Legacy Score accumulates based on lasting achievements, not just current success.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  AIRLINE LEGACY · Meridian Airways                                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  LEGACY SCORE: 847 points                                                  │
│  Industry Rank: #3 globally (of 127 active airlines)                       │
│                                                                             │
│  LEGACY DIMENSIONS                                                          │
│                                                                             │
│  Pioneering         ████████░░ 82    First on 34 routes, 3 aircraft types │
│  Reliability        █████████░ 91    45-year safety record                │
│  Innovation         ███████░░░ 68    12 industry firsts                   │
│  Cultural Impact    ██████░░░░ 58    Brand recognized in 67 countries     │
│  Employee Legacy    ████████░░ 78    CEO pipeline, union relations        │
│  Passenger Loyalty  █████████░ 88    28M lifetime members                 │
│                                                                             │
│  LEGACY MILESTONES                                                          │
│  ✓ Connected 6 continents (Year 12)                                       │
│  ✓ Survived 3 industry crises                                             │
│  ✓ Groomed 2 successor CEOs                                               │
│  ☐ Hall of Fame induction (need 1000 points)                              │
│  ☐ Century carrier (100+ years operation)                                 │
│                                                                             │
│  [View full history] [Compare to rivals] [Legacy investments]              │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Legacy Score Calculation (Hypothesis):**

| Factor | Points | How Earned |
|--------|--------|------------|
| Route pioneering | 2-10 per route | First to serve a route that becomes successful |
| Safety record | 0-100 | Years without incidents × quality factor |
| Fleet innovation | 5 per type | First carrier to order new aircraft type |
| Industry influence | 1-50 | Alliance leadership, regulatory influence |
| Cultural moments | 10-50 | Historic flights, crisis responses, brand events |
| Succession success | 25-100 | Successors who perform well |
| Longevity | 1 per year | Years of continuous operation |

**Legacy Investments:**

Chairman-phase players can make decisions that cost money now but build legacy:

| Investment | Cost | Legacy Benefit |
|------------|------|----------------|
| Aviation museum sponsorship | $5-20M | +5-15 Cultural Impact |
| Pilot academy founding | $50-100M | +20-40 Employee Legacy, talent pipeline |
| Historic livery restoration | $2-5M | +3-8 Cultural Impact |
| Sustainability commitment | $100M+ | +10-30 Innovation, future-proofs brand |
| Community hub development | $20-50M | +5-15 Cultural Impact, regulatory goodwill |

### 3.2 Track 2: Industry Politics

**Player Type:** The Strategist. Wants to shape the competitive landscape.

**Core Mechanic:** Influence over industry structure, alliances, and regulations.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  INDUSTRY POSITION · Global Aviation                                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  YOUR ALLIANCE: SkyTeam                                                    │
│  Role: Founding Member, Steering Committee Chair                           │
│  Influence: ████████░░ High                                               │
│                                                                             │
│  ALLIANCE POLITICS                                                          │
│  ▸ EuroWings proposes admitting AeroMex                                   │
│    Your vote matters. AeroMex would strengthen Latin America               │
│    but competes with your SFO-Mexico routes.                              │
│    [Support] [Oppose] [Abstain] [Propose conditions]                       │
│                                                                             │
│  REGULATORY LANDSCAPE                                                       │
│  ▸ EU considering stricter emissions standards                             │
│    You can lobby for delay (saves $40M fleet updates)                      │
│    or early adoption (first-mover advantage if passed).                    │
│    Your influence: Can sway 2 of 7 key votes                              │
│    [Lobby for delay] [Advocate adoption] [Stay neutral]                    │
│                                                                             │
│  INDUSTRY BALANCE                                                           │
│  ▸ TransPac struggling financially                                         │
│    Acquisition would give you Pacific dominance                            │
│    But regulators watching — may trigger scrutiny on your network          │
│    [Explore acquisition] [Let them fail] [Support merger with rival]       │
│                                                                             │
│  RIVAL DYNAMICS                                                             │
│  SkyConnect: Aggressive expansion, leveraged          Threat level: High   │
│  GlobalAir: Conservative, profitable                  Rival level: Medium  │
│  AeroNorth: Alliance partner, occasional friction     Ally level: Good     │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Industry Influence Mechanics:**

| Lever | How It Works | Chairman Decisions |
|-------|--------------|-------------------|
| Alliance voting | Votes on new members, policies | Accept/reject airlines, shape rules |
| Regulatory lobbying | Influence pending regulations | Push for favorable rules, delay harmful ones |
| M&A positioning | Shape consolidation | Acquire, merge, or block combinations |
| Industry initiatives | Lead or undermine programs | Sustainability, safety, standards |
| Airport politics | Slot allocation influence | Support or oppose redistribution |

**Political Capital System:**

| Action | Costs Political Capital | Earns Political Capital |
|--------|------------------------|------------------------|
| Oppose alliance consensus | 10-30 | — |
| Lead industry initiative | — | 15-40 |
| Lobby against public interest | 20-50 | — |
| Compromise on disputes | — | 10-25 |
| Block rival acquisition | 30-60 | — |
| Support rival in crisis | — | 20-40 |

*Note: Political Capital storage, regeneration rate, and maximum caps to be detailed in `governance-spec.md`. This section provides the conceptual framework; implementation mechanics require further specification.*

### 3.3 Track 3: Competitive Rankings

**Player Type:** The Competitor. Wants to be the best.

**Core Mechanic:** Global rankings that compare your airline to AI competitors across multiple dimensions.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  GLOBAL AIRLINE RANKINGS · Year 47                                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  OVERALL RANKING: #3 of 127 airlines                                       │
│                                                                             │
│  CATEGORY RANKINGS                                                          │
│                                                                             │
│  By Revenue:                   By Passengers:                              │
│  1. GlobalAir      $48.2B     1. SkyConnect     142M                       │
│  2. SkyConnect     $41.7B     2. GlobalAir      128M                       │
│  3. Meridian (You) $38.9B     3. Meridian (You) 114M                       │
│                                                                             │
│  By Profitability:             By Customer Satisfaction:                   │
│  1. AeroNorth      14.2%      1. Meridian (You) 4.6/5                      │
│  2. Meridian (You) 12.8%      2. NordicAir      4.5/5                      │
│  3. TransPac        9.1%      3. AeroNorth      4.4/5                      │
│                                                                             │
│  By Network Reach:             By Fleet Modernity:                         │
│  1. GlobalAir      412 routes 1. SkyConnect     4.2 years avg              │
│  2. SkyConnect     398 routes 2. Meridian (You) 5.8 years avg              │
│  3. Meridian (You) 287 routes 3. AeroNorth      6.1 years avg              │
│                                                                             │
│  YOUR GOALS                                                                 │
│  ☐ Reach #1 in Customer Satisfaction (current: #1 ✓)                      │
│  ☐ Reach #1 in Profitability (gap: 1.4 points to AeroNorth)               │
│  ☐ Reach #1 Overall (need to overtake SkyConnect + GlobalAir)             │
│                                                                             │
│  [Set competitive targets] [Analyze rivals] [View historical trends]       │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Ranking Categories (Hypothesis):**

| Category | Metric | Why It Matters |
|----------|--------|----------------|
| Revenue | Total annual revenue | Scale measurement |
| Passengers | Annual pax count | Market reach |
| Profitability | Operating margin % | Efficiency |
| Customer satisfaction | Average rating | Service quality |
| Network reach | Unique routes | Geographic scope |
| Fleet modernity | Average aircraft age | Investment level |
| On-time performance | % flights on time | Operational excellence |
| Employee satisfaction | Internal rating | Culture health |
| Safety record | Incidents per million flights | Trust |
| Sustainability | Emissions per RPK | Future-readiness |

**Competitive Goals System:**

Players can set targets and track progress:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  SET COMPETITIVE GOAL                                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Goal: Overtake GlobalAir in Revenue                                       │
│                                                                             │
│  Current gap: $9.3B annually                                               │
│  Your growth rate: 8.2%/year                                               │
│  GlobalAir growth: 4.1%/year                                               │
│  Estimated time to overtake: 6-8 years                                     │
│                                                                             │
│  ACCELERATION OPTIONS                                                       │
│  ▸ Acquire TransPac ($12B, adds $8B revenue)          Risk: Regulatory    │
│  ▸ Enter 40 new routes aggressively                   Risk: Profitability │
│  ▸ Win SkyConnect's Asia partnership                  Risk: Alliance     │
│                                                                             │
│  [Set this goal] [Modify target] [Cancel]                                  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 4. Historical Scenarios as Endgame Variety

### 4.1 Relationship to Sandbox

Historical scenarios are **not** replacements for sandbox endgame — they're **complements**.

| Sandbox Endgame | Historical Scenarios |
|-----------------|---------------------|
| Your airline, your choices | Defined starting conditions |
| Open-ended | Victory/defeat conditions |
| Legacy accumulates | Fresh start each time |
| Chairman-phase complexity | Can start from any phase |
| Infinite playtime | 4-10 hours each |

### 4.2 Scenario Unlocks Through Sandbox Success

Reaching Chairman phase unlocks historical scenarios as rewards:

| Unlock Trigger | Scenario Unlocked |
|----------------|------------------|
| Reach Chairman phase | "Deregulation Gamble" (1978 USA) |
| First successful M&A | "Consolidation Wars" (2005 Europe) |
| 100+ routes | "Silk Road Revival" (2005 Central Asia) |
| Survive major crisis | "Post-COVID Rebuild" (2020 Global) |
| #1 ranking in any category | "Pan Am Challenge" (1970 Alternative History) |
| Legacy score 500+ | "From Scratch" (No starting advantages) |
| Complete all above | "Sandbox Grandmaster" (Permanent bonuses) |

### 4.3 Scenario Completion Benefits

Completing scenarios provides sandbox benefits:

| Scenario Completed | Sandbox Benefit |
|--------------------|-----------------|
| Deregulation Gamble (Gold) | Unlock "Low-Cost Pioneer" airline trait |
| Silk Road Revival (Gold) | Unlock "Hub Master" efficiency bonus |
| Island Empire (Gold) | Unlock "Regional Specialist" trait |
| Any scenario (Silver+) | +10 starting Legacy Score |
| All scenarios (Gold) | Unlock "Legend Mode" |

**Legend Mode (Unlocked by completing all scenarios at Gold):**
- Harder: AI competitors 20% more aggressive, random events 30% more frequent, no first-failure mercy mechanics
- More rewarding: Legacy Score gains +50%, Hall of Fame threshold reduced to 800 points, exclusive "Legendary" achievement tier
- Visual distinction: Unique UI chrome, "Legend" badge on airline profile

*Hypothesis: Legend Mode multipliers require playtesting to confirm they create appropriate challenge/reward balance.*

---

## 5. Concrete Goal Systems

### 5.1 Hall of Fame

The ultimate long-term goal: permanent recognition for exceptional airlines.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  HALL OF FAME · Aviation Legends                                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  INDUCTED AIRLINES                                                          │
│                                                                             │
│  ★ Pan American World Airways (Player, 2024)                               │
│    Legacy Score: 1,247 │ Years: 68 │ Peak rank: #1 globally                │
│    Known for: Transpacific pioneering, jet age innovation                  │
│                                                                             │
│  ★ Imperial Airways (Player, 2023)                                         │
│    Legacy Score: 1,089 │ Years: 54 │ Peak rank: #2 globally                │
│    Known for: Empire routes, flying boat era                               │
│                                                                             │
│  PENDING INDUCTION                                                          │
│                                                                             │
│  ☐ Meridian Airways (You)                                                  │
│    Current: 847 points │ Need: 1,000                                       │
│    Gap: 153 points                                                         │
│    Estimated time: 8-12 years at current pace                              │
│                                                                             │
│  INDUCTION REQUIREMENTS                                                     │
│  ✓ Reach Chairman phase                                                    │
│  ✓ Operate for 30+ years                                                   │
│  ☐ Legacy Score 1,000+                                                     │
│  ☐ Complete at least one successful succession                            │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 5.2 Achievement System

Achievements provide collection goals and rewards:

| Category | Example Achievements | Difficulty |
|----------|---------------------|------------|
| **Pioneering** | "First across the Atlantic", "Connected all continents" | Medium-Hard |
| **Survival** | "Weathered 5 crises", "50-year anniversary" | Time-based |
| **Dominance** | "#1 in 3+ categories simultaneously" | Hard |
| **Perfection** | "Zero incidents for 10 years", "100% on-time month" | Very Hard |
| **Legacy** | "Hall of Fame", "Dynasty (3 successful successions)" | Endgame |
| **Challenge** | "Turnaround master", "From nothing to #1" | Expert |
| **Collection** | "Operated every aircraft type", "Served 200 airports" | Completionist |
| **Political** | "Alliance founder", "Blocked a merger", "Changed a regulation" | Chairman |

### 5.3 Succession as Endgame Mechanic

Succession isn't just thematic — it's mechanical:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  SUCCESSION PLANNING · CEO Transition                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  You have been CEO for 42 years.                                           │
│  Board is asking about succession planning.                                │
│                                                                             │
│  CANDIDATES                                                                 │
│                                                                             │
│  Sarah Chen · COO (12 years)                                               │
│  Strengths: Operations excellence, employee loyalty                        │
│  Weaknesses: Conservative, may slow innovation                             │
│  Board opinion: Strong support │ Your relationship: Excellent              │
│  If selected: +Stability, -Growth rate                                     │
│                                                                             │
│  Marcus Webb · CCO (8 years)                                               │
│  Strengths: Commercial genius, aggressive growth                           │
│  Weaknesses: Risky bets, political enemies                                 │
│  Board opinion: Mixed │ Your relationship: Good                            │
│  If selected: +Revenue growth, -Stability, alliance risk                   │
│                                                                             │
│  External hire: Jennifer Park (ex-SkyConnect)                              │
│  Strengths: Fresh perspective, competitor knowledge                        │
│  Weaknesses: Unknown loyalty, culture clash risk                           │
│  Board opinion: Curious │ Your relationship: New                           │
│  If selected: +Innovation, -Cultural continuity                            │
│                                                                             │
│  SUCCESSION OPTIONS                                                         │
│  ▸ Groom preferred candidate (takes 2-3 years)                             │
│  ▸ Announce succession plan (stabilizes stock, limits flexibility)         │
│  ▸ Delay decision (board increasingly concerned)                           │
│  ▸ Step back to Chairman (retain influence, new CEO decides)               │
│                                                                             │
│  [Develop Sarah] [Develop Marcus] [Explore external] [Delay]               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Succession Outcomes:**

| Outcome | Effect on Your Game |
|---------|---------------------|
| Successful succession | Continue as Chairman with reduced decisions, Legacy bonus |
| Messy succession | Crisis period, possible intervention needed |
| Failed succession | Must resume CEO role OR company declines |
| Dynasty succession | Major Legacy bonus, "Dynasty" achievement |

### 5.4 What-If Mode

For players who want to explore alternatives:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  WHAT-IF EXPLORER · Meridian Airways                                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Explore alternate histories of your airline.                              │
│  These don't affect your main timeline.                                    │
│                                                                             │
│  AVAILABLE SCENARIOS                                                        │
│                                                                             │
│  ▸ "What if we had ordered 787s instead of A350s?" (Year 28)              │
│    Your actual choice: A350 fleet                                          │
│    Explore: 787 alternative timeline                                       │
│                                                                             │
│  ▸ "What if we had acquired TransPac?" (Year 34)                          │
│    Your actual choice: Let them fail                                       │
│    Explore: Integration challenge                                          │
│                                                                             │
│  ▸ "What if we had stayed independent of alliances?" (Year 15)            │
│    Your actual choice: Joined SkyTeam                                      │
│    Explore: Independent carrier path                                       │
│                                                                             │
│  These scenarios run for 10 years from the decision point.                 │
│  Compare outcomes to your actual history.                                  │
│                                                                             │
│  [Launch What-If] [Compare to main timeline]                               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 6. Preventing Endgame Plateau

### 6.1 Content Injection Schedule

Even in Chairman phase, new content emerges:

| Trigger | Content Injected |
|---------|-----------------|
| Every 5 game years | New competitor reaches major status |
| Every 10 game years | Industry technology shift |
| Random (low frequency) | Geopolitical event affecting routes |
| Legacy milestones | Reflection moments, history review |
| Succession events | Major decision points |

### 6.2 Escalating Challenges

*Reference: difficulty-curve-spec.md Section 6.4*

| Challenge Type | Chairman Manifestation |
|----------------|----------------------|
| Competition | Industry-level rivalry, not route-by-route |
| Market saturation | Only M&A or innovation opens growth |
| Operational complexity | Organization has momentum, hard to change |
| Legacy burden | Past compromises create obligations |

### 6.3 Player-Directed Goals

If the game isn't generating goals, prompt the player:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  CHAIRMAN'S AGENDA · What matters to you now?                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Your airline is stable. What would you like to focus on?                  │
│                                                                             │
│  LEGACY FOCUS                                                               │
│  ☐ Push for Hall of Fame induction (153 points to go)                     │
│  ☐ Establish pilot training academy                                        │
│  ☐ Complete the "Connected Planet" achievement (need 15 more countries)   │
│                                                                             │
│  COMPETITIVE FOCUS                                                          │
│  ☐ Overtake GlobalAir for #1 revenue                                      │
│  ☐ Achieve #1 ranking in 5 categories simultaneously                      │
│  ☐ Block SkyConnect's attempted acquisition of AeroMex                    │
│                                                                             │
│  STRATEGIC FOCUS                                                            │
│  ☐ Lead alliance restructuring                                            │
│  ☐ Prepare for CEO succession                                             │
│  ☐ Enter Africa market (underserved, high-growth)                         │
│                                                                             │
│  EXPERIMENTAL FOCUS                                                         │
│  ☐ Launch What-If scenario on 787 decision                                │
│  ☐ Start new airline in different region (New Game+)                      │
│  ☐ Try historical scenario: Pan Am Challenge                              │
│                                                                             │
│  [Set focus] [I'll decide later] [Suggest something]                       │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 7. Integration Points

### 7.1 Related Specifications

| Spec | Integration | Status |
|------|-------------|--------|
| `decision-density-spec.md` | Chairman phase decision sources | ✓ Committed |
| `difficulty-curve-spec.md` | Chairman phase challenges | ✓ Committed |
| `governance-spec.md` | Board/succession mechanics, Political Capital | 📝 Draft |
| `world-events-spec.md` | Industry events, crises | 📝 Draft |
| `ai-competitors-spec.md` | Rival airline behavior for rankings | 📝 Draft |

*Status key: ✓ Committed = in repo, 📝 Draft = exists locally but not yet committed/reviewed.*

### 7.2 Data Model Integration

Uses existing entities from `data-model.md`:

| Entity | Endgame Role |
|--------|--------------|
| `Airline.stage` | Determines phase (EMPIRE = Chairman) |
| `BrandScore.*` | Contributes to Legacy Score |
| `Alliance` / `AllianceMembership` | Industry politics track |
| `Executive` | Succession candidates |
| `FinancialPeriod` | Competitive rankings data |

### 7.3 Suggested Data Model Additions

*Suggestions pending data model review:*

```yaml
# Legacy tracking
LegacyScore:
  airline_id: FK → Airline
  dimension: enum  # PIONEERING / RELIABILITY / INNOVATION / etc.
  score: int
  last_updated: date

LegacyMilestone:
  airline_id: FK → Airline
  type: enum  # CONTINENT_CONNECTED / CRISIS_SURVIVED / etc.
  achieved_date: date
  description: string

# Competitive tracking
CompetitiveRanking:
  period: date
  category: enum  # REVENUE / PASSENGERS / PROFITABILITY / etc.
  airline_id: FK → Airline
  rank: int
  value: decimal

CompetitiveGoal:
  airline_id: FK → Airline
  target_category: enum
  target_rank: int
  set_date: date
  achieved_date: date?

# Hall of Fame
HallOfFameEntry:
  airline_id: FK → Airline
  induction_date: date
  legacy_score_at_induction: int
  notable_achievements: json
```

---

## 8. Tuning Guidelines

### 8.1 Playtest Metrics to Track

| Metric | Target Range | Too Low | Too High |
|--------|--------------|---------|----------|
| Chairman phase session length | 30-60 min | Not engaging | Too demanding |
| Time between major decisions | 10-20 min | Too busy | Boring |
| Players reaching Hall of Fame | 10-20% | Too hard | Too easy |
| Scenario completion rate | 30-50% | Too hard | Too easy |
| Succession success rate | 50-70% | Too punishing | No stakes |

### 8.2 Content Balance

| Content Type | Target % of Chairman Time |
|--------------|--------------------------|
| Legacy/Prestige activities | 25-35% |
| Industry politics | 20-30% |
| Competitive monitoring | 15-25% |
| Succession/internal | 15-20% |
| Historical scenarios | Optional, varies |

---

## Document History

| Version | Date | Changes |
|---------|------|---------|
| 0.1 | January 2026 | Initial specification |
| 0.2 | January 2026 | Added Political Capital stub note referencing governance-spec.md. Defined Legend Mode mechanics. Fixed spec status indicators. |
