# Airline Tycoon - Implementation Plan

**Date:** January 2026  
**Status:** Ready for Implementation  
**Priority:** High

---

## Executive Summary

After comprehensive review of the game design documents and codebase, the project is in excellent shape with most core systems implemented. This plan focuses on completing Phase 1 and beginning Phase 2 implementation.

**Key Findings:**
- ✅ Core systems (routes, aircraft, simulation) are solid
- ✅ Bidirectional demand and hub network effects are implemented
- ✅ Tutorial system is complete (28 steps)
- ⚠️ Phase 1.3 needs completion (profitability scoring updates)
- ❌ Phase 2 features (seasonality, price elasticity, enhanced AI) not started

---

## Immediate Implementation Tasks

### Task 1: Complete Phase 1.3 - Enhanced Profitability Scoring ⚠️

**Status:** Partially Complete  
**Priority:** HIGH  
**Effort:** 2-3 hours  
**Impact:** Improves route planning UX significantly

#### Current State
- ✅ Bidirectional demand incorporated into scoring
- ✅ Hub network multiplier exists in code
- ❌ Scores don't update when routes are added/removed
- ❌ Connection potential not shown in real-time

#### Implementation Steps

1. **Add Route Change Signals** (30 min)
   - Modify `GameData.gd` to emit signals when routes are added/removed
   - Connect signals to trigger profitability recalculation

2. **Implement Score Recalculation** (1 hour)
   - Add function in `MarketAnalysis.gd` to recalculate all route opportunities
   - Cache results to avoid expensive recalculations
   - Update route opportunity dialog when network changes

3. **Add Live Connection Potential Display** (1 hour)
   - Update `RouteOpportunityDialog.gd` to show real-time connection potential
   - Add indicator showing how many connections this route would create
   - Show network value multiplier in profitability score

4. **Testing** (30 min)
   - Test score updates when adding routes to hub
   - Verify connection potential updates correctly
   - Test performance with large hub networks

#### Files to Modify
```
scripts/GameData.gd              - Add route change signals
scripts/MarketAnalysis.gd        - Add recalculation function
scripts/RouteOpportunityDialog.gd - Add live updates
scripts/WorldMap.gd              - Connect to route creation signals
```

#### Success Criteria
- [ ] Profitability scores update when routes are added/removed
- [ ] Connection potential shown in route planning dialog
- [ ] Network effect multiplier visible in UI
- [ ] Performance: Recalculation completes in <100ms for 50 routes

---

### Task 2: Verify Tutorial System Integration ✅

**Status:** Code Complete, Needs Verification  
**Priority:** MEDIUM  
**Effort:** 1-2 hours  
**Impact:** Critical for new player experience

#### Current State
- ✅ All 28 tutorial steps implemented
- ✅ TutorialManager architecture complete
- ⚠️ UI integration needs verification
- ⚠️ Action triggers need testing

#### Verification Steps

1. **Test Tutorial Flow** (30 min)
   - Start new game
   - Complete all 28 steps
   - Verify all action triggers work (hub selection, aircraft purchase, route creation, simulation)
   - Check reward system ($50M bonus)

2. **Verify UI Integration** (30 min)
   - Check if `TutorialOverlay.gd` is connected
   - Test UI highlighting works
   - Verify tutorial dialog displays correctly
   - Check skip functionality

3. **Test Objective System** (30 min)
   - Verify objectives activate after tutorial
   - Test objective progress tracking
   - Verify rewards are given correctly

4. **Fix Any Issues** (30 min)
   - Fix missing triggers
   - Fix UI integration problems
   - Add missing console commands if needed

#### Files to Review
```
scripts/TutorialManager.gd      - Verify all steps
scripts/TutorialOverlay.gd       - Check UI integration
scripts/ObjectiveSystem.gd       - Verify objectives
scripts/GameUI.gd                - Check console commands
scripts/GameData.gd              - Verify action triggers
```

#### Success Criteria
- [ ] Tutorial completes without errors
- [ ] All action steps trigger correctly
- [ ] UI highlights work
- [ ] $50M reward given on completion
- [ ] Objectives activate after tutorial

---

## Short-Term Implementation (Next 2-3 Sessions)

### Task 3: Implement Seasonality System (Phase 2.1)

**Status:** Not Started  
**Priority:** HIGH  
**Effort:** 4-5 hours  
**Impact:** Adds realism and strategic depth

