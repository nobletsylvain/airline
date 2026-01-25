# Airliner - Data Model Addendum

**Version:** 0.7  
**Date:** January 2026  
**Purpose:** Sync data-model.md with companion specifications

This addendum adds entities and enumerations defined in companion specs but missing from the core data model. Apply these additions to data-model.md v0.6.

---

## New Entities

### Domain: Commercial

**CompetitorRoute** — Competitor presence on a route (from route-economics-spec)

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `route_id` | FK → Route | Which route |
| `airline_id` | FK → Airline | Competitor |
| `weekly_frequency` | int | Departures per week |
| `weekly_seats` | int | Total capacity |
| `avg_fare` | decimal | Estimated average fare |
| `service_quality` | int | 1-100 score |
| `last_updated` | date | Data freshness |

**AncillaryProduct** — Revenue products beyond tickets (from route-economics-spec)

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `airline_id` | FK → Airline | Which airline |
| `type` | enum | See `AncillaryType` |
| `name` | string | Display name |
| `price` | decimal | Customer price |
| `cost` | decimal | Delivery cost |
| `attach_rate` | float | % of pax who buy |
| `active` | bool | Currently offered |
| `cabin_restriction` | enum? | If cabin-specific |
| `route_type_restriction` | enum? | If route-type specific |

**AncillaryPolicy** — Airline-wide ancillary settings (from route-economics-spec)

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `airline_id` | FK → Airline | Which airline |
| `product_type` | enum | Which product category |
| `included_in_fare` | bool | Free with ticket |
| `economy_price` | decimal | Economy price |
| `business_price` | decimal? | Business override |
| `effective_date` | date | When policy starts |

---

### Domain: Fleet & Market

**AircraftListing** — Marketplace listings (from fleet-market-spec)

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `aircraft_id` | FK? → Aircraft | If existing aircraft |
| `type_id` | FK → AircraftType | Aircraft type |
| `listing_type` | enum | SALE / LEASE / SLOT |
| `seller_id` | FK → Airline | Seller |
| `asking_price` | decimal | Listed price |
| `estimated_value` | decimal | System estimate |
| `condition` | enum | Condition rating |
| `availability_date` | date | When available |
| `status` | enum | See `ListingStatus` |
| `created_date` | date | When listed |

---

### Domain: Brand & Marketing

**MarketingCampaign** — Active marketing campaigns (from brand-marketing-spec)

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `airline_id` | FK → Airline | Which airline |
| `campaign_type` | enum | See `CampaignType` |
| `name` | string | Campaign name |
| `budget` | decimal | Total budget |
| `spent` | decimal | Spent to date |
| `start_date` | date | Campaign start |
| `end_date` | date | Campaign end |
| `target_markets` | string[] | Geographic targets |
| `target_segments` | string[] | Passenger segments |
| `message` | string | Core message |
| `channels` | json | Channel allocation |
| `effectiveness` | float? | Measured ROI |
| `status` | enum | PLANNED / ACTIVE / COMPLETED / CANCELLED |

**ReputationEvent** — Brand-impacting incidents (from brand-marketing-spec)

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `airline_id` | FK → Airline | Which airline |
| `event_type` | enum | See `ReputationEventType` |
| `date` | date | When occurred |
| `severity` | int | 1-10 |
| `brand_impact` | int | Points lost/gained |
| `description` | string | What happened |
| `response_type` | enum? | See `CrisisResponse` |
| `response_date` | date? | When responded |
| `recovery_progress` | float | 0-1 recovery |
| `resolved` | bool | Crisis over |

---

### Domain: Slots

**Add to existing Slot entity** (from network-scheduler-spec):

| Field | Type | Description |
|-------|------|-------------|
| `usage_count` | int | Times used this season |
| `usage_required` | int | 80% of available days |
| `lease_from_id` | FK? → Airline | If leased |
| `lease_rate` | decimal? | If leased |

