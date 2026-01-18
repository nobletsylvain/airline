# Airline Tycoon Game - Godot Prototype

A Godot 4.x prototype of an airline tycoon game based on the [Airline Club](https://www.airline-club.com/) open-source project.

## Overview

This prototype simulates the core mechanics of running an airline, including:
- **Route Management**: Create flight routes between major airports worldwide
- **Financial Simulation**: Track revenue, expenses, and profitability
- **Aircraft Fleet**: View available aircraft models with different capacities and ranges
- **Weekly Simulation**: Automated weekly cycles that simulate passenger demand and calculate finances
- **World Map**: Visual representation of airports and routes on a simplified world map

## Features Implemented

### Core Game Systems
- **15 Major Airports**: JFK, LAX, LHR, NRT, SYD, DXB, CDG, FRA, SIN, ORD, ATL, HND, PEK, ICN, MIA
- **8 Aircraft Models**: Boeing 737, Airbus A320, Boeing 787, Airbus A350, and more
- **Passenger Classes**: Economy, Business, and First Class
- **Dynamic Pricing**: Distance-based pricing with class multipliers
- **Quality System**: Service quality and aircraft condition affect demand
- **Financial Tracking**: Weekly revenue, expenses, and profit calculations

### Simulation Engine
The simulation runs weekly cycles (configurable speed) that calculate:
- Passenger demand based on airport size and population
- Revenue from ticket sales (economy, business, first class)
- Operating costs (fuel, crew, maintenance, airport fees)
- Aircraft degradation over time
- Airline reputation changes

### Visual Interface
- **World Map**: Click airports to select, click two airports to create a route
- **Top Panel**: Displays airline name, grade, reputation, week number, and balance
- **Route List**: Shows all active routes with passenger count and profit
- **Aircraft Panel**: Browse available aircraft models for purchase
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

### Creating Routes
1. Click on an airport to select it (it will highlight in white)
2. Click on another airport to create a route between them
3. The route will appear as a line on the map:
   - **Green line**: Profitable route
   - **Red line**: Unprofitable route

### Running the Simulation
- **Play Button**: Start/pause automatic weekly simulation (5 seconds per week)
- **Step Week Button**: Manually advance one week at a time

### Understanding the UI
- **Top Panel**: Shows your airline info, current week, and balance
- **Routes Panel**: Lists all your routes with performance metrics
- **Airport Info**: Shows details about selected airports or routes
- **Aircraft Panel**: Displays available aircraft (purchase feature not yet implemented)

### Default Setup
- Starting airline: "SkyLine Airways"
- Starting balance: $5,000,000
- Starting reputation: 0 (Grade: New)
- No routes created initially - you create them!

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
- Reputation determines airline grade (19 grades from "New" to "Mythic")

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
    ├── Airline.gd            # Airline data model
    ├── Route.gd              # Route/link data model
    ├── Aircraft.gd           # Aircraft model and instance classes
    ├── SimulationEngine.gd   # Weekly simulation logic
    ├── WorldMap.gd           # Map visualization and interaction
    └── GameUI.gd             # Main UI controller
```

## Future Enhancement Ideas

This prototype includes the basic mechanics. Potential additions:
- Aircraft purchasing system
- Base/hub management
- Alliance system
- Loan system
- More detailed financial reports
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
