# Airline Tycoon PC - Game Design Document

**Project:** Airline Tycoon (PC Prototype)  
**Based on:** Airline Club (open source)  
**Repository:** https://github.com/nobletsylvain/airline  
**Last Updated:** January 21, 2026  
**Version:** 0.2

---

## Table of Contents

1. [Overview](#1-overview)
2. [Core Gameplay Loop](#2-core-gameplay-loop)
3. [First Time User Experience (FTUE)](#3-first-time-user-experience-ftue)
4. [Campaigns](#4-campaigns)
5. [Game Mechanics](#5-game-mechanics)
6. [UI/UX Design](#6-uiux-design)
7. [Technical Architecture](#7-technical-architecture)
8. [Open Questions](#8-open-questions)
9. [Changelog](#9-changelog)

---

## 1. Overview

### Vision

A premium PC airline tycoon experience focused on building and managing your own airline company. Players experience the strategic depth of route planning, fleet management, and competitive positioning across different eras and regions of aviation history.

### Target Audience

- Tycoon/management game enthusiasts
- Aviation fans
- Players who enjoy strategic economic simulation
- Ages 16+

### Platform

- PC (Windows primary, Mac/Linux TBD)

### Pillars

1. **Strategic Depth** — Meaningful decisions in route planning, fleet composition, and market positioning
2. **Historical Authenticity** — Real aircraft, airports, and economic contexts
3. **Accessible Complexity** — Easy to start, deep to master
4. **Visual Satisfaction** — Watching your airline grow and planes fly

---

## 2. Core Gameplay Loop

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│   BUY/LEASE AIRCRAFT → ASSIGN ROUTES → TIME PASSES     │
│         ↑                                    ↓         │
│         └──── EARN REVENUE ← PASSENGERS FLY ←┘         │
│                    ↓                                    │
│              EXPAND / OPTIMIZE                          │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Primary Actions

- Purchase or lease aircraft
- Open new routes between airports
- Set ticket prices and service levels
- Manage finances (loans, cash flow)
- React to market changes and competition

### Secondary Actions

- Negotiate codeshares and alliances
- Invest in airport facilities
- Handle crew and maintenance
- Respond to random events (weather, strikes, crises)

---

## 3. First Time User Experience (FTUE)

### Design Principles

1. **Fly fast** — First plane in the air within 2-3 minutes
2. **Guided first route** — Suggest a simple, profitable route
3. **Celebrate early wins** — First flight, first profit, first milestone
4. **Drip complexity** — Introduce advanced features over first hour
5. **Safe sandbox** — Starting scenario prevents early bankruptcy

### FTUE Flow

| Step | Player Action | What They Learn | Time |
|------|---------------|-----------------|------|
| 1 | Name airline, pick logo | Ownership, identity | 30s |
| 2 | Receive starter plane + cash | No overwhelm | 10s |
| 3 | Guided to select first route | Route basics, demand | 60s |
| 4 | Set departure, confirm | Scheduling | 30s |
| 5 | Watch first flight depart | The core loop | 20s |
| 6 | Time skip to see revenue | Profit feedback | 10s |
| 7 | Prompted to buy second plane | Growth decisions | 60s |
| 8 | Tutorial fades, advisor available | Independence | — |

**Total guided time:** ~4 minutes

### Post-FTUE Unlocks (First Hour)

| Unlock | Trigger | Feature |
|--------|---------|---------|
| Fleet View | Own 3+ planes | Detailed fleet management |
| Competition Panel | Competitor enters your route | Pricing strategy |
| Finances | First loan offer | Debt, expansion capital |
| Hub Strategy | 5+ routes from one airport | Hub bonuses |
| Alliances | Reach 10 routes | Codeshares |

---

## 4. Campaigns

> **Detailed specifications:** See [CAMPAIGNS_Detailed.md](CAMPAIGNS_Detailed.md) for full campaign data including aircraft specs, airport lists, events timeline, and mission structure.

Three campaigns teaching different strategic playstyles:

### Campaign 1: "The Deregulation Gamble"

**Setting:** USA, 1978  
**Historic Context:** US Airline Deregulation Act just passed. Legacy carriers scramble, new entrants rush in.

**Setup:**
- Role: Tiny regional carrier in the Midwest
- Starting assets: 2 turboprops, $3M cash
- Home base: Kansas City (or player choice from Midwest)
- Competition: Legacy giants (Pan Am, TWA) dominate coasts

**Strategic Positioning:** Low-cost disruptor
- Undercut on price
- Focus on point-to-point (not hubs)
- Grow fast before consolidation

**Key Mechanics Introduced:**
- Yield management and pricing
- Cost control (no frills vs. full service)
- Timing expansion vs. competition

**Mission Structure:**

| Phase | Objective | Reward |
|-------|-----------|--------|
| 1 | Establish 5 profitable routes | Unlock used jet purchases |
| 2 | Reach $500K monthly profit | Bank increases credit line |
| 3 | Survive fuel crisis event | Reputation bonus |
| 4 | Expand to 25 routes | Acquisition offers appear |
| 5 | Reach 50 routes OR accept buyout | Campaign complete |

**Win Conditions:**
- Victory A: 50 profitable routes by 1985
- Victory B: Sell airline for 3x starting valuation
- Failure: Bankruptcy

**Estimated Playtime:** 4-6 hours

---

### Campaign 2: "Silk Road Revival"

**Setting:** Central Asia, 2005  
**Historic Context:** Post-Soviet states modernizing. China booming. Underserved east-west corridor.

**Setup:**
- Role: State-backed startup in Kazakhstan
- Starting assets: 3 aging Soviet jets (Tu-154), $8M cash
- Home base: Almaty
- Competition: Minimal, but infrastructure is poor

**Strategic Positioning:** Connecting hub builder
- Bridge Europe ↔ Asia traffic
- Pursue codeshares with major carriers
- Balance passenger vs. cargo

**Key Mechanics Introduced:**
- Hub-and-spoke network design
- Codeshares and alliances
- Cargo operations
- Airport infrastructure investment

**Mission Structure:**

| Phase | Objective | Reward |
|-------|-----------|--------|
| 1 | Connect Almaty to 3 major hubs (Moscow, Dubai, Beijing) | Codeshare offers |
| 2 | Achieve 20% transit passenger ratio | Hub status bonus |
| 3 | Launch cargo division | New revenue stream |
| 4 | Partner with Star Alliance or SkyTeam | Global feed traffic |
| 5 | Become #1 transit hub between EU and East Asia | Campaign complete |

**Win Conditions:**
- Victory: #1 market share on Europe-Asia transit by 2015
- Failure: Lose state funding (negative profits 3 years running)

**Estimated Playtime:** 5-7 hours

---

### Campaign 3: "Island Empire"

**Setting:** Indonesia, 1990  
**Historic Context:** Archipelago nation with 17,000 islands. Domestic travel is a lifeline. Tourism rising.

**Setup:**
- Role: Family-owned carrier
- Starting assets: 1 turboprop (Fokker F27), $1.5M cash
- Home base: Surabaya (secondary city, less competition)
- Competition: Garuda (state airline) dominates Jakarta

**Strategic Positioning:** Regional network specialist
- Win underserved domestic routes
- Leverage government subsidies
- Build density before trunk routes

**Key Mechanics Introduced:**
- Subsidized/public service routes
- Fleet diversity (right-sizing planes to routes)
- Seasonal demand (tourism cycles)
- Domestic vs. international expansion

**Mission Structure:**

| Phase | Objective | Reward |
|-------|-----------|--------|
| 1 | Connect 10 islands with subsidized routes | Government contract bonus |
| 2 | Achieve profitability without subsidies on 5 routes | Bank financing unlocked |
| 3 | Enter tourism market (Bali connections) | Premium pricing |
| 4 | Challenge Garuda on one trunk route | Media attention, reputation |
| 5 | Connect 100 islands, 30% domestic share | Campaign complete |

**Win Conditions:**
- Victory: 100 islands connected + 30% domestic market share by 2000
- Failure: Bankruptcy or family sells airline

**Estimated Playtime:** 6-8 hours

---

### Campaign Comparison

| Campaign | Era | Playstyle | Core Lesson | Difficulty |
|----------|-----|-----------|-------------|------------|
| Deregulation Gamble | 1978 USA | Aggressive disruptor | Pricing, speed, cost | Medium |
| Silk Road Revival | 2005 Central Asia | Strategic hub builder | Networks, partnerships | Hard |
| Island Empire | 1990 Indonesia | Patient regional grower | Fleet mix, subsidies | Easy |

---

## 5. Game Mechanics

*To be expanded*

### 5.1 Route Economics
### 5.2 Fleet Management
### 5.3 Pricing & Yield Management
### 5.4 Competition AI
### 5.5 Random Events
### 5.6 Alliances & Codeshares

---

## 6. UI/UX Design

*To be expanded*

### 6.1 Main Map View
### 6.2 Fleet Screen
### 6.3 Route Planner
### 6.4 Finances Dashboard
### 6.5 Animated Plane Sprites (see branch: animated-plane-sprites)

---

## 7. Technical Architecture

*To be expanded*

### 7.1 Engine/Framework
### 7.2 Data Model (from Airline Club)
### 7.3 Simulation Loop
### 7.4 Save System

---

## 8. Open Questions

- [ ] What engine/framework for PC build? (Godot, Unity, Electron?)
- [ ] Keep web tech stack or rewrite?
- [ ] Multiplayer or single-player only for PC version?
- [ ] Monetization model? (Premium, DLC campaigns, free-to-play?)
- [ ] How much simulation depth to expose vs. automate?

---

## 9. Changelog

| Date | Version | Changes |
|------|---------|---------|
| 2026-01-21 | 0.2 | Added detailed campaign specs (CAMPAIGNS_Detailed.md): aircraft, airports, events, missions |
| 2026-01-21 | 0.1 | Initial draft: Overview, FTUE, 3 campaigns |

