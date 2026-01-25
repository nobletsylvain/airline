# Brand & Marketing — Detailed Specification

**Version:** 0.1  
**Date:** January 2026  
**Companion to:** Game Design Document v0.7, Route Economics Spec v0.1

---

## Overview

This document specifies how brand reputation and marketing work in Airliner — how passengers perceive your airline, how that perception affects demand, and how marketing can shape it.

**Design Philosophy:** Brand is the accumulated story of your airline. It's built through consistent experience and damaged by incidents. Marketing can nudge perception, but can't override reality.

**Core Principle:** Brand = Promise. Delivering on the promise builds equity; failing to deliver destroys it.

---

## 1. Brand Components

### 1.1 Brand Dimensions

| Dimension | What It Measures | Affected By |
|-----------|------------------|-------------|
| **Awareness** | "Have they heard of us?" | Marketing, presence, PR |
| **Quality perception** | "Are they good?" | Service, incidents, word of mouth |
| **Value perception** | "Fair price for what I get?" | Price vs. delivered experience |
| **Loyalty** | "Would I fly them again?" | Consistent positive experience |
| **Premium worthiness** | "Worth paying more?" | Quality + uniqueness |

### 1.2 Brand Score Calculation

```
Brand_Score = (Awareness × 0.15) + (Quality × 0.30) + (Value × 0.25) 
            + (Loyalty × 0.20) + (Premium × 0.10)
```

### 1.3 Brand by Segment

Different segments weight factors differently:

| Segment | Quality | Value | Loyalty | Premium |
|---------|---------|-------|---------|---------|
| Business | High | Medium | High | High |
| Premium Leisure | High | Medium | Medium | High |
| Leisure | Medium | High | Low | Low |
| VFR | Medium | High | Medium | Low |
| Budget | Low | Very High | Low | Very Low |

---

## 2. Brand Drivers

### 2.1 Positive Drivers

| Driver | Impact | Duration | Notes |
|--------|--------|----------|-------|
| On-time performance | +0.1/% above target | Ongoing | Cumulative trust |
| Service consistency | +0.05/month | Ongoing | Builds loyalty |
| Cabin quality | +5-15 | Ongoing | Per quality level |
| Crisis handled well | +5-10 | 3-6 months | Recovery bonus |
| Awards/recognition | +3-8 | 6-12 months | Third-party validation |
| Marketing campaign | +1-10 | 1-3 months | Temporary boost |

### 2.2 Negative Drivers

| Driver | Impact | Duration | Notes |
|--------|--------|----------|-------|
| Delays (significant) | -0.1/% below target | Ongoing | Cumulative damage |
| Service failures | -2-5 per incident | 1-3 months | Complaints, social media |
| Safety incident | -10-50 | 6-24 months | Severity dependent |
| Overbooking crisis | -5-15 | 3-6 months | PR disaster |
| Strike | -5-10 | Duration + 2 months | Unreliability |
| Bad press | -3-10 | 1-3 months | News cycle |

### 2.3 Brand Decay

Without active management, brand scores drift toward market average:

| Scenario | Decay Rate |
|----------|------------|
| No marketing, average service | -0.5/month |
| Good service, no marketing | Neutral |
| Marketing only, poor service | -1/month (faster decay) |

---

## 3. Marketing Campaigns

### 3.1 Campaign Types

| Campaign | Cost | Duration | Primary Effect |
|----------|------|----------|----------------|
| **Brand awareness** | $100-500K | 1-3 months | +Awareness |
| **Quality positioning** | $200-800K | 2-4 months | +Quality perception |
| **Value messaging** | $150-600K | 1-3 months | +Value perception |
| **Loyalty program promo** | $100-400K | 1-2 months | +Loyalty |
| **Route launch** | $50-200K | 2-4 weeks | Route awareness |
| **Crisis response** | $200-1M | As needed | Damage control |

