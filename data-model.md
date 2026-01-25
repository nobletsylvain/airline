# Airliner - Data Model

**Version:** 0.6  
**Date:** January 2026  
**Companion to:** Game Design Document v0.7

---

## Overview

This document defines the data structures required to implement Airliner. It extracts all entities, relationships, and constraints from the GDD into a schema-ready format.

**Principles:**
- History is first-class (append-only logs for biographies)
- Named characters matter (people are full entities)
- Relationships carry metadata (terms, dates, context)
- Simulation independence (AI airlines use same schema as player)

---

## Domain: Core Operations

### Aircraft

The central asset. Each aircraft is a unique entity with history.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `serial_number` | string | Manufacturer serial (unique) |
| `registration` | string | Current tail number |
| `type_id` | FK → AircraftType | Aircraft model |
| `configuration_id` | FK → AircraftConfiguration | Current cabin layout |
| `livery_id` | FK → Livery | Current paint scheme |
| `name` | string? | Optional aircraft name ("Spirit of Lyon") |
| `total_hours` | int | Lifetime airframe hours |
| `total_cycles` | int | Lifetime takeoff/landing cycles |
| `hours_since_last_check` | int | For maintenance tracking |
| `condition` | enum | EXCELLENT / GOOD / FAIR / POOR |
| `status` | enum | ACTIVE / MAINTENANCE / AOG / STORED / SOLD |
| `owner_id` | FK → Airline | Legal owner |
| `operator_id` | FK → Airline | Current operator (may differ if leased) |
| `acquisition_date` | date | When acquired by current owner |
| `acquisition_type` | enum | NEW_ORDER / LEASE / PURCHASE / AUCTION |
| `acquisition_context` | string? | "Compromise—wanted 787, couldn't get slots" |
| `manufactured_date` | date | Factory completion date |

**History tracking:** See `AircraftHistoryEntry`

**Prestige tracking:** See `AircraftPrestige`

---

### AircraftPrestige

Tracks the accumulated prestige and character of an individual aircraft. This is the mechanical weight behind "Aircraft as Characters" (Pillar 1).

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `aircraft_id` | FK → Aircraft | Which aircraft |
| `reliability_modifier` | float | Bonus/penalty to reliability (e.g., +0.05 = 5% better) |
| `appeal_modifier` | float | Bonus/penalty to passenger appeal |
| `crew_preference` | int | How much crews like this aircraft (-100 to +100) |
| `marketing_value` | int | Value for promotional campaigns (0-100) |
| `notable_events` | int | Count of prestige-building events |
| `last_updated` | date | Last recalculation |

**Computed from:** `PrestigeEvent` history

---

### PrestigeEvent

Individual events that contribute to aircraft prestige.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `aircraft_id` | FK → Aircraft | Which aircraft |
| `date` | date | When it occurred |
| `type` | enum | See `PrestigeEventType` |
| `description` | string | Human-readable summary |
| `reliability_impact` | float | Change to reliability modifier |
| `appeal_impact` | float | Change to appeal modifier |
| `crew_impact` | int | Change to crew preference |
| `marketing_impact` | int | Change to marketing value |
| `metadata` | json? | Additional context (VIP name, route, etc.) |

---

### AircraftType

Aircraft model specifications (e.g., "Boeing 737 MAX 8").

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `manufacturer` | string | "Boeing", "Airbus", etc. |
| `family` | string | "737", "A320", etc. |
| `variant` | string | "MAX 8", "-900ER", etc. |
| `display_name` | string | "Boeing 737 MAX 8" |
| `category` | enum | REGIONAL / NARROWBODY / WIDEBODY / JUMBO / CARGO |
| `pax_capacity_typical` | int | Standard 2-class config |
| `cargo_capacity_kg` | int | Belly hold capacity |
| `range_nm` | int | Max range nautical miles |
| `cruise_speed_kts` | int | Typical cruise speed |
| `fuel_burn_kg_hr` | int | Typical fuel consumption |
| `mtow_kg` | int | Max takeoff weight |
| `list_price_usd` | bigint | Catalog price |
| `year_introduced` | int | Entry into service |
| `year_discontinued` | int? | If no longer produced |
| `requires_etops` | bool | Needs ETOPS certification for overwater |
| `noise_category` | enum | CHAPTER_3 / CHAPTER_4 / CHAPTER_14 |

---

### AircraftConfiguration

Cabin layout for an aircraft type.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `type_id` | FK → AircraftType | Which aircraft type |
| `name` | string | "High-density domestic", "Long-haul 3-class" |
| `classes` | json | `[{class: "J", seats: 12, pitch: 40}, {class: "Y", seats: 162, pitch: 31}]` |
| `total_seats` | int | Sum of all classes |
| `ife_type` | enum | NONE / SHARED / PERSONAL |
| `wifi` | bool | Connectivity available |
| `power_outlets` | bool | At-seat power |
| `reconfiguration_cost` | int | Cost to install this config |
| `reconfiguration_days` | int | Downtime required |

---

### Airport

Airports in the network.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `icao` | string | 4-letter ICAO code (unique) |
| `iata` | string? | 3-letter IATA code |
| `name` | string | Full name |
| `city` | string | City served |
| `country` | string | Country code |
| `region` | enum | NORTH_AMERICA / EUROPE / ASIA / etc. |
| `latitude` | float | Coordinates |
| `longitude` | float | Coordinates |
| `elevation_ft` | int | Field elevation |
| `timezone` | string | IANA timezone |
| `runway_length_ft` | int | Longest runway |
| `slot_controlled` | bool | Requires slots |
| `total_slots` | int? | If slot controlled |
| `gates` | int | Available gates |
| `hub_for` | FK[]? → Airline | Airlines using as hub |
| `base_demand` | json | `{business: 1000, leisure: 5000, cargo: 2000}` per week |
| `ground_cost_per_turn` | int | Landing fees, handling |

---

### Route

A city pair with demand characteristics.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `origin_id` | FK → Airport | Departure airport |
| `destination_id` | FK → Airport | Arrival airport |
| `distance_nm` | int | Great circle distance |
| `block_time_minutes` | int | Typical block time |
| `demand_business` | int | Weekly business pax demand |
| `demand_leisure` | int | Weekly leisure pax demand |
| `demand_cargo_kg` | int | Weekly cargo demand |
| `seasonality` | json | `{jan: 0.8, jul: 1.3, ...}` monthly multipliers |
| `competition` | json | `[{airline_id, weekly_seats, avg_fare}, ...]` |

---

### Schedule

A planned service on a route.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `airline_id` | FK → Airline | Operating airline |
| `route_id` | FK → Route | Which route |
| `aircraft_id` | FK → Aircraft | Assigned aircraft |
| `frequency_per_week` | int | How many times weekly |
| `departure_time` | time | Scheduled departure |
| `days_of_week` | int[] | 1=Mon, 7=Sun |
| `effective_from` | date | Schedule start |
| `effective_to` | date? | Schedule end (null = ongoing) |
| `pricing_class_j` | int | Business fare |
| `pricing_class_y` | int | Economy fare |
| `status` | enum | ACTIVE / SUSPENDED / PLANNED |

---

### Flight

A single operated flight instance.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `schedule_id` | FK → Schedule | Parent schedule |
| `date` | date | Flight date |
| `flight_number` | string | "MR 401" |
| `status` | enum | SCHEDULED / BOARDING / DEPARTED / ARRIVED / DELAYED / CANCELLED / DIVERTED |
| `pax_business` | int | Business passengers |
| `pax_economy` | int | Economy passengers |
| `cargo_kg` | int | Cargo loaded |
| `load_factor` | float | Percentage filled |
| `revenue` | int | Total revenue |
| `fuel_cost` | int | Fuel expense |
| `delay_minutes` | int | Delay if any |
| `delay_reason` | enum? | See `DelayReason` |
| `incidents` | json? | Any operational issues |
| `cabin_satisfaction_avg` | float | Average pax mood 0.0-1.0 (calculated continuously) |
| `crew_fatigue_level` | float | Crew tiredness 0.0-1.0 (calculated continuously) |
| `service_phase` | enum | See `ServicePhase` |

**In-flight state tracking:** See `FlightSnapshot` for point-in-time cabin state.

---

### FlightSnapshot

Point-in-time state of an in-progress flight. Used for Living Flight visualization and post-flight reports.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `flight_id` | FK → Flight | Parent flight |
| `timestamp` | datetime | When snapshot taken |
| `flight_phase` | enum | See `FlightPhase` |
| `altitude_ft` | int | Current altitude |
| `position_lat` | float | Current latitude |
| `position_lon` | float | Current longitude |
| `pax_mood_distribution` | json | `{happy: 45, neutral: 30, cramped: 15, irritated: 10}` |
| `pax_activity_distribution` | json | `{sleeping: 20, eating: 15, watching: 40, working: 25}` |
| `crew_fatigue_avg` | float | Average crew fatigue 0.0-1.0 |
| `service_phase` | enum | Current service state |
| `cabin_lighting` | enum | DAY / DIMMED / NIGHT |
| `turbulence_level` | enum | NONE / LIGHT / MODERATE / SEVERE |
| `events_in_progress` | json? | Active events (meal service, turbulence, etc.) |

---

### Slot

Airport slot allocation.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `airport_id` | FK → Airport | Which airport |
| `airline_id` | FK → Airline | Holder |
| `time_window` | string | "0600-0700" |
| `day_type` | enum | WEEKDAY / WEEKEND / ALL |
| `season` | enum | SUMMER / WINTER |
| `acquired_date` | date | When obtained |
| `acquisition_method` | enum | GRANDFATHER / PURCHASE / ALLOCATION |
| `cost` | int? | If purchased |
| `use_it_or_lose_it` | bool | Subject to 80/20 rule |

---

## Domain: Ownership & Governance

### Airline

The core business entity.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `name` | string | "Meridian Air" |
| `icao_code` | string | "MER" |
| `iata_code` | string? | "MR" |
| `callsign` | string | "MERIDIAN" |
| `founded_date` | date | In-game founding |
| `hq_airport_id` | FK → Airport | Headquarters |
| `is_player` | bool | Player-controlled |
| `type` | enum | LEGACY / LCC / REGIONAL / CARGO / CHARTER / STARTUP |
| `stage` | enum | BOOTSTRAP / REGIONAL / NATIONAL / MAJOR / EMPIRE |
| `cash` | bigint | Current cash |
| `credit_available` | bigint | Undrawn credit facilities |
| `monthly_burn` | int | Cash burn rate |
| `employee_count` | int | Total headcount |
| `brand_id` | FK → Brand | Brand metrics |
| `livery_id` | FK → Livery | Default livery |
| `alliance_id` | FK? → Alliance | If alliance member |
| `is_public` | bool | Publicly traded |
| `stock_ticker` | string? | "MAIR" if public |

---

### Ownership