#### Design Requirements

1. **Calendar System**
   - Track current week, month, season, year
   - Display calendar in UI
   - Support multi-year gameplay

2. **Seasonal Demand Multipliers**
   - Winter: MIA, Caribbean +40%, Europe -20%
   - Summer: Europe +50%, Florida -10%
   - Spring/Fall: Moderate across all
   - Apply to route demand calculations

3. **UI Integration**
   - Show current season in top panel
   - Display seasonal demand curves in route planning
   - Show seasonal modifiers in route analysis

#### Implementation Steps

1. **Create Calendar System** (1.5 hours)
   ```gdscript
   # New file: scripts/Calendar.gd
   class_name Calendar
   extends Node
   
   var current_week: int = 0
   var current_year: int = 2024
   var current_season: Season
   
   enum Season { SPRING, SUMMER, FALL, WINTER }
   
   func get_season() -> Season:
       var week_in_year = current_week % 52
       if week_in_year < 13: return Season.SPRING
       elif week_in_year < 26: return Season.SUMMER
       elif week_in_year < 39: return Season.FALL
       else: return Season.WINTER
   ```

2. **Add Seasonal Demand Modifiers** (1.5 hours)
   - Create `SeasonalDemand.gd` with modifier functions
   - Integrate into `MarketAnalysis.gd` demand calculations
   - Apply modifiers based on route origin/destination

3. **Update UI** (1 hour)
   - Add season indicator to top panel
   - Show seasonal demand in route planning dialog
   - Add seasonal demand curve visualization

4. **Update Simulation** (1 hour)
   - Apply seasonal modifiers in `SimulationEngine.gd`
   - Update demand calculations weekly
   - Test seasonal transitions

#### Files to Create
```
scripts/Calendar.gd              - Calendar system
scripts/SeasonalDemand.gd        - Seasonal modifiers
```

#### Files to Modify
```
scripts/GameData.gd              - Add calendar reference
scripts/MarketAnalysis.gd         - Add seasonal demand
scripts/SimulationEngine.gd       - Apply seasonal modifiers
scripts/RouteOpportunityDialog.gd - Show seasonal data
scripts/GameUI.gd                 - Add calendar display
```

#### Success Criteria
- [ ] Calendar tracks weeks, months, seasons, years correctly
- [ ] Seasonal multipliers apply to demand
- [ ] UI shows current season
- [ ] Route planning shows seasonal demand curves
- [ ] Demand changes smoothly between seasons

---

### Task 4: Enhance Competition AI (Phase 2.4)

**Status:** Basic AI Exists, Needs Enhancement  
**Priority:** HIGH  
**Effort:** 5-6 hours  
**Impact:** Makes market feel alive and competitive

#### Current State
- ✅ 4 AI airlines with different strategies
- ✅ AI creates routes and buys aircraft
- ❌ AI doesn't analyze market gaps
- ❌ AI doesn't adjust pricing dynamically
- ❌ AI doesn't abandon unprofitable routes

#### Implementation Steps

1. **AI Market Gap Analysis** (2 hours)
   - Add market analysis to `AIController.gd`
   - AI identifies underserved routes
   - AI prioritizes high-opportunity routes
   - AI avoids over-saturated markets

2. **AI Dynamic Pricing** (1.5 hours)
   - AI adjusts prices based on load factor
   - AI responds to competitor pricing
   - AI undercuts on competitive routes
   - AI raises prices on monopoly routes

3. **AI Route Abandonment** (1 hour)
   - AI tracks route profitability
   - AI abandons routes after sustained losses
   - AI frees up aircraft for better routes

4. **Price War Detection** (1 hour)
   - Detect when multiple airlines compete aggressively
   - Trigger price war mechanics
   - AI responds to price wars based on strategy

5. **Testing** (30 min)
   - Test AI route opening
   - Test AI pricing adjustments
   - Test AI route abandonment
   - Test price war scenarios

#### Files to Modify
```
scripts/AIController.gd          - Add market analysis, pricing, abandonment
scripts/SimulationEngine.gd       - Add price war mechanics
scripts/MarketAnalysis.gd         - Add AI helper functions
```

