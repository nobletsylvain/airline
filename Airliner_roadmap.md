# Airliner Tycoon - Development Roadmap

**Project**: Godot-based Airline Management Simulation
**Inspired by**: Airline Club (original web game)
**Goal**: Strategic airline empire building with realistic market dynamics
**Last Updated**: 2026-01-20

---

## 🎯 Vision Statement

Build a deep, strategic airline simulation where players must:
- Analyze market demand and competition
- Build hub networks for competitive advantage
- Balance profitability with expansion
- React to dynamic market conditions
- Compete with AI airlines

**Core Pillars**:
1. **Strategic Depth** - Data-driven decisions over guesswork
2. **Hub Economics** - Network effects reward smart hub placement
3. **Market Realism** - Bidirectional demand, seasonality, competition
4. **Progressive Complexity** - Start simple, unlock depth over time

---

## ✅ Completed Features (Current State)

### **Core Systems**
- [x] Airport data system (50+ airports, hub tiers, population, income)
- [x] Aircraft models (range, capacity, costs, configurable seat layouts)
- [x] Route creation and management
- [x] Basic financial system (balance, revenue, expenses, loans)
- [x] Weekly simulation engine
- [x] Airline management (reputation, service quality, grading)

### **Hub System** ✨ NEW
- [x] Hub-based route restrictions (routes must originate from hubs)
- [x] First hub free during tutorial
- [x] Hub purchase system ($500K-$5M based on airport tier)
- [x] Visual hub indicators (double ring on map)
- [x] Hub purchase dialog with filtering

### **Route Planning & Analysis**
- [x] Market analysis engine (demand, supply, competition, profitability)
- [x] Route opportunity scoring (0-100 profitability score)
- [x] **Route planning dialog from hubs** ✨ NEW
  - [x] Distance filters (Short/Medium/Long haul)
  - [x] Sorted by profitability
  - [x] Aircraft compatibility checking
  - [x] Market intelligence display
- [x] Route configuration dialog (aircraft, frequency, pricing)
- [x] AI-recommended pricing based on distance and competition

### **Visual & UX**
- [x] Interactive world map with zoom/pan
- [x] Route visualization with profitability colors
- [x] Variable route thickness by capacity
- [x] Route labels (passengers, profit, load factor)
- [x] Route preview during creation (dashed line)
- [x] Hub visual markers
- [x] Route editing (click existing route to modify)

### **Tutorial System (FTUE)**
- [x] 28-step guided tutorial
- [x] Hub selection during tutorial (Step 5-6)
- [x] Progressive objectives with $145M rewards
- [x] Skip tutorial option

### **Aircraft Customization**
- [x] Configurable seat layouts (economy/business/first)
- [x] Capacity constraints per aircraft model
- [x] Configuration profitability analysis

### **Branding**
- [x] Custom airline colors (primary, secondary, accent)
- [x] Random branding generation

---

## 🚧 Phase 1: Market Realism & Hub Economics (CURRENT PRIORITY)

**Goal**: Make demand realistic and reward hub strategy

### 1.1 Bidirectional Demand Modeling ✅ COMPLETE
**Why**: Currently LAX→LHR has same demand as LHR→LAX (unrealistic)

**Implementation**:
- [x] Split demand into outbound (from hub) and inbound (to hub)
- [x] Model business vs tourist travelers separately
  - Business: Higher from economic centers (NYC, LHR, TYO)
  - Tourist: Higher toward destinations (MIA, LAS, DXB)
- [x] Income-based demand skew (wealthy cities generate more outbound)
- [x] Leisure vs business split by city type
- [x] Display bidirectional breakdown in route planning dialog

**Impact**:
- MIA→NYC winter tourism spike vs NYC→MIA business travel
- LHR→DXB wealthy tourists vs DXB→LHR lower reverse flow
- Strategic route selection based on directional strength

