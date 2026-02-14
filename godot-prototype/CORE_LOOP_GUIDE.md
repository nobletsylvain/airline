# Airline Tycoon - Core Gameplay Loop Guide

## 🎯 Overview

This guide explains the enhanced core gameplay loop focusing on:
1. **Aircraft Customization** - Configure seat layouts to match market demand
2. **Market Analysis** - Discover profitable route opportunities
3. **Strategic Route Planning** - Open routes based on demand/supply gaps
4. **Dynamic Pricing** - Optimize pricing based on competition

---

## 🛩️ Aircraft Configuration System

### Concept
Instead of fixed seat configurations, each aircraft can be customized when purchased. Players choose the mix of Economy, Business, and First class seats based on their route strategy.

### Aircraft Constraints
Each aircraft model has physical constraints:

| Aircraft | Max Seats | Min Economy | Max Business | Max First |
|----------|-----------|-------------|--------------|-----------|
| 737-700 | 149 | 90 | 24 | 12 |
| 737-800 | 189 | 100 | 30 | 12 |
| A220-300 | 160 | 120 | 20 | 8 |
| A320 | 180 | 100 | 30 | 12 |
| 787-9 | 296 | 180 | 60 | 16 |
| A350-900 | 325 | 200 | 70 | 18 |
| 777-300ER | 396 | 250 | 80 | 20 |
| A380 | 853 | 400 | 120 | 28 |

### Configuration Examples

**High-Density Economy** (Budget Airline Strategy)
- 737-800: 189Y / 0J / 0F = 189 total seats
- Good for: Short haul, high-frequency routes with price-sensitive passengers
- Lower revenue per seat but maximum capacity

**Balanced Configuration** (Full-Service Strategy)
- 737-800: 162Y / 12J / 0F = 174 total seats
- Good for: Medium-haul domestic/regional routes
- Balanced revenue and market appeal

**Premium Configuration** (Business-Focused Strategy)
- 787-9: 180Y / 60J / 16F = 256 total seats
- Good for: Long-haul international routes with high-income markets
- Higher revenue per passenger, targets business travelers

### How to Use

```gdscript
# Create custom configuration
var config = AircraftConfiguration.new(189, 100, 12, 30)  # max_seats, min_economy, max_first, max_business
config.set_configuration(162, 12, 0)  # economy, business, first

# Purchase aircraft with configuration
var aircraft = GameData.purchase_aircraft(player_airline, model, config)

# Aircraft automatically uses configuration for capacity
print(aircraft.get_economy_capacity())  # 162
print(aircraft.get_total_capacity())  # 174
```

---

## 🎨 Airline Branding System

### Concept
Each airline has customizable brand colors (primary, secondary, accent) that affect recognition and visual identity.

### Features
- **Auto-generated colors**: New airlines get aesthetically pleasing random colors
- **Custom branding**: Players can set specific RGB colors
- **Hex export**: Colors available as hex strings for UI

### How to Use

```gdscript
# Set custom branding
player_airline.set_branding(
    Color(0.1, 0.3, 0.8),  # Primary blue
    Color(0.95, 0.95, 0.95),  # Secondary white
    Color(1.0, 0.7, 0.0)  # Accent gold
)

# Get colors as hex for UI
var colors = player_airline.get_brand_colors_hex()
# Returns: {"primary": "#1a4dcc", "secondary": "#f2f2f2", "accent": "#ffb300"}

# Randomize branding
player_airline.randomize_branding()
```

---

## 📊 Market Analysis & Route Opportunities

### Market Analysis System

The `MarketAnalysis` class provides comprehensive market intelligence:

#### Key Metrics

**Demand Calculation**
- Based on: Population, airport size, income levels, distance
- Formula factors:
  - Population demand: `sqrt(from_factor * to_factor) * 500`
  - Income multiplier: `0.5x to 1.4x` (higher income = more travel)
  - Distance sweet spots:
    - < 500km: **0.6x** (people drive/train)
    - 500-1500km: **1.2x** (optimal domestic)
    - 1500-3500km: **1.0x** (regional international)
    - 3500-8000km: **0.85x** (long haul)
    - > 8000km: **0.7x** (ultra long haul)
  - Business factor: Short routes get +30% (more business travel)

**Supply Calculation**
- Counts all competing airlines on route
- Sums weekly capacity (seats × frequency)
- Calculates average market pricing

