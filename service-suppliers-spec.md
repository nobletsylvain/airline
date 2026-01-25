# Service & Suppliers — Detailed Specification

**Version:** 0.1  
**Date:** January 2026  
**Companion to:** Game Design Document v0.7, Cabin Designer Spec v0.1

---

## Overview

This document specifies the supplier contract system and service profile configuration. Players negotiate multi-year contracts with suppliers, define reusable service profiles, and assign profiles to routes based on flight duration and cabin class.

**Design Philosophy:** Contracts create meaningful long-term commitments. Service profiles let players define their brand identity. The combination produces emergent airline personalities — your choices make your airline feel distinct.

---

## 1. Supplier Categories

### 1.1 Overview

| Category | What They Provide | Contract Typical Length |
|----------|-------------------|------------------------|
| Seat Manufacturer | Seat hardware, cushions, mechanisms | 5-10 years |
| IFE Hardware | Screens, controllers, headphone jacks | 5-8 years |
| IFE Content | Movies, TV, music, games libraries | 1-3 years |
| Connectivity | WiFi hardware and bandwidth | 3-5 years |
| Catering | Meals, beverages, galley supplies | 1-3 years |
| Amenity Kits | Kits, blankets, pillows, slippers | 1-2 years |
| Ground Handling | Not cabin, but affects service | 1-3 years |

---

### 1.2 Seat Manufacturers

**Long-term commitment.** Changing seat suppliers requires cabin refit.

| Supplier | Tier | Comfort Bonus | Cost Modifier | Notes |
|----------|------|---------------|---------------|-------|
| Recaro | Premium | +8 | +15% | German engineering, reliable |
| Collins Aerospace | Premium | +7 | +12% | Wide product range |
| Safran | Standard | +4 | Base | Good value |
| Geven | Standard | +3 | -5% | Budget-friendly |
| HAECO | Budget | +1 | -15% | Basic, functional |
| Stelia | Premium | +10 | +20% | Luxury focus |

**Contract Terms:**

| Term | Range | Impact |
|------|-------|--------|
| Duration | 5-10 years | Longer = 5-15% discount |
| Exclusivity | Optional | +10% discount if exclusive |
| Maintenance included | Optional | +8% cost, but no surprise repairs |
| Early exit penalty | 15-30% of remaining contract | Locked in |

---

### 1.3 IFE Hardware Providers

**Medium-term commitment.** Hardware installed in aircraft.

| Supplier | Tier | Quality | Screen Sizes | Cost/Seat |
|----------|------|---------|--------------|-----------|
| Panasonic Avionics | Premium | Excellent | 10"-18" | $3,500 |
| Thales | Premium | Excellent | 10"-17" | $3,200 |
| Collins Aerospace | Standard | Good | 9"-15" | $2,400 |
| Safran | Standard | Good | 9"-13" | $2,000 |
| Burrana | Budget | Basic | 8"-11" | $1,200 |
| Rosen Aviation | Budget | Basic | 7"-10" | $900 |

**Hardware Options (per class):**

| Option | Cost Impact | Comfort Impact |
|--------|-------------|----------------|
| Screen size (per inch above base) | +$150/seat | +2 comfort |
| Touchscreen (vs remote only) | +$200/seat | +3 comfort |
| Noise-canceling headphones | +$45/seat | +4 comfort |
| Bluetooth audio | +$80/seat | +2 comfort |
| Handset/controller | +$60/seat | +1 comfort |

---

### 1.4 IFE Content Providers

**Short-term commitment.** Content libraries licensed.

| Provider | Tier | Library Size | Monthly Cost | Notes |
|----------|------|--------------|--------------|-------|
| Encore (major studios) | Premium | 500+ movies, 200+ TV series | $2.50/seat | Hollywood blockbusters |
| Spafax | Standard | 300+ movies, 100+ TV series | $1.50/seat | Good variety |
| Global Eagle | Standard | 250+ movies, 80+ TV series | $1.20/seat | International focus |
| West Entertainment | Budget | 150+ movies, 50+ TV series | $0.70/seat | Older catalog |
| In-house curation | Variable | You select | $0.40/seat + licensing | Full control, more work |

