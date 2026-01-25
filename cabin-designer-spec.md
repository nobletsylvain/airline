# Cabin Designer — Detailed Specification

**Version:** 0.1  
**Date:** January 2026  
**Companion to:** Game Design Document v0.7, Art Bible v0.1

---

## Overview

The Cabin Designer is where players craft the passenger experience. It's a visual editor for configuring aircraft interiors — seats, galleys, lavatories, and amenities.

**Design Philosophy:** This is a productivity tool with emotional stakes. Every seat placement decision affects passenger satisfaction, revenue potential, and brand identity.

**Core Loop:** Configure → Preview → Commit → Observe (via Living Flight)

---

## 1. Access Points

Players access the Cabin Designer from:

| Entry Point | Context |
|-------------|---------|
| Fleet view → Aircraft → [Configure cabin] | Modify existing aircraft |
| Aircraft delivery event | Configure before entering service |
| Hangar view → [Configure cabin] | From glorification scene |
| Order placement | Pre-configure before delivery |

---

## 2. View Modes

### 2.1 Blueprint View (Primary)

**Purpose:** Configuration workspace. Where decisions happen.

**Visual Style:** CAD/engineering schematic

| Element | Specification |
|---------|---------------|
| Background | Dark (`#0a0e14`) with technical grid lines (cyan `#0099b8` at 10% opacity) |
| Fuselage | Top-down cross-section, clean white outline |
| Grid | Snap-to-grid divisions at 1-inch increments |
| Scale | 1 grid unit = 1 inch of seat pitch |

**Camera:**
- Fixed top-down orthographic view
- Scroll to pan along fuselage length
- Zoom levels: Fit-all, Section, Seat-level

---

### 2.2 Preview View (Secondary)

**Purpose:** Visualization check before committing. Empty cabin, no passengers.

**Visual Style:** 3D interior render, walk-through perspective

| Element | Specification |
|---------|---------------|
| Camera | First-person, aisle-level |
| Lighting | Neutral daylight cabin lighting |
| Seats | Rendered with selected materials/colors |
| Movement | Click-and-drag to look around, scroll to move fore/aft |

