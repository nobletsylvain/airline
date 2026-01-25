# Airliner - Game Design Document

**Version:** 0.7  
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

*Core References*
- Data Model: data-model.md + data-model-addendum.md (entity schemas, enumerations, validation rules)
- Art Bible: art-bible.md (visual language, UI components, audio direction)
- UI Mockups: ui-mockups-terminal-style.md
- FTUE Design: FTUE_Endless_Mode.md
- Economic Parameters: economic-parameters.md (era-specific pricing, costs, calibration)
- Historical Airlines: historical-airlines-database.md (scenario seed data)

*System Specifications*
- Cabin Designer: cabin-designer-spec.md (layout tool, seat configuration)
- Service & Suppliers: service-suppliers-spec.md (contracts, service profiles, amenities)
- Network Scheduler: network-scheduler-spec.md (Gantt view, slots, conflict detection)
- Route Economics: route-economics-spec.md (demand model, pricing, competition, ancillary, cargo)
- Financial Model: financial-model-spec.md (P&L, cash flow, financing, fuel hedging)
- Fleet & Market: fleet-market-spec.md (acquisition, leasing, used market, manufacturer relations)
- Maintenance: maintenance-spec.md (checks, MRO, reliability)
- Crew Management: crew-management-spec.md (hiring, rostering, unions)
- AI Competitors: ai-competitors-spec.md (behavior, rivalry, alliances, codeshares)
- Brand & Marketing: brand-marketing-spec.md (reputation, campaigns, loyalty)
- Governance: governance-spec.md (ownership, investors, board)
- Executive & Delegation: executive-delegation-spec.md (C-suite, delegation levels, policies)
- Living Flight: living-flight-spec.md (cabin simulation, passenger moods, service phases)
- World Events: world-events-spec.md (economic cycles, disruptions, opportunities)
- Tutorial: tutorial-spec.md (advisor system, progressive disclosure, learning)

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

**Mechanical weight:** Aircraft history translates to gameplay modifiers. High-cycle veterans gain reliability buffs from familiarity. Famous provenance ("Flew the Pope") adds passenger appeal. Visual wear reflects service life.

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

### 7.1 Create Your Airline (Sandbox)
*"I'm building something that never existed."*

> **Data Model:** See `Scenario`, `ScenarioObjective`, `ScenarioEvent` entities in data-model.md

- Choose starting region, era, and difficulty
- Full freedom to define strategy
- Optional self-set objectives

### 7.2 Historical Campaigns
*"I'm rewriting history."*

- Fixed start state and time period
- Clear objectives and constraints
- Difficulty modulation (Forgiving to Ironman)

### 7.3 Snapshot Mode (Frozen Time)
*"I just want to play without pressure."*

- Time paused at macro level
- No achievements or leaderboards
- Learning and experimentation mode

---

## 8. Starting Positions