### 3.2 Campaign Builder

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  NEW MARKETING CAMPAIGN                                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  CAMPAIGN TYPE                                                              │
│  ○ Brand awareness    ● Quality positioning    ○ Value messaging           │
│  ○ Loyalty promotion  ○ Route launch           ○ Crisis response           │
│                                                                             │
│  TARGET MARKET                                                              │
│  ○ All markets       ● Home market (France)   ○ Specific routes            │
│                                                                             │
│  TARGET SEGMENT                                                             │
│  ☑ Business          ☑ Premium Leisure        ☐ Leisure                    │
│  ☐ VFR               ☐ Budget                                              │
│                                                                             │
│  BUDGET                                                                     │
│  [$350,000          ] (Recommended: $300-500K for this type)               │
│                                                                             │
│  DURATION                                                                   │
│  [3 months          ] (Recommended: 2-4 months)                            │
│                                                                             │
│  MESSAGE FOCUS                                                              │
│  "Experience the difference. Meridian Air - where comfort meets            │
│   reliability."                                                            │
│  [Edit message]                                                            │
│                                                                             │
│  CHANNELS                                                                   │
│  ☑ Digital (40%)     ☑ Airport (25%)          ☑ Trade press (20%)         │
│  ☐ TV (expensive)    ☑ Partnerships (15%)                                  │
│                                                                             │
│  PROJECTED IMPACT                                                           │
│  Quality perception: +4-6 points over 3 months                             │
│  Awareness: +2-3 points (secondary)                                        │
│  Est. revenue impact: +$180K from improved conversion                      │
│                                                                             │
│  [Cancel]                                    [Launch campaign: $350,000]   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3.3 Campaign Effectiveness

| Factor | Effect on ROI |
|--------|---------------|
| **Market fit** | Message aligned with reality = better |
| **Budget adequacy** | Too little = wasted, too much = diminishing returns |
| **Timing** | Crisis response faster = better |
| **Channel match** | Right channels for segment = better |
| **Duration** | Too short = forgotten, too long = fatigue |

---

## 4. Reputation Events

### 4.1 Crisis Events

| Event | Brand Impact | Required Response |
|-------|--------------|-------------------|
| **Accident** | -30 to -50 | Full crisis response |
| **Incident** | -10 to -20 | Statement, transparency |
| **Service meltdown** | -5 to -15 | Apology, compensation |
| **Data breach** | -10 to -25 | Notification, remediation |
| **PR disaster** | -5 to -20 | Damage control |

### 4.2 Crisis Response

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  ⚠ REPUTATION CRISIS                                                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  INCIDENT: Passenger removal video goes viral                              │
│  Date: January 18, 2026                                                    │
│  Views: 2.4M and growing                                                   │
│                                                                             │
│  Current brand impact: -8 points (and dropping)                            │
│  Social sentiment: 78% negative                                            │
│  Press coverage: Major outlets picked up story                             │
│                                                                             │
│  RESPONSE OPTIONS                                                           │
│                                                                             │
│  1. Full apology + compensation                                            │
│     Cost: $50K immediate + policy change                                   │
│     Projected impact: Limits damage to -10, recovery in 4 weeks           │
│                                                                             │
│  2. Defensive statement                                                    │
│     Cost: Minimal                                                          │
│     Projected impact: Damage continues to -15-20, slow recovery           │
│                                                                             │
│  3. No comment                                                             │
│     Cost: None                                                             │
│     Projected impact: Damage peaks at -12-18, becomes "their thing"       │
│                                                                             │
│  4. Launch counter-narrative                                               │
│     Cost: $150K campaign                                                   │
│     Projected impact: Risky - could backfire or limit damage              │
│                                                                             │
│  Time pressure: Response within 24 hours has 2x effectiveness             │
│                                                                             │
│  [Option 1] [Option 2] [Option 3] [Option 4]                               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.3 Recovery Curve

After negative event:

| Time | Recovery (with good response) | Recovery (poor/no response) |
|------|------------------------------|----------------------------|
| 1 month | 20% recovered | 5% recovered |
| 3 months | 60% recovered | 25% recovered |
| 6 months | 85% recovered | 50% recovered |
| 12 months | 95% recovered | 75% recovered |

---

## 5. Loyalty Program

### 5.1 FFP Structure

| Tier | Threshold | Benefits |
|------|-----------|----------|
| **Basic** | 0 | Earn miles |
| **Silver** | 25K miles | Priority boarding, +25% bonus |
| **Gold** | 50K miles | Lounge access, +50% bonus, upgrades |
| **Platinum** | 100K miles | All benefits, concierge, guaranteed seats |

### 5.2 FFP Economics

| Metric | Typical Value |
|--------|---------------|
| Miles liability | 1.2-1.5 cents/mile |
| Breakage (unused) | 15-25% |
| Partner revenue | $0.01-0.02/mile sold |
| Redemption cost | 0.8-1.0 cents/mile |