**Content Options:**

| Option | Cost Impact | Satisfaction Impact |
|--------|-------------|---------------------|
| New releases (within 3 months) | +$0.80/seat/month | +5 satisfaction |
| Live TV channels | +$0.50/seat/month | +3 satisfaction |
| Premium sports | +$0.40/seat/month | +2 satisfaction (business travelers) |
| Kids content package | +$0.20/seat/month | +3 satisfaction (families) |
| Music library (Spotify-tier) | +$0.15/seat/month | +2 satisfaction |
| Games library | +$0.25/seat/month | +2 satisfaction |
| Destination guides | +$0.10/seat/month | +1 satisfaction |

---

### 1.5 Connectivity Providers

**Medium-term commitment.** Satellite/air-to-ground equipment.

| Provider | Tier | Speed | Coverage | Cost/Flight Hour |
|----------|------|-------|----------|------------------|
| Viasat | Premium | 100+ Mbps | Global | $180 |
| Inmarsat GX | Premium | 50+ Mbps | Global | $150 |
| Gogo 2Ku | Standard | 20+ Mbps | Americas/Europe | $100 |
| Panasonic Ku | Standard | 15+ Mbps | Global | $90 |
| SmartSky | Budget | 10+ Mbps | North America only | $60 |
| Gogo ATG | Budget | 5 Mbps | North America only | $40 |

**Connectivity Options:**

| Option | Implementation | Passenger Impact |
|--------|----------------|------------------|
| Free for all | Airline absorbs cost | High satisfaction, high cost |
| Free messaging only | WhatsApp/iMessage free, browsing paid | Good balance |
| Tiered paid | Basic/Stream/Business tiers | Revenue generating, lower satisfaction |
| Free for premium cabins | Business+ free, economy paid | Class differentiation |
| Free on long-haul only | Duration-based policy | Cost control |

---

### 1.6 Catering Partners

**Short-term commitment.** Most flexible supplier category.

| Provider | Tier | Meal Quality | Cost/Meal (Econ) | Cost/Meal (Biz) |
|----------|------|--------------|------------------|-----------------|
| DO & CO | Premium | Exceptional | $18 | $85 |
| Gate Gourmet | Standard | Good | $12 | $55 |
| LSG Sky Chefs | Standard | Good | $11 | $50 |
| Flying Food Group | Standard | Decent | $9 | $40 |
| Newrest | Budget | Basic | $7 | $30 |
| In-house catering | Variable | You control | Setup cost + per-meal | Full control |

**Meal Options:**

| Option | Cost Impact | Satisfaction Impact |
|--------|-------------|---------------------|
| Chef-designed menu | +30% | +8 satisfaction |
| Local cuisine options | +15% | +4 satisfaction |
| Premium beverages (wine/champagne) | +$8/pax (biz), +$3/pax (econ) | +3 satisfaction |
| Special meals (dietary) | +$2/meal | Required for compliance, +1 brand |
| Snack variety | +$1.50/pax | +2 satisfaction |
| Brand partnerships (celebrity chef) | +40% | +10 satisfaction, +5 brand |

**Beverage Options:**

| Option | Cost/Flight | Notes |
|--------|-------------|-------|
| Basic bar | $150 | Standard spirits, beer, wine |
| Premium bar | $350 | Top-shelf spirits, champagne |
| Craft/local selection | $250 | Regional specialties |
| Non-alcoholic focus | $100 | Premium coffee, juices, mocktails |

---

### 1.7 Amenity Kit Suppliers

**Short-term commitment.** High brand visibility.

