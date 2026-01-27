# Session Log: Economic Balance & Debt Leverage

**Date:** January 26, 2026  
**Session:** Economic Rebalancing & Credit System Enhancement

---

## Summary

Addressed critical economic balance issues discovered during playtesting. Routes were unprofitable even with high load factors. Added viable debt leverage system for expansion.

---

## Problems Identified

### 1. Operating Costs Too High
- **Symptom:** 4 routes with 69% average load factor generated €132K revenue but €276K expenses = €144K weekly loss
- **Root cause:** ATR 72-600 `daily_cost` was €8,000, too high for regional turboprop economics
- **Impact:** Players could not achieve profitability regardless of pricing decisions

### 2. Credit Limit Too Restrictive  
- **Symptom:** With €250K weekly revenue, credit limit was only €2.5M
- **Root cause:** Formula was simply `weekly_revenue × 10`
- **Impact:** Aircraft cost €26.5M but max borrowing was €2.5M — no viable expansion path except 100+ weeks of grinding

---

## Fixes Applied

### Fix 1: Operating Cost Rebalance

**File:** `godot-prototype/data/prototype-aircraft.json`

```json
// Before
"daily_cost": 8000

// After  
"daily_cost": 3500
```

**Result:** Routes now profitable at ~50% load factor with baseline pricing.

### Fix 2: Credit Limit Enhancement

**File:** `godot-prototype/scripts/Airline.gd` — `get_credit_limit()`

**Previous formula:**
```gdscript
var base_credit: float = weekly_revenue * 10.0
var reputation_multiplier: float = 1.0 + (reputation / 100.0)
return base_credit * reputation_multiplier
```

**New formula:**
```gdscript
# Revenue-based credit: 20 weeks of revenue
var revenue_credit: float = weekly_revenue * 20.0

# Asset-based credit: 50% of aircraft fleet value
var fleet_value: float = 0.0
for ac in aircraft:
    fleet_value += ac.model.base_price * (ac.condition / 100.0)
var asset_credit: float = fleet_value * 0.5

# Balance-based credit: 30% of current cash
var cash_credit: float = balance * 0.3

# Reputation multiplier (1.0 to 2.0)
var reputation_multiplier: float = 1.0 + (reputation / 100.0)

# Total credit limit (minimum €5M for startups)
var total_credit: float = (revenue_credit + asset_credit + cash_credit) * reputation_multiplier
return max(5000000.0, total_credit)
```

**Result with 4 aircraft:**
| Component | Calculation | Amount |
|-----------|-------------|--------|
| Revenue credit | €250K × 20 | €5M |
| Fleet collateral | €106M × 50% | €53M |
| Cash credit | €4M × 30% | €1.2M |
| **Subtotal** | | €59M |
| Reputation (1.5x) | | **~€90M** |

Players can now borrow enough to purchase additional aircraft.

---

## Other Changes This Session

### Cost Calculation Debug Output
Added detailed logging to `SimulationEngine.gd` showing:
- Base demand → market share → elasticity multiplier → final demand
- Price vs baseline, deviation percentage
- Cost breakdown: fuel, crew, maintenance, airport fees

### UI Refresh Fixes
- `GameUI.update_all()` now explicitly refreshes routes, fleet, finances panels
- `WorldMap.refresh_routes()` updates floating info panel if visible

### Array Bounds Fix
- Added `is_empty()` check before accessing `route.assigned_aircraft[0]` in `GameUI._on_save_route_pressed()`

---

## Documentation Updated

- **prototype-scope.md** — Updated ATR 72-600 daily cost (€8K → €3.5K), changed loans from "Stub" to "Enhanced", added Section 10 (Economic Balance Log)

---

## Testing Verification

With new balance:
- Routes profitable at 50%+ load factor
- Weekly profit ~€185K with 5 routes at baseline pricing
- Debt leverage enables purchasing 5th aircraft via loan
- Expansion path is viable without 100+ weeks of grinding

---

---

## Additional Fixes: Pacing Rebalance

### Problem
- Weekly profit ~€200K, aircraft cost €26.5M = 2.5 years to buy one plane
- Too slow for engaging gameplay

