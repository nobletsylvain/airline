# Tutorial System — Detailed Specification

**Version:** 0.1  
**Date:** January 2026  
**Companion to:** Game Design Document v0.7, FTUE_Endless_Mode.md

---

## Overview

This document specifies the tutorial and learning systems in Airliner — how new players learn the game without mandatory hand-holding.

**Design Philosophy:** Respect player intelligence. Provide scaffolding, not rails. The best tutorial is one that players don't notice because it emerges naturally from good UI design and contextual guidance.

**Core Principle:** Flying in 90 seconds. Understanding in hours. Mastery in dozens of hours. Each layer should feel earned, not dumped.

---

## 1. Learning Philosophy

### 1.1 Tutorial Anti-Patterns (What We Avoid)

| Anti-Pattern | Problem | Our Alternative |
|--------------|---------|-----------------|
| **Mandatory tutorials** | Wastes expert time | All guidance skippable |
| **Click here, click there** | No understanding | Explain why, not just how |
| **Information dump** | Overwhelming | Reveal progressively |
| **Locked features** | Arbitrary gates | Soft suggestions |
| **Quiz gates** | Insulting | Learning by doing |
| **Unskippable cutscenes** | Disrespectful | All skippable |

### 1.2 Learning Modes

| Mode | Description | Target Player |
|------|-------------|---------------|
| **Zero guidance** | No advisor, no tips | Genre veterans |
| **Minimal tips** | Tooltips only | Experienced players |
| **Advisor available** | Can ask for help | Most players |
| **Guided start** | Active suggestions | Complete beginners |

---

## 2. The Advisor System

### 2.1 Advisor Concept

An in-world character (your first hire) who offers contextual advice. Not a tutorial — a resource you can use or ignore.

**Advisor characteristics:**
- Has a name and portrait (e.g., "Marie, your Operations Manager")
- Speaks in character, not as game system
- Can be dismissed permanently
- Remembers what you've been told
- Never repeats advice

### 2.2 Advisor Activation

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  💬 ADVISOR · Marie Laurent                                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  "I notice you haven't scheduled your second aircraft yet. Want me         │
│  to walk you through finding a good second route?"                         │
│                                                                             │
│  [Yes, show me] [I'll figure it out] [Don't remind me about this]         │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2.3 Advisor Triggers

| Trigger | Advisor Offers |
|---------|----------------|
| First launch | Introduction, explain "Fresh Start" profile |
| Aircraft idle >1 week | Route suggestions |
| Cash low, obvious fix | Point out high-cost area |
| Profitable but not reinvesting | Growth options |
| Approaching unlock threshold | What's coming |
| First competitor entry | Competitive response options |
| First profitable month | Celebration + next goals |

### 2.4 Advisor Intelligence

The advisor doesn't just trigger on events — they observe your play:

| Observation | Advisor Behavior |
|-------------|------------------|
| Player clicks help frequently | More proactive |
| Player dismisses advice | Less proactive |
| Player makes expert moves | Reduces suggestions |
| Player struggles with area | Offers that topic |
| Player hasn't used feature | Mentions when relevant |

---

## 3. First Session Flow