**Opportunity Metrics**
- **Gap**: Unmet demand (demand - supply)
- **Market Saturation**: supply / demand (0 = empty, 1 = saturated)
- **Competition**: Number of competing airlines
- **Profitability Score**: 0-100 rating based on:
  - Gap ratio: +40 points for high unmet demand
  - Competition penalty: -8 points per competitor (max -30)
  - Saturation penalty: Markets >80% saturated lose points
  - Distance bonus: +15 for 800-5000km sweet spot
  - Volume bonus: +10 for demand > 2000 pax/week

### Finding Opportunities

```gdscript
# Find top 10 opportunities from JFK
var jfk = GameData.get_airport_by_iata("JFK")
var opportunities = GameData.find_route_opportunities(jfk, 10)

for opp in opportunities:
    print("%s → %s" % [opp.from_airport.iata_code, opp.to_airport.iata_code])
    print("  Score: %.0f/100" % opp.profitability_score)
    print("  Demand: %.0f | Supply: %.0f | Gap: %.0f" % [opp.demand, opp.supply, opp.gap])
    print("  Competition: %d airlines" % opp.competition)
```

### Analyzing Existing Routes

```gdscript
# Analyze a specific route
var analysis = GameData.analyze_route(from_airport, to_airport)

print("Market Demand: %.0f pax/week" % analysis.demand)
print("Current Supply: %.0f seats/week" % analysis.supply)
print("Market Gap: %.0f pax/week" % analysis.gap)
print("Saturation: %.0f%%" % (analysis.market_saturation * 100))
print("Profitability: %.0f/100" % analysis.profitability_score)
```

### AI-Recommended Pricing

```gdscript
# Get recommended pricing based on market conditions
var pricing = GameData.get_recommended_pricing_for_route(from_airport, to_airport)

print("Recommended Pricing:")
print("  Economy: $%.0f" % pricing.economy)
print("  Business: $%.0f" % pricing.business)
print("  First: $%.0f" % pricing.first)

# Pricing adjusts for:
# - Supply/demand balance (high demand = +20% prices)
# - Competition (each competitor = -5% price)
# - Distance (base: $50 + $0.15/km)
```

---

## 🔄 Core Gameplay Loop

### Step 1: Analyze Market Opportunities

```gdscript
# In GameUI or console
var home_base = GameData.get_airport_by_iata("LAX")
show_route_opportunities(home_base)
```

**Output Example:**
```
=== Route Opportunities from Los Angeles International (LAX) ===

1. LAX → NRT (8800km)
   Score: 87/100
   Demand: 2.5K pax/week | Supply: 800 | Gap: 1.7K
   Competition: 2 airlines | Saturation: 32%
   Recommended: Y:$1400 J:$3500 F:$7000

2. LAX → LHR (8750km)
   Score: 82/100
   Demand: 3.1K pax/week | Supply: 1.2K | Gap: 1.9K
   Competition: 3 airlines | Saturation: 39%
   Recommended: Y:$1380 J:$3450 F:$6900
```

### Step 2: Buy & Configure Aircraft

```gdscript
# Choose aircraft for the route
var model = GameData.get_aircraft_model_by_name("787-9")

# Configure for long-haul premium market
var config = model.get_default_configuration()
config.set_configuration(200, 60, 16)  # More premium seats for business travelers

# Purchase
var aircraft = GameData.purchase_aircraft(player_airline, model, config)
```

### Step 3: Create Optimized Route

```gdscript
# Create route with recommended pricing
var route = Route.new(lax, nrt, player_airline.id)
route.frequency = 7  # Daily flights

# Set pricing based on recommendations
var pricing = GameData.get_recommended_pricing_for_route(lax, nrt)
route.price_economy = pricing.economy
route.price_business = pricing.business
route.price_first = pricing.first

# Assign configured aircraft
route.assign_aircraft(aircraft)

# Add to airline
player_airline.add_route(route)
```

### Step 4: Monitor & Optimize

```gdscript
# After simulation runs
analyze_existing_route(route)
```

**Output Example:**
```
=== Route Analysis: LAX → NRT ===
Distance: 8800km | Duration: 11.0h

Market Conditions:
  Total Demand: 2.5K pax/week
  Total Supply: 1.1K seats/week
  Unmet Demand: 1.4K pax/week
  Competition: 3 airlines
  Market Saturation: 44%
  Opportunity Score: 78/100

Your Route:
  Capacity: 276 seats x 7 freq = 1932/week
  Load Factor: 89.3%
  Pricing: Y:$1400 J:$3500 F:$7000
  Weekly Profit: $1.2M

Recommended Pricing:
  Y:$1320 J:$3300 F:$6600
```