---

### Domain: Fuel Hedging

**Extend FuelHedge entity** (from financial-model-spec):

| Field | Type | Description |
|-------|------|-------------|
| `instrument_type` | enum | FIXED / COLLAR / CALL / SWAP |
| `ceiling_price` | float? | For collars |
| `floor_price` | float? | For collars |
| `premium_paid` | decimal | Upfront cost |
| `counterparty` | string | Bank/trader |
| `status` | enum | ACTIVE / EXPIRED / EXERCISED |
| `realized_pnl` | decimal? | Final gain/loss |

---

## New Enumerations

### From route-economics-spec

```yaml
DemandSegment:
  BUSINESS
  PREMIUM_LEISURE
  LEISURE
  VFR
  BUDGET

SeasonalityPattern:
  BUSINESS_HEAVY
  LEISURE_HEAVY
  RESORT
  SKI_RESORT
  FLAT
  HOLIDAY_DRIVEN

PricingStrategy:
  AGGRESSIVE
  BALANCED
  PREMIUM
  PENETRATION
  CUSTOM

AncillaryType:
  BAGGAGE
  SEAT_SELECTION
  EXTRA_LEGROOM
  PRIORITY_BOARDING
  WIFI
  BUY_ON_BOARD
  LOUNGE_ACCESS
  FAST_TRACK
  TRAVEL_INSURANCE
```

### From fleet-market-spec

```yaml
AcquisitionChannel:
  MANUFACTURER_ORDER
  SLOT_PURCHASE
  OPERATING_LEASE
  FINANCE_LEASE
  SALE_LEASEBACK
  USED_PURCHASE
  AUCTION

OrderStatus:
  LETTER_OF_INTENT
  MEMORANDUM_OF_UNDERSTANDING
  FIRM_ORDER
  IN_PRODUCTION
  DELIVERED
  CANCELLED

ListingStatus:
  ACTIVE
  UNDER_OFFER
  SOLD
  LEASED
  WITHDRAWN
```

### From financial-model-spec

```yaml
FacilityType:
  TERM_LOAN
  REVOLVING_CREDIT
  AIRCRAFT_LOAN
  BOND
  CONVERTIBLE

HedgeInstrument:
  FIXED_PRICE
  COLLAR
  CALL_OPTION
  SWAP

HedgeStatus:
  ACTIVE
  EXPIRED
  EXERCISED

FinancialHealth:
  EXCELLENT
  GOOD
  ADEQUATE
  STRESSED
  DISTRESSED
  CRISIS
```

### From maintenance-spec

```yaml
MELCategory:
  A    # As specified in individual item
  B    # 3 calendar days
  C    # 10 calendar days
  D    # 120 calendar days
```

### From brand-marketing-spec

```yaml
CampaignType:
  BRAND_AWARENESS
  QUALITY_POSITIONING
  VALUE_MESSAGING
  LOYALTY_PROMOTION
  ROUTE_LAUNCH
  CRISIS_RESPONSE

CampaignStatus:
  PLANNED
  ACTIVE
  COMPLETED
  CANCELLED

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

### From network-scheduler-spec

```yaml
SlotAcquisition:
  GRANDFATHER
  PURCHASE
  ALLOCATION
  LEASE
  SWAP
  BABYSITTING
```

### From governance-spec

```yaml
OwnerType:
  FOUNDER
  PRIVATE_INVESTOR
  STRATEGIC_INVESTOR
  GOVERNMENT
  PUBLIC
  EMPLOYEE

InvestorSentiment:
  PLEASED
  SATISFIED
  WATCHING
  CONCERNED
  UNHAPPY
  HOSTILE

BoardConfidence:
  STRONG
  GOOD
  MIXED
  LOW
  CRITICAL

StakeholderSentiment:
  PLEASED
  SATISFIED
  CONTENT
  NEUTRAL
  GRUMBLING
  CONCERNED
  UNHAPPY
  HOSTILE