**Example**:
```
LAX → MIA (Winter):
- Outbound LAX: 800 pax/week (50% business, 50% leisure)
- Inbound MIA: 1,200 pax/week (20% business, 80% leisure - tourists going home)
- Total: 2,000 pax/week

MIA → LAX (Winter):
- Outbound MIA: 400 pax/week (mostly business)
- Inbound LAX: 600 pax/week
- Total: 1,000 pax/week

Asymmetric! LAX→MIA is 2x more profitable in winter.
```

### 1.2 Hub Network Effects ⭐ HIGH PRIORITY
**Why**: Currently no benefit to concentrated hub vs scattered routes

**Implementation**:
- [ ] Calculate connecting passenger demand
- [ ] Routes from same hub create transfer passengers
- [ ] Connection quality scoring:
  - Compatible flight times (layover 1-4 hours)
  - Same airline bonus (no baggage re-check)
  - Hub size penalty (overcrowding)
- [ ] Display connection potential in route planning
- [ ] Revenue split for connecting passengers (origin + destination legs)

**Impact**:
- Building LAX hub with 10 routes creates exponential value
- JFK→LAX→NRT generates demand on BOTH legs
- Strategic hub concentration rewarded over point-to-point

**Example**:
```
LAX Hub Network:
- LAX → JFK (2,000 pax/week direct)
- LAX → NRT (1,500 pax/week direct)

With connections:
- LAX → JFK: 2,000 + 300 (JFK→LAX→NRT connections) = 2,300 pax
- LAX → NRT: 1,500 + 400 (NRT→LAX→JFK connections) = 1,900 pax

Total system capacity: +700 pax/week from network effects!
```

### 1.3 Enhanced Profitability Scoring
- [ ] Incorporate bidirectional demand into scoring
- [ ] Add hub network multiplier to scores
- [ ] Show "connecting passenger potential" in route dialog
- [ ] Recalculate scores when new routes added (network effect updates)

**Estimated Effort**: 2-3 sessions
**Dependencies**: None (can start immediately)

---

## 🔮 Phase 2: Market Dynamics & Competition

**Goal**: Living, breathing competitive market

### 2.1 Basic Seasonality
- [ ] Four seasons with demand multipliers
  - Winter: MIA, Caribbean +40%, Europe -20%
  - Summer: Europe +50%, Florida -10%
  - Spring/Fall: Moderate across all
- [ ] Route planning shows seasonal demand curves
- [ ] Annual calendar with week tracking

### 2.2 Price Elasticity
- [ ] Demand responds to pricing
- [ ] Premium pricing reduces demand but increases revenue
- [ ] Budget pricing increases demand but may lose money
- [ ] Sweet spot calculation per route

### 2.3 Passenger Type Modeling (from Airline Club)
- [ ] Business travelers (higher price tolerance, frequency preference, weekday peak)
- [ ] Tourist travelers (price sensitive, seasonal, weekend preference)
- [ ] Different demand patterns by passenger type
- [ ] Class preference influenced by distance and passenger type
- [ ] Business: Short/medium routes prefer frequency over price
- [ ] Tourist: Long routes prioritize price over schedule

### 2.4 Competition AI Response
- [ ] AI airlines analyze market gaps and open profitable routes
- [ ] AI adjusts pricing to compete with player
- [ ] AI abandons unprofitable routes after sustained losses
- [ ] Market share dynamics and competitive pressure
- [ ] AI builds hubs in response to player success
- [ ] Price wars triggered by aggressive player pricing

### 2.5 Dynamic Market Saturation
- [ ] Over-served routes see demand decline (market fatigue)
- [ ] Under-served routes see demand grow (pent-up demand)
- [ ] Competition intensity affects new entrant difficulty
- [ ] Route maturity curve (new routes grow demand, old routes stabilize)
- [ ] First-mover advantage vs late-entrant challenges

**Estimated Effort**: 4-5 sessions
**Dependencies**: Phase 1 complete

---

## 🌟 Phase 3: Events & Advanced Simulation

**Goal**: Dynamic world events create strategic opportunities