| Provider | Tier | Kit Quality | Cost/Kit (Econ) | Cost/Kit (Biz) |
|----------|------|-------------|-----------------|-----------------|
| Buzz Products | Premium | Luxury | $8 | $45 |
| FORMIA | Premium | Luxury | $7 | $40 |
| Wessco International | Standard | Good | $4 | $25 |
| Mills Textiles | Standard | Good | $3 | $20 |
| Linstol | Budget | Basic | $1.50 | $12 |
| No kit | — | — | $0 | $0 |

**Amenity Options:**

| Item | When Provided | Cost | Satisfaction |
|------|---------------|------|--------------|
| Blanket (basic) | All flights >2hr | $2 | +2 |
| Blanket (premium) | Long-haul | $8 | +4 |
| Pillow (basic) | All flights >2hr | $1.50 | +2 |
| Pillow (premium) | Long-haul | $6 | +4 |
| Amenity kit (economy) | Long-haul only | $3-8 | +3 |
| Amenity kit (business) | All business flights | $20-45 | +5 |
| Slippers | Business long-haul | $4 | +2 |
| Pajamas | First class | $25 | +5 |
| Eye mask | Long-haul | $1 | +2 |
| Noise-reducing earplugs | All flights | $0.50 | +1 |

**Brand Partnerships:**