```

### From executive-delegation-spec

```yaml
ExecutiveRole:
  CEO
  COO
  CFO
  CCO
  CMO
  CTO
  CPO
  CHRO
  CSO

DelegationFunction:
  SCHEDULING
  MAINTENANCE
  CREW_ROSTERING
  PRICING
  REVENUE_MANAGEMENT
  SALES_CHANNELS
  TREASURY
  FUEL_HEDGING
  DEBT_MANAGEMENT
  MARKETING
  LOYALTY_PROGRAM
  FLEET_PLANNING
  PROCUREMENT
  HR_HIRING
  HR_COMPENSATION
  LABOR_RELATIONS
  STRATEGY
  M_AND_A

DelegationLevel:
  DIRECT_CONTROL     # Level 0
  ASSISTED           # Level 1
  APPROVAL           # Level 2
  GUIDELINES         # Level 3
  OVERSIGHT          # Level 4
  TRUST              # Level 5

PerformanceRating:
  EXCEPTIONAL
  GOOD
  ADEQUATE
  POOR
  FAILING

LoyaltyLevel:
  COMMITTED
  SOLID
  WAVERING
  LOOKING

PolicyCategory:
  COMMERCIAL
  OPERATIONAL
  FINANCIAL
  HR
  BRAND
```

---

## Naming Reconciliation

### Resolve conflicts between specs and data-model:

| Spec Uses | Data-Model Has | Resolution |
|-----------|----------------|------------|
| `DebtFacility` | `Loan` | Keep `Loan`, add `facility_type` field |
| `AircraftOrder` | `Order` | Keep `Order` |
| `BrandMetrics` | `Brand` | Keep `Brand`, it covers metrics |

### Add field to Loan entity:

| Field | Type | Description |
|-------|------|-------------|
| `facility_type` | enum | TERM_LOAN / REVOLVING / AIRCRAFT / BOND |

---

## Validation Rules to Add

```yaml
Slot:
  - usage_count / usage_required must be >= 0.8 or slot at risk
  - Cannot schedule flight without matching slot at Level 3 airports

FuelHedge:
  - sum(coverage_pct) for overlapping periods should not exceed 1.0
  - end_date must be > start_date

MarketingCampaign:
  - budget must be > 0
  - end_date must be > start_date
  - spent must be <= budget

AncillaryProduct:
  - price must be >= cost (or flag as loss leader)
  - attach_rate must be between 0.0 and 1.0
```

---

## New Computed Fields

```python
Airline.ancillary_revenue_pct:
  """Ancillary as % of total revenue"""
  total = FinancialStatement.latest().revenue_total
  ancillary = FinancialStatement.latest().revenue_ancillary
  return (ancillary / total) * 100 if total > 0 else 0

Slot.utilization_pct:
  """Current season slot utilization"""
  return usage_count / usage_required if usage_required > 0 else 1.0

Slot.at_risk:
  """Whether slot may be lost"""
  return utilization_pct < 0.8

FuelHedge.mark_to_market:
  """Current P&L if hedge closed today"""
  spot = FuelPrice.current().price_per_gallon
  if instrument_type == 'FIXED':
    return (spot - price_per_gallon) * notional_gallons
  # More complex for collars/options