Who owns what stake in an airline.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `airline_id` | FK → Airline | The airline |
| `owner_type` | enum | FOUNDER / INVESTOR / PUBLIC / GOVERNMENT / OTHER_AIRLINE / EMPLOYEE |
| `owner_id` | UUID? | FK to Person, Investor, or Airline |
| `stake_percent` | float | Ownership percentage |
| `acquired_date` | date | When stake acquired |
| `acquisition_type` | enum | FOUNDING / INVESTMENT / IPO / ACQUISITION |
| `board_seat` | bool | Has board representation |
| `terms` | json? | Investment terms, expectations |

---

### Investor

External capital sources.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `name` | string | "Altitude Partners" |
| `type` | enum | VC / PE / FAMILY_OFFICE / SOVEREIGN / STRATEGIC / INDIVIDUAL / DEVELOPMENT_FUND |
| `aum` | bigint? | Assets under management |
| `focus` | string[] | ["aviation", "transport"] |
| `typical_check_size` | int? | Typical investment size |
| `typical_horizon_years` | int? | Expected hold period |
| `risk_tolerance` | float | 0.0 to 1.0 |
| `expectations` | json | `{revenue_growth: 0.20, exit_years: 5}` |
| `sentiment` | enum | PLEASED / SATISFIED / WATCHING / CONCERNED / UNHAPPY |
| `network_value` | int | Connections, introductions |
| `person_id` | FK? → Person | Key contact |

---

### Board

Board of directors for an airline.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `airline_id` | FK → Airline | Which airline |
| `overall_confidence` | enum | STRONG / GOOD / MIXED / LOW / CRITICAL |
| `next_meeting_date` | date | Scheduled meeting |
| `meeting_frequency` | enum | MONTHLY / QUARTERLY |

---

### BoardMember

Individual board director.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `board_id` | FK → Board | Which board |
| `person_id` | FK → Person | The person |
| `role` | enum | CHAIR / CEO / INVESTOR_REP / INDEPENDENT / GOVERNMENT_REP / EMPLOYEE_REP |
| `represents` | FK? → Investor | If investor representative |
| `joined_date` | date | When appointed |
| `focus_areas` | string[] | ["operations", "finance"] |
| `confidence_in_ceo` | enum | STRONG / GOOD / MIXED / LOW / CRITICAL |
| `current_concerns` | string[] | Active issues |
| `communication_style` | string | "direct", "diplomatic" |

---

### BoardMeeting

Record of board meetings.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `board_id` | FK → Board | Which board |
| `date` | date | Meeting date |
| `type` | enum | REGULAR / EMERGENCY / SPECIAL |
| `agenda` | json | Topics discussed |
| `results_presented` | json | Financial/operational results |
| `decisions` | json | Decisions made |
| `confidence_change` | int | Net change in confidence |
| `notable_quotes` | json? | Memorable statements |

---

### Stakeholder

Non-owner stakeholder groups.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `airline_id` | FK → Airline | Which airline |
| `type` | enum | SHAREHOLDERS / CREDITORS / EMPLOYEES / GOVERNMENT |
| `sentiment` | enum | PLEASED through HOSTILE |
| `trend` | enum | IMPROVING / STABLE / DECLINING |
| `top_concern` | string | Primary issue |
| `last_updated` | date | Last assessment |

---

### StockPrice

Public company stock tracking.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `airline_id` | FK → Airline | Which airline |
| `date` | date | Trading date |
| `open` | float | Opening price |
| `close` | float | Closing price |
| `high` | float | Day high |
| `low` | float | Day low |
| `volume` | bigint | Shares traded |
| `market_cap` | bigint | Market capitalization |

---

### AnalystCoverage

Wall Street coverage for public companies.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `airline_id` | FK → Airline | Which airline |
| `firm_name` | string | "Goldman Sachs" |
| `analyst_name` | string | Covering analyst |
| `rating` | enum | BUY / HOLD / SELL |
| `price_target` | float | Target price |
| `concerns` | string[] | Key concerns |
| `last_updated` | date | Last report |

---

## Domain: People & Organization

### Person

Named individuals in the game world.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `name` | string | Full name |
| `birth_date` | date? | For age calculation |
| `nationality` | string | Country code |
| `background` | string | Career summary |
| `portrait_id` | string? | Image reference |
| `personality` | json | `{risk_tolerance: 0.7, autonomy_preference: 0.5, communication_style: "direct", loyalty: 0.8, ambition: 0.9}` |
| `competencies` | json | `{strategic_thinking: 8, execution: 7, innovation: 6, cost_focus: 5, quality_focus: 8, people_skills: 7, industry_knowledge: 9}` (1-10 scale) |
| `current_employer_id` | FK? → Airline | Current employer |
| `current_role` | string? | Current position |
| `salary` | int? | Current compensation |
| `career_history` | json | Past positions |
| `network_strength` | int | Industry connections (1-10) |
| `available` | bool | Open to opportunities |
| `retirement_date` | date? | When they'll retire |

---

### Executive

C-suite position at an airline.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `person_id` | FK → Person | The person |
| `airline_id` | FK → Airline | The airline |
| `role` | enum | CEO / COO / CFO / CCO / CMO / CTO / CPO / CHRO / CSO |
| `hired_date` | date | Start date |
| `salary` | int | Base salary |
| `bonus_target_pct` | float | Target bonus as % |
| `equity_pct` | float? | Ownership stake |
| `autonomy_level` | int | 0-5 delegation level |
| `performance_rating` | enum | EXCEPTIONAL / GOOD / ADEQUATE / POOR / FAILING |
| `loyalty` | enum | COMMITTED / SOLID / WAVERING / LOOKING |
| `relationship_with_ceo` | int | -100 to +100 |
| `last_review_date` | date | Last performance review |

---

### DelegationSetting

Per-system delegation configuration.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `airline_id` | FK → Airline | Which airline |
| `system` | enum | PRICING / FLEET_ASSIGNMENT / MAINTENANCE / CREW / HR / FINANCE / MARKETING |
| `level` | int | 0 (manual) to 5 (full trust) |
| `responsible_executive_id` | FK? → Executive | Who handles it |
| `policy_id` | FK? → Policy | Governing policy |
| `last_changed` | date | When adjusted |

---

### Policy

Rules governing delegated operations.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `airline_id` | FK → Airline | Which airline |
| `category` | enum | COMMERCIAL / OPERATIONAL / FINANCIAL / HR / BRAND |
| `name` | string | "Leisure route pricing" |
| `description` | string | What it governs |
| `parameters` | json | `{target_margin: 0.15, min_load: 0.65}` |
| `active` | bool | Currently in effect |
| `created_date` | date | When established |

---

### Staff

Aggregate employee groups.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `airline_id` | FK → Airline | Which airline |
| `category` | enum | PILOTS / CABIN_CREW / GROUND / MAINTENANCE / ADMIN |
| `count` | int | Headcount |
| `avg_salary` | int | Average compensation |
| `avg_tenure_years` | float | Average service length |
| `morale` | enum | HIGH / GOOD / NEUTRAL / LOW / CRITICAL |
| `union_id` | FK? → Union | If unionized |
| `turnover_rate` | float | Annual turnover % |

---

### Union

Labor unions.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `name` | string | "Air Line Pilots Association" |
| `represents` | enum | PILOTS / CABIN_CREW / GROUND / ALL |
| `airlines` | FK[] → Airline | Represented at |
| `sentiment` | enum | Sentiment toward management |
| `current_demands` | json | Active negotiations |
| `contract_expiry` | date? | Current contract end |
| `strike_risk` | float | 0.0 to 1.0 |
| `leader_person_id` | FK? → Person | Union leader |

---

## Domain: Financials

### FinancialStatement

Periodic financial results.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `airline_id` | FK → Airline | Which airline |
| `period_type` | enum | MONTHLY / QUARTERLY / ANNUAL |
| `period_start` | date | Period beginning |
| `period_end` | date | Period ending |
| `revenue_passenger` | bigint | Ticket revenue |
| `revenue_cargo` | bigint | Freight revenue |
| `revenue_ancillary` | bigint | Fees, extras |
| `revenue_other` | bigint | Wet lease, etc. |
| `cost_fuel` | bigint | Fuel expense |
| `cost_crew` | bigint | Crew costs |
| `cost_maintenance` | bigint | MRO costs |
| `cost_airport` | bigint | Landing, handling |
| `cost_aircraft` | bigint | Lease, depreciation |
| `cost_overhead` | bigint | G&A, other |
| `ebitda` | bigint | Computed |
| `depreciation` | bigint | D&A |
| `interest` | bigint | Interest expense |
| `taxes` | bigint | Tax expense |
| `net_income` | bigint | Bottom line |
| `cash_end` | bigint | Ending cash |
| `debt_end` | bigint | Ending debt |

---

### Loan

Debt instruments.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `airline_id` | FK → Airline | Borrower |
| `lender_name` | string | "Banque Nationale" |
| `lender_type` | enum | BANK / DEVELOPMENT / GOVERNMENT / PRIVATE / BOND |
| `principal_original` | bigint | Original amount |
| `principal_remaining` | bigint | Outstanding |
| `interest_rate` | float | Annual rate |
| `term_months` | int | Loan term |
| `monthly_payment` | int | Debt service |
| `origination_date` | date | When taken |
| `maturity_date` | date | Final payment |
| `covenants` | json | `{debt_service_ratio: 1.5, max_leverage: 3.0}` |
| `covenant_status` | enum | COMPLIANT / WARNING / BREACHED |
| `secured` | bool | Asset-backed |
| `collateral` | string? | What secures it |

---

### Lease

Aircraft lease agreements.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `aircraft_id` | FK → Aircraft | Which aircraft |
| `lessor_id` | FK → Lessor | Who owns it |
| `lessee_id` | FK → Airline | Who operates it |
| `lease_type` | enum | OPERATING / FINANCE / WET |
| `monthly_rate` | int | Monthly payment |
| `term_months` | int | Lease term |
| `start_date` | date | Commencement |
| `end_date` | date | Expiration |
| `return_conditions` | json | Maintenance requirements |
| `buyout_option` | bool | Purchase option |
| `buyout_price` | int? | Option price |
| `early_termination_fee` | int? | Break fee |

---

### Lessor

Aircraft leasing companies.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `name` | string | "AerCap", "GECAS" |
| `portfolio_size` | int | Aircraft owned |
| `preferred_lessees` | json | Airline preferences |
| `relationship` | json | `{airline_id: relationship_score}` |

---

### FuelHedge

Fuel price hedging contracts.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `airline_id` | FK → Airline | Who hedged |
| `coverage_pct` | float | % of consumption hedged |
| `price_per_gallon` | float | Locked price |
| `start_date` | date | Hedge start |
| `end_date` | date | Hedge expiry |
| `notional_gallons` | bigint | Volume covered |

---

### Order

