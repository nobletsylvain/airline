# Airline Tycoon Game - Godot Prototype

A Godot 4.x prototype of an airline tycoon game based on the [Airline Club](https://www.airline-club.com/) open-source project.

## Overview

This prototype simulates the core mechanics of running an airline, including:
- **Aircraft Fleet Management**: Purchase aircraft and manage your fleet
- **Route Management**: Create flight routes between major airports worldwide
- **Aircraft Assignment**: Assign aircraft to routes based on range and capacity
- **Financial Simulation**: Track revenue, expenses, and profitability
- **Weekly Simulation**: Automated weekly cycles that simulate passenger demand and calculate finances
- **World Map**: Visual representation of airports and routes on a simplified world map

## Features Implemented

### Core Game Systems
- **15 Major Airports**: JFK, LAX, LHR, NRT, SYD, DXB, CDG, FRA, SIN, ORD, ATL, HND, PEK, ICN, MIA
- **8 Aircraft Models**: Boeing 737, Airbus A320, Boeing 787, Airbus A350, and more with realistic prices and specs
- **Fleet Management**: Purchase aircraft, track fleet status, and assign to routes
- **Aircraft Assignment**: Routes require available aircraft, automatic assignment based on range
- **Passenger Classes**: Economy, Business, and First Class
- **Dynamic Pricing**: Distance-based pricing with class multipliers
- **Quality System**: Service quality and aircraft condition affect demand
- **Financial Tracking**: Weekly revenue, expenses, and profit calculations
- **Range Restrictions**: Aircraft can only fly routes within their maximum range
- **Loan System**: Take out loans to finance expansion with dynamic interest rates based on airline grade
- **AI Competition**: 4 competitor airlines with different strategies (aggressive, conservative, balanced)
- **Market Share**: Compete for passengers on the same routes based on price, quality, and reputation

### Simulation Engine
The simulation runs weekly cycles (configurable speed) that calculate:
- Passenger demand based on airport size and population
- Revenue from ticket sales (economy, business, first class)
- Operating costs (fuel, crew, maintenance, airport fees)
- Aircraft degradation over time
- Airline reputation changes

### Visual Interface
- **World Map**: Click airports to select, click two airports to create a route
- **Top Panel**: Displays airline name, grade, reputation, fleet size, week number, and balance
- **Route List**: Shows all active routes with assigned aircraft ID, passenger count and profit
- **Aircraft Panel**: Browse available aircraft models and purchase them
- **Fleet List**: View your owned aircraft with assignment status and condition
- **Loan Panel**: Apply for loans and view active loan details
- **Competitor Panel**: Monitor rival airlines' fleet size, routes, balance, debt, and strategy
- **Control Buttons**: Play/Pause and Step Week for manual control

## How to Run

### Requirements
- [Godot Engine 4.3](https://godotengine.org/download) or later

### Steps
1. Download and install Godot Engine 4.3+
2. Open Godot and click "Import"
3. Navigate to this `godot-prototype` folder and select `project.godot`
4. Click "Import & Edit"
5. Press F5 or click the "Run Project" button to start

## How to Play

### Getting Started
**IMPORTANT**: You must purchase aircraft before you can create routes!

1. **Purchase Aircraft**:
   - Look at the "Available Aircraft" list in the bottom-right panel
   - Click on an aircraft model to see its details (capacity, range, price)
   - Click "Purchase Selected Aircraft" if you have enough money
   - Your new aircraft will appear in the "Your Fleet" list below

2. **Create Routes**:
   - Click on an airport to select it (it will highlight in white)
   - Click on another airport to create a route between them
   - The system will automatically assign an available aircraft that can fly the distance
   - If successful, the route will appear as a line on the map:
     - **Green line**: Profitable route
     - **Red line**: Unprofitable route

3. **Manage Your Fleet**:
   - Fleet list shows: ✓ = assigned to route, ○ = available
   - Aircraft degrade over time (condition percentage)
   - Each aircraft can only be assigned to one route

4. **Take Out Loans** (if needed):
   - Enter loan amount in millions (e.g., "50" for $50M)
   - Enter term in weeks (e.g., "52" for 1 year)
   - Check your credit limit and interest rate displayed below
   - Click "Apply for Loan" to receive funds instantly
   - Weekly loan payments are automatically deducted during simulation

### Running the Simulation
- **Play Button**: Start/pause automatic weekly simulation (5 seconds per week)
- **Step Week Button**: Manually advance one week at a time

### Understanding the UI
- **Top Panel**: Shows airline name, grade, reputation, fleet size, week, and balance
- **Routes Panel**: Lists all routes with assigned aircraft ID, passengers, and profit
- **Airport Info**: Shows details about selected items (airports, routes, aircraft)
- **Aircraft Panel**: Browse and purchase aircraft, view your fleet
- **Loan Panel**: Shows active loans and loan application form with credit limit and interest rate

### Default Setup
- Starting airline: "SkyLine Airways"
- Starting balance: **$100,000,000** (realistic startup capital)
- Starting reputation: 0 (Grade: New)
- Starting fleet: Empty - purchase your first aircraft!
- No routes created initially - you create them!

### Aircraft Pricing Philosophy
**Realistic Economics**: Aircraft prices reflect real-world costs ($74M-$445M). This creates:
- **Strategic decisions**: Do you buy one widebody or multiple narrowbodies?
- **Fleet composition matters**: Each aircraft choice has trade-offs
- **Loan system**: Debt financing allows expansion beyond cash reserves with dynamic interest rates

### Gameplay Loop
1. **Purchase aircraft** with your starting $100M (can buy 1-2 aircraft initially)
2. **Create profitable routes** between major airports
3. **Run simulation** to generate revenue
4. **Reinvest profits** into more aircraft
5. **Expand your network** to more destinations
6. **Manage fleet** as aircraft degrade over time
7. **Use loans** to accelerate expansion with leverage when needed

## Game Mechanics

### Demand Calculation
Passenger demand is based on:
- Airport size (1-12 scale, larger = more passengers)
- Population of the city
- Route quality (service quality + aircraft condition)
- Distance penalties for very long routes

### Revenue & Costs
**Revenue**:
- Economy class: Base price
- Business class: 2.5x base price
- First class: 5x base price

**Costs per route**:
- Fuel: Based on flight duration and frequency
- Crew: $2,000 per flight
- Maintenance: $500 per flight hour
- Airport fees: $5,000 landing fee + $10 per passenger

### Reputation System
- Profitable weeks: +0.5 reputation
- Unprofitable weeks: -0.2 reputation
- Reputation determines airline grade (New → Emerging → Established → Professional → Elite → Legendary → Mythic)
- Higher grades get better interest rates on loans (8% for New, down to 2% for Mythic)

### Loan System
**Dynamic Credit System**:
- Credit limit based on: Weekly revenue × 10 × (1 + Reputation/100)
- Interest rates determined by airline grade
- Weekly payments automatically deducted from balance
- Loans paid off automatically when remaining balance reaches zero
- Can take multiple loans simultaneously (within credit limit)

**Interest Rates by Grade**:
- New: 8.0%
- Emerging: 7.0%
- Established: 6.0%
- Professional: 5.0%
- Elite: 4.0%
- Legendary: 3.0%
- Mythic: 2.0%

### AI Competition System
**Competitor Airlines**:
- 4 AI-controlled airlines: Global Wings, Pacific Air, Euro Express, TransContinental
- Each starts with same $100M capital as the player
- Three distinct strategies:
  - **Aggressive**: Fast expansion, low prices (15% cheaper), high risk tolerance
  - **Conservative**: Slow growth, premium prices (+15%), low debt usage
  - **Balanced**: Moderate expansion and pricing strategy

**AI Decision-Making**:
- AI makes decisions every 2-4 weeks based on their personality
- Purchases aircraft when needed (cheapest, most expensive, or mid-range based on personality)
- Creates routes on profitable airport pairs, avoiding over-competition
- Takes loans to finance expansion (frequency depends on personality)
- Adjusts prices dynamically based on route load factors
- Handles financial crisis situations with emergency measures

**Market Competition**:
- Multiple airlines can operate the same route (e.g., JFK-LAX)
- Market share calculated based on:
  - **Price competitiveness**: Lower prices attract more passengers
  - **Service quality**: Better service increases market share
  - **Airline reputation**: Higher reputation airlines get more passengers
  - **Flight frequency**: More flights = more convenient for passengers
- Total demand split proportionally between competing airlines
- Watch competitors in the "Competitor Airlines" panel to track their growth

**Strategic Gameplay**:
- First-mover advantage on underserved routes
- Can compete on price OR quality
- Monitor competitors to identify market opportunities
- Adjust pricing to compete or dominate routes

## Code Structure

```
godot-prototype/
├── project.godot              # Main Godot project file
├── icon.svg                   # Project icon
├── scenes/
│   └── Main.tscn             # Main game scene
└── scripts/
    ├── GameData.gd           # Global singleton with game data
    ├── Airport.gd            # Airport data model
    ├── Airline.gd            # Airline data model with loan management
    ├── Route.gd              # Route/link data model
    ├── Aircraft.gd           # Aircraft model classes
    ├── AircraftInstance.gd   # Individual aircraft instances
    ├── Loan.gd               # Loan data model with amortization
    ├── AIController.gd       # AI decision-making for competitor airlines
    ├── SimulationEngine.gd   # Weekly simulation logic with competition
    ├── WorldMap.gd           # Map visualization and interaction
    └── GameUI.gd             # Main UI controller
```

## Future Enhancement Ideas

This prototype includes the basic mechanics. Potential additions:
- Base/hub management
- Alliance system
- More detailed financial reports
- Aircraft leasing options
- Airport slots and competition
- Real-world map textures
- More detailed aircraft specifications
- Maintenance scheduling
- Dynamic events (Olympics, disasters, etc.)
- Multiplayer/competitive AI airlines

## Technical Details

- **Engine**: Godot 4.3 (GDScript)
- **Rendering**: OpenGL Compatibility mode for maximum compatibility
- **Resolution**: 1280x720 (canvas scaling enabled)
- **Architecture**: Singleton pattern for global game data, modular scene structure

## Credits

Based on the open-source [Airline Club](https://github.com/patsonluk/airline) project originally written in Scala/Play Framework.

## License

This prototype is for educational and demonstration purposes. Original game source code license applies.