**Not shown:** Passengers, crew, service items (that's Living Flight)

---

### 2.3 Comparison View (Optional)

**Purpose:** Compare two configurations side-by-side

| Left Panel | Right Panel |
|------------|-------------|
| Current configuration | Proposed configuration |
| Capacity: 186 | Capacity: 174 |
| Avg pitch: 31" | Avg pitch: 33" |
| Est. comfort: 62/100 | Est. comfort: 78/100 |

---

## 3. UI Layout

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  CABIN DESIGNER · Boeing 737-800 · F-GKXA "Spirit of Lyon"                  │
├─────────────┬───────────────────────────────────────────────────┬───────────┤
│             │                                                   │           │
│  COMPONENT  │                                                   │ PROPERTIES│
│  PALETTE    │              BLUEPRINT CANVAS                     │           │
│             │                                                   │  [Class]  │
│  ┌───────┐  │  ┌─────────────────────────────────────────────┐  │  Business │
│  │ Econ  │  │  │ ══╪══╪══╪══ · ══╪══╪══╪══ · ══╪══╪══╪══    │  │           │
│  │ Seat  │  │  │    COCKPIT    │ BUSINESS   │  ECONOMY  ... │  │  [Pitch]  │
│  └───────┘  │  │ ══╪══╪══╪══ · ══╪══╪══╪══ · ══╪══╪══╪══    │  │  40"      │
│  ┌───────┐  │  └─────────────────────────────────────────────┘  │           │
│  │ Prem  │  │                                                   │  [Width]  │
│  │ Econ  │  │                                                   │  21"      │
│  └───────┘  │                                                   │           │
│  ┌───────┐  │                                                   │  [IFE]    │
│  │ Biz   │  │                                                   │  Personal │
│  │ Seat  │  │                                                   │           │
│  └───────┘  │                                                   │  [Power]  │
│  ┌───────┐  │                                                   │  Yes      │
│  │ First │  │                                                   │           │
│  │ Pod   │  │                                                   │           │
│  └───────┘  │                                                   │           │
│  ┌───────┐  │                                                   │           │
│  │Galley │  │                                                   │           │
│  └───────┘  │                                                   │           │
│  ┌───────┐  │                                                   │           │
│  │ Lav   │  │                                                   │           │
│  └───────┘  │                                                   │           │
│             │                                                   │           │
├─────────────┴───────────────────────────────────────────────────┴───────────┤
│  CAPACITY: 174 pax │ COMFORT: 😊 Good (72/100) │ EST. REVENUE: $48,200/flight│
├─────────────────────────────────────────────────────────────────────────────┤
│  [Cancel]                    [Preview 3D]              [Save] [Apply: $1.2M]│
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 4. Component Palette

### 4.1 Seat Types

| Component | Icon | Grid Size | Base Cost | Comfort Impact |
|-----------|------|-----------|-----------|----------------|
| Economy Seat | Small rectangle, white outline | 1×1 | $2,500 | Baseline |
| Premium Economy | Medium rectangle, amber outline | 1×1.2 | $4,500 | +15 comfort |
| Business Seat | Medium rectangle, lie-flat indicator, cyan | 1×2 | $12,000 | +40 comfort |
| Business Suite | Large rectangle with shell, cyan | 2×2 | $25,000 | +55 comfort |
| First Class Pod | Large detailed rectangle, gold | 2×2.5 | $45,000 | +70 comfort |
| First Class Suite | Very large with door indicator, gold | 2×3 | $85,000 | +85 comfort |

### 4.2 Service Components

| Component | Icon | Grid Size | Required | Notes |
|-----------|------|-----------|----------|-------|
| Galley (Small) | Cabinet icon | 2×3 | 1 per 50 pax | Snack service only |
| Galley (Full) | Cabinet + cart icon | 3×4 | 1 per 100 pax | Full meal service |
| Lavatory (Standard) | Toilet icon | 2×2 | 1 per 50 pax | Minimum regulatory |
| Lavatory (Accessible) | Toilet + wheelchair | 3×2 | 1 per aircraft | Required by regulation |
| Crew Rest (Bunk) | Bed icon | 2×4 | Long-haul only | >8hr flights |
| Closet | Cabinet icon | 1×2 | Optional | Premium cabin storage |

### 4.3 Amenities

| Component | Grid Size | Cost | Impact |
|-----------|-----------|------|--------|
| Bar/Lounge | 3×4 | $35,000 | Premium pax satisfaction +20 |
| Shower Suite | 2×3 | $50,000 | First class only, satisfaction +15 |
| Onboard Chef Station | 2×3 | $40,000 | Meal quality +25 |

---

## 5. Properties Panel

When a component is selected, the Properties panel shows:

### For Seats:

| Property | Control | Range | Impact |
|----------|---------|-------|--------|
| Pitch | Slider | 28"–60" | Comfort, capacity |
| Width | Slider | 17"–24" | Comfort |
| Recline | Dropdown | Standard / Deep / Lie-flat | Comfort |
| IFE | Dropdown | None / Shared / Personal / Premium | Satisfaction |
| Power | Toggle | AC / USB / Both / None | Business pax satisfaction |
| WiFi | Toggle | Yes / No | Business pax satisfaction |
| Manufacturer | Dropdown | Recaro / Collins / Safran / etc. | Cost, reliability |

### For Galleys:

| Property | Control | Range |
|----------|---------|-------|
| Meal Capacity | Display | Meals per service |
| Cart Storage | Display | Number of carts |
| Equipment | Checklist | Oven / Coffee / Chiller |

---

## 6. Interaction Design

### 6.1 Placement

| Action | Input | Result |
|--------|-------|--------|
| Select component | Click palette item | Cursor becomes component ghost |
| Place component | Click valid grid cell | Component placed, click sound |
| Invalid placement | Click invalid cell | Red flash, error tone, tooltip explains why |
| Cancel placement | Right-click or Esc | Return to selection mode |

### 6.2 Selection & Editing

| Action | Input | Result |
|--------|-------|--------|
| Select placed component | Click it | Highlight, show properties |
| Multi-select | Shift+Click or drag box | Multiple selection |
| Move component | Drag selected | Ghost preview, snap to grid |
| Delete | Delete key or drag to trash | Soft "pop" sound, component removed |
| Duplicate | Ctrl+D | Copy at offset |

### 6.3 Row Operations

| Action | Input | Result |
|--------|-------|--------|
| Select row | Click row number | All seats in row selected |
| Add row | Right-click → "Insert row after" | New empty row, seats shift aft |
| Delete row | Right-click → "Delete row" | Row removed, seats shift forward |
| Change row pitch | Drag row divider | All seats in row adjust |

### 6.4 Section Operations

| Action | Input | Result |
|--------|-------|--------|
| Define section | Drag to select multiple rows | Section created |
| Name section | Right-click → "Name section" | "Business", "Economy Plus", etc. |
| Apply uniform settings | Right-click → "Apply to section" | All seats get same properties |

---

## 7. Snap-to-Grid System

### 7.1 Grid Configuration

| Setting | Value |
|---------|-------|
| Base unit | 1 inch |
| Pitch increments | 1 inch (display shows even numbers primarily) |
| Width increments | 0.5 inch |
| Aisle width | Fixed per aircraft type (typically 20") |

### 7.2 Snap Behavior

| Scenario | Behavior |
|----------|----------|
| Dragging seat | Snaps to valid pitch positions |
| Near invalid position | Red highlight, won't snap |
| Override snap | Hold Alt while dragging (for advanced users) |

### 7.3 Auto-Alignment

When placing seats:
- Automatically aligns to row if near existing seats
- Suggests standard configurations: 3-3, 2-2, 2-3-2, etc.
- Shows alignment guides when dragging

---

## 8. Validation Rules

### 8.1 Regulatory Minimums

| Rule | Requirement | Enforcement |
|------|-------------|-------------|
| Emergency exits | Clear path, no obstructions | Hard block |
| Lavatory ratio | 1 per 50 pax minimum | Warning at 1:60, block at 1:75 |
| Accessible lavatory | 1 per aircraft | Hard block |
| Aisle width | Minimum 20" | Hard block |
| Galley access | Crew must reach all galleys | Warning |
| Crew rest | Required for >8hr duty | Warning |

### 8.2 Operational Constraints

| Rule | Requirement | Enforcement |
|------|-------------|-------------|
| MTOW | Total weight ≤ aircraft MTOW | Warning, prevents save |
| Balance | CG within limits | Warning with visual indicator |
| Door clearance | Seats clear of door swing | Hard block |
| Exit row | Extra legroom required | Auto-adjust pitch |

### 8.3 Visual Feedback for Violations

```
┌─────────────────────────────────────────────────────────────────┐
│ ⚠ CONFIGURATION ISSUES                                          │
│                                                                  │
│ ✗ Lavatory ratio: 1:72 (minimum 1:50)                           │
│   → Add 1 lavatory or remove 22 seats                           │
│                                                                  │
│ ⚠ Exit row 15 pitch: 31" (recommend 36"+)                       │
│   → Passengers may have difficulty evacuating                   │
│                                                                  │
│ ✓ Weight: 18,240 kg / 20,500 kg max                             │
│ ✓ Balance: CG at 28% MAC (limits: 15-35%)                       │
│                                                                  │
│                                              [Fix issues] [Ignore]│
└─────────────────────────────────────────────────────────────────┘
```

---

## 9. Comfort Score Calculation

Comfort is calculated from two sources:
1. **Physical configuration** (this tool) — seat hardware, layout, facilities
2. **Service profile** (separate system) — IFE, catering, amenities

> **See also:** Service & Suppliers Specification for service profile details.

### 9.1 Physical Comfort Factors (Cabin Designer)

| Category | Elements | Configured Here |
|----------|----------|-----------------|
| **Seat Hardware** | Pitch, width, recline, cushion quality, headrest | ✓ |
| **Personal Space** | Storage, coat hook, privacy divider | ✓ |
| **Power** | AC outlet, USB-A, USB-C, wireless charging | ✓ |
| **Lighting** | Reading light, ambient control | ✓ |
| **Climate** | Personal air vent | ✓ |
| **IFE Hardware** | Screen size, touchscreen, headphone jack | ✓ |
| **Facilities** | Lavatory ratio, galley access | ✓ |

### 9.2 Service Comfort Factors (Service Profile)

| Category | Elements | Configured Elsewhere |
|----------|----------|---------------------|
| **IFE Content** | Movies, TV, music, games library | Service Profile |
| **Connectivity** | WiFi speed, free vs paid | Service Profile |
| **Catering** | Meal quality, beverage selection | Service Profile |
| **Amenity Items** | Blanket, pillow, amenity kit, slippers | Service Profile |
| **Crew Service** | Attentiveness, training level | Crew Management |

### 9.3 Per-Seat Physical Comfort

```
seat_comfort = base_comfort[class]
             + pitch_bonus(pitch - minimum_pitch[class])
             + width_bonus(width - minimum_width[class])
             + recline_bonus[recline_type]
             + power_bonus(power_options)
             + lighting_bonus(has_reading_light, has_ambient)
             + climate_bonus(has_air_vent)
             + ife_hardware_bonus(screen_size, touchscreen)
             + privacy_bonus(divider_type)
```

### 9.4 Cabin-Wide Physical Comfort

```
cabin_comfort = weighted_average(seat_comfort, by_class_weight)
              + galley_bonus(galley_ratio)
              + lavatory_bonus(lavatory_ratio)
              + amenity_bonus(bar, lounge, shower)
              - density_penalty(if_above_threshold)
```

### 9.5 Total Passenger Comfort (Calculated at Flight Time)

```
total_comfort = cabin_physical_comfort (from configuration)
              + service_comfort (from service profile)
              + operational_factors (delays, turbulence, crew)
```

### 9.6 Comfort Display in Cabin Designer

The Cabin Designer shows **physical comfort only** (what this tool controls):

| Score | Label | Emoji | Color |
|-------|-------|-------|-------|
| 0-30 | Cramped | 😠 | Red |
| 31-50 | Basic | 😐 | Amber |
| 51-70 | Good | 😊 | Green |
| 71-85 | Comfortable | 😄 | Cyan |
| 86-100 | Spacious | 🤩 | Gold |

*Note: Service profile adds +10 to +40 points on top of physical comfort.*

### 9.7 Comfort Preview with Service

Optional toggle shows combined estimate:

```
┌─────────────────────────────────────────────────────────────────┐
│ COMFORT PREVIEW                                                 │
│                                                                 │
│ Physical (this config):     68/100  😊 Good                     │
│ + Service ("LH Business"):  +35                                 │
│ ──────────────────────────────────────                          │
│ Combined estimate:          103 → 100/100 🤩 Luxurious          │
│                                                                 │
│ [Show physical only] [Show with service profile ▼]              │
└─────────────────────────────────────────────────────────────────┘
```

---

## 10. Revenue Impact Preview

### 10.1 Estimated Revenue Per Flight

```
┌─────────────────────────────────────────────────────────────────┐
│ REVENUE ESTIMATE · LYS → JFK                                    │
│                                                                  │
│ Business (12 seats × $4,200 avg fare)          $50,400          │
│ Premium Economy (24 seats × $1,800)            $43,200          │
│ Economy (186 seats × $680)                    $126,480          │
│                                               ─────────          │
│ Gross Revenue                                 $220,080          │
│                                                                  │
│ vs. Current Config                             +$8,200 (+3.9%)  │
│                                                                  │
│ Note: Based on 87% historical load factor                       │
└─────────────────────────────────────────────────────────────────┘
```

### 10.2 Tradeoff Visualization

When adjusting pitch:

```
Pitch: 31" ──●────────── 34"

         ◄ More seats          More comfort ►
         
Capacity: 186 → 174 (-12 seats)
Comfort:  62 → 78 (+16 points)
Est. Rev: $220K → $215K (-2.3%)
BUT: Higher fares possible (+$45/seat)
Net:      +$3,100/flight potential
```

---

## 11. Configuration Templates

### 11.1 Preset Configurations

| Template | Description | Use Case |
|----------|-------------|----------|
| High Density | Maximum seats, minimum pitch | LCC, short-haul |
| Standard 2-Class | Business + Economy | Domestic/regional |
| Premium 2-Class | Larger business, comfortable economy | Business routes |
| 3-Class | First + Business + Economy | Long-haul premium |
| Long-Haul Comfort | Generous pitch, premium amenities | Ultra long-haul |

### 11.2 Applying Templates

```
┌─────────────────────────────────────────────────────────────────┐
│ APPLY TEMPLATE                                                  │
│                                                                  │
│ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐                 │
│ │ High Density│ │ Standard    │ │ Premium     │                 │
│ │ 189 seats   │ │ 2-Class     │ │ 2-Class     │                 │
│ │ 29" pitch   │ │ 174 seats   │ │ 156 seats   │                 │
│ │ $0 cost     │ │ $0 cost     │ │ $450K cost  │                 │
│ └─────────────┘ └─────────────┘ └─────────────┘                 │
│                                                                  │
│ ┌─────────────┐ ┌─────────────┐                                 │
│ │ 3-Class     │ │ Long-Haul   │                                 │
│ │ 148 seats   │ │ 142 seats   │                                 │
│ │ $1.2M cost  │ │ $1.8M cost  │                                 │
│ └─────────────┘ └─────────────┘                                 │
│                                                                  │
│ [Cancel]                              [Apply and customize]     │
└─────────────────────────────────────────────────────────────────┘
```

---

## 12. Reconfiguration Workflow

### 12.1 Existing Aircraft

When modifying an aircraft already in service:

```
┌─────────────────────────────────────────────────────────────────┐
│ RECONFIGURATION IMPACT                                          │
│                                                                  │
│ Aircraft: F-GKXA "Spirit of Lyon"                               │
│ Current status: In service (LYS hub)                            │
│                                                                  │
│ Changes:                                                        │
│ • Remove 12 economy seats                                       │
│ • Add 8 premium economy seats                                   │
│ • Upgrade IFE throughout                                        │
│                                                                  │
│ Cost breakdown:                                                 │
│   Seat removal                          $24,000                 │
│   Premium economy seats (8×)           $36,000                  │
│   IFE upgrade                         $180,000                  │
│   Labor and installation               $85,000                  │
│                                       ─────────                  │
│   Total                               $325,000                  │
│                                                                  │
│ Downtime: 14 days                                               │
│ Scheduled: [Select date ▼]                                      │
│                                                                  │
│ ⚠ 23 flights will need reassignment during refit               │
│                                                                  │
│ [Cancel]                    [Schedule refit]                    │
└─────────────────────────────────────────────────────────────────┘
```

### 12.2 Downtime Scheduling

Integration with Network Scheduler:
- Shows calendar with maintenance windows
- Highlights conflicts with scheduled flights
- Suggests optimal refit timing based on seasonal demand

---

## 13. Audio Feedback

| Action | Sound |
|--------|-------|
| Place seat | Mechanical click (satisfying, precise) |
| Remove seat | Soft pop |
| Invalid placement | Low buzz / rejection tone |
| Complete row | Subtle chime |
| Validation error | Alert tone |
| Save configuration | Confirmation tone |
| Apply (commit) | Heavy "stamp" sound |

---

## 14. Keyboard Shortcuts

| Key | Action |
|-----|--------|
| 1-6 | Select seat type (1=Econ, 2=PremEcon, etc.) |
| G | Select galley |
| L | Select lavatory |
| Delete / Backspace | Delete selected |
| Ctrl+Z | Undo |
| Ctrl+Y | Redo |
| Ctrl+A | Select all |
| Ctrl+D | Duplicate selection |
| Ctrl+S | Save (draft) |
| Enter | Apply configuration |
| Tab | Cycle through sections |
| Arrow keys | Nudge selected (with snap) |
| Space | Toggle between Blueprint and Preview |
| Esc | Cancel current action / Deselect |

---

## 15. Data Model Integration

### 15.1 Saving Configuration

When player clicks [Save]:
- Creates/updates `AircraftConfiguration` entity
- Does NOT apply to aircraft yet (draft state)

When player clicks [Apply]:
- Links configuration to `Aircraft.configuration_id`
- Creates `MaintenanceEvent` for refit if aircraft in service
- Updates `Aircraft.status` during refit period
- Logs to `AircraftHistoryEntry` (type: CONFIGURED)

### 15.2 Entity References

| Entity | Usage |
|--------|-------|
| `AircraftConfiguration` | Stores layout, seats, amenities |
| `AircraftConfiguration.classes` | JSON array of cabin sections |
| `Aircraft.configuration_id` | Links to active configuration |
| `MaintenanceEvent` | Tracks refit schedule |
| `AircraftHistoryEntry` | Logs configuration changes |

---

## 16. Edge Cases

### 16.1 Mid-Flight Configuration

If player tries to reconfigure aircraft currently flying:
- Allow editing, but cannot apply until aircraft lands
- Show warning: "Aircraft in flight. Changes will apply after landing."

### 16.2 Leased Aircraft

Some leases restrict configuration changes:
- Show lease terms in header
- Block restricted modifications
- "This aircraft's lease prohibits cabin modifications. [View lease terms]"

### 16.3 Historical Aircraft

Older aircraft have limited options:
- Some seat types unavailable (modern IFE on 1970s aircraft)
- Show era-appropriate components only
- "Personal IFE not available for this aircraft vintage."

---

## 17. Performance Considerations

| Scenario | Target |
|----------|--------|
| Initial load | <1 second |
| Place component | Instant (<50ms) |
| Full cabin validation | <200ms |
| Preview mode switch | <500ms |
| Save configuration | <1 second |

---

## 18. Future Considerations

Not in v1.0, but designed for:

- **Seat map sharing** — Export/import configurations
- **Historical accuracy mode** — Era-locked components
- **Passenger class demand preview** — Show demand by class for route
- **A/B configuration testing** — Run same route with two configs, compare results

---

## Document History

| Version | Date | Changes |
|---------|------|---------|
| 0.1 | January 2026 | Initial specification |