### 3.1 First 90 Seconds (Goal: First Flight)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  GAME START · Fresh Start Profile                                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  [Scene: Your small headquarters, Lyon airport in background]              │
│                                                                             │
│  Marie: "Welcome, boss. I'm Marie, your operations manager.                │
│  We've got two ATR 72s on the tarmac and a blank schedule.                 │
│  Let's get one in the air."                                                │
│                                                                             │
│  [She gestures to the route map]                                           │
│                                                                             │
│  "Lyon to Marseille is a good first route — short flight,                  │
│  steady business traffic. I've already checked demand."                    │
│                                                                             │
│  [Route card appears: LYS-MRS, 45 min, €89 avg fare, Est. profit €2.1K/wk] │
│                                                                             │
│  [Open this route] [Show me other options] [I'll pick my own]              │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

If player clicks "Open this route":

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  ROUTE OPENED · Lyon → Marseille                                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  [Flight schedule appears with F-GKXA assigned]                            │
│                                                                             │
│  Marie: "Your first flight departs tomorrow at 07:00.                      │
│  Let's see it take off."                                                   │
│                                                                             │
│  [Time advances, cutscene: ATR 72 taxiing in your livery]                  │
│  [Takeoff, brief flight, landing at Marseille]                             │
│                                                                             │
│  Marie: "Congratulations. You're officially an airline CEO.                │
│  Revenue from that flight: €4,270. Not bad for a first day."              │
│                                                                             │
│  [Continue to dashboard]                                                   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Elapsed real time: ~60-90 seconds**
**Player has:** One operating route, revenue flowing, emotional hook set

### 3.2 First 10 Minutes (Goal: Basic Loop Understood)

After first flight, player arrives at main dashboard. Advisor goes quiet unless asked or player seems stuck.

**Soft goals appear (not mandatory):**

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  SUGGESTED NEXT STEPS                                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  □ Open a second route                                                     │
│    Your second aircraft is sitting idle. Put it to work.                   │
│                                                                             │
│  □ Adjust your Lyon-Marseille schedule                                     │
│    Try adding frequency or changing times.                                 │
│                                                                             │
│  □ Check your finances                                                     │
│    See where money comes from and where it goes.                           │
│                                                                             │
│  [Dismiss panel] [Don't show suggestions]                                  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3.3 First Hour (Goal: Self-Directed Play)

By end of first hour, player should have:
- 2-4 routes operating
- Understanding of route economics
- Made at least one pricing decision
- Seen weekly financial summary
- Possibly faced first competitor move

Advisor available but not intrusive.

---

## 4. Progressive Disclosure

### 4.1 UI Complexity Levels

| Level | Visible Features | Hidden Until |
|-------|------------------|--------------|
| **Basic** | Routes, fleet, finances, schedule | Start |
| **Standard** | + Competitors, brand, crew basics | 4 routes OR 2 weeks |
| **Advanced** | + Maintenance, fuel hedging, detailed crew | 10 routes OR 1 month |
| **Expert** | + All features, raw data exports | 6 months OR manual unlock |

### 4.2 Feature Introduction

When a feature unlocks:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  ⭐ NEW CAPABILITY                                                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  MAINTENANCE PLANNING                                                       │
│                                                                             │
│  Your fleet is growing. Time to think about maintenance.                   │
│                                                                             │
│  Aircraft need regular checks to stay airworthy. The maintenance           │
│  screen helps you plan these without disrupting operations.                │
│                                                                             │
│  Your first A-check is due in 3 weeks on F-GKXA.                          │
│                                                                             │
│  [Open maintenance] [I'll look later] [Tell me more]                       │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.3 Complexity Settings

Player can adjust at any time:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  INTERFACE COMPLEXITY                                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Show me:                                                                  │
│  [ ] Basic — Core features only, simplified views                          │
│  [●] Standard — Most features, moderate detail                             │
│  [ ] Advanced — All features, full detail                                  │
│  [ ] Expert — Everything, including debug/raw data                         │
│                                                                             │
│  Auto-progression: [●] On [ ] Off                                          │
│  (Unlock features as you grow)                                             │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 5. Contextual Help

### 5.1 Tooltips

Every UI element has a tooltip. Extended tooltips appear on hover-hold (1 second):

```
[Standard tooltip - immediate]
"Passenger Load Factor"

[Extended tooltip - 1 second hold]
"Passenger Load Factor

The percentage of seats filled on this route.

Higher is generally better (more revenue), but 
very high (>90%) means you might be turning 
away passengers. Consider adding frequency.

Your target: 75-85% for most routes
This route: 82% — Healthy"
```

### 5.2 Help Panel

`?` key or help icon opens contextual help for current screen:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  HELP · Route Economics Screen                                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  This screen shows how money flows on a specific route.                    │
│                                                                             │
│  KEY CONCEPTS                                                               │
│                                                                             │
│  Revenue per Flight                                                         │
│  How much money you make when the plane flies this route.                  │
│  Affected by: ticket prices, load factor, ancillaries.                     │
│                                                                             │
│  Cost per Flight                                                            │
│  What it costs to operate: fuel, crew, landing fees, etc.                  │
│                                                                             │
│  Contribution                                                               │
│  Revenue minus costs. Positive = route makes money.                        │
│                                                                             │
│  WHAT TO DO HERE                                                            │
│  · Adjust prices to balance load and yield                                 │
│  · Change frequency to match demand                                        │
│  · Compare against competitors                                             │
│                                                                             │
│  [Got it] [Show me a walkthrough] [Ask the advisor]                        │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 5.3 Aviapedia

In-game encyclopedia for deeper learning:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  AVIAPEDIA · Yield Management                                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Yield management is the practice of adjusting prices based on            │
│  demand to maximize revenue.                                               │
│                                                                             │
│  KEY PRINCIPLES                                                             │
│                                                                             │
│  1. Segment your passengers                                                │
│     Business travelers pay more, book late.                                │
│     Leisure travelers are price-sensitive, book early.                     │
│                                                                             │
│  2. Price to fill the plane                                                │
│     An empty seat earns nothing. A cheap seat earns something.             │
│                                                                             │
│  3. Protect high-yield seats                                               │
│     Don't sell all seats cheap early. Save some for late bookers.          │
│                                                                             │
│  IN AIRLINER                                                                │
│  The pricing panel lets you set strategies that balance these factors.    │
│  Start with "Balanced" and observe results before tweaking.                │
│                                                                             │
│  SEE ALSO: Price Elasticity, Load Factor, Revenue Management               │
│                                                                             │
│  [Close] [Search Aviapedia]                                                │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 6. Failure Prevention

### 6.1 Soft Guardrails

The game warns before disastrous decisions:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  ⚠ ARE YOU SURE?                                                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  You're about to set prices 60% below competitors on this route.           │
│                                                                             │
│  This will likely:                                                         │
│  · Lose money on every flight (-€1,200 estimated)                          │
│  · Trigger a price war with SkyEuro                                        │
│  · Be difficult to reverse (customers expect low prices)                   │
│                                                                             │
│  Sometimes this is the right move. Is it intentional?                      │
│                                                                             │
│  [Yes, I want aggressive pricing] [Let me reconsider]                      │
│  [ ] Don't warn me about pricing decisions                                 │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 6.2 Recoverable Mistakes

First-time catastrophic mistakes have softer consequences:

| Mistake | First Time | Subsequent |
|---------|------------|------------|
| Bankruptcy | Government bridge loan offered | Game over |
| Price war loss | Competitor offers truce | Fight to the end |
| Grounding fleet | Emergency maintenance | Full downtime |
| Losing key route | Competitor shares slots temporarily | Permanent loss |

### 6.3 "What Went Wrong" Analysis

After negative events:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  📊 WHAT HAPPENED · Q3 Loss                                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  You lost €840K this quarter. Here's why:                                  │
│                                                                             │
│  MAIN FACTORS                                                               │
│  1. Fuel costs up 23% (you're 0% hedged)           -€420K vs plan          │
│  2. Lyon-Barcelona price war                        -€280K vs plan          │
│  3. Aircraft AOG for 3 weeks (unplanned mx)        -€140K vs plan          │
│                                                                             │
│  WHAT YOU COULD DO DIFFERENTLY                                              │
│  · Fuel hedging would have saved €280K                                     │
│  · Exiting the price war earlier saved margin                              │
│  · Better mx planning reduces surprise groundings                          │
│                                                                             │
│  This is normal. Airlines have bad quarters. The key is learning.         │
│                                                                             │
│  [View fuel hedging] [View pricing] [View maintenance] [Dismiss]           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 7. Tutorial Scenarios

### 7.1 Optional Tutorial Scenario

For players who want structured learning:

**"The Lyon Startup"** — Guided 2-hour scenario

| Chapter | Duration | Teaches |
|---------|----------|---------|
| 1. First Flight | 10 min | Route opening, basic scheduling |
| 2. Growing Pains | 20 min | Fleet expansion, pricing basics |
| 3. Competition Arrives | 20 min | Competitive response, yield |
| 4. Money Matters | 20 min | Finances, cash management |
| 5. Building the Network | 30 min | Hub thinking, connections |
| 6. Your First Crisis | 20 min | Disruption handling |

Completing tutorial unlocks cosmetic reward (livery pattern).

### 7.2 Reference Scenarios

One-page scenarios for specific learning:

| Scenario | Duration | Focus |
|----------|----------|-------|
| **Pricing Playground** | 15 min | Experiment with pricing, see results |
| **Fleet Planner** | 20 min | Aircraft selection, acquisition |
| **Hub Builder** | 30 min | Connection banking, network design |
| **Turnaround** | 30 min | Rescuing failing airline |

---

## 8. Data Model

### 8.1 Tutorial State

| Field | Type | Purpose |
|-------|------|---------|
| `advisor_enabled` | bool | Show advisor? |
| `advisor_proactivity` | enum | LOW / MEDIUM / HIGH |
| `complexity_level` | enum | BASIC / STANDARD / ADVANCED / EXPERT |
| `auto_unlock` | bool | Progress automatically? |
| `tips_seen` | string[] | Which tips shown |
| `features_unlocked` | string[] | Manually unlocked |
| `tutorial_completed` | bool | Did guided tutorial |
| `scenarios_completed` | string[] | Which scenarios done |

### 8.2 Advisor Memory

| Field | Type | Purpose |
|-------|------|---------|
| `topics_explained` | string[] | Don't repeat |
| `advice_dismissed` | string[] | Never show again |
| `player_skill_estimate` | json | Per-system assessment |
| `last_struggle_area` | string? | Where to help next |

---

## Document History

| Version | Date | Changes |
|---------|------|---------|
| 0.1 | January 2026 | Initial specification |