Aircraft orders with manufacturers.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `airline_id` | FK → Airline | Buyer |
| `manufacturer` | string | "Boeing", "Airbus" |
| `type_id` | FK → AircraftType | Aircraft type |
| `quantity` | int | Number ordered |
| `configuration_id` | FK → AircraftConfiguration | Planned config |
| `list_price_each` | bigint | Catalog price |
| `negotiated_discount` | float | Discount achieved |
| `deposit_paid` | bigint | Deposits made |
| `order_date` | date | When ordered |
| `delivery_window_start` | date | Earliest delivery |
| `delivery_window_end` | date | Latest delivery |
| `status` | enum | CONFIRMED / DEFERRED / CANCELLED |
| `next_delivery_date` | date? | Next aircraft |

---

## Domain: Brand & Commercial

### Brand

Airline brand perception.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `airline_id` | FK → Airline | Which airline |
| `reliability` | int | 0-100 score |
| `comfort` | int | 0-100 score |
| `service` | int | 0-100 score |
| `value` | int | 0-100 score |
| `prestige` | int | 0-100 score |
| `overall` | int | Weighted average |
| `trend` | enum | IMPROVING / STABLE / DECLINING |
| `last_updated` | date | Last calculation |

---

### Livery

Aircraft paint schemes.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `airline_id` | FK → Airline | Owner |
| `name` | string | "Standard", "Retro", "Special" |
| `primary_color` | string | Hex code |
| `secondary_color` | string | Hex code |
| `tail_design` | string | Design reference |
| `fuselage_design` | string | Design reference |
| `is_default` | bool | Standard livery |

---

### Lounge

Airport lounges.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `airport_id` | FK → Airport | Location |
| `airline_id` | FK → Airline | Operator |
| `name` | string | "Meridian Club" |
| `terminal` | string | Terminal location |
| `capacity` | int | Seats |
| `quality` | enum | BASIC / STANDARD / PREMIUM / FLAGSHIP |
| `annual_cost` | int | Operating cost |
| `opened_date` | date | When opened |

---

### Alliance

Airline alliances.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `name` | string | "SkyTeam", "Star Alliance" |
| `founded_date` | date | Establishment |
| `hq_city` | string | Headquarters |
| `member_count` | int | Number of members |

---

### AllianceMembership

Airline membership in alliances.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `alliance_id` | FK → Alliance | Which alliance |
| `airline_id` | FK → Airline | Which airline |
| `tier` | enum | FOUNDING / FULL / ASSOCIATE / CONNECTING |
| `joined_date` | date | When joined |
| `benefits` | json | What they receive |
| `obligations` | json | What they provide |

---

### Codeshare

Code-sharing agreements.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `operating_airline_id` | FK → Airline | Who flies |
| `marketing_airline_id` | FK → Airline | Who sells |
| `route_id` | FK → Route | Which route |
| `revenue_share` | float | Marketing carrier share |
| `start_date` | date | Agreement start |
| `end_date` | date? | Agreement end |

---

## Domain: Service & Suppliers

### Supplier

External service providers for onboard product.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `name` | string | "Gate Gourmet", "Panasonic Avionics" |
| `category` | enum | See `SupplierCategory` |
| `tier` | enum | BUDGET / STANDARD / PREMIUM |
| `quality_rating` | int | 1-100 quality score |
| `base_cost` | decimal | Standard rate for this supplier |
| `regions` | string[] | Regions/airports served |
| `min_contract_months` | int | Minimum contract length |
| `is_active` | bool | Available for new contracts |

---

### SupplierContract

Multi-year agreements with suppliers.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `airline_id` | FK → Airline | Contract holder |
| `supplier_id` | FK → Supplier | The supplier |
| `category` | enum | See `SupplierCategory` |
| `start_date` | date | Contract start |
| `end_date` | date | Contract end |
| `is_exclusive` | bool | Exclusivity clause |
| `volume_commitment` | int? | Minimum units per month |
| `volume_penalty_rate` | decimal? | Penalty per unit shortfall |
| `base_rate` | decimal | Negotiated base rate |
| `discount_percent` | float | Applied discounts |
| `service_level` | enum | STANDARD / PRIORITY / PREMIUM |
| `early_exit_penalty` | decimal | Fee to terminate early |
| `terms` | json | Full contract terms |
| `status` | enum | See `ContractStatus` |
| `renewal_offered` | bool? | Supplier offered renewal |
| `renewal_terms` | json? | Proposed renewal terms |

---

### ServiceProfile

Reusable service configuration bundles.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `airline_id` | FK → Airline | Owner (null for presets) |
| `name` | string | "Atlantic Business", "No Frills" |
| `is_preset` | bool | System-provided preset |
| `is_active` | bool | Available for assignment |
| `seat_amenities` | json | `{reading_light, ambient, air_vent, power_ac, power_usb_a, power_usb_c, wireless_charging}` |
| `ife_hardware` | json | `{screen_size, touchscreen, bluetooth, headphone_type}` |
| `ife_content` | json | `{movies, tv, live_tv, music, games}` |
| `connectivity` | json | `{wifi_tier, wifi_policy}` |
| `catering` | json | `{meal_type, menu_style, beverage_service, special_meals, snacks}` |
| `amenities` | json | `{kit_tier, blanket, pillow, slippers, eye_mask, pajamas}` |
| `estimated_cost_per_pax` | decimal | Calculated average cost |
| `comfort_contribution` | int | Calculated comfort bonus |
| `created_date` | date | When created |
| `last_modified` | date | When last updated |

---

### ServiceAssignment

Maps service profiles to flight duration categories and cabin classes.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `airline_id` | FK → Airline | Owner |
| `duration_category` | enum | See `DurationCategory` |
| `cabin_class` | enum | ECONOMY / PREMIUM_ECONOMY / BUSINESS / FIRST |
| `profile_id` | FK → ServiceProfile | Assigned profile |
| `effective_from` | date | When assignment takes effect |
| `effective_to` | date? | When assignment ends (null = ongoing) |

---

### RouteServiceOverride

Route-specific service profile overrides.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `route_id` | FK → Route | Which route |
| `cabin_class` | enum | Which cabin class |
| `profile_id` | FK → ServiceProfile | Override profile |
| `reason` | string? | Why overridden ("Flagship route") |
| `effective_from` | date | Override start |
| `effective_to` | date? | Override end |

---

## Domain: World Simulation

### Manufacturer

Aircraft manufacturers.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `name` | string | "Boeing", "Airbus" |
| `hq_country` | string | Headquarters country |
| `product_lines` | FK[] → AircraftType | What they make |
| `production_rate_monthly` | int | Output capacity |
| `backlog_years` | float | Order backlog |
| `financial_health` | enum | STRONG / STABLE / STRUGGLING |
| `relationship` | json | `{airline_id: relationship_level}` |

---

### MROProvider

Maintenance, repair, overhaul providers.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `name` | string | "Lufthansa Technik" |
| `locations` | FK[] → Airport | Where they operate |
| `capabilities` | enum[] | LINE / A_CHECK / C_CHECK / D_CHECK / ENGINE |
| `type_ratings` | FK[] → AircraftType | What they service |
| `quality` | enum | BASIC / GOOD / EXCELLENT |
| `cost_modifier` | float | vs. baseline (1.0 = average) |
| `turnaround_modifier` | float | Speed vs. baseline |

---

### EconomicCycle

Macroeconomic conditions.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `region` | enum | GLOBAL / NORTH_AMERICA / EUROPE / ASIA / etc. |
| `phase` | enum | BOOM / GROWTH / STABLE / SLOWDOWN / RECESSION |
| `gdp_growth` | float | Growth rate |
| `fuel_price_modifier` | float | Impact on fuel |
| `demand_modifier` | float | Impact on travel demand |
| `credit_availability` | enum | EASY / NORMAL / TIGHT |
| `effective_from` | date | When phase started |

---

### WorldEvent

Random and scripted events.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `type` | enum | ECONOMIC / POLITICAL / DISASTER / INDUSTRY / COMPETITIVE / OPPORTUNITY |
| `name` | string | "Oil Price Shock" |
| `description` | string | What happened |
| `date` | date | When it occurred |
| `duration_days` | int? | If temporary |
| `affected_regions` | enum[] | Which regions |
| `affected_airlines` | FK[]? → Airline | Specific airlines |
| `effects` | json | Mechanical impacts |
| `resolved` | bool | Still active |

---

## Domain: Passengers & Commercial

### PassengerSegment

Traveler categories with distinct preferences.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `name` | string | "Business", "Leisure", "Premium Leisure" |
| `code` | string | "BIZ", "LEI", "PRM" |
| `price_sensitivity` | float | 0.0 (insensitive) to 1.0 (very sensitive) |
| `time_sensitivity` | float | 0.0 to 1.0 |
| `comfort_weight` | float | How much comfort matters |
| `service_weight` | float | How much service matters |
| `reliability_weight` | float | How much OTP matters |
| `prestige_weight` | float | How much brand status matters |
| `value_weight` | float | How much price/quality ratio matters |
| `advance_booking_days` | int | Typical booking window |
| `flexibility_preference` | float | Willingness to pay for changes |

---

### FareClass

Revenue management fare buckets.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `airline_id` | FK → Airline | Which airline |
| `cabin` | enum | FIRST / BUSINESS / PREMIUM_ECONOMY / ECONOMY |
| `code` | string | "Y", "B", "M", "Q", etc. |
| `name` | string | "Full Fare Economy", "Discount" |
| `rank` | int | Hierarchy (higher = more expensive) |
| `refundable` | bool | Can cancel for refund |
| `changeable` | bool | Can modify |
| `advance_purchase_days` | int? | Minimum days before departure |
| `min_stay_days` | int? | Saturday night rule, etc. |
| `baggage_included` | int | Number of checked bags |
| `seat_selection` | enum | FREE / PAID / NONE |
| `lounge_access` | bool | Includes lounge |
| `multiplier` | float | vs. base fare |

---

### BookingSnapshot

Point-in-time demand and booking state for a flight.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `flight_id` | FK → Flight | Which flight |
| `snapshot_date` | date | When recorded |
| `days_to_departure` | int | Countdown |
| `bookings_j` | int | Business class booked |
| `bookings_y` | int | Economy booked |
| `revenue_to_date` | int | Collected so far |
| `forecast_final_load` | float | Predicted final |
| `demand_score` | float | Current demand level |

---

### DemandSnapshot

Time-series demand data for routes.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `route_id` | FK → Route | Which route |
| `date` | date | Snapshot date |
| `base_demand_business` | int | Before modifiers |
| `base_demand_leisure` | int | Before modifiers |
| `base_demand_cargo` | int | Before modifiers |
| `economic_modifier` | float | From EconomicCycle |
| `seasonal_modifier` | float | From seasonality |
| `event_modifier` | float | From WorldEvents |
| `competition_modifier` | float | From competitor capacity |
| `effective_demand_business` | int | Final demand |
| `effective_demand_leisure` | int | Final demand |
| `effective_demand_cargo` | int | Final demand |