#### Success Criteria
- [ ] AI opens routes based on market opportunities
- [ ] AI adjusts pricing based on competition
- [ ] AI abandons unprofitable routes
- [ ] Price wars occur and resolve naturally
- [ ] AI behavior feels strategic, not random

---

## Medium-Term Implementation (Next 4-6 Sessions)

### Task 5: Price Elasticity (Phase 2.2)
**Effort:** 3-4 hours  
**Priority:** MEDIUM

### Task 6: Passenger Type Behaviors (Phase 2.3)
**Effort:** 4-5 hours  
**Priority:** MEDIUM

### Task 7: Dynamic Market Saturation (Phase 2.5)
**Effort:** 3-4 hours  
**Priority:** MEDIUM

### Task 8: Calendar & Events System (Phase 3.1-3.2)
**Effort:** 6-8 hours  
**Priority:** LOW (after Phase 2 complete)

---

## Long-Term Implementation (Future)

### Task 9: Campaign System
**Effort:** 10-15 hours  
**Priority:** MEDIUM (post-MVP)

### Task 10: Save/Load System
**Effort:** 4-5 hours  
**Priority:** HIGH (for MVP)

### Task 11: Performance Optimization
**Effort:** 3-4 hours  
**Priority:** MEDIUM

---

## Implementation Schedule

### Week 1 (Immediate)
- **Day 1-2:** Complete Phase 1.3 (Task 1)
- **Day 3:** Verify Tutorial System (Task 2)

### Week 2-3 (Short-Term)
- **Day 4-6:** Implement Seasonality (Task 3)
- **Day 7-9:** Enhance Competition AI (Task 4)

### Week 4-6 (Medium-Term)
- **Day 10-12:** Price Elasticity (Task 5)
- **Day 13-15:** Passenger Behaviors (Task 6)
- **Day 16-18:** Market Saturation (Task 7)

### Week 7+ (Long-Term)
- Campaign System
- Save/Load
- Performance Optimization

---

## Technical Decisions Needed

### 1. Seasonality Balance
**Question:** What seasonal multipliers feel right?  
**Recommendation:** Start conservative (20-30% max), adjust based on playtesting

### 2. AI Difficulty
**Question:** How aggressive should AI be?  
**Recommendation:** Scale with player performance, configurable difficulty

### 3. Save Format
**Question:** JSON or binary?  
**Recommendation:** JSON for MVP (easier debugging), binary for release

### 4. Performance Targets
**Question:** What's acceptable performance?  
**Recommendation:** 60 FPS with 50+ routes, <100ms for route analysis

---

## Risk Mitigation

### High Risk Items
1. **Seasonality Balance** - May make game too complex
   - **Mitigation:** Start with simple multipliers, iterate based on feedback

2. **AI Complexity** - May make AI too predictable or too random
   - **Mitigation:** Test with different AI personalities, adjust weights

3. **Performance** - Route analysis may be slow
   - **Mitigation:** Add caching, optimize calculations, profile early

### Medium Risk Items
1. **Save/Load Complexity** - Data migration concerns
   - **Mitigation:** Version save files, add migration system

2. **Campaign Scope** - Large feature, many dependencies
   - **Mitigation:** Break into smaller milestones, test each phase

---

## Success Metrics

### Technical Metrics
- [ ] All Phase 1 features complete
- [ ] Tutorial completion rate > 80%
- [ ] No critical bugs in core systems
- [ ] Performance: 60 FPS with 50+ routes

### Gameplay Metrics
- [ ] Average playtime per session > 30 minutes
- [ ] Route planning decisions feel meaningful
- [ ] Hub strategy provides clear advantage
- [ ] Market feels dynamic and competitive

---

## Next Steps

1. **Immediate:** Start Task 1 (Phase 1.3 completion)
2. **This Week:** Complete Tasks 1-2
3. **Next Week:** Begin Task 3 (Seasonality)
4. **Ongoing:** Test and iterate based on feedback

---

## Questions for Game Designer

1. **Tutorial Priority:** Is tutorial verification critical, or can we focus on gameplay features first?

2. **Seasonality:** Should we implement seasonality now, or wait for more core gameplay feedback?

3. **AI Difficulty:** How aggressive should AI competition be? Should it scale with player?

4. **Campaign Timeline:** When should campaign system be implemented? v1.0 or post-launch?

5. **Save System:** Is save/load required for MVP, or can it come later?

---

**End of Implementation Plan**
