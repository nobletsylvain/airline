# Features from Airline Club Worth Implementing

**Analysis Date:** January 2026  
**Source:** Original Airline Club (airline-data/src/main/scala)  
**Priority:** High → Medium → Low

---

## 🔥 HIGH PRIORITY - Core Strategic Depth

### 1. **Delegates System** ⭐⭐⭐
**What it is:** Staff allocation system where you assign delegates to tasks
- **Country Relationship Development**: Assign delegates to countries to improve diplomatic relations
- **Link Negotiation**: Use delegates to negotiate route access (reduces route creation costs)
- **Campaigns**: Delegate-powered marketing campaigns in regions

**Why implement:**
- Adds strategic depth to route creation
- Creates meaningful choices (where to allocate limited delegates)
- Makes country relationships matter
- Provides long-term progression

**Implementation Complexity:** Medium
- Need: `Delegate` class, `DelegateTask` system, UI for assignment
- Dependencies: Country relationship system

**Current Status:** Not implemented

---

### 2. **Link Difficulty & Negotiation** ⭐⭐⭐
**What it is:** Routes have difficulty based on:
- Country relationships (diplomatic ties)
- Market share in destination country
- Airport features (gateway airports easier)
- Delegate negotiation discounts

**Why implement:**
- Makes route creation strategic (not just "click two airports")
- Rewards building relationships
- Creates barriers and opportunities
- Adds negotiation mini-game

**Implementation Complexity:** Medium-High
- Need: Difficulty calculation, negotiation system, country relationships
- Dependencies: Delegates system, country relationship tracking

**Current Status:** Routes are free to create (only hub requirement)

---

### 3. **Lounges System** ⭐⭐
**What it is:** Airport lounges that:
- Reduce ticket prices (passengers willing to pay more for lounge access)
- Generate revenue from visitors
- Require hub scale (level 3+)
- Can be shared with alliance members

**Why implement:**
- Premium service differentiation
- Revenue stream
- Strategic hub investment
- Alliance benefits

**Implementation Complexity:** Medium
- Need: `Lounge` class, lounge management UI, revenue calculation
- Dependencies: Hub scale system, alliance system (optional)

**Current Status:** Not implemented

---

### 4. **Country Relationships** ⭐⭐
**What it is:** Diplomatic relationships between countries affect:
- Route creation difficulty
- Market access
- Passenger demand (some routes blocked by poor relations)

**Why implement:**
- Realistic international aviation constraints
- Strategic depth (choose home country matters)
- Creates geopolitical gameplay

**Implementation Complexity:** Medium
- Need: Country relationship data, relationship calculation
- Dependencies: Country data system

**Current Status:** Not implemented (routes are globally accessible)

---

## 🎯 MEDIUM PRIORITY - Enhanced Gameplay

### 5. **Airport Assets** ⭐⭐
**What it is:** Build facilities at airports:
- Hotels (attract tourists, reduce passenger costs)
- Convention Centers (boost business travel)
- Museums, Stadiums, Resorts (various bonuses)
- Office Buildings (rental income)
- Transit systems (population boost)

**Why implement:**
- Long-term investment strategy
- Airport development gameplay
- Revenue diversification
- Strategic airport control

**Implementation Complexity:** High
- Need: Asset system, construction timers, ROI calculations, 30+ asset types
- Dependencies: Airport ownership/control system

**Current Status:** Not implemented

**Recommendation:** Start with 3-5 key assets (Hotel, Convention Center, Lounge) rather than all 30

---

### 6. **Alliances System** ⭐⭐
**What it is:** Form alliances with other airlines:
- Shared lounges
- Code-share agreements
- Alliance missions (cooperative goals)
- Reputation bonuses
- Market share benefits

**Why implement:**
- Multiplayer/social gameplay
- Strategic partnerships
- Long-term goals
- Competitive rankings

**Implementation Complexity:** High
- Need: Alliance management, member roles, missions system
- Dependencies: Multiplayer infrastructure (or AI alliances)

**Current Status:** Not implemented

**Recommendation:** Start with AI alliances, add player alliances later

---

### 7. **Service Quality Investment** ⭐
**What it is:** Invest money to improve service quality:
- Affects passenger demand
- Different from maintenance quality
- Target vs current quality (gradual improvement)

**Why implement:**
- Strategic spending choice
- Quality vs cost tradeoff
- Long-term reputation building

**Implementation Complexity:** Low-Medium
- Need: Service quality investment UI, cost calculation
- Dependencies: None (already have service quality stat)

**Current Status:** Service quality exists but can't be improved manually

---

### 8. **Office Staff Requirements** ⭐
**What it is:** Routes require office staff:
- Scales with route complexity
- Overtime costs if understaffed
- Base upkeep costs