---

### AncillaryProduct

Optional revenue products.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `airline_id` | FK → Airline | Which airline |
| `type` | enum | BAGGAGE / SEAT_SELECTION / WIFI / MEAL / LOUNGE / FAST_TRACK / INSURANCE |
| `name` | string | "Extra Legroom Seat" |
| `price` | int | Charge |
| `cost` | int | Delivery cost |
| `attach_rate` | float | % of passengers who buy |
| `cabin_restriction` | enum? | Only for certain cabins |
| `active` | bool | Currently offered |

---

### CargoContract

Freight agreements.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `airline_id` | FK → Airline | Carrier |
| `customer_name` | string | "DHL", "FedEx", etc. |
| `contract_type` | enum | SPOT / BLOCK_SPACE / DEDICATED |
| `routes` | FK[] → Route | Applicable routes |
| `volume_kg_weekly` | int | Committed volume |
| `rate_per_kg` | float | Price |
| `start_date` | date | Contract start |
| `end_date` | date | Contract end |
| `penalties` | json | For non-performance |

---

## Domain: Crew & Maintenance

### CrewPool

Aggregate crew resources (simplified model).

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `airline_id` | FK → Airline | Which airline |
| `type` | enum | PILOT / CABIN |
| `base_airport_id` | FK → Airport | Crew base |
| `count` | int | Headcount |
| `type_ratings` | FK[] → AircraftType | Qualified aircraft |
| `avg_salary` | int | Average compensation |
| `avg_experience_years` | float | Seniority |
| `utilization_pct` | float | Hours flown vs available |
| `fatigue_index` | float | 0.0 (rested) to 1.0 (stretched) |
| `shortage` | int | Understaffed by how many |

---

### MaintenanceEvent

Scheduled and unscheduled maintenance.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `aircraft_id` | FK → Aircraft | Which aircraft |
| `type` | enum | LINE / A_CHECK / B_CHECK / C_CHECK / D_CHECK / ENGINE_OVERHAUL / UNSCHEDULED |
| `provider_id` | FK? → MROProvider | If outsourced |
| `location_id` | FK → Airport | Where performed |
| `scheduled_start` | date | Planned start |
| `scheduled_end` | date | Planned end |
| `actual_start` | date? | When started |
| `actual_end` | date? | When completed |
| `status` | enum | SCHEDULED / IN_PROGRESS / COMPLETED / DEFERRED |
| `estimated_cost` | int | Budget |
| `actual_cost` | int? | Final cost |
| `findings` | json? | Issues discovered |
| `deferred_items` | json? | Pushed to next check |

---

### MaintenanceSchedule

Recurring maintenance planning.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `aircraft_id` | FK → Aircraft | Which aircraft |
| `check_type` | enum | A_CHECK / B_CHECK / C_CHECK / D_CHECK |
| `interval_hours` | int? | Hours between checks |
| `interval_cycles` | int? | Cycles between checks |
| `interval_months` | int? | Calendar interval |
| `last_completed` | date | Previous check |
| `next_due` | date | Upcoming check |
| `hours_remaining` | int? | Until due |
| `cycles_remaining` | int? | Until due |

---

## Domain: Regulatory & Government

### RegulatoryBody

Aviation authorities and government entities.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `name` | string | "FAA", "EASA", "DGAC" |
| `type` | enum | AVIATION_AUTHORITY / TRANSPORT_MINISTRY / COMPETITION_AUTHORITY |
| `jurisdiction` | string[] | Countries/regions |
| `strictness` | enum | LAX / MODERATE / STRICT |
| `corruption_index` | float | 0.0 (clean) to 1.0 (corrupt) |
| `relationship` | json | `{airline_id: relationship_score}` |

---

### Regulation

Rules that constrain operations.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `regulatory_body_id` | FK → RegulatoryBody | Who enforces |
| `type` | enum | SLOT / NOISE / EMISSIONS / OWNERSHIP / LABOR / SAFETY |
| `name` | string | "Night Flight Ban" |
| `description` | string | What it requires |
| `affected_airports` | FK[]? → Airport | If location-specific |
| `affected_regions` | enum[]? | If region-wide |
| `parameters` | json | Specific limits |
| `penalty_type` | enum | FINE / BAN / WARNING |
| `penalty_amount` | int? | If fine |
| `effective_date` | date | When it started |
| `sunset_date` | date? | If temporary |

---

### BilateralAgreement

Air service agreements between countries.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `country_a` | string | First country |
| `country_b` | string | Second country |
| `type` | enum | RESTRICTED / LIBERAL / OPEN_SKIES |
| `designated_carriers_a` | int? | How many from A |
| `designated_carriers_b` | int? | How many from B |
| `frequency_cap` | int? | Weekly flights allowed |
| `fifth_freedom` | bool | Beyond rights allowed |
| `cabotage` | bool | Domestic rights (rare) |
| `effective_date` | date | When signed |

---

## Domain: Pricing & Economics

### FuelPrice

Time-series fuel costs.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `date` | date | Price date |
| `region` | enum | GLOBAL / NORTH_AMERICA / EUROPE / ASIA / etc. |
| `price_per_gallon` | float | Spot price |
| `price_per_kg` | float | Converted |
| `trend` | enum | RISING / STABLE / FALLING |

---

### Currency

For multi-region operations.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `code` | string | "USD", "EUR", "GBP" |
| `name` | string | "US Dollar" |
| `symbol` | string | "$" |

---

### ExchangeRate

Currency conversion rates.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `from_currency_id` | FK → Currency | Source |
| `to_currency_id` | FK → Currency | Target |
| `date` | date | Rate date |
| `rate` | float | Conversion rate |

---

## Domain: Scenarios & Campaigns

### Scenario

Playable scenarios and campaigns.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `name` | string | "The Deregulation Gamble" |
| `description` | string | Scenario premise |
| `type` | enum | CAMPAIGN / HISTORICAL / CHALLENGE / TUTORIAL |
| `difficulty` | enum | EASY / MEDIUM / HARD / EXPERT |
| `era` | enum | ERA_1950 / ERA_1970 / etc. |
| `start_date` | date | In-game start |
| `end_date` | date? | If time-limited |
| `region` | enum | Starting region |
| `starting_airline_id` | FK? → Airline | If historical takeover |
| `starting_cash` | bigint | Initial funds |
| `starting_aircraft` | json | Fleet at start |
| `locked_settings` | json | What player can't change |

---

### ScenarioObjective

Goals within a scenario.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `scenario_id` | FK → Scenario | Parent scenario |
| `type` | enum | PRIMARY / SECONDARY / BONUS |
| `name` | string | "Survive Deregulation" |
| `description` | string | What to achieve |
| `metric` | string | "fleet_size", "cash", "routes", etc. |
| `target_value` | int | Goal value |
| `comparison` | enum | GTE / LTE / EQ | Greater/less/equal |
| `deadline_date` | date? | If time-bound |
| `reward` | json? | What completing gives |
| `failure_consequence` | json? | What missing causes |

---

### ScenarioEvent

Scripted events within scenarios.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `scenario_id` | FK → Scenario | Parent scenario |
| `trigger_type` | enum | DATE / METRIC / PLAYER_ACTION |
| `trigger_condition` | json | When it fires |
| `name` | string | "Oil Crisis Hits" |
| `description` | string | What happens |
| `effects` | json | Mechanical impacts |
| `choices` | json? | If player has options |
| `fired` | bool | Has it triggered |
| `fired_date` | date? | When it triggered |

---

## Domain: Tutorial & Progression

### TutorialProgress

Tracking FTUE and advisor state.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `game_state_id` | FK → GameState | Which save |
| `advisor_enabled` | bool | Advisor on/off |
| `advisor_dismissed_permanently` | bool | Never show again |
| `completed_steps` | string[] | Tutorial steps done |
| `current_step` | string? | Active tutorial |
| `tips_shown` | string[] | Contextual tips seen |
| `tips_dismissed` | string[] | Tips user said "don't show" |

---

### UnlockState

Feature unlocks based on progression.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `game_state_id` | FK → GameState | Which save |
| `feature` | string | "coo_position", "revenue_management", etc. |
| `unlocked` | bool | Available to use |
| `unlock_date` | date? | When unlocked |
| `unlock_trigger` | string? | What caused unlock |

---

### PlayerSettings

User preferences.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `game_state_id` | FK → GameState | Which save |
| `auto_pause_weekly` | bool | Pause each week |
| `auto_pause_monthly` | bool | Pause each month |
| `interrupt_aircraft_delivery` | bool | Pause on delivery |
| `interrupt_competitor_move` | bool | Pause on competition |
| `interrupt_acquisition` | bool | Pause on M&A opportunity |
| `interrupt_staff_resignation` | bool | Pause on departures |
| `interrupt_route_profitable` | bool | Pause when route turns profit |
| `interrupt_maintenance` | bool | Pause on maintenance complete |
| `default_game_speed` | enum | SLOW / NORMAL / FAST |
| `currency_display` | FK → Currency | Preferred currency |
| `date_format` | string | "DD/MM/YYYY" etc. |

---

## Domain: AI Behavior

### AIStrategy

Behavior parameters for AI airlines.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `airline_id` | FK → Airline | Which AI airline |
| `archetype` | enum | AGGRESSIVE_GROWTH / STEADY_INCUMBENT / COST_CUTTER / PREMIUM_NICHE / OPPORTUNIST |
| `risk_tolerance` | float | 0.0 to 1.0 |
| `growth_priority` | float | vs. profitability |
| `competition_response` | enum | IGNORE / MATCH / UNDERCUT / RETREAT |
| `hub_defense_intensity` | float | How hard they fight |
| `price_sensitivity` | float | How quickly they adjust fares |
| `fleet_preference` | json | Preferred aircraft types |
| `route_preference` | json | Preferred route types |
| `alliance_interest` | float | Likelihood to join/form |
| `acquisition_interest` | float | M&A appetite |

---

### Relationship

Current state of entity relationships.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `entity_a_type` | string | "Airline", "Person", etc. |
| `entity_a_id` | UUID | First party |
| `entity_b_type` | string | "Airline", "Person", etc. |
| `entity_b_id` | UUID | Second party |
| `relationship_type` | enum | BUSINESS / PERSONAL / COMPETITIVE / REGULATORY |
| `value` | int | -100 (hostile) to +100 (allied) |
| `trust` | int | -100 to +100 |
| `last_interaction` | date | Most recent contact |
| `notes` | string? | Context |

---

### CompetitorRelationship