```

---

## Document History

| Version | Date | Changes |
|---------|------|---------|
| 0.7 | January 2026 | Addendum: Synced with all companion specs. Added CompetitorRoute, AncillaryProduct, AncillaryPolicy, AircraftListing, MarketingCampaign, ReputationEvent. Extended Slot, FuelHedge. Added 40+ new enumerations. |
| 0.8 | January 2026 | Added KeyCrewMember, CargoContract entities. Added alliance/codeshare entities. |

---

## Additional Entities (v0.8)

### Domain: People

**KeyCrewMember** — Named crew who appear in narrative events (from crew-management-spec v0.2)

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `airline_id` | FK → Airline | Employer |
| `name` | string | Full name |
| `role` | enum | CHIEF_PILOT / UNION_REP / SENIOR_PURSER / INSTRUCTOR |
| `base` | FK → Airport | Home base |
| `hired_date` | date | Start of employment |
| `satisfaction` | int | 0-100 |
| `influence` | int | 0-100 (affects negotiations, morale) |
| `portrait` | string? | Image reference |
| `notes` | string? | Notable history |

Note: General crew tracked via `CrewPool` (aggregate). `KeyCrewMember` only for individuals who appear in events.

---

### Domain: Commercial

**CargoContract** — Freight agreements (from route-economics-spec v0.3)

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `airline_id` | FK → Airline | Your airline |
| `customer_name` | string | FedEx, DHL, etc. |
| `contract_type` | enum | BLOCK_SPACE / ACMI / INTERLINE |
| `routes` | FK[] → Route | Applicable routes |
| `volume_kg_weekly` | int | Committed volume |
| `rate_per_kg` | decimal | Contracted rate |
| `start_date` | date | Contract start |
| `end_date` | date | Contract end |
| `penalty_rate` | decimal | For under-delivery |
| `status` | enum | ACTIVE / EXPIRED / TERMINATED |

---

### Domain: Partnerships

**Alliance** — Global/regional airline alliances (from ai-competitors-spec v0.2)

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `name` | string | Alliance name |
| `type` | enum | GLOBAL / REGIONAL / BILATERAL |
| `annual_fee` | decimal | Membership cost |
| `service_standards` | json | Required minimums |
| `member_count` | int | Current members |

**AllianceMembership** — Membership records (from ai-competitors-spec v0.2)

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `airline_id` | FK → Airline | Member airline |
| `alliance_id` | FK → Alliance | Alliance |
| `joined_date` | date | Membership start |
| `tier` | enum | FULL / REGIONAL / AFFILIATE |
| `sponsor_id` | FK → Airline? | Sponsoring member |
| `status` | enum | ACTIVE / SUSPENDED / PENDING |

**Codeshare** — Codeshare agreements (from ai-competitors-spec v0.2)

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `marketing_carrier_id` | FK → Airline | Sells the seat |
| `operating_carrier_id` | FK → Airline | Flies the plane |
| `routes` | FK[] → Route | Covered routes |
| `codeshare_type` | enum | FREE_FLOW / BLOCK / HARD / SOFT |
| `prorate_pct` | float | Marketing carrier share |
| `start_date` | date | Agreement start |
| `end_date` | date | Agreement end |
| `status` | enum | ACTIVE / TERMINATED / PENDING |

---

## Additional Enumerations (v0.8)

```yaml
KeyCrewRole:
  CHIEF_PILOT           # Senior captain, standards
  UNION_REP             # Labor negotiations
  SENIOR_PURSER         # Cabin crew leader
  INSTRUCTOR            # Training captain
  SAFETY_OFFICER        # SMS representative

CargoContractType:
  BLOCK_SPACE           # Guaranteed capacity
  ACMI                  # Aircraft + crew
  INTERLINE             # Partner network
  SPOT                  # Per-shipment

AllianceType:
  GLOBAL                # StarAlliance, SkyTeam, Oneworld
  REGIONAL              # Regional groupings
  BILATERAL             # Two-airline partnership

MembershipTier:
  FULL                  # Full voting member
  REGIONAL              # Regional affiliate
  AFFILIATE             # Limited participation

CodeshareType:
  FREE_FLOW             # Either sells all segments
  BLOCK_SPACE           # Wholesale seat purchase
  HARD_BLOCK            # Guaranteed purchase
  SOFT_BLOCK            # Release if unsold

PartnershipStatus:
  ACTIVE                # In force
  PENDING               # Under negotiation
  SUSPENDED             # Temporarily halted
  TERMINATED            # Ended
```
