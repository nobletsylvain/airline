# Airliner - Game Design Document

**Version:** 0.6  
**Date:** January 2026  
**Status:** Foundation Draft

---

## Executive Summary

Airliner is a premium PC airline tycoon game where players become CEOs of their own airline companies. Built on the open-source Airline Club project, the game emphasizes experience crafting over transportation optimization, treating aircraft as collectibles with individual histories rather than interchangeable assets.

**Core Identity:** Not a transportation optimizer. An experience-crafting game about building something you're proud of.

**The Fantasy:** Own what you could never own. Command the skies. Build a fleet with history and meaning.

---

## Table of Contents

1. [Target Audience](#1-target-audience)
2. [Market Analysis](#2-market-analysis)
3. [Core Design Pillars](#3-core-design-pillars)
4. [The Emotional Core](#4-the-emotional-core)
5. [Gameplay Loops](#5-gameplay-loops)
6. [Turn Structure](#6-turn-structure)
7. [Game Modes](#7-game-modes)
8. [Starting Positions](#8-starting-positions)
9. [Progression & Delegation](#9-progression--delegation)
10. [Ownership & Governance](#10-ownership--governance)
11. [Objectives & Ambitions](#11-objectives--ambitions)
12. [Systems Architecture](#12-systems-architecture)
13. [The Living World](#13-the-living-world)
14. [The Compromise Engine](#14-the-compromise-engine)
15. [Visual Design & UI](#15-visual-design--ui)
16. [Borrowed Mechanics](#16-borrowed-mechanics)
17. [Economic Philosophy](#17-economic-philosophy)
18. [Design Principles](#18-design-principles)

**Appendices**
- [Appendix A: Aircraft Lifecycle Example](#appendix-a-aircraft-lifecycle-example)
- [Appendix B: Tension Drivers](#appendix-b-tension-drivers)
- [Appendix C: Compromise Tracking Example](#appendix-c-compromise-tracking-example)
- [Appendix D: Historical Airlines Database](#appendix-d-historical-airlines-database)
- [Appendix E: Executive Hiring Example](#appendix-e-executive-hiring-example)
- [Appendix F: Ownership Stage Gameplay Examples](#appendix-f-ownership-stage-gameplay-examples)

**Companion Documents**
- Data Model: data-model.md (entity schemas, enumerations, validation rules, computed fields, event triggers)
- UI Mockups: ui-mockups-terminal-style.md
- FTUE Design: FTUE_Endless_Mode.md

---

## 1. Target Audience

### Primary Profile

**Management/Tycoon Enthusiasts**

- Age 25-45, skewing male
- Often professionals in business, engineering, or logistics
- Enjoy systems thinking in work and leisure
- Played Transport Tycoon, SimCity, or similar games growing up
- Spreadsheet-comfortable, often run external calculations

**Aviation Hobbyists (Subset)**

- Genuine interest in airlines, aircraft, route networks
- Read airline industry news
- Recognize aircraft types, have opinions on configurations
- Find authenticity meaningful

### What "Fun" Means to Them

| Need | Description |
|------|-------------|
| Mastery Through Understanding | Fun isn't the click—it's knowing *why* you clicked. Good outcomes should feel earned, not lucky. |
| Visible Consequence | Decisions must ripple. A route choice made Tuesday should visibly affect finances by Friday. |
| Emergent Complexity | Simple rules creating complex situations. Complexity from system interactions, not from 47 menus. |
| Ownership and Expression | "This is *my* airline." Networks should reflect strategy, not a solved optimal path. |
| Quiet Competence | Not adrenaline or spectacle. The satisfaction of a well-running machine. |

### Tolerance Thresholds

| Accept | Reject |
|--------|--------|
| Complexity if it's learnable | Complexity that's just busywork |
| Slow pacing if decisions matter | Waiting without agency |
| Failure if it's fair and teachable | Random punishment |
| Depth over polish | Shallow with pretty graphics |
| Reading and learning | Mandatory tutorials |

### Critical Insight

These players *think* they want total simulation realism. They don't. They want **plausible systems that reward smart thinking**. Realism is a tool for immersion, not an end goal. If real airline economics say "the optimal strategy is boring," deviate from realism.

---

## 2. Market Analysis

### Market Size

- **Simulation games overall:** ~$20-25 billion (2024), growing 8-15% annually
- **Tycoon/Management subset:** ~$2-4 billion (10-15% of simulation)
- **Airline-specific tycoon:** Niche within niche, estimated $50-150 million globally including mobile

The audience exists but is underserved. Most successful tycoon games sell 500K-2M copies at premium price points.

### Current Competition

| Game | Platform | Reception | Key Traits |
|------|----------|-----------|------------|
| Airline Tycoon Deluxe (1998/2003) | PC | 84% positive | Humorous, cartoony, beloved but dated |
| Airline Tycoon 2 (2011) | PC | 21% positive | Sequel that failed—lost the charm |
| Airline Manager (Trophy Games) | Mobile/PC | 71% positive | Real-time, F2P, grindy, pay-to-progress |
| Airlines Manager (Playrion) | Mobile | 15M+ downloads | Mobile-first, IATA partnership, aggressive monetization |
| Airline Club | Browser | Niche cult following | Open-source, deep simulation, steep learning curve |

### The Gap

No modern, premium, PC-focused airline tycoon combines:
- Simulation depth (like Airline Club)
- Personality and accessibility (like AT Deluxe)
- Dynamic world events
- Buy-once-play-forever model

**This is the opportunity.**

---

## 3. Core Design Pillars

### Pillar 1: Aircraft as Characters
Scarcity, provenance, biography. Planes have lives, not just stats.

### Pillar 2: Experience Over Efficiency
Cabin design, brand building, passenger perception. You're selling a feeling, not seat-miles.

### Pillar 3: Visible Empire
Network visualization, livery presence, your planes at gates. See your decisions materialized.

### Pillar 4: Space for Personal Meaning
Systems deep enough to support self-imposed challenges, emergent stories, player identity.

### Pillar 5: Earned Milestones
First international route, first widebody, flagship delivery. Ceremony over transaction.

### Pillar 6: A World That Doesn't Revolve Around You
The ecosystem exists independently. You're a participant, not the protagonist.

### Pillar 7: Evolving Role
As your airline grows, your job changes. From doing everything to leading an organization.

---

## 4. The Emotional Core

### Why Planes Are Different

- **Flight = freedom.** One of humanity's oldest fantasies.
- **Airlines = aspiration.** A billionaire fantasy—"I command the skies."
- **Aircraft = romance.** The Concorde, the 747, the A380. These machines have *fans*.

### The Two Fantasies

| Fantasy | Emotion | What Satisfies It |
|---------|---------|-------------------|
| **The Builder** | Pride in creation | Watching network grow, seeing livery everywhere |
| **The Tycoon** | Power and mastery | Making bold bets, crushing competitors, defying odds |

### Untapped Emotional Beats

- First international route
- First widebody delivery
- The flagship route
- Fleet retirement ceremony
- The livery on your planes
- The painful compromise you finally resolved

---

## 5. Gameplay Loops

### The 30-Second Loop (Moment-to-Moment)
Route management, pricing, immediate feedback.

### The 5-Minute Loop (Session Rhythm)
Network optimization, fleet decisions, competitive response.

### The 30-Minute Loop (Strategic Arc)
Major acquisitions, hub development, market events. The "one more turn" hook.

### The Meta Game (Long-Term Progression)
Empire building, reputation, legacy, competitive positioning.

### The "One More Turn" Hook

| Trigger | Example |
|---------|---------|
| Pending Deliveries | "My 737 arrives in 3 weeks—I need to decide its route" |
| Route Maturation | "Is this new route profitable yet?" |
| Financial Thresholds | "Two more good weeks until I can afford that A320" |
| Competitive Pressure | "A rival just opened a hub in my territory" |
| Unresolved Compromises | "I can finally fix that bad deal from last year" |

---

## 6. Turn Structure

### Time Model

**Continuous time with player-controlled speed + structured rhythm.**

Time flows continuously. Player controls pace. Natural stopping points create rhythm without forcing turns.

### Base Unit

**1 hour of game time = 1 second of real time** (at Normal speed)

| Speed | 1 Hour | 1 Day | 1 Week | 1 Month | 1 Year |
|-------|--------|-------|--------|---------|--------|
| **Slow** | 2s | 48s | 5.5 min | 24 min | ~5 hrs |
| **Normal** | 1s | 24s | 2.8 min | 12 min | ~2.5 hrs |
| **Fast** | 0.5s | 12s | 1.4 min | 6 min | ~1.2 hrs |
| **Ultra** | — | — | — | — | instant |

Controls: `Space` pause, `1-4` speeds or scroll wheel.

### Structured Rhythm

| Rhythm | Engagement |
|--------|------------|
| **Daily** | Background. Operations run. No mandatory engagement. |
| **Weekly** | Summary available. Pending decisions surface. Optional pause. |
| **Monthly** | Financial statements. Route performance. Recommended pause. |
| **Quarterly** | Board meetings. Earnings (if public). Significant moment. |
| **Annual** | Budget cycle. Fleet planning. Contract renewals. Major planning. |

### Interrupts

**Always interrupt (game pauses):**
- Crisis (cash, safety, labor strike)
- Board confidence critical
- Bankruptcy imminent

**Default interrupt (player can disable):**
- Aircraft delivery ready
- Competitor major move
- Acquisition opportunity
- Key staff resignation

**Optional interrupt (player enables):**
- Route turns profitable
- Weekly summary ready
- Maintenance complete

**Never interrupt:**
- Routine operations
- Normal revenue/costs
- Background market changes

### Skip-To System

"Advance to next..." options:
- Next decision point
- End of week / month / quarter
- Specific upcoming event (delivery, board meeting, route launch)
- Custom date

Game accelerates, pausing for enabled interrupts.

### Session Pacing

| Session | Real Time | Game Time (approx) |
|---------|-----------|-------------------|
| Short | 30 min | 2-3 months |
| Medium | 1-2 hrs | 6-12 months |
| Long | 3+ hrs | 1-2 years |

*Assumes ~50% time paused for decisions.*

### Map & Live Operations

The map shows flights in progress at appropriate scale for current speed. Available for immersion—not the core loop. Player is running an airline, not watching planes.

At Slow speed, a transatlantic flight visibly crosses the ocean (~8 minutes for 8-hour flight). At Normal/Fast, flights update position but aren't the focus.

---

## 7. Game Modes

### 14.1 Create Your Airline (Sandbox)
*"I'm building something that never existed."*

- Era selection (1945 to 2100+)
- Custom starting position
- Time flows forward, world evolves
- No end condition—play until you choose to stop

### 14.2 Take the Helm (Historical Takeover)
*"What if I had been running Pan Am in 1980?"*

- Select historical airline at critical moment
- Inherit actual fleet, network, finances, challenges
- Optional victory conditions
- See [Appendix D](#appendix-d-historical-airlines-database) for scenarios

### 14.3 Scenarios (Structured Challenges)
*"Give me a puzzle with clear goals."*

> **Data Model:** See `Scenario`, `ScenarioObjective`, `ScenarioEvent` entities in data-model.md

- Fixed start state and time period
- Clear objectives and constraints
- Difficulty modulation (Forgiving to Ironman)

### 12.4 Snapshot Mode (Frozen Time)
*"I just want to play without pressure."*

- Time paused at macro level
- No achievements or leaderboards
- Learning and experimentation mode

---

## 8. Starting Positions

### 12.4 Historical Airline Database
Recreations of real airlines at specific moments. See [Appendix D](#appendix-d-historical-airlines-database).

---

## 9. Progression & Delegation

### Design Philosophy

**The Core Problem:**
- Hour 1: Player manages one plane, one route. Every decision is theirs. Fun.
- Hour 100: Player manages 200 planes, 150 routes. If every decision is still theirs, they're drowning. If automated away, they're watching a screensaver.

**The Solution:** As the airline grows, the player's *role* changes. From pilot to manager to executive to chairman. The decisions change in nature, not just quantity.

---

### 14.1 The CEO Evolution

#### Phase 1: Founder (Hours 0-10)
**You are:** The person doing everything.
**Decisions:** Which route? Which plane? What price? When to fly?
**Tools:** Direct control. Simple interfaces. Immediate feedback.
**Feeling:** Scrappy, hands-on, every dollar matters.

#### Phase 2: Manager (Hours 10-30)
**You are:** Building your first team.
**Decisions:** Which markets to enter? Fleet strategy. Hiring key people.
**Tools:** First delegation options. Route managers. Basic automation.
**Feeling:** Growing pains. Can't do everything. Learning to trust systems.

#### Phase 3: Executive (Hours 30-70)
**You are:** Running a real company.
**Decisions:** Strategic direction. Capital allocation. Competitive positioning.
**Tools:** Full C-suite. Department heads. Policies instead of individual choices.
**Feeling:** Powerful but removed. Decisions ripple through layers.

#### Phase 4: Chairman (Hours 70+)
**You are:** Shaping the industry.
**Decisions:** Legacy. Succession. Industry influence. Long-term vision.
**Tools:** Board management. M&A. Political relationships. Delegation of delegation.
**Feeling:** Reflective. Your early compromises are history. What's the airline's soul?

---

### 14.2 The Delegation System

#### Delegation Levels

| Level | Name | Player Role | System Role |
|-------|------|-------------|-------------|
| 0 | **Direct Control** | Every decision | None |
| 1 | **Assisted** | Decides with recommendations | Suggests, analyzes |
| 2 | **Approval** | Reviews and approves/rejects | Proposes actions |
| 3 | **Guidelines** | Sets policies and constraints | Executes within bounds |
| 4 | **Oversight** | Reviews outcomes, intervenes rarely | Autonomous operation |
| 5 | **Trust** | Sets goals only | Full autonomy, reports results |

#### Per-System Delegation

| System | Level 0 (Manual) | Level 5 (Delegated) |
|--------|------------------|---------------------|
| Route Pricing | Set every fare manually | Revenue Management AI optimizes |
| Fleet Assignment | Assign each plane to each route | Network Planning assigns optimally |
| Maintenance | Schedule every check | VP Maintenance handles all |
| Crew Scheduling | Build every roster | Crew Planning department runs it |
| HR/Hiring | Interview every candidate | HR screens, you approve key roles |
| Finance | Approve every expense | CFO manages within budget |
| Marketing | Design every campaign | CMO executes brand strategy |

---

### 14.3 The Staff System

#### C-Suite Executives

> **Data Model:** See `Executive`, `Person`, `DelegationSetting` entities and `ExecutiveRole` enum in data-model.md

| Role | Unlocks At | Responsibility | Delegation Enables |
|------|------------|----------------|-------------------|
| **COO** | 10 aircraft | Daily operations | Fleet assignment, scheduling |
| **CFO** | $50M revenue | Financial management | Budgeting, financing, hedging |
| **CCO** | 20 routes | Commercial strategy | Pricing, revenue management |
| **CMO** | Brand score 50 | Marketing & brand | Campaigns, partnerships |
| **CTO** | 30 aircraft | Technology & systems | IT, distribution, innovation |
| **CPO** | 50 aircraft | Procurement | Vendor management, contracts |
| **CHRO** | 500 staff | Human resources | Hiring, training, labor relations |
| **CSO** | 100 routes | Strategy | Long-term planning, M&A |

#### Executive Attributes

> **Data Model:** See `Person.personality` and `Person.competencies` JSON fields

**Competence Scores:** (1-10 scale)
- Strategic thinking, Execution, Innovation
- Cost focus, Quality focus, People skills

**Personality Traits:** (0.0-1.0 scale)
- Risk tolerance, Autonomy preference
- Communication style, Loyalty

**Experience:**
- Industry background, Specialist knowledge, Network

#### Executive Actions

Executives don't just automate—they *propose*:
- "Recommend hedging 60% of next year's fuel consumption."
- "Route A underperforming. Recommend frequency reduction."

**Player response options:**
- Approve as proposed
- Modify and approve
- Reject with feedback
- Request more analysis
- Adjust executive's autonomy level

---

### 12.4 The Talent Market

See [Appendix E](#appendix-e-executive-hiring-example) for detailed hiring process.

> **Data Model:** See `RecruitmentChannel` enum in data-model.md

#### Recruitment Channels
1. **Direct Approach** - Personal contact, no fees, visible
2. **Executive Search Firms** - Discreet, expensive, broader reach
3. **Internal Promotion** - Culture fit, loyalty, may lack outside perspective
4. **Industry Networking** - Relationships built over time
5. **Opportunistic** - Bankruptcies, mergers release talent

#### Poaching & Retention
- Golden handcuffs (deferred comp)
- Career development
- Counter-offers (risky)
- Sometimes let them go

---

### 12.5 The Policy System

As you delegate, you shift from decisions to rules:

> **Data Model:** See `Policy`, `DelegationSetting` entities and `PolicyCategory`, `DelegationSystem` enums

| Instead of... | You set... |
|---------------|------------|
| "Price this flight at $299" | "Target 15% margin on leisure routes" |
| "Schedule maintenance Tuesday" | "Maintain 95% fleet availability" |
| "Hire this pilot" | "Minimum 2,000 hours, max 5% above market" |

**Policy Categories:** Commercial, Operational, Financial, HR, Brand

---

### 11.6 The Recommendation Engine

> **Data Model:** See `Alert` entity and `AlertPriority`, `AlertCategory` enums in data-model.md

The game surfaces opportunities and issues:
- **Opportunity Alerts:** "Competitor exiting Route X."
- **Problem Alerts:** "Route Z underperforming for 6 months."
- **Strategic Insights:** "Your brand perception has shifted."

**Alert Priority:** Critical → Important → Advisory → Informational

Players control filtering by category, threshold, and delegation status.

---

### 8.7 Automation Unlock Tree

> **Data Model:** See `UnlockState` entity and "Unlock Triggers" in Event Triggers section of data-model.md

| Milestone | Unlocks |
|-----------|---------|
| 5 aircraft | Basic scheduling assistant |
| 10 aircraft | COO position, fleet delegation |
| 25 routes | Revenue management system |
| $100M revenue | Full C-suite positions |
| 50 aircraft | Advanced analytics dashboard |
| 100 routes | Policy system |
| $500M revenue | Board of directors |
| 200 aircraft | AI-powered optimization suite |
| $1B revenue | Holding company structure |

---

## 10. Ownership & Governance

### Design Philosophy

**You don't choose an ownership structure—you grow into it.**

Ownership evolves naturally as your airline grows. The board doesn't block you—it advises, pressures, and reflects the reality of your scale.

**The principle:** Immersive, not realistic. Stakes without bureaucracy.

---

### 14.1 Ownership Evolution Stages

> **Data Model:** See `Airline.stage`, `Ownership`, `Investor` entities and `AirlineStage`, `InvestmentOption` enums in data-model.md

#### Stage 1: Bootstrap (1-5 Aircraft)

**What you are:** A person with a plane and a dream.

**Ownership:** You. Maybe a partner or family member.

**"Board":** Doesn't exist. Maybe your spouse asks why you're never home.

**Pressure:** Survival. Making payroll. The bank that gave you the loan.

**Feeling:** Scrappy. Personal. Every passenger matters.

**Gameplay:** 
- Simple dashboard: your planes, routes, cash
- Occasional flavor events (loan officer calls)
- No governance mechanics

---

#### Stage 2: Regional Player (5-20 Aircraft)

**What you are:** A small airline people have heard of locally.

**Ownership:** Still mostly you, but capital options appear.

**Pressure:** Growth vs. stability. First real competitors noticing you.

**Feeling:** Proving yourself. Building reputation.

**Transition Trigger:** You need capital to grow. Someone offers investment.

**Investment Options:**

| Option | Capital | Freedom | New Mechanics |
|--------|---------|---------|---------------|
| Bootstrap further | None | Full | None |
| Development fund | Low | High | Route commitment |
| Private investor | Medium | High | Quarterly updates (simple) |
| Venture capital | High | Medium | Board member, growth targets |

**If you take investment:**
- New dashboard element showing investor sentiment
- Brief quarterly conversations (30 seconds, flavor + relationship)
- Their mood affects future options

---

#### Stage 3: National Contender (20-75 Aircraft)

**What you are:** A real airline. National press covers you.

**Ownership:** Investors involved. Maybe PE. Maybe strategic partner.

**"Board":** Exists now. 3-5 people. They don't block—they *ask questions*.

**Pressure:** Profitability expectations. Growth targets. Your investors want to know the plan.

**Feeling:** Running a real company. Delegation necessary.

**Board Mechanics:**
- Board screen showing members, their focus, their sentiment
- Brief quarterly meetings (2-minute interaction)
- Board perspectives shown before major decisions
- You always decide—but you see their input

**What the Board Does:**
- Reviews results
- Asks uncomfortable questions
- Offers advice (sometimes useful)
- Connects you with their network
- Occasionally pushes back on big risks

**What the Board Doesn't Do:**
- Veto your decisions
- Require approval for operations
- Micromanage

---

#### Stage 4: Major Carrier (75-200 Aircraft)

**What you are:** One of the airlines. International routes. Real player.

**Ownership:** Likely public by now, or close to it.

**"Board":** Professional directors. Industry veterans. Investor representatives.

**Pressure:** Quarterly earnings. Analyst expectations. Stock price.

**Feeling:** Powerful but exposed. Legacy matters.

**IPO as Milestone:**
- Player-triggered, not forced
- Unlocks massive capital, adds stock price visibility
- New mechanics: earnings pressure, analyst sentiment, activist risk

**Public Company Additions:**
- Stock price on dashboard (ambient awareness)
- Analyst consensus and concerns
- Shareholder sentiment
- Occasional decisions (earnings approach, activist arrives)

---

#### Stage 5: Empire (200+ Aircraft)

**What you are:** Industry leader. Your decisions shape markets.

**Pressure:** Legacy. Succession. What happens when you're gone?

**Feeling:** Historical. You're stewarding, not just building.

---

### 14.2 Board as Advisory System

> **Data Model:** See `Board`, `BoardMember`, `BoardMeeting` entities and `BoardConfidence`, `BoardMemberRole` enums in data-model.md

#### Board Perspectives on Decisions

Before major decisions, you see board input:

```
STRATEGIC DECISION: Transatlantic Expansion
Investment required: $180M (3× 787-9)

BOARD PERSPECTIVES

SARAH CHEN (Investor Rep)
"Bold move. But are we ready?"
Confidence in plan: ████████░░

PHILIPPE MARTIN (Industry Veteran)
"Operationally complex. Do we have the bench?"
Confidence in plan: █████░░░░░

MARIE FONTAINE (Finance Expert)
"Debt ratios concern me. Lease instead?"
Confidence in plan: ████░░░░░░

OVERALL CONFIDENCE: Mixed

[Proceed] [Address concerns] [Defer] [Cancel]
```

**If you "Address concerns":** Sub-choices to modify the plan, make concessions, or provide more analysis.

**You always decide.** But informed, with relationship consequences.

---

#### Board Confidence

Not an approval gate—a relationship meter.

| Level | Effect |
|-------|--------|
| High | They defer to you. Network opens doors. |
| Medium | Healthy tension. Candid advice. |
| Low | They question openly. Less helpful. |
| Critical | Crisis territory. May push for changes. |

**What Affects Confidence:**
- Beating/missing targets
- Success/failure of major initiatives
- Taking their advice (when they're right)
- Surprising them (they hate surprises)

---

### 14.3 Stakeholder Pressure (Background System)

> **Data Model:** See `Stakeholder` entity and `StakeholderType`, `Sentiment`, `Trend` enums in data-model.md

You always see stakeholder sentiment on your dashboard:

| Stakeholder | Sentiment | Trend | Top Concern |
|-------------|-----------|-------|-------------|
| Shareholders | Content | ↑ | Growth pace |
| Creditors | Satisfied | ↑ | Debt ratios |
| Employees | Grumbling | ↓ | Pay stagnant |
| Government | Supportive | ↑ | Regional service |

**You don't "manage" these directly.** Your decisions affect them organically.

**Low Sentiment Effects:**

| Stakeholder | Effect |
|-------------|--------|
| Shareholders | Stock pressure, activist risk |
| Creditors | Higher rates, tighter terms |
| Employees | Lower morale, turnover, strike risk |
| Government | Regulatory scrutiny, fewer favors |

---

### 12.4 Ownership Transitions

#### Taking Investment (Player-Triggered)

When available and you choose to pursue:

```
GROWTH OPPORTUNITY

Altitude Partners is interested in investing $25M for 30%.

WHAT YOU GET:
· $25M capital injection
· Board seat for their partner
· Access to their network

WHAT THEY EXPECT:
· 20% annual revenue growth
· Path to liquidity in 5-7 years
· Quarterly reporting

[Accept] [Negotiate] [Decline]
```

#### Going Public (Player-Triggered)

When you qualify ($300M+ revenue, profitability):

```
IPO ASSESSMENT

Estimated valuation: $1.8 - 2.2B
Capital raised: $400-500M
Your stake after: 18-22%

WHAT CHANGES:
+ Massive capital access
+ Prestige and credibility
− Quarterly earnings pressure
− Stock price always visible
− Activist investor risk

[Begin IPO process] [Defer] [Explore alternatives]
```

#### Government Involvement (Can Be Offered)

```
MINISTRY PROPOSAL

"We'll guarantee $200M in loans and protect your slots.
In exchange: board seat, commitment to three regional routes."

[Accept] [Negotiate] [Decline]
```

---

### 12.5 Crisis Intervention (Rare)

Crisis fires only when things go **really wrong:**
- Cash < 60 days AND losses continuing
- Debt covenant breach
- Major safety incident
- Board confidence falls to "Critical"

**Crisis Event:**

```
⚠ CRISIS MODE

"The board has called an emergency session."

SITUATION:
· Cash runway: 47 days
· Covenant: BREACHED
· Stock: Down 34%

BOARD POSITION:
"We need a credible turnaround plan within 48 hours."

[Present turnaround plan]
[Request emergency capital]
[Propose asset sales]
[Seek buyer]
[Challenge the board]
```

**If you present a turnaround plan:** Build actual plan from menu of cost/revenue actions. The game doesn't auto-solve.

---

### 11.6 The Failure Spectrum

| Outcome | What Happened | Gameplay |
|---------|---------------|----------|
| **Recovery** | Crisis fixed | Triumphant return |
| **Graceful exit** | Sold the airline | Bittersweet ending |
| **Forced out** | Board replaced you | Airline continues without you |
| **Bankruptcy (restructure)** | Company survives, ownership changes | May continue |
| **Bankruptcy (liquidation)** | Airline ceases | Game over for this save |

**After dismissal, you have options:**
- Watch your successor (painful)
- Start again (harder to raise money)
- Take another CEO role (different airline)
- Retire (final score, legacy recorded)

---

## 11. Objectives & Ambitions

### Design Philosophy

Players need direction, but hate being told what to do.

**Bad:** "Tutorial: Click here to buy a plane"
**Good:** "Your investor expects 20% growth. You have 3 routes. Figure it out."

Objectives emerge from your situation—they feel like your own goals.

---

### 14.1 Three Types of Objectives

#### External Expectations (From Stakeholders)

What others want from you. Creates pressure.

| Source | Expectation |
|--------|-------------|
| Bank | Service the debt |
| Investor | Growth + returns |
| Board | Hit the plan |
| Government | Serve mandated routes |
| Employees | Job security |

#### Internal Ambitions (Your Vision)

What you want to build. Creates motivation.

> **Data Model:** See `Ambition` entity and `AmbitionCategory`, `AmbitionStatus` enums in data-model.md

| Type | Example |
|------|---------|
| Geographic | "I want to fly to New York" |
| Fleet | "I want a 787" |
| Scale | "I want to be the national carrier" |
| Identity | "I want to be the premium choice" |
| Legacy | "I want this to outlast me" |

#### Emergent Goals (From Gameplay)

What the situation demands. Creates urgency.

| Situation | Emergent Goal |
|-----------|---------------|
| Competitor enters your hub | Defend market share |
| Aircraft coming off lease | Decide: renew, return, buy |
| Delivery slot available | Commit or lose it |
| Fuel prices spike | Hedge or ride it out |

---

### 14.2 The Situation Dashboard

Not a quest log—a situation dashboard:

```
MERIDIAN AIR · Year 4

STAKEHOLDER EXPECTATIONS

ALTITUDE PARTNERS (your VC)
"20% revenue growth this year"
Progress: ████████░░░░ 16% (4 months left)
Their mood: Watching

BANQUE NATIONALE (your lender)
"Maintain 1.5x debt service coverage"
Current: 1.7x ✓
Their mood: Satisfied

────────────────────────────────────────

YOUR AMBITIONS

"Reach 25 aircraft by Year 5"
Current: 18 aircraft
Gap: 7 aircraft · On order: 2

"Launch Paris-New York by Year 6"
Requirements: Widebody, slots, capital
Status: Not yet ready

────────────────────────────────────────

PRESSING MATTERS

⚡ Air France announced Lyon hub expansion
   Your routes at risk · Response needed

📋 Lease on F-GKXA expires in 8 weeks
   Renew, return, or buy?

📬 Boeing offering early delivery slot
   737 MAX 8 · $52M · Commit by Friday
```

---

### 14.3 Setting Your Ambitions

At key moments, the game asks what you're aiming for.

**After First Profitable Year:**

```
MILESTONE: First Profitable Year

You've proven you can make money. What's next?

FLEET AMBITION
○ Stay small (under 10 aircraft)
● Grow to regional scale (25 aircraft)
○ Build a national fleet (75+ aircraft)
○ I don't want to commit yet

GEOGRAPHIC AMBITION
○ Master my home region
● Expand nationally
○ Go international
○ I'll see where opportunities lead

POSITIONING AMBITION
○ Lowest cost operator
○ Best value for money
● Premium experience
○ I want flexibility to adapt

*These aren't commitments—they're aspirations.*
*The game tracks them, but you can change your mind.*
```

**Why this works:**
- Player ownership (you chose these)
- Guidance without rails
- Flexibility to change
- Roleplay depth (your airline has a *vision*)

---

### 12.4 Objective Evolution by Stage

#### Stage 1: Bootstrap
**Dominant:** Survival
- Make payroll
- Keep load factors above breakeven
- Service the loan
- Don't crash (literally and figuratively)

#### Stage 2: Regional Player
**Dominant:** Growth + Prove Yourself
- Hit investor's revenue target
- Expand routes and fleet
- Build regional reputation
- Show you can manage complexity

#### Stage 3: National Contender
**Dominant:** Scale + Identity
- Reach fleet targets
- Enter new markets
- What kind of airline are you?
- Prepare for IPO (if desired)

#### Stage 4: Major Carrier
**Dominant:** Position + Legacy
- Compete with majors
- Defend your hubs
- Alliance strategy
- What survives when you leave?

---

### 12.5 Objective Conversations

At key moments, the game has brief conversations about your goals.

**Investor Conversation:**

```
QUARTERLY CALL: ALTITUDE PARTNERS

Sarah Chen reviews the numbers, then asks:

"We invested in you to grow a national carrier.
Are you still committed to that?"

[Reaffirm] "Absolutely. The plan is on track."
→ She'll hold you to it.

[Adjust] "Regional dominance is more realistic."
→ She'll push back, may accept. Expectations shift.

[Defer] "I'm still assessing. Give me another quarter."
→ Slightly frustrated. Uncertainty costs trust.
```

**Board Conversation:**

```
ANNUAL STRATEGY SESSION

Philippe Martin raises a question:

"Five years ago, you said premium. But load factors
suggest passengers see you as mid-market. Still premium?"

[Recommit] "Yes. We're investing in product."
→ Board expects follow-through.

[Pivot] "The market has spoken. We're repositioning."
→ Some concern, but honest.

[Hybrid] "Premium international, value domestic."
→ Complexity. Can you execute two identities?
```

---

### 11.6 Consistency and Pivots

The game quietly tracks whether you're building what you said you'd build.

**High Consistency:**
- Stakeholders trust you
- Brand is clear to passengers
- Decisions compound

**Low Consistency:**
- Stakeholders question you
- Brand is muddled
- Decisions feel random

**The Pivot Moment:**

If your actions diverge from stated ambitions:

```
STRATEGIC PIVOT DETECTED

You've been building a premium regional carrier.
Recent decisions suggest budget national expansion.

This is fine—strategies evolve.
But stakeholders will need to understand.

[Announce the pivot] Board meeting to explain
[Stay the course] Recommit to premium regional
[Let it evolve] No announcement, gradual shift
```

---

### 11.7 Roleplay Through Objectives

Different player archetypes naturally emerge:

| Archetype | Plays For | Objective Style |
|-----------|-----------|-----------------|
| **The Visionary** | The dream | "First Asian route by Year 10" |
| **The Opportunist** | Adaptation | "I'll see where it leads" |
| **The Operator** | Excellence | "Best OTP in the industry" |
| **The Legacy Builder** | Permanence | "An airline for 100 years" |

The objective system supports all of them.

---

## 12. Systems Architecture

### The Core Triangle

```
FLEET ←――→ NETWORK ←――→ BRAND
  ↑           ↑           ↑
  └――――――― MONEY ―――――――┘
```

---

### 14.1 Fleet Systems

> **Data Model:** See `Aircraft`, `AircraftType`, `AircraftConfiguration`, `MaintenanceEvent`, `MaintenanceSchedule`, `Order`, `Lease` entities

**Acquisition Channels:** New order, slot purchase, lessor, secondary market, auction

**Aircraft Biography:** Serial number, age, hours, operator history, incidents, your chapter

**Configuration:** Cabin layout, onboard product, exterior livery

**Maintenance:** Line, A/C/D checks, engine overhauls. In-house vs. outsourced decisions.

---

### 14.2 Network Systems

> **Data Model:** See `Route`, `Schedule`, `Flight`, `Airport`, `Slot`, `DemandSnapshot` entities

**Route Economics:** Demand model, yield management, competition effects

**Airport Relationships:** Slots, gates, lounges, hubs

**Schedule Building:** Frequency, timing, rotation, crew legality

---

### 14.3 Brand Systems

> **Data Model:** See `Brand`, `PassengerSegment` entities in data-model.md

**Reputation Dimensions:** Reliability, Comfort, Service, Value, Prestige

**Passenger Segments:** Business, Leisure, Premium—each values different things

---

### 12.4 Money Systems

> **Data Model:** See `FinancialStatement`, `Loan`, `FuelHedge`, `AncillaryProduct`, `CargoContract` entities in data-model.md

**Revenue:** Tickets, ancillaries, cargo, loyalty, wet lease

**Costs:** Aircraft, fuel, crew, maintenance, airports, overhead

**Financial Tools:** Debt, equity, hedging, leasing, sale-leaseback

---

### 12.5 Event Systems

> **Data Model:** See `WorldEvent`, `EconomicCycle` entities, `WorldEventType` enum, and "Event Triggers" section in data-model.md

| Type | Predictability |
|------|----------------|
| Seasonal | Known |
| Economic cycles | Partial |
| Competitor moves | Observable |
| Disruptions | Random |
| Opportunities | Random |

---

## 13. The Living World

### Design Philosophy

The player is not the protagonist. The world exists independently.

**The test:** If you do nothing for a year, the world should change without you.

---

### 14.1 Industry Actors

> **Data Model:** See `Airline`, `AIStrategy`, `Manufacturer`, `Lessor` entities in data-model.md

**Airlines:** Legacy, LCC, regional, cargo, state-owned, startups—each with interests and behaviors.

**Manufacturers:** Boeing, Airbus, Embraer, COMAC—production limits, backlogs, relationships.

**Lessors:** Portfolio optimization, will repossess for better tenants.

---

### 14.2 Supporting Ecosystem

**Airports:** Varying interests (throughput, flag carrier protection, revenue)

> **Data Model:** See `RegulatoryBody`, `Regulation`, `BilateralAgreement`, `MROProvider`, `CrewPool`, `Union` entities in data-model.md

**Service Providers:** Seat manufacturers, IFE, caterers, MRO

**Human Capital:** Pilot market, training organizations, unions

**Regulatory:** Aviation authorities, transport ministries, competition authorities

---

### 14.3 Implementation Principles

- Simulate the ecosystem, not just competition
- Information asymmetry
- Relationship memory
- Named characters with lifecycles
- The player is not special

---

## 14. The Compromise Engine

### Design Philosophy

Progress is not linear. The path to your vision runs through decisions you wouldn't make in an ideal world.

---

### 14.1 Compromise Categories

> **Data Model:** See `Compromise` entity and `CompromiseCategory`, `CompromiseStatus` enums in data-model.md

**Resource:** Can't afford what you need
**Timing:** Right thing isn't available when needed
**Relationship:** Getting requires giving
**Identity:** Becoming something unintended
**Ethical:** Right thing vs. profitable thing

---

### 14.2 The Compromise Lifecycle

```
CRISIS → FORCED CHOICE → LIVING WITH IT → 
RESOLUTION POSSIBILITY → REDEMPTION OR ACCEPTANCE
```

---

### 14.3 Compromise Visibility

- Fleet pages show "acquired under duress"
- Route history notes "launched against plan"
- Timeline view of major decisions

---

### 14.4 Emotional Payoffs

- The Recovery
- The Unexpected Win
- The Principled Stand
- The Lingering Regret
- The Full Circle

---

## 15. Visual Design & UI

### Style: Terminal Dashboard (TUI)

A deliberately text-forward, data-dense aesthetic evoking Bloomberg terminals, airline operations systems (SABRE, Amadeus), and command-line interfaces.

**Why this works:**
- Serious tone (you're running a business)
- Information density (respects player intelligence)
- Timeless (won't look dated)
- Era-flexible (works for 1958 and 2025)
- Distinct (nothing else in tycoon space looks like this)

**Core elements:** Monospace font, muted color palette, box-drawing borders, block-character progress bars, minimal icons.

*See companion document: ui-mockups-terminal-style.md for detailed screen mockups, color palettes, typography, and interaction patterns.*

---

## 16. Borrowed Mechanics

| Source | Element | Implementation |
|--------|---------|----------------|
| Transport Tycoon | Network visualization | Animated flows |
| Factorio | Optimization itch | Visible inefficiency |
| Two Point Hospital | Personality | Quirky passengers |
| Rimworld | Emergent stories | Cascading events |
| Football Manager | Asset attachment | Named aircraft histories |
| Football Manager | Delegation | Staff system, policies |
| Football Manager | Accountability | Board expectations, job security |
| Crusader Kings | Character system | Executive personalities |
| Crusader Kings | Compromise narrative | Conflicting interests |
| Stardew Valley | Gentle onramp | Depth reveals itself |

---

## 17. Economic Philosophy

### The Problem with Realism

Real airline economics: $150M+ widebodies, 15-year financing, 2% margins. Realistic but not fun.

### The Solution

Compress timelines, amplify volatility, preserve the *feeling* of investment.

| Real World | Game World |
|------------|------------|
| 3-5 year delivery | Weeks/months |
| 15-year financing | Faster payback |
| 2% margins | Higher, more volatile |

---

## 18. Design Principles

### Player-Generated Meaning
Systems with texture create self-imposed quests.

### Scaffolding Without Mandating
Structure for those who want it, sandbox for those who don't.

### Emergent Storytelling
Systems collide to create stories.

### Non-Linear Progression
Downturns are part of the story.

### Depth Without Gatekeeping
Complexity available but not required.

### Evolving Engagement
The game changes as you grow. Hour 100 is different from hour 1—but equally engaging.

### Stakes Without Bureaucracy
Feel accountable without managing approval workflows.

### Objectives as Guidance
External pressure + internal ambition + emergent situations = always knowing what you're working toward.

---

## Appendix A: Aircraft Lifecycle Example

> **Data Model:** This biography is stored in `AircraftHistoryEntry` records. See `AircraftHistoryEventType` enum for event types.

```
N782UA - Boeing 777-200

2004: Delivered new to United Airlines
2004-2018: Pacific routes, 45,000 hours
2018: Sold to [Player]—COMPROMISE (wanted 787, no slots)
2018-2019: Refit, $4.2M
2019-2025: Flagship JFK-LHR
2025: Replaced by 787—REDEMPTION
2025: Sold to Ethiopian Airlines
2028: Converted to freighter
2035: Retired, scrapped in Mojave
```

---

## Appendix B: Tension Drivers

| Tension | Description |
|---------|-------------|
| Cash vs Growth | Expand or build reserves? |
| Efficiency vs Coverage | Optimal routes or market presence? |
| Own vs Lease | Pride or flexibility? |
| Premium vs Budget | Margins or volume? |
| Principle vs Pragmatism | Beliefs or results? |
| Now vs Eventually | Compromise today, redeem tomorrow? |

---

## Appendix C: Compromise Tracking Example

> **Data Model:** Stored in `Compromise` entity with `CompromiseStatus` tracking resolution.

| Date | Decision | Wanted | Got | Status |
|------|----------|--------|-----|--------|
| 2019 | Fleet | 787-9 | Leased A330 | RESOLVED 2025 |
| 2020 | Financing | Reserves | Sale-leaseback | ONGOING |
| 2021 | Slots | Full schedule | Reduced, owe favor | CARRYING |
| 2022 | Alliance | Equal terms | Junior partner | ACCEPTED |

---

## Appendix D: Historical Airlines Database

*See separate document: appendix-d-historical-airlines.md*

Featured scenarios: Pan Am (1980), TWA (1985), Eastern (1989), People Express (1984), Braniff (1978), British Caledonian (1986), Swissair (2001), Alitalia (2008), Japan Airlines (2010), and more.

---

## Appendix E: Executive Hiring Example

### Scenario: Hiring a CCO

**Step 1: Define Need** - LCC pricing experience, $350-450K budget

**Step 2: Engage Headhunter** - Aviation specialist, $50K retainer

**Step 3: Review Candidates**

| Candidate | Background | Notes |
|-----------|-----------|-------|
| A | CCO at competitor | Why leaving? Non-compete issues |
| B | VP Revenue at LCC | Star performer, never been CCO |
| C | Aviation consultant | Strategic, no ops experience |

**Step 4: Assessment** - References reveal B is being held back

**Step 5: Decision** - Choose B, offer $400K + 50% bonus

**Step 6: Negotiation** - Counter-offer from current employer, add equity to close

**Step 7: Outcome** - B performing well. COO resents new title—next challenge.

---

## Appendix F: Ownership Stage Gameplay Examples

### Bootstrap Stage Dashboard

```
┌─────────────────────────────────────────────────────────┐
│  MERIDIAN AIR                        Cash: $847,000     │
│  Regional Carrier · Founded 2025                        │
├─────────────────────────────────────────────────────────┤
│  YOUR FLEET          YOUR ROUTES         THIS WEEK      │
│  ✈ ATR 72-600       Lyon → Marseille    Flights: 28    │
│  ✈ ATR 72-600       Lyon → Bordeaux     Pax: 1,847     │
│                                                         │
│  BANK LOAN                                              │
│  $2.1M remaining · $47K/month · Covenants: OK          │
└─────────────────────────────────────────────────────────┘
```

### National Contender Board Screen

```
┌─────────────────────────────────────────────────────────┐
│  BOARD OF DIRECTORS                                     │
├─────────────────────────────────────────────────────────┤
│  YOU · CEO & Chair · 35%                                │
│  ▓▓▓▓▓▓▓▓▓▓ Confidence: Strong                         │
│                                                         │
│  SARAH CHEN · Altitude Partners · 25%                   │
│  ▓▓▓▓▓▓▓▓░░ Confidence: Good                           │
│  Focus: Growth, exit timeline                           │
│                                                         │
│  PHILIPPE MARTIN · Independent                          │
│  ▓▓▓▓▓▓▓▓▓░ Confidence: Strong                         │
│  Focus: Operations, safety                              │
│  "Your OTP is slipping. Watch it."                      │
│                                                         │
│  OVERALL: ▓▓▓▓▓▓▓▓░░ Good                              │
│  Next meeting: 6 weeks                                  │
└─────────────────────────────────────────────────────────┘
```

### Public Company Dashboard Addition

```
┌─────────────────────────────────────────────────────────┐
│  MERIDIAN AIR · NYSE: MAIR                              │
│  Stock: $34.72 ▲ +2.3%    Market cap: $2.1B            │
├─────────────────────────────────────────────────────────┤
│  ANALYST CONSENSUS: ████████░░ BUY                     │
│  Concerns: Fuel exposure, Atlantic competition          │
│                                                         │
│  NEXT EARNINGS: 4 weeks                                 │
│  Consensus: $0.42 EPS                                   │
│  Your trajectory: $0.38 EPS (miss likely)               │
└─────────────────────────────────────────────────────────┘
```

### Crisis Screen

```
┌─────────────────────────────────────────────────────────┐
│  ⚠ CRISIS MODE                                          │
├─────────────────────────────────────────────────────────┤
│  SITUATION                                              │
│  · Cash runway: 47 days                                 │
│  · Covenant: BREACHED                                   │
│  · Stock: Down 34%                                      │
│                                                         │
│  BOARD: "Credible plan within 48 hours."                │
│                                                         │
│  [Present turnaround plan]                              │
│  [Request emergency capital]                            │
│  [Propose asset sales]                                  │
│  [Seek buyer]                                           │
│  [Challenge the board]                                  │
└─────────────────────────────────────────────────────────┘
```

---

## Document History

| Version | Date | Changes |
|---------|------|---------|
| 0.1 | January 2026 | Foundation draft |
| 0.2 | January 2026 | Living World, Compromise Engine |
| 0.3 | January 2026 | Game Modes, Starting Positions, Historical Airlines |
| 0.4 | January 2026 | Progression & Delegation, Staff & Talent Market |
| 0.5 | January 2026 | Ownership & Governance, Objectives & Ambitions, gameplay examples |
| 0.5.1 | January 2026 | Visual Design & UI section, Terminal Dashboard style reference |
| 0.5.2 | January 2026 | Turn Structure section (time model, speeds, rhythm, interrupts) |
| 0.6 | January 2026 | Added data-model.md cross-references throughout; added FTUE companion doc |

---

*This is a living document. Update as design evolves.*