Tracks competitive friction between the player and AI airlines. **Internal only** — player sees patterns, not this data.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `player_airline_id` | FK → Airline | Player's airline |
| `competitor_airline_id` | FK → Airline | AI competitor |
| `friction_score` | int | 0-100, higher = more competitive tension |
| `primary_overlap` | string? | Main point of conflict ("Lyon hub", "transatlantic") |
| `route_overlap_count` | int | Number of shared O&D pairs |
| `slot_conflicts` | int | Times they've competed for same slots |
| `talent_poached` | int | Staff lost to this competitor |
| `price_war_intensity` | float | Current pricing aggression (0.0-1.0) |
| `trend` | enum | ESCALATING / STABLE / COOLING |
| `last_major_action` | string? | Most recent significant move |
| `last_major_action_date` | date? | When it happened |
| `last_updated` | date | Last recalculation |

**Design note:** This powers the emergent rivalry system. No "nemesis" label is shown to player — they perceive rivalry through patterns in the Competitive Intelligence panel.

---

### FrictionEvent

Individual events that contribute to competitive friction.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `competitor_relationship_id` | FK → CompetitorRelationship | Parent relationship |
| `date` | date | When it occurred |
| `type` | enum | See `FrictionEventType` |
| `description` | string | Human-readable summary |
| `friction_impact` | int | Change to friction score |
| `route_id` | FK? → Route | If route-related |
| `airport_id` | FK? → Airport | If airport-related |
| `person_id` | FK? → Person | If talent-related |
| `metadata` | json? | Additional context |

---

## Domain: Player State

### Ambition

Player-stated goals.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `airline_id` | FK → Airline | Player's airline |
| `category` | enum | FLEET / GEOGRAPHIC / POSITIONING / SCALE / LEGACY |
| `target` | string | "Fly to New York", "25 aircraft" |
| `target_value` | int? | Numeric goal if applicable |
| `current_value` | int? | Current progress |
| `stated_date` | date | When declared |
| `target_date` | date? | Target completion |
| `status` | enum | ACTIVE / ACHIEVED / ABANDONED / SUPERSEDED |
| `achieved_date` | date? | When accomplished |

---

### Compromise

Tracking forced suboptimal decisions.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `airline_id` | FK → Airline | Player's airline |
| `date` | date | When it happened |
| `category` | enum | RESOURCE / TIMING / RELATIONSHIP / IDENTITY / ETHICAL |
| `context` | string | What led to it |
| `wanted` | string | What you wanted |
| `got` | string | What you accepted |
| `related_entity_type` | string? | "Aircraft", "Route", etc. |
| `related_entity_id` | UUID? | The specific entity |
| `status` | enum | ONGOING / RESOLVED / ACCEPTED |
| `resolution_date` | date? | When fixed |
| `resolution_description` | string? | How it was resolved |

---

### Obligation

Implicit debts created by compromises. **Not visible to player** — surfaces only when creditor calls it in.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `airline_id` | FK → Airline | Who owes |
| `creditor_type` | enum | GOVERNMENT / INVESTOR / UNION / COMPETITOR / LESSOR / BANK / OTHER |
| `creditor_id` | UUID? | FK to specific entity (Investor, RegulatoryBody, etc.) |
| `creditor_name` | string | Human-readable ("Ministry of Transport") |
| `origin_compromise_id` | FK → Compromise | What created this obligation |
| `origin_date` | date | When the deal was made |
| `terms_implicit` | string | What was understood ("maintain regional service") |
| `terms_explicit` | string? | If anything was written down |
| `status` | enum | OUTSTANDING / CALLED / HONORED / BROKEN / EXPIRED |
| `called_date` | date? | When creditor invoked it |
| `called_request` | string? | What they asked for |
| `response` | enum? | HONORED / PARTIAL / REFUSED |
| `response_date` | date? | When player responded |
| `relationship_impact` | int? | Effect on relationship (-100 to +100) |
| `notes` | string? | Additional context |

**Design note:** Player cannot see a list of outstanding obligations. They only know they "owe" someone. The tension comes from not knowing when or how it will be called in.

---

### Milestone

Achievement tracking.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `airline_id` | FK → Airline | Which airline |
| `type` | enum | FIRST_FLIGHT / FIRST_PROFIT / FIRST_INTERNATIONAL / etc. |
| `achieved_date` | date | When reached |
| `details` | json | Context (which aircraft, route, etc.) |
| `ceremony_shown` | bool | Player saw the popup |

---

### Alert

Player notifications.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `airline_id` | FK → Airline | Which airline |
| `created_date` | date | When generated |
| `priority` | enum | CRITICAL / IMPORTANT / ADVISORY / INFORMATIONAL |
| `category` | enum | OPPORTUNITY / PROBLEM / STRATEGIC / OPERATIONAL |
| `title` | string | Short description |
| `message` | string | Full text |
| `related_entity_type` | string? | What it's about |
| `related_entity_id` | UUID? | Specific entity |
| `action_required` | bool | Needs response |
| `action_deadline` | date? | When response needed |
| `dismissed` | bool | Player saw it |
| `resolved` | bool | Issue addressed |

---

### Decision

Log of major player decisions.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `airline_id` | FK → Airline | Which airline |
| `date` | date | When decided |
| `type` | enum | FLEET / ROUTE / FINANCIAL / STRATEGIC / PERSONNEL / GOVERNANCE |
| `description` | string | What was decided |
| `choice_made` | string | The option selected |
| `alternatives` | json | Options not chosen |
| `board_input` | json? | What board advised |
| `rationale` | string? | Player's stated reason |
| `outcome` | string? | How it turned out |
| `outcome_date` | date? | When outcome known |

---

## Domain: History & Biography

### AircraftHistoryEntry

Append-only log of aircraft events.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `aircraft_id` | FK → Aircraft | Which aircraft |
| `date` | date | When it happened |
| `event_type` | enum | See `AircraftHistoryEventType` in Enumerations |
| `description` | string | Human-readable |
| `owner_id` | FK? → Airline | Owner at time |
| `operator_id` | FK? → Airline | Operator at time |
| `location_id` | FK? → Airport | Where it happened |
| `related_entity_id` | UUID? | Route, maintenance event, etc. |
| `metadata` | json? | Additional details |

---

### RouteHistoryEntry

Log of route-level events.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `route_id` | FK → Route | Which route |
| `airline_id` | FK → Airline | Which airline |
| `date` | date | When it happened |
| `event_type` | enum | See `RouteHistoryEventType` in Enumerations |
| `description` | string | Human-readable |
| `context` | string? | "Launched against plan", etc. |
| `metadata` | json? | Frequency before/after, etc. |

---

### RelationshipHistory

Tracks relationship changes between entities.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `entity_a_type` | string | "Airline", "Person", etc. |
| `entity_a_id` | UUID | First party |
| `entity_b_type` | string | "Airline", "Person", etc. |
| `entity_b_id` | UUID | Second party |
| `date` | date | When changed |
| `relationship_type` | string | What kind |
| `value` | int | -100 to +100 |
| `reason` | string | What caused change |

---

## Domain: Game State

### GameState

Current game session state.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `current_date` | date | In-game date |
| `game_speed` | enum | PAUSED / SLOW / NORMAL / FAST / ULTRA |
| `era` | enum | ERA_1950 / ERA_1970 / ERA_1990 / ERA_2000 / ERA_2020 / FUTURE |
| `difficulty` | enum | FORGIVING / STANDARD / CHALLENGING / IRONMAN |
| `player_airline_id` | FK → Airline | Player's airline |
| `interrupts_enabled` | json | Which interrupts are on |
| `hours_played` | float | Real-time played |
| `last_save` | timestamp | Last save time |

---

### SaveGame

Save file metadata.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `game_state_id` | FK → GameState | The state |
| `name` | string | Save name |
| `created_at` | timestamp | When saved |
| `playtime_hours` | float | Total playtime |
| `game_date` | date | In-game date |
| `airline_name` | string | For display |
| `fleet_size` | int | For display |
| `cash` | bigint | For display |

---

## Enumeration Definitions

### Airline & Ownership

```
AirlineType:
  LEGACY          # Traditional full-service carrier
  LCC             # Low-cost carrier
  REGIONAL        # Regional/feeder airline
  CARGO           # Freight-focused
  CHARTER         # Charter/leisure
  STARTUP         # New entrant

AirlineStage:
  BOOTSTRAP       # 1-5 aircraft
  REGIONAL        # 5-20 aircraft
  NATIONAL        # 20-75 aircraft
  MAJOR           # 75-200 aircraft
  EMPIRE          # 200+ aircraft

CEOPhase:
  FOUNDER         # Hours 0-10: Doing everything
  MANAGER         # Hours 10-30: Building first team
  EXECUTIVE       # Hours 30-70: Running a real company
  CHAIRMAN        # Hours 70+: Shaping the industry

BrandDimension:
  RELIABILITY     # On-time performance, consistency
  COMFORT         # Seat quality, cabin experience
  SERVICE         # Crew quality, responsiveness
  VALUE           # Price/quality ratio
  PRESTIGE        # Status, brand cachet

OwnerType:
  FOUNDER         # Original founder(s)
  INVESTOR        # External investor
  PUBLIC          # Public shareholders
  GOVERNMENT      # State ownership
  OTHER_AIRLINE   # Strategic/parent airline
  EMPLOYEE        # Employee ownership

InvestorType:
  VC              # Venture capital
  PE              # Private equity
  FAMILY_OFFICE   # Family investment office
  SOVEREIGN       # Sovereign wealth fund
  STRATEGIC       # Industry investor
  INDIVIDUAL      # High-net-worth individual
  DEVELOPMENT_FUND # Regional/government development fund

InvestmentOption:
  BOOTSTRAP       # No external capital, maintain full control
  DEVELOPMENT_FUND # Low capital, high freedom, route commitments
  PRIVATE_INVESTOR # Medium capital, high freedom, quarterly updates
  VENTURE_CAPITAL  # High capital, medium freedom, growth targets, board seat
```

### Aircraft & Fleet

```
AircraftCategory:
  REGIONAL        # <100 seats, <2000nm
  NARROWBODY      # 100-240 seats, single aisle
  WIDEBODY        # 200-400 seats, twin aisle
  JUMBO           # 400+ seats
  CARGO           # Freighter

AircraftStatus:
  ACTIVE          # In service
  MAINTENANCE     # In scheduled maintenance
  AOG             # Aircraft on ground (unscheduled)
  STORED          # Parked, not in use
  SOLD            # Transferred to new owner

AircraftCondition:
  EXCELLENT       # Near-new, minimal wear
  GOOD            # Normal wear for age
  FAIR            # Above-average wear
  POOR            # Significant issues

AcquisitionType:
  NEW_ORDER       # Direct from manufacturer
  LEASE           # Operating or finance lease
  PURCHASE        # Secondary market purchase
  AUCTION         # Bankruptcy/liquidation auction
  MERGER          # Acquired via M&A

MaintenanceType:
  LINE            # Daily/turnaround checks
  A_CHECK         # ~500 hours, minor inspection
  B_CHECK         # ~6 months (if applicable)
  C_CHECK         # ~18-24 months, heavy
  D_CHECK         # ~6 years, structural
  ENGINE_OVERHAUL # Engine shop visit
  UNSCHEDULED     # Defect rectification

MaintenanceStatus:
  SCHEDULED       # Planned, not started
  IN_PROGRESS     # Currently in work
  COMPLETED       # Finished
  DEFERRED        # Postponed (with approval)
  CANCELLED       # No longer needed
```