### 3.1 Calendar System
- [ ] Full calendar with dates (52 weeks/year, multi-year gameplay)
- [ ] Week display with actual dates (Jan 1-7, Jan 8-14, etc.)
- [ ] Historical performance tracking by week/month/quarter/year
- [ ] Seasonal patterns visualization (demand curves by route)
- [ ] Holiday awareness (Thanksgiving, Christmas, New Year, Easter, etc.)
- [ ] National holidays by country (impact local demand)

### 3.2 World Events System
**Major Events**:
- [ ] Olympics (host city +300% demand spike, 2-week duration)
- [ ] FIFA World Cup (host country, 4-week event)
- [ ] Formula 1 Races (weekend spikes, rotating calendar)
- [ ] Political Summits (G7, UN, NATO - business traveler surge)
- [ ] Trade Shows (CES, Mobile World Congress, Paris Air Show)
- [ ] Music Festivals (Coachella, Glastonbury, Tomorrowland)
- [ ] Cultural Events (Carnival, Oktoberfest, Chinese New Year)

**Event Properties**:
- [ ] Duration (days/weeks)
- [ ] Demand multiplier (2x to 5x normal)
- [ ] Passenger type (mostly tourist, mostly business, mixed)
- [ ] Advance warning (plan ahead for capacity)
- [ ] Temporary route viability (charter operations)

**Random Events** (lower priority):
- [ ] Natural disasters (volcano eruptions, hurricanes - route closures)
- [ ] Economic crises (demand decline globally or by region)
- [ ] Pandemics (catastrophic demand drop, recovery timeline)
- [ ] Oil price shocks (fuel cost volatility)
- [ ] Labor strikes (competitor disruption, opportunity for player)
- [ ] Airport closures (construction, incidents)

### 3.3 Advanced Hub Modeling
- [ ] Hub congestion (slot limits)
- [ ] Hub quality ratings (transfer experience)
- [ ] Hub investment (lounges, facilities)
- [ ] Alliance hub sharing

### 3.4 Aircraft Aging & Maintenance
- [ ] Aircraft condition degradation
- [ ] Maintenance costs increase with age
- [ ] Customer satisfaction impact
- [ ] Fleet renewal strategy

**Estimated Effort**: 4-5 sessions
**Dependencies**: Phase 2 complete

---

## 🚀 Phase 4: Advanced Features

### 4.1 Alliances & Partnerships
- [ ] Code-share agreements
- [ ] Alliance networks (Star Alliance, OneWorld, SkyTeam)
- [ ] Joint ventures
- [ ] Interlining

### 4.2 Advanced Fleet Management
- [ ] Leasing vs ownership
- [ ] Secondary market for used aircraft
- [ ] Charter operations
- [ ] Cargo operations

### 4.3 Marketing & Branding
- [ ] Advertising campaigns
- [ ] Loyalty programs
- [ ] Brand reputation effects on demand
- [ ] Service class differentiation

### 4.4 Detailed Financials
- [ ] Cash flow statements
- [ ] Balance sheets
- [ ] Quarterly reports
- [ ] Investor relations

### 4.5 Multiplayer/Persistent World
- [ ] Multiple airlines compete in real-time
- [ ] Persistent world state
- [ ] Player vs player competition
- [ ] Rankings and achievements

**Estimated Effort**: 10+ sessions
**Dependencies**: Phases 1-3 complete

---

## 📚 Airline Club Feature Reference

**Features to Study/Adapt from Original Game**:

### Route Planning & Analysis
- **planLink Endpoint**: Returns comprehensive route analysis before creation
  - Direct demand breakdown (business vs tourist, from each airport)
  - Competitor analysis (existing routes, pricing, capacity, load factor)
  - Suggested pricing based on distance and flight type
  - Link creation cost (negotiation difficulty)
  - Aircraft viability (range, availability, country restrictions)
- **Flight Type Classification**: 10 categories based on distance/domestic/international
  - Affects demand calculations and pricing suggestions
- **Via-Transit Analysis**: Shows competing routes through connection hubs
- **Rejection System**: Clear reasons why routes can't be opened (network insufficiency, titles, relationships)