---

## 📈 Passenger Demand System

### Class Distribution

Passenger class preference is **dynamic** based on:

#### Distance-Based Distribution

| Distance | Economy | Business | First |
|----------|---------|----------|-------|
| < 1000km (Short) | 80% | 18% | 2% |
| 1000-3000km (Medium) | 70% | 25% | 5% |
| 3000-6000km (Long) | 65% | 28% | 7% |
| > 6000km (Ultra Long) | 60% | 32% | 8% |

**Reasoning**: Long-haul flights have more business travelers willing to pay for comfort.

#### Reputation Adjustment

- Airlines with **reputation > 100** attract more premium passengers
- Bonus: Up to **+15%** business class, **+7.5%** first class
- Comes from economy class reduction

**Example**:
- Base: 60% Y, 32% J, 8% F
- High reputation (+100): 52.5% Y, 39.5% J, 8% F

#### Income Level Adjustment

- High-income cities (income > 70) have more premium travelers
- Bonus scales with income: **(income - 70) / 100**
- Up to **+10%** business, **+5%** first

**Example**:
- LAX ↔ LHR (both income 85):
  - Base long-haul: 60% Y, 32% J, 8% F
  - Income bonus: 53% Y, 38% J, 9% F

### Quality Multiplier

Passenger demand is affected by route quality:
```gdscript
var quality_multiplier = route.get_quality_score() / 100.0  # 0-100 → 0.0-1.0
quality_multiplier = clamp(quality_multiplier, 0.3, 1.5)  # Range: 0.3x to 1.5x
```

- **Quality Score** = (Service Quality + Aircraft Condition) / 2
- Poor quality (30): Only 30% of potential passengers
- Excellent quality (100+): Up to 150% of potential passengers

---

## 🎮 Practical Strategies

### Budget Airline Strategy
1. **Aircraft**: High-density economy configurations (189Y/0J/0F)
2. **Routes**: Short-haul (<1500km) with high frequency
3. **Pricing**: 10-15% below market recommendations
4. **Target**: Price-sensitive leisure travelers

### Premium Carrier Strategy
1. **Aircraft**: Business-heavy configurations (200Y/60J/16F)
2. **Routes**: Long-haul (>6000km) between high-income cities
3. **Pricing**: At or above market recommendations
4. **Target**: Business travelers, premium leisure

### Market Gap Strategy
1. **Find routes** with high opportunity scores (>70)
2. **Identify undersupplied markets** (saturation <60%)
3. **Enter with aggressive pricing** initially
4. **Gradually raise prices** as reputation builds

### Competitive Strategy
1. **Analyze competitor routes** using analyze_existing_route()
2. **Undercut pricing** by 5-10% to steal market share
3. **Offer better service quality** to justify premium pricing
4. **Match capacity** to avoid market oversaturation

---

## 🔧 Development: Adding UI Components

To add visual route opportunity display to the game UI:

### Add Opportunities Tab

In the Godot scene editor:
1. Add new `TabContainer` child to `ManagementTabs`
2. Name it "Opportunities"
3. Add structure:
   ```
   Opportunities (VBoxContainer)
   ├── AirportSelector (OptionButton)
   ├── RefreshButton (Button)
   ├── OpportunityList (ItemList)
   └── OpportunityDetails (RichTextLabel)
   ```

### Connect to GameUI

```gdscript
# In GameUI.gd _ready()
opportunity_list.item_selected.connect(_on_opportunity_selected)
refresh_button.pressed.connect(_on_refresh_opportunities)

func _on_refresh_opportunities() -> void:
    var airport = get_selected_airport()
    var opps = GameData.find_route_opportunities(airport, 10)

    opportunity_list.clear()
    for opp in opps:
        var text = "%s → %s | Score: %.0f | Gap: %s pax" % [
            opp.from_airport.iata_code,
            opp.to_airport.iata_code,
            opp.profitability_score,
            format_number(int(opp.gap))
        ]
        opportunity_list.add_item(text)
```

---

## 📝 Summary

The enhanced core loop creates a realistic airline management experience:

1. **Market Research**: Analyze demand, supply, and competition
2. **Strategic Planning**: Choose profitable routes with unmet demand
3. **Aircraft Optimization**: Configure planes to match passenger class distribution
4. **Pricing Strategy**: Balance competitiveness with profitability
5. **Performance Monitoring**: Track load factors and adjust strategy

This creates engaging gameplay where **informed decisions lead to success**, not just random expansion.