### Operations

```
FlightStatus:
  SCHEDULED       # Future flight
  BOARDING        # Passengers boarding
  DEPARTED        # In flight
  ARRIVED         # Completed
  DELAYED         # Behind schedule
  CANCELLED       # Will not operate
  DIVERTED        # Landed elsewhere

DelayReason:
  WEATHER         # Weather conditions
  MECHANICAL      # Aircraft technical issue
  ATC             # Air traffic control
  CREW            # Crew availability
  PASSENGER       # Passenger-related
  SECURITY        # Security issue
  LATE_ARRIVAL    # Inbound aircraft late
  GROUND_OPS      # Airport/handling issue
  COMMERCIAL      # Load consolidation

Cabin:
  FIRST           # First class
  BUSINESS        # Business class
  PREMIUM_ECONOMY # Premium economy
  ECONOMY         # Economy class

SeatSelection:
  FREE            # Included in fare
  PAID            # Available for fee
  NONE            # Not available
```

### Governance & People

```
BoardConfidence:
  STRONG          # Full support
  GOOD            # Supportive with minor concerns
  MIXED           # Divided opinions
  LOW             # Significant concerns
  CRITICAL        # CEO position at risk

BoardMemberRole:
  CHAIR           # Board chairman
  CEO             # CEO (if board member)
  INVESTOR_REP    # Represents investor
  INDEPENDENT     # Independent director
  GOVERNMENT_REP  # Government appointee
  EMPLOYEE_REP    # Employee representative

StakeholderType:
  SHAREHOLDERS    # Equity owners
  CREDITORS       # Lenders
  EMPLOYEES       # Workforce
  GOVERNMENT      # Regulators, politicians

Sentiment:
  PLEASED         # Very positive
  SATISFIED       # Positive
  CONTENT         # Neutral-positive
  NEUTRAL         # No strong feeling
  WATCHING        # Concerned but waiting
  GRUMBLING       # Negative
  CONCERNED       # Actively worried
  UNHAPPY         # Very negative
  HOSTILE         # Adversarial

Trend:
  IMPROVING       # Getting better
  STABLE          # No change
  DECLINING       # Getting worse

ExecutiveRole:
  CEO             # Chief Executive Officer
  COO             # Chief Operating Officer
  CFO             # Chief Financial Officer
  CCO             # Chief Commercial Officer
  CMO             # Chief Marketing Officer
  CTO             # Chief Technology Officer
  CPO             # Chief Procurement Officer
  CHRO            # Chief Human Resources Officer
  CSO             # Chief Strategy Officer

DelegationLevel:
  0               # Direct control - every decision
  1               # Assisted - recommendations provided
  2               # Approval - review and approve/reject
  3               # Guidelines - set policies, system executes
  4               # Oversight - review outcomes only
  5               # Trust - goals only, full autonomy

PerformanceRating:
  EXCEPTIONAL     # Top performer
  GOOD            # Above average
  ADEQUATE        # Meeting expectations
  POOR            # Below expectations
  FAILING         # Not acceptable

LoyaltyLevel:
  COMMITTED       # Very loyal
  SOLID           # Reliable
  WAVERING        # Uncertain
  LOOKING         # Actively seeking other options

RecruitmentChannel:
  DIRECT_APPROACH     # Personal contact, no fees, visible to market
  EXECUTIVE_SEARCH    # Headhunter, discreet, expensive
  INTERNAL_PROMOTION  # Culture fit, loyalty, may lack outside perspective
  INDUSTRY_NETWORK    # Relationships built over time
  OPPORTUNISTIC       # Bankruptcies, mergers release talent

PolicyCategory:
  COMMERCIAL      # Pricing, revenue management, sales
  OPERATIONAL     # Scheduling, maintenance, crew
  FINANCIAL       # Budgeting, hedging, capital
  HR              # Hiring, compensation, training
  BRAND           # Marketing, product, customer experience

DelegationSystem:
  PRICING             # Fare setting and revenue management
  FLEET_ASSIGNMENT    # Which aircraft on which route
  MAINTENANCE         # Check scheduling, provider selection
  CREW                # Roster building, training
  HR                  # Hiring, firing, compensation
  FINANCE             # Budgeting, cash management
  MARKETING           # Campaigns, partnerships
```

### Financial

```
LeaseType:
  OPERATING       # Off-balance sheet, return at end
  FINANCE         # On-balance sheet, ownership transfer
  WET             # Includes crew and maintenance

CovenantStatus:
  COMPLIANT       # Within limits
  WARNING         # Approaching limits
  BREACHED        # Violated

LenderType:
  BANK            # Commercial bank
  DEVELOPMENT     # Development bank (EBRD, etc.)
  GOVERNMENT      # Government loan/guarantee
  PRIVATE         # Private credit
  BOND            # Bond holders
```

### World & Events

```
EconomicPhase:
  BOOM            # Strong growth
  GROWTH          # Moderate growth
  STABLE          # Flat
  SLOWDOWN        # Declining growth
  RECESSION       # Negative growth

CreditAvailability:
  EASY            # Abundant credit
  NORMAL          # Standard conditions
  TIGHT           # Restricted lending

WorldEventType:
  ECONOMIC        # Recession, boom, currency crisis
  POLITICAL       # Regulation, sanctions, agreements
  DISASTER        # Pandemic, volcano, earthquake
  INDUSTRY        # Manufacturer issue, fuel crisis
  COMPETITIVE     # Merger, bankruptcy, new entrant
  OPPORTUNITY     # Slot release, aircraft available

Region:
  NORTH_AMERICA   
  SOUTH_AMERICA   
  EUROPE          
  MIDDLE_EAST     
  AFRICA          
  ASIA            
  OCEANIA         
  GLOBAL          # Affects all regions

AIArchetype:
  AGGRESSIVE_GROWTH   # Expand at all costs
  STEADY_INCUMBENT    # Defend position
  COST_CUTTER         # Minimize costs
  PREMIUM_NICHE       # Quality focus
  OPPORTUNIST         # React to market
  STATE_SUPPORTED     # Government backed

CompetitionResponse:
  IGNORE          # Don't react
  MATCH           # Match competitor moves
  UNDERCUT        # Beat competitor on price
  RETREAT         # Exit contested markets
```

### Scenarios & Game State