### Demand Modeling
- **Bidirectional**: fromAirportBusinessDemand, toAirportBusinessDemand separately
- **Passenger Types**: Business vs Tourist with different behaviors
  - Business: Higher willingness to pay, schedule preference, weekday peak
  - Tourist: Price sensitive, seasonal patterns, weekend preference
- **Airport Features**: Lounges, monuments, vacation spots affect demand
  - Business lounges boost business traveler demand
  - Tourist attractions boost leisure demand
  - Demand adjustments specific to passenger type and flight direction

### Service Quality & Pricing
- **Service Level**: Configurable per route (0-100)
- **Price Classes**: Economy, Business, First with different space multipliers
- **Load Factor Tracking**: Detailed sold seats / capacity by class
- **Satisfaction Metrics**: Customer satisfaction affects repeat business

### Operations Management
- **Frequency Optimization**: Multiple flights per week on same route
- **Aircraft Assignment**: Assign specific planes to routes
- **Delegate Assignment**: Staff allocation affects service quality
- **Office Staff Requirements**: Scales with network complexity
- **Overtime Compensation**: Costs when exceeding staff capacity

### Financial Modeling
- **Link Creation Cost**: Based on airport income, size, relationship
- **Estimated Difficulty**: Negotiation challenge score
- **Suggested Price**: AI-calculated optimal pricing
- **Revenue/Cost Tracking**: Per route profitability

### Competition Features
- **Competitor Route Display**: See all competing airlines on route
- **Pricing Comparison**: Competitor prices visible
- **Capacity Comparison**: Competitor frequencies and aircraft
- **Load Factor Visibility**: See how full competitor flights are
- **Market Share**: Percentage of total route capacity

### Relationships & Restrictions
- **Country Relationships**: Bilateral agreements affect route access
- **Title Requirements**: Hub status, airline grade requirements
- **Negotiation Difficulty**: Harder to enter certain markets
- **Airport Income Levels**: Richer airports cost more to access

---

## 🔧 Technical Debt & Improvements

### Code Quality
- [ ] Unit tests for market analysis
- [ ] Integration tests for simulation
- [ ] Performance optimization (route calculation caching)
- [ ] Save/load game state
- [ ] Settings persistence

### UI/UX Enhancements
- [ ] Tutorial improvements based on user feedback
- [ ] Keyboard shortcuts
- [ ] Accessibility features
- [ ] Mobile-friendly UI (if targeting mobile)
- [ ] Chart/graph visualizations for trends

### Data Management
- [ ] Expand airport database (100+ airports)
- [ ] More aircraft models (50+ types)
- [ ] Real-world airport data integration
- [ ] Historical demand data (if available)

---

## 📊 Success Metrics

### Gameplay Depth
- Average playtime per session
- Number of decisions per hour
- Strategic variety (hub strategies observed)

### Market Realism
- Demand prediction accuracy vs real airline data
- Profitability alignment with real-world routes
- Competition dynamics feel authentic

### Player Satisfaction
- Tutorial completion rate
- Feature usage statistics
- Player retention

---

## 🎮 Inspirations & References

### Games
- **Airline Tycoon** (1998) - Fun, accessible airline management
- **Airline Club** (web) - Deep simulation, market analysis
- **Transport Tycoon** - Network effects, strategic placement
- **SimCity** - Growth simulation, feedback loops

### Real-World Data Sources
- IATA statistics (route demand)
- Bureau of Transportation Statistics (US routes)
- FlightRadar24 (route networks)
- Airline annual reports (costs, pricing)

---

## 📝 Development Guidelines

### Session Structure
1. Review roadmap and priorities
2. Implement focused feature set
3. Test and validate
4. Update roadmap with learnings
5. Commit and document

### Code Principles
- **Readability**: Clear variable names, comments for complex logic
- **Modularity**: Separate concerns (UI, logic, data)
- **Performance**: Cache expensive calculations
- **Extensibility**: Design for future features