| Partner Type | Cost Premium | Brand Impact |
|--------------|--------------|--------------|
| Luxury brand (Rimowa, Acqua di Parma) | +80% | +15 brand score |
| Mid-tier brand (Clarins, Kiehl's) | +40% | +8 brand score |
| Generic/unbranded | Base | No bonus |
| Airline-branded | +10% | +3 brand score |

---

## 2. Contract Negotiation

### 2.1 Contract Structure

```
┌─────────────────────────────────────────────────────────────────┐
│ CONTRACT NEGOTIATION · Gate Gourmet Catering                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ TERM LENGTH                                                     │
│ ○ 1 year        ○ 2 years       ● 3 years                      │
│   Base rate       -5%             -12%                          │
│                                                                 │
│ EXCLUSIVITY                                                     │
│ ○ Non-exclusive (use multiple caterers)                        │
│ ● Exclusive (all catering from Gate Gourmet)                   │
│   Additional -8% discount                                       │
│                                                                 │
│ VOLUME COMMITMENT                                               │
│ Minimum monthly meals: [15,000 ▼]                              │
│ Your forecast: 18,500 meals/month                              │
│ Penalty if below minimum: $2.50/meal shortfall                 │
│                                                                 │
│ SERVICE LEVEL                                                   │
│ ○ Standard (24hr notice for changes)                           │
│ ● Priority (4hr notice, dedicated account manager)             │
│   +6% cost                                                      │
│                                                                 │
│ ─────────────────────────────────────────────────────────────  │
│                                                                 │
│ SUMMARY                                                         │
│                                                                 │
│ Base cost per economy meal:        $12.00                       │
│ 3-year discount:                   -$1.44                       │
│ Exclusivity discount:              -$0.96                       │
│ Priority service:                  +$0.72                       │
│                                    ────────                     │
│ Final cost per economy meal:       $10.32                       │
│                                                                 │
│ Contract value (36 months):        $6.8M                        │
│ Early termination fee:             $1.2M (18% of remaining)     │
│                                                                 │
│ [Decline]              [Counter-offer]              [Accept]    │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 Contract Variables

| Variable | Options | Impact |
|----------|---------|--------|
| Duration | 1-10 years | Longer = lower rates |
| Exclusivity | Yes/No | Yes = discount, but locked in |
| Volume commitment | Min monthly units | Higher = lower rates, penalty risk |
| Service level | Standard/Priority/Premium | Higher = better service, higher cost |
| Payment terms | Net 30/60/90 | Longer = slight premium |
| Price escalation | Fixed/CPI-linked/Annual review | Risk allocation |

### 2.3 Negotiation Factors

Your leverage depends on:

| Factor | Impact on Negotiation |
|--------|----------------------|
| Fleet size | Larger = better rates |
| Brand reputation | Higher = suppliers want you |
| Payment history | Good = better terms offered |
| Market competition | More suppliers = better leverage |
| Contract timing | End of supplier's quarter = eager to close |
| Existing relationship | Renewals often get loyalty discounts |

### 2.4 Contract Events

During contract lifetime:

| Event | Trigger | Options |
|-------|---------|---------|
| **Price review** | Annual or per contract | Accept, negotiate, exit |
| **Service failure** | Supplier misses SLA | Penalty credit, terminate for cause |
| **Supplier financial trouble** | News event | Monitor, seek backup, renegotiate |
| **Your growth** | Hit volume milestone | Request volume discount |
| **Early termination** | Your choice | Pay penalty, walk away |
| **Contract expiry** | End of term | Renew, switch suppliers, renegotiate |

---

## 3. Service Profiles

### 3.1 Concept

A **Service Profile** is a saved configuration of all onboard service elements. Players create profiles and assign them to route categories.

```
SERVICE PROFILE = Seat amenities + IFE + Connectivity + Catering + Amenity items
```

### 3.2 Default Profiles (Presets)

The game provides starter profiles:

| Profile Name | Target | Description |
|--------------|--------|-------------|
| **No Frills** | LCC short-haul | No meal, no IFE, no amenities |
| **Basic Short-Haul** | Legacy short-haul | Snack, basic IFE, no amenities |
| **Standard Domestic** | Domestic medium | Light meal, standard IFE, basic amenities |
| **Regional Business** | Business travelers | Quality meal, good IFE, amenity kit |
| **Long-Haul Economy** | International coach | Full meal, full IFE, blanket/pillow |
| **Long-Haul Premium Economy** | Premium cabin | Enhanced meal, larger screen, amenity kit |
| **Long-Haul Business** | Business class | Multi-course meal, premium IFE, full amenity kit |
| **Long-Haul First** | First class | Chef-prepared, largest screen, luxury kit, pajamas |
| **Ultra Long-Haul** | 14+ hour flights | Multiple meals, premium everything, wellness items |

### 3.3 Profile Builder UI

```
┌─────────────────────────────────────────────────────────────────┐
│ SERVICE PROFILE BUILDER                                         │
│ Profile: "Atlantic Business" [Rename]                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ SEAT AMENITIES                                                  │
│ ├─ Reading light              [● Yes ○ No]                     │
│ ├─ Ambient light control      [● Yes ○ No]                     │
│ ├─ Personal air vent          [● Yes ○ No]                     │
│ ├─ Power outlets              [AC ▼] [USB-A ▼] [USB-C ▼]       │
│ └─ Wireless charging          [● Yes ○ No]                     │
│                                                                 │
│ IFE HARDWARE                                                    │
│ ├─ Screen size                [15" ▼]                          │
│ ├─ Touchscreen                [● Yes ○ No]                     │
│ ├─ Bluetooth audio            [● Yes ○ No]                     │
│ └─ Headphones                 [Noise-canceling ▼]              │
│                                                                 │
│ IFE CONTENT (from Encore contract)                              │
│ ├─ Movies                     [● Full library ○ Curated]       │
│ ├─ TV Shows                   [● Full library ○ Curated]       │
│ ├─ Live TV                    [● Yes ○ No]                     │
│ ├─ Music                      [● Yes ○ No]                     │
│ └─ Games                      [● Yes ○ No]                     │
│                                                                 │
│ CONNECTIVITY (from Viasat contract)                             │
│ ├─ WiFi access                [● Free ○ Paid ○ None]           │
│ └─ Speed tier                 [Full speed ▼]                   │
│                                                                 │
│ CATERING (from Gate Gourmet contract)                           │
│ ├─ Meal service               [3-course ▼]                     │
│ ├─ Menu style                 [Chef-designed ▼]                │
│ ├─ Beverage service           [Premium bar ▼]                  │
│ ├─ Special meals              [● All options available]        │
│ └─ Mid-flight snack           [● Yes ○ No]                     │
│                                                                 │
│ AMENITIES (from FORMIA contract)                                │
│ ├─ Amenity kit                [Business kit ▼]                 │
│ ├─ Blanket                    [Premium ▼]                      │
│ ├─ Pillow                     [Premium ▼]                      │
│ ├─ Slippers                   [● Yes ○ No]                     │
│ ├─ Eye mask                   [● Yes ○ No]                     │
│ └─ Pajamas                    [○ Yes ● No]                     │
│                                                                 │
│ ─────────────────────────────────────────────────────────────  │
│                                                                 │
│ PROFILE SUMMARY                                                 │
│                                                                 │
│ Cost per passenger (6hr flight):    $127                        │
│ Comfort score contribution:         +45                         │
│ Brand score contribution:           +12                         │
│                                                                 │
│ [Delete profile]        [Duplicate]        [Save]               │
└─────────────────────────────────────────────────────────────────┘
```

### 3.4 Profile Constraints

Profiles are constrained by active contracts:

| Constraint | Behavior |
|------------|----------|
| No IFE contract | IFE options disabled, "Sign contract to enable" |
| Budget catering contract | Premium meal options unavailable |
| Regional WiFi only | "Not available on this route" warning |
| Seat hardware limits | Options beyond installed hardware greyed out |

---

## 4. Flight Duration Categories

### 4.1 Category Definitions

| Category | Duration | Typical Flights |
|----------|----------|-----------------|
| **Ultra Short** | <1 hour | Shuttle routes, island hops |
| **Short-haul** | 1-2 hours | Domestic, regional |
| **Medium-haul** | 2-5 hours | Transcontinental, near-international |
| **Long-haul** | 5-10 hours | International |
| **Ultra Long-haul** | 10-14 hours | Intercontinental |
| **Extreme Long-haul** | 14+ hours | Longest routes (SIN-JFK, etc.) |

### 4.2 Service Expectations by Duration

| Category | Meal Expectation | IFE Expectation | Amenity Expectation |
|----------|------------------|-----------------|---------------------|
| Ultra Short | None | None | None |
| Short-haul | Snack/beverage | Optional | None |
| Medium-haul | Light meal | Expected | Basic (blanket) |
| Long-haul | Full meal | Required | Standard kit |
| Ultra Long-haul | 2 meals + snacks | Premium | Full kit |
| Extreme Long-haul | 2-3 meals + snacks | Premium | Luxury kit |

### 4.3 Profile Assignment

Players assign profiles to duration categories per cabin class:

```
┌─────────────────────────────────────────────────────────────────┐
│ SERVICE STANDARDS · Profile Assignment                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│                    Economy    Prem Econ   Business    First     │
│ ─────────────────────────────────────────────────────────────  │
│ Ultra Short (<1h)  No Frills  No Frills   Basic Dom   —         │
│ Short (1-2h)       Basic SH   Basic SH    Reg Biz     —         │
│ Medium (2-5h)      Std Dom    Std Dom     Reg Biz     —         │
│ Long (5-10h)       LH Econ    LH PremEc   LH Biz      LH First  │
│ Ultra Long (10-14) LH Econ+   LH PremEc+  LH Biz+     LH First+ │
│ Extreme (14+)      ULH Econ   ULH PremEc  ULH Biz     ULH First │
│                                                                 │
│ [Edit assignments]                                              │
└─────────────────────────────────────────────────────────────────┘
```

### 4.4 Route Overrides

Individual routes can override the default:

```
┌─────────────────────────────────────────────────────────────────┐
│ ROUTE SERVICE · LYS → JFK                                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ Flight duration: 8h 45m (Long-haul)                             │
│ Default profiles applied: LH Econ, LH Biz                       │
│                                                                 │
│ ○ Use default profiles                                          │
│ ● Override for this route                                       │
│                                                                 │
│   Economy:  [Atlantic Economy ▼]     (upgraded from LH Econ)    │
│   Business: [Atlantic Business ▼]    (custom profile)           │
│                                                                 │
│ Reason: Flagship route, premium positioning                     │
│                                                                 │
│ Additional cost vs default: +$12/pax                            │
│ Comfort improvement: +8 points                                  │
│                                                                 │
│ [Apply override]                                                │
└─────────────────────────────────────────────────────────────────┘
```

---

## 5. Cost Calculations

### 5.1 Per-Flight Service Cost

```
service_cost = Σ (per_pax_costs × pax_count) + fixed_flight_costs

Per-pax costs:
├── Meal cost (from catering contract × meal type)
├── Beverage cost (allocated per pax)
├── Amenity kit cost (if provided)
├── Blanket/pillow (amortized over uses)
├── IFE content (monthly fee ÷ flights × load)
├── WiFi (if free, per-pax bandwidth cost)
└── Consumables (cups, napkins, etc.)

Fixed flight costs:
├── Catering delivery/uplift fee
├── Galley equipment rental (if applicable)
└── Crew meal allocation
```

### 5.2 Example Calculation

**Route:** LYS → JFK (8h 45m)  
**Aircraft:** 787-9, 30 Business + 216 Economy  
**Load factor:** 87%

| Item | Business (26 pax) | Economy (188 pax) | Total |
|------|-------------------|-------------------|-------|
| Meals | 26 × $55 = $1,430 | 188 × $12 = $2,256 | $3,686 |
| Beverages | 26 × $15 = $390 | 188 × $4 = $752 | $1,142 |
| Amenity kits | 26 × $40 = $1,040 | 188 × $3 = $564 | $1,604 |
| Blanket/pillow | 26 × $2 = $52 | 188 × $1 = $188 | $240 |
| IFE content | 26 × $2 = $52 | 188 × $1.50 = $282 | $334 |
| WiFi (free biz) | 26 × $8 = $208 | — | $208 |
| **Per-pax subtotal** | $122/pax | $32/pax | — |
| **Class subtotal** | $3,172 | $4,042 | $7,214 |
| Fixed costs | — | — | $450 |
| **Total service cost** | — | — | **$7,664** |

---

## 6. Satisfaction Impact

### 6.1 Satisfaction Components

```
pax_satisfaction = base_satisfaction
                 + seat_comfort
                 + service_satisfaction
                 + brand_expectation_modifier
                 - negative_events

service_satisfaction = Σ (amenity_satisfaction × amenity_weight)
```

### 6.2 Amenity Satisfaction Values

| Amenity | Satisfaction Value | Weight (Economy) | Weight (Business) |
|---------|-------------------|------------------|-------------------|
| Seat pitch (per inch above min) | +2 | 1.0 | 0.8 |
| Seat width (per inch above min) | +1.5 | 0.8 | 0.6 |
| Reading light | +1 | 0.3 | 0.5 |
| Power outlet | +3 | 0.6 | 1.0 |
| USB charging | +2 | 0.7 | 0.8 |
| Screen (per inch above 6") | +1 | 0.5 | 0.7 |
| Touchscreen | +2 | 0.4 | 0.6 |
| Content library (premium) | +4 | 0.5 | 0.7 |
| WiFi (free) | +5 | 0.6 | 1.0 |
| WiFi (paid available) | +2 | 0.4 | 0.6 |
| Meal (per quality tier) | +3 | 0.8 | 1.0 |
| Premium beverages | +2 | 0.3 | 0.8 |
| Amenity kit | +3 | 0.4 | 0.9 |
| Blanket | +2 | 0.6 | 0.5 |
| Pillow | +2 | 0.6 | 0.5 |
| Noise-canceling headphones | +3 | 0.3 | 0.8 |

### 6.3 Expectation Modifiers

Satisfaction is relative to expectations:

| Your Brand Position | Expectation Level | Modifier |
|--------------------|--------------------|----------|
| Ultra Low Cost | Low | Service above expectation = bonus |
| Low Cost | Low-Medium | Neutral |
| Standard | Medium | Neutral |
| Premium | High | Service below expectation = penalty |
| Luxury | Very High | Must exceed or satisfaction tanks |

```
expectation_modifier = actual_service_level - expected_service_level

If positive: +3 satisfaction ("pleasantly surprised")
If zero: no modifier
If negative: -5 satisfaction ("disappointed")
If very negative: -10 satisfaction ("outraged")
```

---

## 7. Brand Impact

### 7.1 Brand Score Components

Service choices affect brand perception:

| Choice | Brand Impact |
|--------|--------------|
| Premium supplier partnerships | +2-5 per category |
| Luxury brand amenity kits | +5-15 |
| Celebrity chef partnership | +10 |
| Free WiFi policy | +5 |
| No-frills service | -3 (or +3 if LCC brand) |
| Consistent service quality | +2 per year |
| Service failures | -5 to -20 per incident |

### 7.2 Brand Positioning

Service profiles should match brand positioning:

| Brand Position | Expected Service Level | Mismatch Penalty |
|----------------|------------------------|------------------|
| Ultra Low Cost | Basic or none | Premium service confuses market |
| Low Cost | Basic | — |
| Hybrid | Differentiated by route | Inconsistency penalty if too varied |
| Full Service | Standard+ | Below standard = brand damage |
| Premium | Above standard | Below premium = significant damage |
| Luxury | Exceptional | Anything less = severe damage |

---

## 8. Crew Requirements

Service profiles affect crew staffing:

### 8.1 Service Crew Ratios

| Service Level | Crew : Passenger Ratio | Notes |
|---------------|------------------------|-------|
| No service | 1:50 (regulatory min) | Safety only |
| Snack service | 1:45 | Minimal galley work |
| Standard meal | 1:35 | Full galley operation |
| Premium meal | 1:25 | Multiple courses |
| Luxury service | 1:15 | Personalized attention |

### 8.2 Crew Training Requirements

Premium service profiles require trained crew:

| Service Element | Training Required | Training Cost |
|-----------------|-------------------|---------------|
| Standard service | Basic cabin crew | Included |
| Premium meal service | Service certification | $2,000/crew |
| Wine service | Sommelier basics | $1,500/crew |
| First class service | Premium service cert | $5,000/crew |
| Special needs assistance | Accessibility training | $800/crew |

---

## 9. Data Model Integration

### 9.1 New Entities

**SupplierContract**

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `airline_id` | FK → Airline | Contract holder |
| `supplier_id` | FK → Supplier | The supplier |
| `category` | enum | SEAT / IFE_HARDWARE / IFE_CONTENT / WIFI / CATERING / AMENITY |
| `start_date` | date | Contract start |
| `end_date` | date | Contract end |
| `is_exclusive` | bool | Exclusivity clause |
| `volume_commitment` | int? | Minimum units if applicable |
| `base_rate` | decimal | Negotiated rate |
| `discount_percent` | float | Applied discounts |
| `service_level` | enum | STANDARD / PRIORITY / PREMIUM |
| `early_exit_penalty` | decimal | Fee if terminated early |
| `terms` | json | Full contract terms |
| `status` | enum | ACTIVE / EXPIRED / TERMINATED |

**Supplier**

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `name` | string | "Gate Gourmet" |
| `category` | enum | Supplier category |
| `tier` | enum | BUDGET / STANDARD / PREMIUM |
| `quality_rating` | int | 1-100 |
| `base_cost` | decimal | Standard rate |
| `regions` | string[] | Regions served |
| `min_contract_length` | int | Minimum months |

**ServiceProfile**

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `airline_id` | FK → Airline | Owner |
| `name` | string | "Atlantic Business" |
| `is_preset` | bool | System-provided preset |
| `seat_amenities` | json | Reading light, power, etc. |
| `ife_config` | json | Screen, content, headphones |
| `connectivity_config` | json | WiFi tier, free/paid |
| `catering_config` | json | Meal type, beverages |
| `amenity_config` | json | Kit, blanket, pillow, etc. |
| `estimated_cost_per_pax` | decimal | Calculated field |
| `comfort_contribution` | int | Calculated field |
| `created_date` | date | When created |
| `last_modified` | date | When modified |

**ServiceAssignment**

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `airline_id` | FK → Airline | Owner |
| `duration_category` | enum | ULTRA_SHORT / SHORT / MEDIUM / LONG / ULTRA_LONG / EXTREME |
| `cabin_class` | enum | ECONOMY / PREMIUM_ECONOMY / BUSINESS / FIRST |
| `profile_id` | FK → ServiceProfile | Assigned profile |

**RouteServiceOverride**

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `route_id` | FK → Route | Which route |
| `cabin_class` | enum | Which class |
| `profile_id` | FK → ServiceProfile | Override profile |
| `reason` | string? | Why overridden |

### 9.2 New Enumerations

```yaml
SupplierCategory:
  SEAT_MANUFACTURER
  IFE_HARDWARE
  IFE_CONTENT
  CONNECTIVITY
  CATERING
  AMENITY_KIT
  GROUND_HANDLING

SupplierTier:
  BUDGET
  STANDARD
  PREMIUM

ContractServiceLevel:
  STANDARD
  PRIORITY
  PREMIUM

ContractStatus:
  NEGOTIATING
  ACTIVE
  EXPIRED
  TERMINATED

DurationCategory:
  ULTRA_SHORT      # <1 hour
  SHORT            # 1-2 hours
  MEDIUM           # 2-5 hours
  LONG             # 5-10 hours
  ULTRA_LONG       # 10-14 hours
  EXTREME          # 14+ hours

MealType:
  NONE
  SNACK
  LIGHT_MEAL
  FULL_MEAL
  MULTI_COURSE
  CHEF_PREPARED

BeverageService:
  NONE
  NON_ALCOHOLIC
  BASIC_BAR
  PREMIUM_BAR

AmenityKitTier:
  NONE
  BASIC
  STANDARD
  PREMIUM
  LUXURY

WiFiPolicy:
  NONE
  PAID_ONLY
  MESSAGING_FREE
  FREE_PREMIUM_CABIN
  FREE_ALL
```

---

## 10. UI Integration

### 10.1 Access Points

| Location | What Opens |
|----------|------------|
| Main menu → Operations → Service Standards | Full service management |
| Route detail → Service tab | Route service assignment |
| Aircraft detail → Cabin → Service | Aircraft-specific view |
| Contracts menu → Suppliers | Contract negotiation |
| Finance → Operating costs → Service | Cost breakdown |

### 10.2 Notifications

| Event | Notification |
|-------|--------------|
| Contract expiring (90 days) | "Gate Gourmet contract expires in 90 days. [Renew] [Find alternatives]" |
| Contract expiring (30 days) | Warning: "Catering contract expires in 30 days. Service will revert to basic." |
| Supplier issue | "LSG Sky Chefs reports supply shortage. Some flights may have limited meal options." |
| Price increase | "Viasat proposes 8% rate increase at renewal. [Review] [Negotiate] [Switch provider]" |
| New supplier available | "DO & CO now serves your region. Premium catering available." |

---

## 11. Gameplay Integration

### 11.1 Early Game

- Limited supplier access (regional only)
- Budget constraints favor basic profiles
- Few profile slots available

### 11.2 Mid Game

- Major suppliers become available
- Can negotiate better terms with volume
- Profile customization unlocks
- Route-specific overrides available

### 11.3 Late Game

- Exclusive partnership opportunities
- Co-branded amenity deals
- In-house catering option
- Full profile flexibility

### 11.4 Events

| Event | Impact |
|-------|--------|
| Supplier strike | Service disruption, emergency alternatives |
| Contamination incident | Catering grounded, reputation hit |
| New luxury supplier enters market | New options, existing suppliers may improve offers |
| Fuel price spike | Catering costs increase (delivery) |
| Celebrity chef partnership offer | Premium option, high cost, brand boost |

---

## Document History

| Version | Date | Changes |
|---------|------|---------|
| 0.1 | January 2026 | Initial specification |