```
ScenarioType:
  CAMPAIGN        # Multi-objective story
  HISTORICAL      # Real airline takeover
  CHALLENGE       # Single objective puzzle
  TUTORIAL        # Learning scenario

Difficulty:
  FORGIVING       # Easy, mistakes forgiven
  STANDARD        # Normal challenge
  CHALLENGING     # Hard, tight margins
  IRONMAN         # No save-scumming, permadeath

GameSpeed:
  PAUSED          # Time stopped
  SLOW            # 1 hour = 2 seconds
  NORMAL          # 1 hour = 1 second
  FAST            # 1 hour = 0.5 seconds
  ULTRA           # Skip to event

Era:
  ERA_1950        # 1945-1965, prop era
  ERA_1970        # 1965-1985, jet age
  ERA_1990        # 1985-2005, deregulation
  ERA_2000        # 2005-2020, consolidation
  ERA_2020        # 2020-present, modern
  FUTURE          # 2030+, speculative

AlertPriority:
  CRITICAL        # Requires immediate attention
  IMPORTANT       # Should address soon
  ADVISORY        # Worth knowing
  INFORMATIONAL   # FYI only

AlertCategory:
  OPPORTUNITY     # Positive possibility
  PROBLEM         # Issue to fix
  STRATEGIC       # Long-term consideration
  OPERATIONAL     # Day-to-day matter

CompromiseCategory:
  RESOURCE        # Couldn't afford ideal
  TIMING          # Right thing unavailable
  RELATIONSHIP    # Trade-off with partner
  IDENTITY        # Against airline vision
  ETHICAL         # Right vs. profitable

CompromiseStatus:
  ONGOING         # Still living with it
  RESOLVED        # Fixed/replaced
  ACCEPTED        # Made peace with it

AmbitionCategory:
  FLEET           # "I want 25 aircraft", "I want a 787"
  GEOGRAPHIC      # "I want to fly to New York", "Go international"
  POSITIONING     # "Premium experience", "Lowest cost"
  SCALE           # "National carrier", "Industry leader"
  LEGACY          # "An airline for 100 years"

AmbitionStatus:
  ACTIVE          # Currently pursuing
  ACHIEVED        # Reached the goal
  ABANDONED       # Gave up
  SUPERSEDED      # Replaced by new ambition

PlayerArchetype:
  VISIONARY       # Plays for the dream
  OPPORTUNIST     # Plays for adaptation
  OPERATOR        # Plays for excellence
  LEGACY_BUILDER  # Plays for permanence

MilestoneType:
  FIRST_FLIGHT
  FIRST_PROFIT
  FIRST_INTERNATIONAL
  FIRST_WIDEBODY
  FIRST_HUB
  FLEET_SIZE_10
  FLEET_SIZE_25
  FLEET_SIZE_50
  FLEET_SIZE_100
  REVENUE_100M
  REVENUE_500M
  REVENUE_1B
  IPO
  ALLIANCE_JOINED
  AIRCRAFT_RETIRED
  CRISIS_SURVIVED

AircraftHistoryEventType:
  # Lifecycle
  MANUFACTURED        # Built at factory
  DELIVERED           # Delivered to operator
  SOLD                # Ownership transferred
  LEASED              # Entered lease agreement
  RETURNED            # Returned from lease
  # Configuration
  CONFIGURED          # Cabin reconfiguration
  REPAINTED           # New livery
  RENAMED             # Name changed
  CONVERTED_CARGO     # Pax to freighter
  # Maintenance
  MAINTENANCE_A       # A-check
  MAINTENANCE_B       # B-check
  MAINTENANCE_C       # C-check
  MAINTENANCE_D       # D-check
  ENGINE_CHANGE       # Engine swap
  # Operational
  INCIDENT            # Minor issue
  ACCIDENT            # Safety event
  STORED              # Into storage
  REACTIVATED         # Out of storage
  # End of life
  RETIRED             # Out of service
  SCRAPPED            # Dismantled

RouteHistoryEventType:
  LAUNCHED            # Route opened
  SUSPENDED           # Temporarily halted
  RESUMED             # Restarted
  EXITED              # Permanently closed
  FREQUENCY_CHANGE    # Schedule adjustment
  AIRCRAFT_CHANGE     # Different equipment
  PRICING_CHANGE      # Fare adjustment
  COMPETITOR_ENTRY    # New competitor
  COMPETITOR_EXIT     # Competitor left

PrestigeEventType:
  # Milestones
  CYCLE_MILESTONE     # 10k, 25k, 50k cycles
  HOUR_MILESTONE      # Major flight hour achievements
  ANNIVERSARY         # Years in service
  # Notable service
  VIP_TRANSPORT       # Carried dignitary, celebrity
  STATE_VISIT         # Official government use
  FLAGSHIP_ROUTE      # Assigned to premium route
  INAUGURAL_FLIGHT    # First flight on new route
  # Character events
  INCIDENT_SURVIVED   # Bird strike, emergency landing
  RECORD_FLIGHT       # Longest, fastest, etc.
  CREW_FAVORITE       # Designated by pilots/crew
  RETIREMENT_CEREMONY # Formal sendoff

ObligationStatus:
  OUTSTANDING         # Debt exists, not yet called
  CALLED              # Creditor has invoked it
  HONORED             # Player fulfilled the obligation
  BROKEN              # Player refused or failed
  EXPIRED             # Time-limited obligation lapsed

ObligationCreditorType:
  GOVERNMENT          # Ministry, regulator
  INVESTOR            # VC, PE, angel
  UNION               # Labor organization
  COMPETITOR          # Other airline (rare)
  LESSOR              # Aircraft leasing company
  BANK                # Lender
  OTHER               # Catch-all

ObligationResponse:
  HONORED             # Full compliance
  PARTIAL             # Minimum viable compliance
  REFUSED             # Declined to comply

FrictionEventType:
  # Route competition
  ROUTE_ENTRY         # Competitor entered your route
  ROUTE_EXPANSION     # Competitor added frequency
  PRICE_UNDERCUT      # Competitor lowered fares
  # Hub competition
  HUB_ENCROACHMENT    # Competitor opened base in your territory
  GATE_COMPETITION    # Competing for same gates
  SLOT_COMPETITION    # Competing for same slots
  # Talent
  TALENT_POACHED      # Your staff left for competitor
  # Resolution
  ROUTE_EXIT          # Competitor left route
  PRICE_NORMALIZATION # Price war ended
  MARKET_SHARE_SHIFT  # Significant share change

CompetitorTrend:
  ESCALATING          # Friction increasing
  STABLE              # No significant change
  COOLING             # Friction decreasing

ServicePhase:
  BOARDING            # Passengers boarding
  TAXI_OUT            # Pushback and taxi
  TAKEOFF             # Departure roll and climb
  CLIMB               # Climbing to cruise
  CRUISE              # At cruise altitude
  MEAL_SERVICE        # Meal/beverage service active
  REST                # Cabin lights dimmed, quiet time
  DESCENT             # Descending to destination
  APPROACH            # Final approach
  TAXI_IN             # After landing, taxi to gate
  DEBOARDING          # Passengers deplaning

FlightPhase:
  PREFLIGHT           # Before departure
  BOARDING            # Pax boarding
  GROUND              # On ground, doors closed
  AIRBORNE            # In flight
  LANDED              # On ground at destination
  COMPLETE            # Flight finished

PaxMood:
  HAPPY               # Satisfied, comfortable
  NEUTRAL             # Acceptable conditions
  CRAMPED             # Uncomfortable seating
  IRRITATED           # Poor service, delays
  SLEEPING            # Asleep (night flights)

PaxActivity:
  SLEEPING            # Asleep
  EATING              # Meal service
  WATCHING            # IFE/screens
  WORKING             # Laptop/work
  READING             # Book/magazine
  IDLE                # Just sitting

CabinLighting:
  DAY                 # Full cabin lighting
  DIMMED              # Reduced for comfort
  NIGHT               # Night mode, minimal light

TurbulenceLevel:
  NONE                # Smooth flight
  LIGHT               # Minor bumps
  MODERATE            # Noticeable movement
  SEVERE              # Significant turbulence

SupplierCategory:
  SEAT_MANUFACTURER   # Seat hardware
  IFE_HARDWARE        # Screens, controllers
  IFE_CONTENT         # Movies, TV, music
  CONNECTIVITY        # WiFi providers
  CATERING            # Meal providers
  AMENITY_KIT         # Blankets, pillows, kits
  GROUND_HANDLING     # Airport services

SupplierTier:
  BUDGET              # Cost-focused, basic quality
  STANDARD            # Balance of cost and quality
  PREMIUM             # Quality-focused, higher cost

ContractServiceLevel:
  STANDARD            # Normal response times
  PRIORITY            # Faster response, dedicated support
  PREMIUM             # Best service, account manager

ContractStatus:
  NEGOTIATING         # In discussion
  ACTIVE              # Current and valid
  EXPIRING            # Within 90 days of end
  EXPIRED             # Past end date
  TERMINATED          # Ended early

DurationCategory:
  ULTRA_SHORT         # <1 hour
  SHORT               # 1-2 hours
  MEDIUM              # 2-5 hours
  LONG                # 5-10 hours
  ULTRA_LONG          # 10-14 hours
  EXTREME             # 14+ hours

MealType:
  NONE                # No meal service
  SNACK               # Light snacks only
  LIGHT_MEAL          # Simple meal
  FULL_MEAL           # Standard meal service
  MULTI_COURSE        # Multiple courses
  CHEF_PREPARED       # Premium chef-designed

BeverageService:
  NONE                # No beverages (water only)
  NON_ALCOHOLIC       # Soft drinks, juice, coffee
  BASIC_BAR           # Standard spirits, beer, wine
  PREMIUM_BAR         # Top-shelf, champagne

AmenityKitTier:
  NONE                # No kit provided
  BASIC               # Essential items only
  STANDARD            # Good quality items
  PREMIUM             # High-end items
  LUXURY              # Designer branded

WiFiPolicy:
  NONE                # No WiFi available
  PAID_ONLY           # All usage is paid
  MESSAGING_FREE      # Chat apps free, browsing paid
  FREE_PREMIUM_CABIN  # Free for business+, paid economy
  FREE_LONG_HAUL      # Free on long flights only
  FREE_ALL            # Free for all passengers

HeadphoneType:
  NONE                # No headphones provided
  BASIC               # Standard earbuds
  OVER_EAR            # Better quality over-ear
  NOISE_CANCELING     # Active noise cancellation

EconomicEraType:
  JET_AGE_DAWN        # 1958-1970
  WIDEBODY_REVOLUTION # 1970-1978
  DEREGULATION_CHAOS  # 1978-1990
  GLOBAL_EXPANSION    # 1990-2001
  POST_911            # 2001-2010
  MODERN_ERA          # 2010-2025
  NEAR_FUTURE         # 2025-2040

FuelPriceLevel:
  VERY_LOW            # Bottom 10% historical
  LOW                 # 10-30%
  NORMAL              # 30-70%
  HIGH                # 70-90%
  CRISIS              # Top 10% historical

InterestRateEnvironment:
  LOW                 # < 4%
  MODERATE            # 4-8%
  HIGH                # 8-12%
  CRISIS              # > 12%
```

---

## Validation Rules

### Business Rules

```yaml
Ownership:
  - Sum of stake_percent for an airline must equal 100.0
  - stake_percent must be between 0.0 and 100.0
  - Only one owner can have board_seat per ownership record

Aircraft:
  - total_hours must be >= hours_since_last_check
  - manufactured_date must be <= acquisition_date
  - If status is SOLD, owner_id must differ from previous owner
  - registration must be unique among ACTIVE aircraft

Schedule:
  - aircraft_id must belong to airline_id
  - frequency_per_week must be between 1 and 21 (3x daily)
  - effective_to must be > effective_from if set
  - Cannot schedule aircraft during MaintenanceEvent

Flight:
  - date must be within Schedule effective_from/to range
  - load_factor must be between 0.0 and 1.0
  - pax_business + pax_economy must be <= aircraft configuration total_seats

Loan:
  - principal_remaining must be <= principal_original
  - maturity_date must be > origination_date
  - monthly_payment must be > 0

Lease:
  - end_date must be > start_date
  - aircraft_id can only have one active lease at a time

Executive:
  - airline_id can only have one person per role (no duplicate COOs)
  - autonomy_level must be between 0 and 5

DelegationSetting:
  - If level >= 3, responsible_executive_id should be set
  - If level >= 3, policy_id should be set

Board:
  - Must have at least 1 BoardMember if airline stage >= NATIONAL
  - Cannot have more than 12 BoardMembers

Route:
  - origin_id must differ from destination_id
  - distance_nm must be > 0

Slot:
  - airline_id can only hold slots up to airport total_slots
  - Must maintain 80% utilization or lose slot (use_it_or_lose_it)

FuelHedge:
  - coverage_pct must be between 0.0 and 1.0
  - end_date must be > start_date

Order:
  - deposit_paid must be <= list_price_each * quantity * 0.30 (typical max)
  - delivery_window_end must be >= delivery_window_start
```

### Referential Integrity

```yaml
Cascade Delete:
  - Airline deletion → cascades to all owned Aircraft, Routes, Staff, etc.
  - Aircraft deletion → cascades to AircraftHistoryEntry, MaintenanceEvent
  - Person deletion → nullifies Executive, BoardMember references

Restrict Delete:
  - Cannot delete Airport if referenced by active Routes
  - Cannot delete AircraftType if referenced by active Aircraft
  - Cannot delete Airline if has outstanding Loans with principal_remaining > 0

Nullify on Delete:
  - If Investor deleted → Ownership.owner_id set to null
  - If MROProvider deleted → MaintenanceEvent.provider_id set to null
```

---

## Computed Fields

### Aircraft

```python
Aircraft.age_years:
  (current_date - manufactured_date).days / 365.25

Aircraft.book_value:
  # Straight-line depreciation over 25 years to 10% residual
  original_cost = AircraftType.list_price_usd
  residual = original_cost * 0.10
  annual_depreciation = (original_cost - residual) / 25
  book_value = max(residual, original_cost - (age_years * annual_depreciation))

Aircraft.utilization_hours_per_day:
  # Average over last 30 days
  flights = Flight.where(aircraft_id=self, date > current_date - 30)
  total_block_hours = sum(flight.route.block_time_minutes / 60 for flight in flights)
  return total_block_hours / 30
```

### Airline

```python
Airline.fleet_size:
  count(Aircraft.where(owner_id=self, status in [ACTIVE, MAINTENANCE, AOG]))

Airline.route_count:
  count(distinct Schedule.route_id where airline_id=self and status=ACTIVE)

Airline.stage:
  # Auto-computed from fleet_size
  if fleet_size <= 5: return BOOTSTRAP
  if fleet_size <= 20: return REGIONAL
  if fleet_size <= 75: return NATIONAL
  if fleet_size <= 200: return MAJOR
  return EMPIRE

Airline.debt_to_ebitda:
  total_debt = sum(Loan.principal_remaining where airline_id=self)
  latest_annual = FinancialStatement.where(airline_id=self, period_type=ANNUAL).latest()
  return total_debt / latest_annual.ebitda if latest_annual.ebitda > 0 else infinity

Airline.cash_runway_days:
  if monthly_burn >= 0: return infinity  # Not burning cash
  return (cash / abs(monthly_burn)) * 30
```