### 5.3 Loyalty Effect on Demand

| Tier | Price Tolerance | Likelihood to Book |
|------|-----------------|-------------------|
| Non-member | Baseline | Baseline |
| Basic | +3% | +5% |
| Silver | +8% | +15% |
| Gold | +15% | +30% |
| Platinum | +25% | +50% |

---

## 6. Brand Dashboard

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  BRAND HEALTH                                                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  OVERALL BRAND SCORE: 68/100 · ▲ +3 vs last quarter                        │
│                                                                             │
│  DIMENSIONS                                                                 │
│  Awareness:        ████████████░░░░░░░░ 62   Market avg: 58               │
│  Quality:          █████████████░░░░░░░ 72   Market avg: 65               │
│  Value:            ██████████████░░░░░░ 74   Market avg: 68               │
│  Loyalty:          ███████████░░░░░░░░░ 58   Market avg: 55               │
│  Premium:          ██████████████░░░░░░ 71   Market avg: 62               │
│                                                                             │
│  BY SEGMENT                                                                 │
│  Business:         ████████████████░░░░ 78   Strong                        │
│  Premium Leisure:  ██████████████░░░░░░ 72   Good                          │
│  Leisure:          ███████████████░░░░░ 75   Good                          │
│  VFR:              ████████████░░░░░░░░ 62   Average                       │
│  Budget:           ████████░░░░░░░░░░░░ 45   Below average                 │
│                                                                             │
│  RECENT IMPACTS                                                             │
│  +4  Jan 15: On-time performance 94% (above target)                        │
│  +2  Jan 10: New lounges opened at CDG and LYS                             │
│  -3  Jan 05: Service complaint went viral on Twitter                       │
│  +1  Dec 28: Year-end quality campaign completed                           │
│                                                                             │
│  ACTIVE CAMPAIGNS                                                           │
│  "Fly Better" quality campaign - 6 weeks remaining - $210K spent           │
│                                                                             │
│  [Launch campaign] [View loyalty program] [Reputation management]          │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 7. Data Model Integration

### 7.1 Entities

**BrandMetrics** — Brand score tracking

| Field | Type | Purpose |
|-------|------|---------|
| `airline_id` | FK | Airline |
| `date` | date | Snapshot date |
| `awareness` | int | 0-100 |
| `quality_perception` | int | 0-100 |
| `value_perception` | int | 0-100 |
| `loyalty` | int | 0-100 |
| `premium_worthiness` | int | 0-100 |
| `overall_score` | int | Computed |

**MarketingCampaign** — Active campaigns

| Field | Type | Purpose |
|-------|------|---------|
| `id` | UUID | Primary key |
| `airline_id` | FK | Airline |
| `campaign_type` | enum | Type of campaign |
| `budget` | decimal | Total spend |
| `spent` | decimal | Spent to date |
| `start_date` | date | Campaign start |
| `end_date` | date | Campaign end |
| `target_markets` | string[] | Geographic targets |
| `target_segments` | string[] | Segment targets |
| `effectiveness` | float | Measured ROI |

**ReputationEvent** — Brand-impacting events

| Field | Type | Purpose |
|-------|------|---------|
| `id` | UUID | Primary key |
| `airline_id` | FK | Airline |
| `event_type` | enum | Crisis type |
| `date` | date | When occurred |
| `severity` | int | 1-10 |
| `brand_impact` | int | Points lost |
| `response_type` | enum | How handled |
| `recovery_progress` | float | 0-1 |

### 7.2 New Enumerations

```yaml
CampaignType:
  BRAND_AWARENESS
  QUALITY_POSITIONING
  VALUE_MESSAGING
  LOYALTY_PROMOTION
  ROUTE_LAUNCH
  CRISIS_RESPONSE

ReputationEventType:
  ACCIDENT
  INCIDENT
  SERVICE_MELTDOWN
  DATA_BREACH
  PR_DISASTER
  VIRAL_COMPLAINT
  POSITIVE_VIRAL
  AWARD_RECOGNITION

CrisisResponse:
  FULL_APOLOGY
  DEFENSIVE_STATEMENT
  NO_COMMENT
  COUNTER_NARRATIVE
```

---

## Document History

| Version | Date | Changes |
|---------|------|---------|
| 0.1 | January 2026 | Initial specification |
