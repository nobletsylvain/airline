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

## Next Steps

1. Continue playtesting with new pacing
2. Monitor loan payoff rates vs expansion speed
3. Consider adding more aircraft types for variety
4. Test if competition creates meaningful pricing pressure
