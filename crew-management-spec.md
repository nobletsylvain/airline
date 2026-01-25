# Crew Management — Detailed Specification

**Version:** 0.2  
**Date:** January 2026  
**Companion to:** Game Design Document v0.7, Network Scheduler Spec v0.1

---

## Overview

This document specifies how flight crew and cabin crew work in Airliner — hiring, training, rostering, fatigue management, and the trade-offs between cost, compliance, and crew satisfaction.

**Design Philosophy:** Crew are the human element of your airline. They're not just a cost line — they affect safety, service quality, and passenger experience. Managing crew well prevents disruptions; mismanaging them causes strikes.

**Core Loop:** Hire → Train → Roster → Fly → Rest → Repeat

---

## Design Decision: Aggregate vs Individual Crew Tracking

**Decision:** Use aggregate `CrewPool` for v1.0, with named `KeyCrewMember` entities for narrative moments.

**Rationale:**
- Individual tracking of hundreds of crew doesn't add meaningful decisions
- Aggregate pools (pilots per type, FAs per base) capture economic reality
- Named key crew (chief pilots, union reps, senior pursers) appear in events
- Scales from 20-crew startup to 5,000-crew major airline
- Aligns with delegation philosophy (you're CEO, not roster clerk)

**Implementation:**
- `CrewPool`: Aggregate counts, costs, satisfaction by base/type
- `KeyCrewMember`: Named individuals who appear in events, negotiations
- Living Flight shows generic crew figures, not tracked individuals

---

## 1. Crew Types

### 1.1 Flight Crew

| Role | Per Aircraft | Base Salary (2025) | Notes |
|------|--------------|-------------------|-------|
| **Captain** | 4-6 | $150-350K | Type-rated, command authority |
| **First Officer** | 4-6 | $80-180K | Type-rated, can upgrade |
| **Second Officer** | 0-2 | $60-120K | Long-haul relief |

### 1.2 Cabin Crew

| Role | Per Aircraft | Base Salary (2025) | Notes |
|------|--------------|-------------------|-------|
| **Purser** | 2-4 | $50-80K | Cabin manager |
| **Senior FA** | 4-8 | $40-60K | Experienced |
| **Flight Attendant** | 6-12 | $30-50K | Standard |

### 1.3 Crew Ratios

| Aircraft Type | Pilots | Cabin (min) | Cabin (typical) |
|---------------|--------|-------------|-----------------|
| Regional (ATR) | 2 | 1 | 2 |
| Narrowbody (737) | 2 | 4 | 5-6 |
| Widebody (787) | 2-4* | 8 | 10-14 |
| Heavy (747) | 2-4* | 12 | 14-18 |

*3-4 pilots on ultra-long-haul for rest rotation

---

## 2. Hiring

### 2.1 Recruitment Channels

| Channel | Cost | Time | Quality | Volume |
|---------|------|------|---------|--------|
| **Direct application** | Low | 2-4 weeks | Variable | High |
| **Agency/recruiter** | 15-25% salary | 1-2 weeks | Good | Medium |
| **Competitor poaching** | Premium salary | Fast | High | Low |
| **Cadet program** | Training cost | 18-24 months | Trainable | Medium |
| **Military transition** | Signing bonus | 2-3 months | High (pilots) | Low |

### 2.2 Hiring Process

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  PILOT RECRUITMENT                                                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  POSITION: First Officer · Boeing 737 MAX                                  │
│  APPLICATIONS: 47 candidates                                               │
│                                                                             │
│  TOP CANDIDATES                                                             │
│                                                                             │
│  Marie Dupont · Currently: Regional carrier FO                             │
│  Experience: 3,200 hrs total, 1,800 hrs turbine                           │
│  Ratings: CPL, ME, IR · Type: ATR 72                                       │
│  Salary ask: $95K                                                          │
│  Availability: 4 weeks (notice period)                                     │
│  Notes: Needs 737 type rating ($45K training cost)                        │
│  [Interview] [Offer] [Decline]                                             │
│                                                                             │
│  ─────────────────────────────────────────────────────────────────────────│
│                                                                             │
│  Thomas Weber · Currently: LCC First Officer                               │
│  Experience: 5,100 hrs total, 4,200 hrs 737                                │
│  Ratings: ATPL, ME, IR · Type: 737-800, 737 MAX                           │
│  Salary ask: $115K                                                         │
│  Availability: 8 weeks (notice period)                                     │
│  Notes: Already 737 typed, ready immediately after notice                  │
│  [Interview] [Offer] [Decline]                                             │
│                                                                             │
│  COMPARISON                                                                 │
│  Dupont: Lower salary, training needed, 3-month lead time                  │
│  Weber: Higher salary, no training, 8-week lead time                       │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2.3 Hiring Costs

| Cost Type | Amount | Notes |
|-----------|--------|-------|
| Agency fee | 15-25% first year salary | If using recruiter |
| Background check | $500-2K | Required |
| Medical | $1-2K | Class 1 medical |
| Signing bonus | $5-25K | Competitive market |
| Relocation | $5-15K | If applicable |

---

## 3. Training

### 3.1 Type Ratings

| Training Type | Duration | Cost | Who Pays |
|---------------|----------|------|----------|
| **Initial type rating** | 6-8 weeks | $30-60K | Usually airline |
| **Differences training** | 1-2 weeks | $5-15K | Airline |
| **Recurrent training** | 2-4 days | $3-8K | Airline (annual) |
| **Upgrade training** | 4-6 weeks | $20-40K | Airline |

### 3.2 Cabin Crew Training

| Training Type | Duration | Cost | Notes |
|---------------|----------|------|-------|
| **Initial** | 4-6 weeks | $5-10K | Safety, service |
| **Aircraft type** | 1-2 days | $500-1K | Per type |
| **Recurrent** | 2 days | $1-2K | Annual |
| **Premium service** | 3-5 days | $2-5K | For business/first |
| **Purser upgrade** | 1 week | $3-5K | Leadership |

### 3.3 Training Pipeline

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  TRAINING SCHEDULE                                                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  IN PROGRESS                                                                │
│  Marie Dupont · 737 MAX Initial Type Rating                                │
│  Progress: ████████░░░░░░░░ Week 4/8                                       │
│  Instructor: Capt. Renard                                                  │
│  Est. completion: Feb 28                                                   │
│  Cost: $48K (budgeted)                                                     │
│                                                                             │
│  UPCOMING                                                                   │
│  Jan 25: Recurrent - 4 pilots (simulator)                                  │
│  Feb 01: Cabin crew initial - 6 trainees                                   │
│  Feb 15: 787 differences - 2 pilots (new type in fleet)                    │
│                                                                             │
│  TRAINING CAPACITY                                                          │
│  Simulator slots this month: 12 available, 8 scheduled                     │
│  Classroom capacity: 12 trainees max                                       │
│  Instructor availability: 2 TRIs, 1 TRE                                    │
│                                                                             │
│  [Schedule training] [View calendar] [Contract external]                   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 4. Rostering & Duty Limits

### 4.1 Regulatory Limits

| Limit Type | EASA | FAA | Notes |
|------------|------|-----|-------|
| **Max flight duty** | 13 hrs | 14 hrs | Varies by start time |
| **Max flight time** | 10 hrs | 9 hrs | Actual flying |
| **Min rest** | 10 hrs | 10 hrs | Between duties |
| **Max weekly** | 60 hrs | 60 hrs | Flight time |
| **Max 28-day** | 190 hrs | — | EASA cumulative |
| **Max annual** | 900 hrs | 1,000 hrs | Flight time |

### 4.2 Roster Display

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  CREW ROSTER · Week of Jan 20                                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  CAPTAIN DUBOIS                         MON  TUE  WED  THU  FRI  SAT  SUN  │
│  Status: Line flying                    OFF  ═══  ═══  ═══  OFF  OFF  ═══  │
│  This week: 24.5 duty hrs              │    LYS  CDG  LYS      │    LYS   │
│  This month: 72/90 hrs                 │    CDG  NCE  JFK      │    MRS   │
│                                        │    NCE  LYS  LYS      │    LYS   │
│                                                                             │
│  FO MARTIN                             MON  TUE  WED  THU  FRI  SAT  SUN  │
│  Status: Line flying                    ═══  ═══  OFF  OFF  ═══  ═══  OFF  │
│  This week: 28.0 duty hrs              LYS  CDG      │    LYS  LYS      │  │
│  This month: 68/90 hrs                 MRS  LYS      │    BCN  BCN      │  │
│                                        LYS              LYS  LYS         │
│                                                                             │
│  ⚠ Pairing conflict: Martin assigned to MA1456 but also MA1678 on Fri     │
│                                                                             │
│  [Edit roster] [Auto-optimize] [Check legality] [Publish]                  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.3 Fatigue Management

| Factor | Impact | Mitigation |
|--------|--------|------------|
| **Night flying** | Increased fatigue | Extra rest before/after |
| **Time zone crossing** | Circadian disruption | Acclimatization time |
| **Early report** | Reduced alertness | Limit consecutive |
| **Split duty** | Accumulated fatigue | Minimum break rules |
| **Back-to-back** | Compounding | Maximum consecutive days |

---

## 5. Crew Costs

### 5.1 Total Cost per Crew Member

| Component | % of Total | Notes |
|-----------|------------|-------|
| Base salary | 60-70% | Fixed |
| Per diem | 10-15% | When away from base |
| Benefits | 15-20% | Healthcare, pension |
| Training | 5-10% | Ongoing |

### 5.2 Cost per Block Hour

From economic-parameters.md:

| Era | Captain | First Officer | Cabin (per) | Total 737-sized |
|-----|---------|---------------|-------------|-----------------|
| 2025 | $320 | $210 | $80 | $950 |

### 5.3 Cost Comparison: Direct vs Agency

| Model | Monthly Cost | Flexibility | Risk |
|-------|--------------|-------------|------|
| **Direct hire** | Base cost | Low | You bear all |
| **Wet lease** | 2-3x cost | High | Lessor bears |
| **Agency crew** | 1.5-2x cost | Medium | Shared |

---

## 6. Crew Satisfaction

### 6.1 Satisfaction Factors

| Factor | Weight | What Affects It |
|--------|--------|-----------------|
| **Salary** | 25% | Market competitiveness |
| **Schedule quality** | 25% | Predictability, weekends off |
| **Bases** | 15% | Commutable, desirable |
| **Equipment** | 10% | Modern aircraft |
| **Management** | 15% | Communication, fairness |
| **Career growth** | 10% | Upgrade path |

### 6.2 Satisfaction Effects

| Level | Effects |
|-------|---------|
| **High (80+)** | Low turnover, good morale, flexibility |
| **Good (60-80)** | Normal operations |
| **Low (40-60)** | Increased sick calls, turnover |
| **Critical (<40)** | Work-to-rule, strike risk |

### 6.3 Union Relations

If satisfaction drops too low:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  ⚠ LABOR RELATIONS WARNING                                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  PILOT UNION (ALPA Chapter)                                                │
│  Satisfaction: 42/100 · ▼ Critical                                         │
│                                                                             │
│  Grievances filed: 12 (up from 3 last quarter)                             │
│  Sick rate: 8.2% (normal: 3-4%)                                            │
│  Turnover intent: 34% surveyed "likely to leave"                           │
│                                                                             │
│  Key issues:                                                                │
│  1. Scheduling practices (too many reserve days)                           │
│  2. Salary below market (competitor pays 15% more)                         │
│  3. Base closures (Lyon pilot cuts)                                        │
│                                                                             │
│  Union message:                                                             │
│  "If management doesn't address these concerns by Feb 15,                  │
│   we will move to work-to-rule action."                                    │
│                                                                             │
│  Options:                                                                   │
│  [Open negotiations] [Address scheduling] [Review compensation]            │
│  [Maintain current course]                                                 │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 7. Data Model Integration

### 7.1 Entities

**CrewMember** — Individual crew members

| Field | Type | Purpose |
|-------|------|---------|
| `id` | UUID | Primary key |
| `airline_id` | FK | Employer |
| `role` | enum | CAPTAIN / FO / PURSER / FA |
| `name` | string | Display name |
| `base_airport` | FK | Home base |
| `type_ratings` | string[] | Qualified aircraft |
| `hire_date` | date | Start date |
| `salary` | decimal | Annual base |
| `satisfaction` | int | 0-100 |
| `fatigue` | int | 0-100 (accumulates) |
| `flight_hours_total` | int | Career hours |
| `flight_hours_ytd` | int | This year |
| `status` | enum | ACTIVE / TRAINING / LEAVE / TERMINATED |

**CrewAssignment** — Crew to flight assignments

| Field | Type | Purpose |
|-------|------|---------|
| `id` | UUID | Primary key |
| `crew_id` | FK | Crew member |
| `flight_id` | FK | Flight |
| `role` | enum | Operating role |
| `duty_start` | datetime | Report time |
| `duty_end` | datetime | Release time |

### 7.2 New Enumerations

```yaml
CrewRole:
  CAPTAIN
  FIRST_OFFICER
  SECOND_OFFICER
  PURSER
  SENIOR_FA
  FLIGHT_ATTENDANT

CrewStatus:
  ACTIVE
  TRAINING
  SICK
  VACATION
  MATERNITY
  LEAVE_OF_ABSENCE
  SUSPENDED
  TERMINATED

RosterStatus:
  DRAFT
  PUBLISHED
  LOCKED
```

---

## Document History

| Version | Date | Changes |
|---------|------|---------|
| 0.1 | January 2026 | Initial specification |