**Why implement:**
- Realistic operational costs
- Scaling challenge (can't expand infinitely)
- Strategic hiring decisions

**Implementation Complexity:** Medium
- Need: Staff calculation, overtime system, hiring UI
- Dependencies: None

**Current Status:** Not implemented (routes have no staff costs)

---

## 📊 LOW PRIORITY - Nice to Have

### 9. **Oil Price Simulation** ⭐
**What it is:** Dynamic fuel costs based on:
- Global oil prices
- Historical events (oil crises)
- Regional variations

**Why implement:**
- Economic realism
- Strategic planning (fuel hedging)
- Event-driven gameplay

**Implementation Complexity:** Low
- Need: Oil price simulation, fuel cost calculation
- Dependencies: Event system

**Current Status:** Fixed fuel costs

---

### 10. **Aircraft Leasing** ⭐
**What it is:** Lease aircraft instead of buying:
- Lower upfront cost
- Monthly payments
- Return aircraft option

**Why implement:**
- Flexible fleet management
- Lower barrier to entry
- Strategic financing option

**Implementation Complexity:** Medium
- Need: Leasing system, lease contracts, return logic
- Dependencies: None

**Current Status:** Only purchase available

---

### 11. **Campaigns** ⭐
**What it is:** Marketing campaigns in regions:
- Boost awareness/reputation
- Require delegates
- Cost money
- Time-limited effects

**Why implement:**
- Marketing strategy
- Reputation management
- Regional focus

**Implementation Complexity:** Medium
- Need: Campaign system, delegate assignment
- Dependencies: Delegates system

**Current Status:** Not implemented

---

### 12. **Aircraft Maintenance Scheduling** ⭐
**What it is:** Plan maintenance windows:
- Aircraft unavailable during maintenance
- Preventative vs reactive
- Maintenance quality affects condition

**Why implement:**
- Realistic fleet management
- Strategic planning
- Cost optimization

**Implementation Complexity:** Medium
- Need: Maintenance scheduling, aircraft downtime
- Dependencies: None (condition system exists)

**Current Status:** Automatic degradation only

---

## ❌ NOT RECOMMENDED (Too Complex/Not Core)

### 13. **Full Airport Asset System (30+ assets)**
- Too many assets to implement
- Start with 3-5 key ones
- Can expand later

### 14. **Full Alliance Mission System**
- Complex cooperative gameplay
- Better for multiplayer
- Low priority for single-player

### 15. **Generic Transit System**
- Very complex passenger routing
- Current connecting passenger system is simpler
- May add later if needed

---

## 📋 RECOMMENDED IMPLEMENTATION ORDER

### Phase 1: Strategic Depth (Next 2-3 sessions)
1. **Delegates System** - Core strategic resource
2. **Link Difficulty & Negotiation** - Makes route creation strategic
3. **Country Relationships** - Foundation for difficulty system

### Phase 2: Premium Features (After Phase 1)
4. **Lounges System** - Premium service differentiation
5. **Service Quality Investment** - Strategic spending
6. **Office Staff Requirements** - Scaling challenge

### Phase 3: Advanced Systems (Later)
7. **Airport Assets (Simplified)** - 3-5 key assets only
8. **Aircraft Leasing** - Fleet flexibility
9. **Oil Price Simulation** - Economic realism

### Phase 4: Multiplayer/Advanced (Future)
10. **Alliances System** - If multiplayer is added
11. **Campaigns** - Marketing depth
12. **Maintenance Scheduling** - Fleet management depth

---

## 💡 QUICK WINS (Easy to Implement, High Value)

1. **Service Quality Investment** - Just add investment UI, cost calculation
2. **Office Staff Requirements** - Add staff cost to route expenses
3. **Oil Price Simulation** - Simple price fluctuation system

---

## 🎮 FEATURES ALREADY IMPLEMENTED (Don't Re-implement)

✅ Hub system  
✅ Bidirectional demand  
✅ Hub network effects  
✅ Market analysis  
✅ Route opportunity scoring  
✅ Loan system  
✅ AI competition  
✅ Aircraft configuration  
✅ Weekly simulation  

---

## 📝 SUMMARY

**Top 3 Must-Have Features:**
1. **Delegates System** - Adds strategic depth
2. **Link Difficulty & Negotiation** - Makes route creation meaningful
3. **Lounges System** - Premium service differentiation

**Quick Wins:**
- Service Quality Investment
- Office Staff Requirements
- Oil Price Simulation

**Skip for Now:**
- Full Airport Asset System (30+ assets)
- Complex Alliance Missions
- Generic Transit System