### Historical Airline Database
Recreations of real airlines at specific moments. See [Appendix D](#appendix-d-historical-airlines-database).

---

## 9. Progression & Delegation

### Design Philosophy

**The Core Problem:**
- Hour 1: Player manages one plane, one route. Every decision is theirs. Fun.
- Hour 100: Player manages 200 planes, 150 routes. If every decision is still theirs, they're drowning. If automated away, they're watching a screensaver.

**The Solution:** As the airline grows, the player's *role* changes. From pilot to manager to executive to chairman. The decisions change in nature, not just quantity.

---

### 9.1 The CEO Evolution

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

### 9.2 Delegation System

> **Data Model:** See `Executive`, `Department`, `Policy`, `DelegationRule` entities in data-model.md

**Delegation Spectrum:**
- Direct control (player decides everything)
- Approval required (staff recommends, player approves)
- Guidelines (staff operates within player-set parameters)
- Full autonomy (staff decides, player informed)

**Executive Quality Matters:**
- Good executives: handle tasks well, make smart decisions, sometimes suggest better approaches
- Average executives: handle tasks adequately, occasional mistakes
- Poor executives: require intervention, miss opportunities, create problems

---

### 9.3 The Staff System

> **Data Model:** See `CrewPool`, `KeyCrewMember` entities in crew-management-spec.md and `Executive` entity in executive-delegation-spec.md
>
> **Design Decision:** Crew tracked as aggregate pools for scalability. Named key crew (chief pilots, union reps) appear in narrative events. Executives tracked individually.

**C-Suite Roles:**
- COO: Operations, OTP, turnaround
- CFO: Financial planning, hedging, investor relations
- CCO: Revenue, pricing, marketing
- CTO: Fleet, maintenance, IT

**Hiring:**
- Headhunters for executives
- Internal promotion paths
- Competitor poaching (with consequences)
- Industry reputation affects who's available

---

## 10. Ownership & Governance

### Design Philosophy

The player doesn't just *run* an airline—they *own* it. Or partly own it. Or used to own it.

Ownership is not static. It's a negotiated, evolving relationship.

---

### 10.1 Ownership Evolution

> **Data Model:** See `OwnershipStake`, `Investor`, `ShareholderType` entities in data-model.md

| Stage | Typical Ownership | Dynamics |
|-------|-------------------|----------|
| **Bootstrap** | 100% founder | Total control, limited capital |
| **Angel/Seed** | 60-80% founder | First outside voices |
| **Growth** | 30-50% founder | Board matters, investor expectations |
| **Public** | 5-20% founder | Market pressure, analyst coverage |
| **Mature** | Variable | Activist risk, M&A target |

---

### 10.2 The Board

> **Data Model:** See `BoardMember`, `BoardMeeting`, `BoardVote` entities in data-model.md

The board isn't decoration. They have power.

**Board Composition Evolves:**
- Bootstrap: No board (just you)
- Angel: Advisory board (non-binding)
- Growth: Real board (investor seats, independents)
- Public: Full governance (audit committee, compensation committee)

**What the Board Does:**
- Approves major decisions (above threshold)
- Sets CEO compensation
- Evaluates CEO performance
- Can fire the CEO (you)

**Managing the Board:**
- Building relationships with individual directors
- Managing information flow
- Lobbying before votes
- Knowing when to push vs. defer

---

### 10.3 Stakeholder Pressure (Background System)

> **Data Model:** See `Stakeholder` entity and `StakeholderType`, `Sentiment`, `Trend` enums in data-model.md

You always see stakeholder sentiment on your dashboard:

| Stakeholder | Sentiment | Trend | Top Concern |
|-------------|-----------|-------|-------------|
| Shareholders | Content | ↑ | Growth pace |
| Creditors | Satisfied | → | Debt ratios |
| Employees | Grumbling | ↓ | Pay stagnant |
| Government | Supportive | → | Regional service |

**You don't "manage" these directly.** Your decisions affect them organically.

**Low Sentiment Effects:**

| Stakeholder | Effect |
|-------------|--------|
| Shareholders | Stock pressure, activist risk |
| Creditors | Higher rates, tighter terms |
| Employees | Lower morale, turnover, strike risk |
| Government | Regulatory scrutiny, fewer favors |

---

### 10.4 Ownership Transitions

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

### 10.5 Crisis Intervention (Rare)

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

### 10.6 The Failure Spectrum

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

### 11.1 Three Types of Objectives

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

### 11.2 The Situation Dashboard

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

### 11.3 Setting Your Ambitions

At key moments, the game asks what you're aiming for.

**After First Profitable Year:**

```
MILESTONE: First Profitable Year

You've proven you can make money. What's next?

CHOOSE AN AMBITION:

[Scale] "I want to be bigger"
→ 50% revenue growth in 2 years

[Reach] "I want to go farther"
→ Launch first international route

[Quality] "I want to be better"
→ Top-tier passenger ratings

[Independence] "I want to stay free"
→ No outside investment for 3 years

[Custom] Define your own goal
```

**Your chosen ambition becomes a visible commitment.** You can change it, but pivots have consequences.

---

### 11.4 Stakeholder Conflict

Sometimes ambitions conflict with expectations:

```
TENSION DETECTED

Your ambition: "Premium service focus"
Investor expectation: "20% revenue growth"

These may conflict. Premium positioning often means
slower growth but higher margins.

OPTIONS:
[Educate] Explain your strategy to investors
[Pivot] Adjust ambition to match expectations
[Ignore] Hope the numbers work out
[Confront] Push back on investor expectations
```

---

### 11.5 The Identity Question

At certain scales, the game asks directly:

```
STRATEGIC CROSSROADS

Your airline has grown beyond regional status.
Passengers are confused about what you stand for.

WHAT ARE YOU?

[Premium] "We're the choice for discerning travelers"
→ Higher fares, better product, selective routes

[Value] "We make flying accessible"
→ Lower fares, efficient product, high volume

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
FLEET ←——→ NETWORK ←——→ BRAND
  ↑           ↑           ↑
  └———————— MONEY ————————┘
```

---

### 12.1 Fleet Systems

> **Data Model:** See `Aircraft`, `AircraftType`, `AircraftConfiguration`, `MaintenanceEvent`, `MaintenanceSchedule`, `Order`, `Lease` entities

**Acquisition Channels:** New order, slot purchase, lessor, secondary market, auction

**Aircraft Biography:** Serial number, age, hours, operator history, incidents, your chapter

**Configuration:** Cabin layout, onboard product, exterior livery

**Maintenance:** Line, A/C/D checks, engine overhauls. In-house vs. outsourced decisions.

#### Aircraft Prestige System

> **Data Model:** See `AircraftPrestige`, `PrestigeEvent` entities in data-model.md

Aircraft accumulate prestige through their operational history. This is the mechanical weight behind "Aircraft as Characters."

**Prestige Sources:**

| Event | Prestige Impact | Gameplay Effect |
|-------|-----------------|-----------------|
| High cycle count (10k+) | +Reliability | Crew knows this bird |
| Notable passenger (VIP, head of state) | +Appeal | "Flew the Pope" badge |
| Incident survived | +Character | Story value, slight appeal penalty |
| Anniversary milestone | +Nostalgia | Marketing opportunities |
| Flagship route service | +Prestige | Brand association |
| Retirement ceremony | +Legacy | Affects successor aircraft morale |

**Prestige Effects:**
- Reliability modifiers (experienced airframes run smoother)
- Passenger appeal (history sells tickets on premium routes)
- Marketing value (anniversary campaigns, commemorative flights)
- Crew assignment preferences (pilots request familiar aircraft)

---

### 12.2 Network Systems

> **Data Model:** See `Route`, `Schedule`, `Flight`, `Airport`, `Slot`, `DemandSnapshot` entities
> **Companion Document:** See network-scheduler-spec.md for scheduling interface details

**Route Economics:** Demand model, yield management, competition effects

**Airport Relationships:** Slots, gates, lounges, hubs

**Schedule Building:** Frequency, timing, rotation, crew legality

**Network Scheduler:** Visual Gantt-style interface for aircraft assignment, maintenance windows, and conflict detection. Gaps represent wasted money; overlaps are operational failures.

---

### 12.3 Brand Systems

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

### 12.6 Service & Suppliers

> **Companion Document:** See service-suppliers-spec.md for detailed specifications
> **Data Model:** See `SupplierContract`, `Supplier`, `ServiceProfile`, `ServiceAssignment`, `RouteServiceOverride` entities

The onboard experience is defined by supplier contracts and service profiles.

#### Supplier Categories

| Category | Commitment | Impact |
|----------|------------|--------|
| Seat Manufacturer | 5-10 years | Hardware quality, comfort ceiling |
| IFE Hardware | 5-8 years | Screen size, features available |
| IFE Content | 1-3 years | Movies, TV, music library |
| Connectivity | 3-5 years | WiFi speed and coverage |
| Catering | 1-3 years | Meal quality, beverage selection |
| Amenity Kits | 1-2 years | Blankets, pillows, kits, brand partnerships |

#### Contract Mechanics

- **Duration:** Longer contracts = better rates, less flexibility
- **Exclusivity:** Discounts for exclusive deals, but locked in
- **Volume commitments:** Minimum usage, penalty if below
- **Service levels:** Standard/Priority/Premium tiers
- **Early exit:** Penalty fees to break contract early

#### Service Profiles

Players define reusable **Service Profiles** that bundle amenity choices:

```
"Atlantic Business" profile:
├── 15" touchscreen, premium headphones
├── Full movie library + live TV
├── Free high-speed WiFi
├── 3-course chef-designed meal
├── Premium bar service
├── Business amenity kit + blanket + pillow
└── Estimated: $127/pax
```

#### Flight Duration Categories

Profiles are assigned by flight duration and cabin class:

| Duration | Economy Profile | Business Profile |
|----------|-----------------|------------------|
| Short (<2h) | No Frills | Basic Business |
| Medium (2-5h) | Standard | Regional Business |
| Long (5-10h) | Long-Haul Economy | Long-Haul Business |
| Ultra (10+h) | ULH Economy | ULH Business |

Individual routes can override defaults for flagship positioning.

#### Brand Consistency

Service choices must match brand positioning:
- **LCC:** Basic service expected, premium confuses market
- **Full Service:** Standard+ expected, below damages brand
- **Premium:** High expectations, shortfalls hurt significantly

---

## 13. The Living World

### Design Philosophy

The player is not the protagonist. The world exists independently.

**The test:** If you do nothing for a year, the world should change without you.

---

### 13.1 Industry Actors

> **Data Model:** See `Airline`, `AIStrategy`, `Manufacturer`, `Lessor` entities in data-model.md

**Airlines:** Legacy, LCC, regional, cargo, state-owned, startups—each with interests and behaviors.

**Manufacturers:** Boeing, Airbus, Embraer, COMAC—production limits, backlogs, relationships.

**Lessors:** Portfolio optimization, will repossess for better tenants.

---

### 13.2 Supporting Ecosystem

**Airports:** Varying interests (throughput, flag carrier protection, revenue)

> **Data Model:** See `RegulatoryBody`, `Regulation`, `BilateralAgreement`, `MROProvider`, `CrewPool`, `Union` entities in data-model.md

**Service Providers:** Seat manufacturers, IFE, caterers, MRO

**Human Capital:** Pilot market, training organizations, unions

**Regulatory:** Aviation authorities, transport ministries, competition authorities

---

### 13.3 Emergent Rivalry System

**Design Philosophy:** Rivalries emerge from gameplay, not from UI labels. The world doesn't revolve around you—your rival doesn't know they're your rival.

**How Rivalries Form:**

Rivalry is a player perception, not a game state. The system tracks competitive friction without declaring "enemies."

| Friction Source | Detection | Player Experience |
|-----------------|-----------|-------------------|
| Route overlap | Same O&D pairs | "They're on all my routes" |
| Slot competition | Bidding against you | "They outbid me again" |
| Hub encroachment | New base in your territory | "They opened in Lyon" |
| Talent poaching | Your staff leaves for them | "They stole my CCO" |
| Price wars | Sustained undercutting | "They're bleeding me dry" |

**What the System Tracks (Hidden):**

> **Data Model:** See `CompetitorRelationship`, `FrictionEvent` entities in data-model.md

```
COMPETITOR PROFILE (Internal)

SkyEuro Airlines
Friction Score: 78 (High)
Primary Overlap: Lyon hub
Recent Actions: 
  - Entered LYS-CDG (your route)
  - Hired your former scheduler
  - Undercutting fares by 12%
```

**Player-Facing View:**

No "Rivals" panel. Instead, patterns surface naturally:

```
COMPETITIVE INTELLIGENCE

Routes Under Pressure:
Lyon → Paris    SkyEuro matching your prices
Lyon → Nice     SkyEuro added frequency

Recent Competitor Moves:
SkyEuro expanded Lyon operations (+4 gates)
TransAir entered your Bordeaux route

Staff Departures to Competitors:
Marie Dubois (Scheduler) → SkyEuro
```

**Rivalry Actions (Available When Friction is High):**

When competitive friction reaches threshold, options appear organically:

```
ROUTE: LYON → PARIS

Competitor: SkyEuro (aggressive presence)
Your share: 34% (was 52%)
Their strategy: Price leadership

RESPONSE OPTIONS:

[Match pricing] Accept lower margins
[Premium pivot] Differentiate on service
[Capacity fight] Add frequency, force their hand
[Tactical retreat] Reduce frequency, redeploy aircraft
[Seek alliance] Codeshare proposal (unusual, but...)
```

**Escalation Without Theatrics:**

If sustained conflict continues, the game notes it matter-of-factly:

```
STRATEGIC ASSESSMENT · Q3

Prolonged competition with SkyEuro is affecting results.
- Lyon hub contribution down 23%
- 3 routes now loss-making
- Aircraft utilization sub-optimal

Board is aware. No action required yet.
Options are available if you wish to escalate or de-escalate.
```

**Resolution Paths:**
- One airline exits the market (you or them)
- Stable equilibrium (both survive at lower margins)
- Acquisition (buy them, or they buy you)
- Alliance formation (if-you-can't-beat-them)
- Market growth absorbs both

---

### 13.4 Implementation Principles

- Simulate the ecosystem, not just competition
- Information asymmetry
- Relationship memory
- Named characters with lifecycles
- The player is not special

---

## 14. The Compromise Engine

### Design Philosophy

Progress is not linear. The path to your vision runs through decisions you wouldn't make in an ideal world.

Compromises are not transactions—they're relationships. When you take something, you owe something. But the debt is implicit, not ledgered. You won't know exactly when it's called in, or how.

---

### 14.1 Compromise Categories

> **Data Model:** See `Compromise` entity and `CompromiseCategory`, `CompromiseStatus` enums in data-model.md

**Resource:** Can't afford what you need
**Timing:** Right thing isn't available when needed
**Relationship:** Getting requires giving
**Identity:** Becoming something unintended
**Ethical:** Right thing vs. profitable thing

---

### 14.2 The Obligation System

> **Data Model:** See `Obligation` entity in data-model.md (creditor, terms, origin_event, status)

When you accept a compromise involving another party, an **obligation** is created. This is tracked internally but **not visible to the player**.

**What Gets Tracked:**
- Who you owe (government, investor, union, competitor)
- What the understanding was (route commitment, board seat, pricing constraint, future consideration)
- The origin event (which crisis, which deal)

**What the Player Sees:**
- Nothing. No token count, no obligation list.
- The stakeholder relationship may show subtle shifts
- Tension builds from *not knowing* when it's called in

**When Obligations Surface:**

The creditor calls in the obligation when *they* need something—not on a predictable schedule. This could be months or years later.

```
MINISTRY REQUEST

"The regional development committee meets next month.
The Lyon-Aurillac service has been... noted.
We trust the 2019 arrangement remains understood."

CONTEXT:
You accepted a government loan guarantee during the cash crisis.
No explicit terms were set. But there was an understanding.

[Maintain the route] Honor the implicit deal
[Reduce to minimum] Technical compliance
[Discontinue] Break the understanding

⚠ The Minister has a long memory.
```

**Player Response Options:**

| Response | Immediate Effect | Long-term Effect |
|----------|------------------|------------------|
| Honor fully | Cost absorbed | Relationship preserved, future favors possible |
| Partial compliance | Reduced cost | Relationship strained, noted |
| Refuse | No cost | Relationship damaged, future dealings harder |

**The Uncertainty is the Point:**

Players should feel the weight of obligations without being able to optimize around them. Real debts work this way—you know you owe, but not exactly what it will cost you until the moment arrives.

---

### 14.3 The Compromise Lifecycle

```
CRISIS → FORCED CHOICE → LIVING WITH IT → 
OBLIGATION CALLED → HONOR OR BREAK
```

The loop may repeat. Honoring one obligation may create goodwill. Breaking one may close doors permanently.

---

### 14.4 Compromise Visibility

What players *can* see:
- Fleet pages show "acquired under duress"
- Route history notes "launched against plan"
- Timeline view of major decisions
- Stakeholder relationship status (but not specific debts)

What players *cannot* see:
- List of outstanding obligations
- When obligations will be called
- Exact terms expected

---

### 14.5 Emotional Payoffs

- **The Recovery:** You fixed the thing you compromised on
- **The Unexpected Win:** The compromise turned out better than planned
- **The Principled Stand:** You refused, and survived anyway
- **The Lingering Regret:** You can't undo what you did
- **The Full Circle:** The debt is finally clear
- **The Betrayal:** You broke an understanding, and they remember

---

## 15. Visual Design & UI

> **Art Direction:** See companion document art-bible.md for complete specifications including color palettes, typography, scene breakdowns, UI components, and audio direction.

### Design Philosophy

**The Terminal is the Controller. The Map and Scenes are the Reward.**

Data density for decisions. Visual beauty for accomplishment.

---

### 15.1 Art Direction Layers

The game operates in three visual modes:

| Layer | Purpose | Style |
|-------|---------|-------|
| **Management Interface** | Decisions, data, control | Professional ops aesthetic |
| **World View** | Network, empire, context | Living map with activity |
| **Glorification Scenes** | Achievement, attachment | High-fidelity beauty |

---

### 15.2 Management Interface

**Inspiration:** Bloomberg terminal, airline ops systems (SABRE, Amadeus), professional trading floors.

**Characteristics:**
- High information density
- Clean typography (not necessarily monospace in production)
- Muted color palette with meaningful color coding
- Responsive feedback on interactions
- Minimal decoration

**Why This Works:**
- Serious tone (you're running a business)
- Respects player intelligence
- Era-flexible (works for 1958 and 2025)
- Distinct from cartoon tycoon competitors

**Prototype vs. Production:**

| Aspect | Prototype (TUI) | Production |
|--------|-----------------|------------|
| Typography | Monospace, box-drawing | Professional sans-serif, subtle borders |
| Layout | Text-only panels | Proper visual hierarchy with data viz |
| Color | Terminal green/amber | Refined palette with brand colors |
| Interactions | Keyboard-focused | Full mouse/keyboard with hover states |

*See companion document: ui-mockups-terminal-style.md for prototype mockups.*

---

### 15.3 World View: The Ops Center Map

The map is not just navigation—it's your empire visualized.

**Core Concept:** A satellite feed showing your airline's presence in the world.

**Visual Elements:**
- Day/night cycle across globe
- Weather systems moving dynamically
- Routes as geodesic arcs (not straight lines)
- Aircraft icons moving along routes (at appropriate speed for game speed)
- Hubs glowing based on traffic density
- Route "pulse" showing activity level

**Zoom Levels:**
- Global: Your network footprint
- Regional: Route density, competitor presence
- Airport: Your gates, aircraft, ground activity

**The "Juice":**
- Routes pulse when flights are active
- Color intensity reflects profitability
- Weather affects visible operations
- Time-of-day lighting shifts

---

### 15.4 Glorification Scenes: The Hangar

**Purpose:** The "character sheet" for your aircraft. Where Pillar 1 (Aircraft as Characters) becomes visible.

**The Hangar View:**

A high-fidelity, static rendering of each aircraft. Not 3D spinning—a portrait.

**Visual Elements:**
- Aircraft in your livery
- Visual wear reflecting service life:
  - Faded paint on high-cycle aircraft
  - Minor oil streaks on veterans
  - Pristine finish on new deliveries
- Lighting that emphasizes the aircraft's character

**The Biography Panel:**

Pinned alongside the aircraft image:

```
N847MA · Boeing 737-800
"The Lyon Express"

DELIVERED: March 2019
CYCLES: 12,847
HOURS: 28,394

HISTORY:
Originally: Southwest Airlines (N8547Q)
Your service: 6 years, 4 months

NOTABLE EVENTS:
✓ 10,000th cycle ceremony
✓ Carried Minister Dupont (state visit)
⚠ Bird strike survival (2022)
✓ First aircraft on Nice route

CURRENT:
Route: Lyon → Paris (CDG)
Next maintenance: C-check in 847 cycles
Crew favorite: Marie's preferred aircraft

[View flight log] [Configure cabin] [Schedule maintenance]
```

**Visual Wear System:**

| Service Level | Visual Indicator |
|---------------|------------------|
| New (0-2 years) | Factory fresh, glossy |
| Mature (2-8 years) | Normal wear, character |
| Veteran (8-15 years) | Visible age, patina |
| Ancient (15+ years) | Heavy wear, "survivor" look |

Wear is aesthetic only—reliability is tracked separately.

---

### 15.5 CEO Office Progression

**Purpose:** Visual shorthand for your empire stage. Low-effort, high emotional payoff.

The office appears in certain screens (board meetings, investor calls, reflection moments) and evolves with your airline.

| Stage | Office Description |
|-------|---------------------|
| **Bootstrap** | Cluttered desk in hangar backroom. Whiteboards, coffee cups, paper everywhere. You can see aircraft through the window. |
| **Regional** | Small office at airport. Professional but modest. Tarmac view. First awards on wall. |
| **National** | Glass-walled corner office. City skyline. Multiple screens. Industry awards visible. |
| **Empire** | High-rise boardroom. Panoramic view. Art on walls. The office of someone who matters. |

**Transition Moments:**

When you hit a stage threshold, brief acknowledgment:

```
NEW OFFICE

Your airline has outgrown its headquarters.
The board approved the move to the new operations center.

[View your new office]
```

No cutscene. Just a moment of recognition.

---

### 15.6 UI Feedback ("Juice")

The interface must feel alive. Data-dense doesn't mean sterile.

**Audio Feedback:**
- Key/click sounds for selections (subtle, satisfying)
- Heavy "thunk" for major purchases
- Subtle tally sound for revenue flow
- Alert tones differentiated by severity

**Visual Feedback:**
- Profitable routes: Subtle warm glow, gold highlight on expansion
- Loss-making routes: Cool tones, slight desaturation
- Crisis: Terminal flicker, red-shift, chromatic aberration
- Achievement: Brief bloom effect, particle flourish

**AI Transparency:**

When executives make decisions, the UI explains why:

```
CCO ACTION

Sarah reduced prices on Lyon-Paris by 8%.
Reason: "SkyEuro entered route. Defending share."

[Review pricing] [Override] [Acknowledge]
```

---

### 15.7 Diegetic UI Elements

Some interfaces are designed to look like in-world objects:

| Element | Diegetic Style |
|---------|----------------|
| Route ticket | Physical airline ticket |
| Boarding pass | Gate display format |
| Financial report | Printed statement aesthetic |
| Board memo | Letterhead document |
| News alert | Wire service ticker |

This grounds the management interface in the airline world.

---

### 15.8 The Living Flight

**Inspiration:** FlightRadar24's follow mode meets The Sims' emotional feedback.

**The Insight:** Your airline isn't abstract numbers. It's people in tubes crossing the planet. The game should let you *watch* your operation work.

#### View Hierarchy

| View Level | What You See | Interaction |
|------------|--------------|-------------|
| **Globe (zoomed out)** | Route arcs, fleet dots moving along paths | Click dot to select flight |
| **Globe (zoomed in)** | Individual aircraft icon, flight number, altitude/speed | Click to follow |
| **Aircraft (following)** | Exterior model moving along route, real-time position | Click "Enter cabin" |
| **Cabin (interior)** | Cross-section view, passengers visible, crew moving | Observe only |

#### Cabin Interior View

When you enter a flight's cabin, you see:

**Passengers:**
- Seated in your configured layout
- Emoji indicators showing current mood (happy/neutral/cramped/irritated)
- Activities visible: sleeping, eating, watching IFE, working
- Reactions to events: turbulence ripples through cabin, meal service brightens mood

**Crew:**
- Positioned in galleys and aisles
- Fatigue indicators on long-haul flights
- Service phase visible (boarding, meal service, rest, landing prep)

**Environmental:**
- Cabin lighting matches time of day (dimmed for night flights)
- Window views show clouds, terrain below (stylized)
- Turbulence indicated by subtle camera shake

#### Mood Indicators

Borrowing from The Sims' emotional feedback:

| Emoji | Meaning | Driven By |
|-------|---------|-----------|
| 😊 | Happy | Good pitch, on-time, meal quality |
| 😐 | Neutral | Acceptable conditions |
| 😤 | Cramped | Low seat pitch, full flight |
| 😠 | Irritated | Delay, poor service, long flight |
| 😴 | Sleeping | Night flight, comfortable seat |
| 🍽️ | Eating | Meal service in progress |

#### Architecture: Simulation vs. Visualization

**Critical distinction:** The simulation always runs. The visualization renders on demand.

```
SIMULATION LAYER (always running, every flight)
├── Passenger satisfaction (config, delay, service, turbulence)
├── Crew fatigue (duty hours, route length, pax load)
├── In-flight events (meal service, turbulence, incidents)
└── → Feeds: Post-flight reports, Brand scores, Crew morale

VISUALIZATION LAYER (on demand)
├── Globe: dots on arcs (lightweight, always available)
├── Aircraft follow: exterior model (medium cost)
└── Cabin interior: full render (expensive, only when viewing)
    └── Pulls current state from simulation, displays visually
```

**Performance rule:** With 100+ aircraft in flight, only the observed cabin renders. All others are simulation-only.

#### The Modelist Fantasy

This feature serves the "quiet competence" need. It's the model train enthusiast watching their creation work:

- No gameplay decisions happen here
- Pure observation and immersion
- Validates that your cabin configuration *matters*
- Makes the "experience crafting" pillar tangible

#### Integration with Cabin Designer

| Tool | View | Purpose |
|------|------|---------|
| **Cabin Designer (Blueprint)** | Top-down schematic | Configure layout, place seats |
| **Cabin Designer (Preview)** | 3D interior, empty | See configuration before committing |
| **Living Flight (Cabin)** | 3D interior, populated | Watch real passengers react to your choices |

The Blueprint is where you *decide*. The Living Flight is where you *see the consequences*.

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

> **Companion Document:** See economic-parameters.md for era-specific pricing tables, cost indices, and scenario calibration data

### The Problem with Realism

Real airline economics: $150M+ widebodies, 15-year financing, 2% margins. Realistic but not fun.

### The Solution

Compress timelines, amplify volatility, preserve the *feeling* of investment.

| Real World | Game World |
|------------|------------|
| 3-5 year delivery | Weeks/months |
| 15-year financing | Faster payback |
| 2% margins | Higher, more volatile |

### Era-Accurate Economics

Historical scenarios use period-accurate prices and costs:
- A 747 costs $24M in 1978, $150M in 2020
- Fuel at $0.42/gallon in 1978, $2.80/gallon in 2025
- But operating margin targets (8-15%) stay consistent across eras

**Core principle:** Year-accurate absolute values, ratio-preserved economics. The *feeling* of running an airline stays consistent; the numbers match the era.

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
Meaningful risk without paperwork.

---

## Appendix A: Aircraft Lifecycle Example

### The Journey of N847MA

**Year 0:** Factory delivery to Southwest. Generic livery, efficient configuration.

**Year 4:** Secondary market sale. You acquire it from a lessor.

**Year 5:** Reconfigured for your premium regional brand. Named "The Lyon Express."

**Year 8:** 10,000 cycles. Ceremony with crew. Reliability bonus unlocked.

**Year 10:** State visit. Carried government minister. Prestige bonus.

**Year 12:** Bird strike. Repaired. Incident marker in history. Character.

**Year 15:** Decision point. Major overhaul required.
- Overhaul cost: $4M
- Remaining useful life: 8-10 years
- Replacement cost: $52M new, $28M used

Player decides: veteran soldier or graceful retirement?

**Year 16 (if kept):** "Survivor" status. Crew requests to fly her. Marketing runs anniversary campaign.

---

## Appendix B: Tension Drivers

| Driver | Tension Created |
|--------|-----------------|
| Capital constraints | Can't do everything you want |
| Delivery timelines | Waiting for the thing you need |
| Competitor actions | Responding to threats |
| Economic cycles | Adapting to conditions |
| Stakeholder pressure | Satisfying multiple masters |
| Staff limitations | Delegation quality varies |
| Regulatory changes | Rules shifting under you |

---

## Appendix C: Compromise Tracking Example

### Scenario: Taking Government Money

**The Crisis:**
Year 3. Cash crunch. Bank won't extend. You need $15M.

**The Offer:**
Ministry will guarantee a loan. In exchange: three unprofitable regional routes for 5 years.

**The Choice:**
- Accept: Survive, but locked into losing routes
- Decline: Risk bankruptcy, maintain independence

**If Accepted:**

Fleet page shows:
```
ATR 72-600 · F-GKXA
Status: Assigned to mandated route
Route: Lyon → Aurillac (government obligation)
Profitability: -$12K/month
Obligation ends: Year 8
```

**Year 8:**
```
OBLIGATION COMPLETE

Your government route commitment has ended.
Lyon → Aurillac is now optional.

The route loses $144K annually.
But Aurillac residents depend on it.
And the Minister remembers your service.

[Discontinue route] End the bleeding
[Maintain service] Keep the relationship
[Reduce frequency] Compromise
```

---

## Appendix D: Historical Airlines Database

> **Companion Document:** See historical-airlines-database.md for complete seed data

This appendix provides starting positions for "Take the Helm" scenarios. Full fleet compositions, network data, financial positions, and scripted events are in the companion document.

### Featured Scenarios

| Airline | Year | Region | Difficulty | Challenge |
|---------|------|--------|------------|-----------|
| Pan Am | 1978 | North America | Hard | Navigate deregulation, fuel crisis, 747 overcapacity |
| Braniff | 1978 | North America | Hard | Resist overexpansion temptation |
| People Express | 1981 | North America | Medium | Scale without losing culture |
| Southwest | 1978 | North America | Medium | Expand faster than history |
| British Caledonian | 1980 | Europe | Medium | Compete with BA from Gatwick |
| Swissair | 1990 | Europe | Hard | Hunter Strategy: genius or folly? |
| Alitalia | 1995 | Europe | Very Hard | Privatize, reform unions, survive LCCs |
| Japan Airlines | 2005 | Asia | Hard | Avoid bankruptcy, simplify structure |
| Singapore Airlines | 1985 | Asia | Medium | Maintain premium in commoditizing market |
| Emirates | 1990 | Middle East | Medium | Build hub before competitors notice |
| Garuda Indonesia | 1990 | Asia | Hard | Survive Asian crisis, fix safety |

### Example: Pan Am (1978)

**Starting Position:**
- Fleet: 127 aircraft including 747s
- Network: Global, hub at JFK
- Brand: Prestigious, "World's Most Experienced Airline"
- Financial: $180M cash, $890M debt

**Historical Context:**
- Just lost domestic routes to competition (no CAB protection)
- Deregulation Act signed October 1978
- Oil crisis approaching (1979)
- No hub-and-spoke system, point-to-point model outdated

**Player Challenge:**
Can you navigate what Pan Am couldn't? The 747 bet, the fuel crisis, deregulation?

**Victory Conditions:**
- Bronze: Survive to 1990
- Silver: Profitable in 1985
- Gold: Still operating independently in 2000

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
┌─────────────────────────────────────────────────────────────┐
│  MERIDIAN AIR                        Cash: $847,000     │
│  Regional Carrier · Founded 2025                        │
├─────────────────────────────────────────────────────────────┤
│  YOUR FLEET          YOUR ROUTES         THIS WEEK      │
│  ✈ ATR 72-600       Lyon → Marseille    Flights: 28    │
│  ✈ ATR 72-600       Lyon → Bordeaux     Pax: 1,847     │
│                                                         │
│  BANK LOAN                                              │
│  $2.1M remaining · $47K/month · Covenants: OK          │
└─────────────────────────────────────────────────────────────┘
```

### National Contender Board Screen

```
┌─────────────────────────────────────────────────────────────┐
│  BOARD OF DIRECTORS                                     │
├─────────────────────────────────────────────────────────────┤
│  YOU · CEO & Chair · 35%                                │
│  ██████████ Confidence: Strong                         │
│                                                         │
│  SARAH CHEN · Altitude Partners · 25%                   │
│  ████████░░ Confidence: Good                           │
│  Focus: Growth, exit timeline                           │
│                                                         │
│  PHILIPPE MARTIN · Independent                          │
│  █████████░ Confidence: Strong                         │
│  Focus: Operations, safety                              │
│  "Your OTP is slipping. Watch it."                      │
│                                                         │
│  OVERALL: ████████░░ Good                              │
│  Next meeting: 6 weeks                                  │
└─────────────────────────────────────────────────────────────┘
```

### Public Company Dashboard Addition

```
┌─────────────────────────────────────────────────────────────┐
│  MERIDIAN AIR · NYSE: MAIR                              │
│  Stock: $34.72 ▲ +2.3%    Market cap: $2.1B            │
├─────────────────────────────────────────────────────────────┤
│  ANALYST CONSENSUS: ████████░░ BUY                     │
│  Concerns: Fuel exposure, Atlantic competition          │
│                                                         │
│  NEXT EARNINGS: 4 weeks                                 │
│  Consensus: $0.42 EPS                                   │
│  Your trajectory: $0.38 EPS (miss likely)               │
└─────────────────────────────────────────────────────────────┘
```

### Crisis Screen

```
┌─────────────────────────────────────────────────────────────┐
│  ⚠ CRISIS MODE                                          │
├─────────────────────────────────────────────────────────────┤
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
└─────────────────────────────────────────────────────────────┘
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
| 0.7 | January 2026 | Design review integration: Emergent Rivalry System, Aircraft Prestige mechanics, Hangar glorification view, Office Progression, Visual Design Direction (prototype vs. production), Obligation System for Compromise Engine, Art Bible companion doc reference, Living Flight observation mode (15.8), Service & Suppliers system (12.6), Cabin Designer, Service Suppliers, and Network Scheduler companion docs |

---

*This is a living document. Update as design evolves.*