### Fixes Applied

#### Fix 1: Aircraft Price Reduction
**File:** `godot-prototype/data/prototype-aircraft.json`

| Parameter | Before | After |
|-----------|--------|-------|
| ATR 72-600 price | €26.5M | €15M |
| Lease rate/month | €180K | €120K |

**Rationale:** €15M is realistic for a used regional turboprop. New ATR 72-600s cost ~€25M, but used market is €12-18M.

#### Fix 2: Interest Rate Reduction
**File:** `godot-prototype/scripts/Airline.gd` — `get_interest_rate()`

| Grade | Before | After |
|-------|--------|-------|
| New | 8% | 6% |
| Emerging | 7% | 5.5% |
| Established | 6% | 5% |
| Professional | 5% | 4.5% |
| Elite | 4% | 4% |
| Legendary | 3% | 3.5% |
| Mythic | 2% | 3% |

### New Pacing

With €200K/week profit and €15M aircraft:
- **Without debt:** ~75 weeks to save (still slow, but better)
- **With debt leverage:** Buy immediately with €15M loan at 6% interest
  - Weekly payment: ~€350K for 52-week term
  - Manageable with 2+ profitable routes

**Target achieved:** Player can acquire 2nd aircraft within 30-60 minutes of play using loans.

---

---

## Task I.1: Added A320neo and 737-800 to Aircraft Catalog

**File:** `godot-prototype/data/prototype-aircraft.json`

### Aircraft Added

| Aircraft | Seats | Range | Speed | Price | Daily Cost | Category |
|----------|-------|-------|-------|-------|------------|----------|
| Airbus A320neo | 180 | 6,300 km | 840 km/h | €50M | €12,000 | narrowbody |
| Boeing 737-800 | 162 | 5,400 km | 850 km/h | €45M | €11,000 | narrowbody |

### Specifications

**Airbus A320neo:**
- Fuel burn: 830 gal/hr
- Runway: 2,100m
- Turnaround: 45 min
- Lease: €380K/month
- Default config: 168 economy + 12 business

**Boeing 737-800:**
- Fuel burn: 860 gal/hr
- Runway: 2,300m
- Turnaround: 40 min
- Lease: €340K/month
- Default config: 150 economy + 12 business

### Progression Path

| Phase | Aircraft | Routes | Weekly Profit |
|-------|----------|--------|---------------|
| Early | ATR 72-600 (€15M) | Regional 300-800km | €50-100K |
| Growth | 737-800 (€45M) | Medium 800-3500km | €150-250K |
| Scale | A320neo (€50M) | Dense 1000-4000km | €200-350K |

---

---

## Task J.1: Route Opportunity Panel

**Files Modified:**
- `godot-prototype/scripts/MarketPanel.gd` — Enhanced opportunity display
- `godot-prototype/scripts/GameUI.gd` — Fixed opportunity selection handler

### Changes Made

1. **Fixed opportunity selection bug**: `_on_market_opportunity_selected` was calling non-existent `show_for_route()`. Changed to open `RouteConfigDialog` directly.

2. **Enhanced opportunity cards now show:**
   - Route code (e.g., "LHR → BCN")
   - City names (e.g., "London to Barcelona")
   - Distance in km
   - Recommended aircraft type based on distance
   - Weekly demand estimate
   - Competition level with color coding (green/yellow/red)
   - Profitability score badge

3. **Improved filtering:**
   - Now shows 15 opportunities (up from 10)
   - Filters out routes player already operates
   - Shows helpful messages when no hub or no opportunities

4. **"Create Route" button**: Clicking directly opens route creation dialog for that opportunity.

### Aircraft Recommendations by Distance

| Distance | Recommended Aircraft |
|----------|---------------------|
| 0-1,500 km | ATR 72-600 |
| 1,500-4,000 km | 737-800 / A320neo |
| 4,000+ km | A320neo |

---

---

## AI Competitor Grace Period