### Route

```python
Route.effective_demand:
  # Apply all modifiers to base demand
  economic = EconomicCycle.where(region=self.origin.region).latest().demand_modifier
  seasonal = self.seasonality[current_month]
  events = sum(WorldEvent.where(affects_route=self, resolved=false).effect.demand_modifier)
  
  return {
    business: base_demand_business * economic * seasonal * (1 + events),
    leisure: base_demand_leisure * economic * seasonal * (1 + events),
  }

Route.competition_capacity:
  # Total weekly seats from all carriers
  schedules = Schedule.where(route_id=self, status=ACTIVE)
  return sum(s.frequency_per_week * s.aircraft.configuration.total_seats for s in schedules)

Route.our_market_share:
  our_capacity = sum(s.frequency_per_week * s.aircraft.configuration.total_seats 
                     for s in Schedule.where(route_id=self, airline_id=player_airline, status=ACTIVE))
  return our_capacity / competition_capacity if competition_capacity > 0 else 1.0
```

### Brand

```python
Brand.overall:
  # Weighted average based on passenger segment mix
  weights = {
    reliability: 0.25,
    comfort: 0.20,
    service: 0.20,
    value: 0.20,
    prestige: 0.15,
  }
  return sum(getattr(self, attr) * weight for attr, weight in weights.items())

Brand.trend:
  previous = BrandSnapshot.where(airline_id=self.airline_id).order_by(date.desc)[1]
  if overall > previous.overall + 2: return IMPROVING
  if overall < previous.overall - 2: return DECLINING
  return STABLE
```

### Financial

```python
FinancialStatement.ebitda:
  revenue = revenue_passenger + revenue_cargo + revenue_ancillary + revenue_other
  costs = cost_fuel + cost_crew + cost_maintenance + cost_airport + cost_aircraft + cost_overhead
  return revenue - costs

FinancialStatement.margin_pct:
  revenue = revenue_passenger + revenue_cargo + revenue_ancillary + revenue_other
  return (net_income / revenue) * 100 if revenue > 0 else 0

Loan.debt_service_coverage:
  # EBITDA / annual debt service
  annual_payment = monthly_payment * 12
  latest_ebitda = FinancialStatement.where(airline_id=self.airline_id, period_type=ANNUAL).latest().ebitda
  return latest_ebitda / annual_payment if annual_payment > 0 else infinity

Loan.covenant_status:
  for covenant_name, required_value in covenants.items():
    actual = compute_covenant_value(covenant_name)
    if actual < required_value * 0.9: return BREACHED
    if actual < required_value * 1.1: return WARNING
  return COMPLIANT
```

### Board

```python
Board.overall_confidence:
  votes = [member.confidence_in_ceo for member in self.members]
  # Convert to numeric, weight by role
  weights = {CHAIR: 2, INVESTOR_REP: 1.5, INDEPENDENT: 1, GOVERNMENT_REP: 1}
  weighted_sum = sum(confidence_to_int(v) * weights.get(m.role, 1) for v, m in zip(votes, self.members))
  weighted_count = sum(weights.get(m.role, 1) for m in self.members)
  avg = weighted_sum / weighted_count
  
  if avg >= 4: return STRONG
  if avg >= 3: return GOOD
  if avg >= 2: return MIXED
  if avg >= 1: return LOW
  return CRITICAL
```

---

## Event Triggers

### Automatic Events

```yaml
Daily:
  - Update all Flight statuses based on schedule
  - Calculate daily revenue/costs
  - Check aircraft maintenance due dates
  - Update FuelPrice from economic model
  - Process AI airline decisions

Weekly:
  - Generate weekly summary Alert
  - Update Route.competition from AI schedules
  - Recalculate Staff.morale based on conditions
  - Check Slot utilization (use-it-or-lose-it)

Monthly:
  - Generate FinancialStatement (MONTHLY)
  - Update Brand scores from passenger feedback
  - Check Loan covenant compliance
  - Update Stakeholder sentiment
  - Process Lease payments
  - Update aircraft hours_since_last_check

Quarterly:
  - Generate FinancialStatement (QUARTERLY)
  - Trigger BoardMeeting if stage >= NATIONAL
  - Update analyst ratings if is_public
  - Generate StockPrice movement if is_public
  - Evaluate Ambition progress
  - Check for WorldEvent generation

Annually:
  - Generate FinancialStatement (ANNUAL)
  - Update EconomicCycle phase
  - Evaluate Union contract expirations
  - Update aircraft depreciation
  - Check Order delivery windows
```

### Threshold Triggers

```yaml
Crisis Triggers:
  - cash_runway_days < 60 AND monthly_burn < 0 → CRISIS_CASH alert
  - Loan.covenant_status = BREACHED → CRISIS_COVENANT alert
  - Board.overall_confidence = CRITICAL → CRISIS_BOARD alert
  - Staff.morale = CRITICAL for PILOTS → CRISIS_STRIKE alert

Milestone Triggers:
  - fleet_size crosses 10/25/50/100 → FLEET_SIZE milestone
  - First FinancialStatement with net_income > 0 → FIRST_PROFIT milestone
  - First Route to different region → FIRST_INTERNATIONAL milestone
  - First Aircraft with category = WIDEBODY → FIRST_WIDEBODY milestone
  - First Alliance membership → ALLIANCE_JOINED milestone

Unlock Triggers:
  # Features
  - fleet_size >= 5 → unlock "scheduling_assistant"
  - fleet_size >= 10 → unlock "coo_position", "fleet_delegation"
  - route_count >= 25 → unlock "revenue_management"
  - revenue >= 100M → unlock "full_csuite"
  - fleet_size >= 50 → unlock "advanced_analytics"
  - route_count >= 100 → unlock "policy_system"
  - revenue >= 500M → unlock "board_of_directors"
  - fleet_size >= 200 → unlock "ai_optimization"
  - revenue >= 1B → unlock "holding_company"
  
  # Executive Positions (GDD Section 9)
  - fleet_size >= 10 → unlock COO position
  - revenue >= 50M → unlock CFO position
  - route_count >= 20 → unlock CCO position
  - brand_score >= 50 → unlock CMO position
  - fleet_size >= 30 → unlock CTO position
  - fleet_size >= 50 → unlock CPO position
  - staff_count >= 500 → unlock CHRO position
  - route_count >= 100 → unlock CSO position

Stage Transition Triggers:
  - fleet_size crosses threshold → update Airline.stage
  - Stage increase → generate stage-specific events (investor offers, etc.)

Competition Response Triggers:
  - Player enters AI airline's hub → AI evaluates response based on AIStrategy
  - Player undercuts AI fare by >15% → AI considers matching/retreat
  - AI loses >20% market share on route → AI considers exit or fight
```

### Player Action Triggers

```yaml
Route Actions:
  - Open new route → update Route.competition, notify AI airlines
  - Close route → free up aircraft, update market shares
  - Change frequency → recalculate demand capture

Fleet Actions:
  - Acquire aircraft → create AircraftHistoryEntry
  - Sell aircraft → update biography, transfer to new owner
  - Configure aircraft → schedule downtime, update capacity

Financial Actions:
  - Take loan → check covenant requirements, add to obligations
  - IPO decision → transform ownership structure, add public mechanics
  - Accept investment → add Investor, create Ownership, BoardMember

Personnel Actions:
  - Hire executive → check market availability, competitor reaction
  - Fire executive → morale impact, replacement needed
  - Change delegation level → adjust automation behavior

Governance Actions:
  - Board meeting response → update BoardMember confidence
  - Stakeholder negotiation → update sentiment, create obligations
```

### WorldEvent Generation

```yaml
Random Event Pool:
  base_probability: 0.02 per week per event type
  
  modifiers:
    - Economic events more likely when EconomicCycle at extremes
    - Industry events more likely when Manufacturer.financial_health = STRUGGLING
    - Competitive events more likely when market concentrated
    - Political events more likely in certain regions

  constraints:
    - Maximum 2 major events per quarter
    - Minimum 30 days between same event type
    - Some events require preconditions (e.g., merger requires 2 struggling airlines)

Scripted Events (Scenarios):
  - Fire based on ScenarioEvent.trigger_condition
  - Historical scenarios have fixed event timelines
  - Campaign scenarios mix scripted + random
```

---

## Performance Notes

### High-Read Tables
- `Aircraft` - Frequently accessed for fleet views
- `Schedule` - Core to operations
- `Flight` - High volume, partition by date
- `FinancialStatement` - Dashboard queries

### Recommended Indexes
- `aircraft(owner_id, type_id, status)`
- `schedule(airline_id, route_id, aircraft_id)`
- `flight(schedule_id, date)`
- `loan(airline_id, covenant_status)`

### Archival Strategy
- Flights older than 2 game-years → cold storage
- Keep monthly aggregates indefinitely
- Never delete history entries (core to biography feature)

---

## Migration from Airline Club

### Key Transformations
1. Add biography fields to Aircraft (acquisition_context, etc.)
2. Add stage/ownership/governance to Airlines
3. Create new tables: Person, Board, Investor, Compromise, Ambition
4. Convert static configs to AircraftConfiguration entities
5. Add relationship tracking throughout

### Seed Data Requirements
- ~150 AircraftType models covering 1950s-2030s
- ~4,000 airports with ICAO codes
- 5-6 manufacturers with production data
- Historical airlines for scenario mode

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 0.1 | January 2026 | Initial draft from GDD extraction |
| 0.2 | January 2026 | Added missing domains: Passengers, Crew, Maintenance, Regulatory, Pricing, Scenarios, Tutorial, AI. Added structural sections: Enumerations, Validation Rules, Computed Fields, Event Triggers |
| 0.3 | January 2026 | GDD v0.7 alignment: Added AircraftPrestige, PrestigeEvent (Aircraft as Characters), Obligation (Compromise Engine), CompetitorRelationship, FrictionEvent (Emergent Rivalry System) |
| 0.4 | January 2026 | Living Flight system: Added FlightSnapshot entity, new fields on Flight (cabin_satisfaction_avg, crew_fatigue_level, service_phase), new enums (ServicePhase, FlightPhase, PaxMood, PaxActivity, CabinLighting, TurbulenceLevel) |
| 0.5 | January 2026 | Service & Suppliers system: Added SupplierContract, Supplier, ServiceProfile, ServiceAssignment, RouteServiceOverride entities. New enums (SupplierCategory, SupplierTier, ContractServiceLevel, ContractStatus, DurationCategory, MealType, BeverageService, AmenityKitTier, WiFiPolicy) |
| 0.6 | January 2026 | Economic Parameters: Added EconomicEraType, FuelPriceLevel, InterestRateEnvironment enums for era-specific scenario calibration |