### Commit Strategy
- Small, focused commits
- Clear commit messages referencing roadmap items
- Push frequently to preserve progress

---

## 🔄 Change Log

### 2026-01-20 - Session 1
**Completed**:
- Hub-based route system
- Route planning dialog with distance filters
- Hub purchase UI
- Route visualization enhancements (colors, labels, editing)

**Next Session Priority**:
- Phase 1.1: Bidirectional demand modeling
- Phase 1.2: Hub network effects

**Key Decisions**:
- Prioritize market realism (Phase 1) over events (Phase 3)
- Hub network effects identified as highest strategic value
- Bidirectional demand provides asymmetric route opportunities

---

## 💡 Ideas Backlog (Unsorted)

### From Airline Club Inspiration
- **Passenger Types**: Business vs Tourist demand modeling (different price sensitivity, schedule preferences)
- **Service Quality Ratings**: In-flight service affects demand and pricing power
- **Link Difficulty**: Negotiation difficulty for new routes based on airport relationships
- **Country Relationships**: International route access based on bilateral agreements
- **Lounges & Facilities**: Airport investments that boost demand and allow premium pricing
- **Delegate Assignment**: Staff allocation to routes affects service quality
- **Load Factor Optimization**: Balance frequency vs capacity per flight
- **Price Competition**: Real-time competitor pricing visible and affects your demand
- **Via-Transit Routes**: Connecting flights through other airlines' hubs
- **Aircraft Procurement**: Country restrictions on buying certain aircraft models
- **Staff Requirements**: Office staff needed scales with route network complexity
- **Overtime Compensation**: Costs when operating beyond staff capacity

### Simulation Depth
- **Weather System**: Delays, cancellations, seasonal route closures
- **Day-of-Week Patterns**: Business routes peak MON-FRI, leisure SAT-SUN
- **Time-of-Day Scheduling**: Red-eye flights, peak hours, slot coordination
- **Pilot/Crew Management**: Crew scheduling, fatigue, training, unions
- **Gate Assignment Optimization**: Hub congestion, gate assignments
- **Environmental Regulations**: Carbon taxes, emissions trading, sustainable aviation fuel

### Strategic Features
- **Airport Investment**: Buy gates, build lounges, expand facilities
- **Fuel Hedging**: Lock in fuel prices, manage price volatility
- **Aircraft Customization**: Livery designer, cabin layouts beyond seat config
- **In-Flight Amenities**: WiFi, meals, entertainment affect service quality
- **Customer Reviews**: Social media, review sites impact reputation
- **Random Events**: Strikes, accidents, pandemics, volcanic ash
- **Aircraft Manufacturer Relationships**: Volume discounts, early access to new models

### Advanced Gameplay
- **Negotiation Mini-Games**: Hub access, slot allocation, landing rights
- **Historic Scenarios**: 1980s deregulation, 2008 financial crisis, COVID-19
- **Bankruptcy & Restructuring**: Chapter 11, debt restructuring, asset sales
- **Stock Market & IPOs**: Go public, manage shareholders, quarterly earnings
- **Mergers & Acquisitions**: Buy competitors, merge airlines, antitrust issues
- **Franchise/Regional Carriers**: Partner with smaller airlines for feeder traffic

### Complex Systems (Long-term)
- **Crew Base Management**: Position crew at hubs, deadheading costs
- **Maintenance Facilities**: Build hangars, MRO operations
- **Cargo Operations**: Belly freight, dedicated cargo aircraft
- **Charter Operations**: Ad-hoc flights, seasonal charters
- **Code-Share Revenue Sharing**: Complex revenue split agreements
- **Loyalty Program Economics**: Frequent flyer programs, redemption costs
- **Ancillary Revenue**: Baggage fees, seat selection, priority boarding
- **Dynamic Pricing**: Revenue management, yield optimization
- **Fleet Commonality Benefits**: Simplified training, parts inventory
- **Airport Slot Trading**: Secondary market for valuable slots

---

**End of Roadmap**
*This document is a living guide. Update after each development session.*