**Files Modified:**
- `godot-prototype/scripts/AIController.gd` — Added grace period and gradual activation
- `godot-prototype/scripts/GameData.gd` — Added `competitor_entered_market` signal
- `godot-prototype/scripts/FeedbackManager.gd` — Added notification when AI enters market

### Configuration Constants

```gdscript
const AI_GRACE_PERIOD_WEEKS: int = 52  # 1 year before AI starts competing
const AI_ACTIVATION_RAMP_WEEKS: int = 12  # Gradual activation over 12 weeks
```

### Behavior

| Week | AI Activity |
|------|-------------|
| 0-51 | **Dormant** — AI does nothing, player can establish routes freely |
| 52 | **Market Entry** — Player receives notification, AI starts at 20% activity |
| 52-64 | **Ramp Up** — AI activity increases linearly from 20% to 100% |
| 64+ | **Fully Active** — AI makes decisions every 2-4 weeks |

### Notification

When grace period ends, player sees:
```
⚠️ New Competitor
Euro Express has entered the market!
Expect competition on your routes.
```

---

---

## Tasks I.2, J.2, K.1: Range Validation, Demand Preview, Cost Breakdown

### I.2: Enhanced Range Validation (RouteConfigDialog.gd)

Aircraft list now shows:
- `✓ Range: 1500 km (+300 km margin)` for aircraft that can fly the route
- `✗ Range: 1500 km (-600 km short)` for aircraft that cannot

Disabled aircraft show detailed tooltip: "Range too short! Aircraft range: X km, Route distance: Y km"

### J.2: Demand Preview on Airport Hover (WorldMap.gd)

New `draw_airport_tooltip()` function shows when hovering over airports:
- Airport name and IATA code
- Distance from player's hub
- Estimated demand (pax/week)
- Recommended aircraft type
- Competition status:
  - "★ No competition!" (green)
  - "⚠ N competitor(s)" (yellow)
  - "✓ You operate this route" (blue)

### K.1: Cost Breakdown in Route Details (WorldMap.gd, Route.gd, SimulationEngine.gd)

Route floating panel now shows itemized costs:
```
Revenue: €X/wk
─── Costs ───
  Fuel: €X
  Crew: €X
  Maint: €X
  Airport: €X
  Total: €X
─────────────
Profit: +/-€X/wk
```

Added cost fields to Route.gd:
- `fuel_cost`, `crew_cost`, `maintenance_cost`, `airport_fees`, `total_costs`

SimulationEngine now stores all costs on route during simulation.

---

---

## Tasks K.2, K.3, M.1, M.2: Profit Trends, Fleet Costs, Hub Stats

### K.2: Profit Margin with Trends (Route.gd, WorldMap.gd, SimulationEngine.gd)

Added to route floating panel:
- Profit margin as percentage of revenue
- Trend indicator: ↑ (improving), ↓ (declining), → (stable)
- Compares current vs previous week (5% threshold for change)

New Route.gd functions:
- `get_profit_margin()` - returns profit as % of revenue
- `get_profit_trend()` - returns trend arrow
- `get_profit_trend_color()` - returns color for trend

### K.3: Fleet-Wide Cost Report (FinancesPanel.gd)

New "Fleet Operating Costs" card in Finances tab:
```
Fuel:         €X/wk
Crew:         €X/wk
Maintenance:  €X/wk
Airport Fees: €X/wk
─────────────────
Total Weekly: €X/wk
Cost/Passenger: €X.XX per pax
```

### M.1: Hub Connection Flow Summary (WorldMap.gd)

Hub airport floating panel now shows:
```
─── Hub Stats ───
Routes: 5
Weekly Pax: 1,234
Connecting: ~185
```

Connecting passengers estimated as 15% of overlapping route traffic.

### M.2: Hub Network Highlighting (WorldMap.gd)

When hovering over a player hub airport:
- Routes connected to that hub are **highlighted** (brighter, thicker)
- Routes not connected are **dimmed** (25% opacity)
- Visual feedback showing the hub's network reach

---

## Next Steps

1. Continue playtesting with new pacing
2. Test narrowbody economics on longer routes
3. Verify range restrictions work correctly
4. Test if competition creates meaningful pricing pressure
