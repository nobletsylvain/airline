# First-Time User Experience (FTUE) Guide

## Overview

The **Airline Tycoon FTUE** system provides a comprehensive 26-step tutorial that guides new players through all core mechanics, followed by a progression-based objective system to encourage continued play.

---

## Tutorial System Architecture

### Components

1. **TutorialStep.gd** - Resource class representing individual tutorial steps
2. **TutorialManager.gd** - Orchestrates the tutorial flow
3. **ObjectiveSystem.gd** - Tracks player goals and provides rewards
4. **GameData integration** - Hooks game events to tutorial progression
5. **GameUI helpers** - Console commands for tutorial control

### Tutorial Flow

```
Welcome → UI Overview → Market Analysis → Aircraft Purchase →
Route Creation → Simulation → Results Analysis → Competition →
Financial Management → Strategies → Completion + Reward
```

---

## Tutorial Steps (26 Total)

### Phase 1: Introduction (Steps 1-5)
**Goal**: Orient player to game concept and UI

1. **Welcome** - Game introduction
2. **Airline Intro** - Explain airline customization and branding
3. **UI Overview** - Highlight top panel (balance, week, info)
4. **Map Intro** - Explain world map navigation
5. **Tabs Intro** - Introduce management tabs (Routes/Fleet/Finances/Market)

### Phase 2: Market Intelligence (Steps 6-7)
**Goal**: Teach demand analysis

6. **Market Analysis Intro** - Explain route profitability
7. **Demand Factors** - Detail demand calculation:
   - Population (bigger cities = more passengers)
   - Income levels (wealth = more flights)
   - Distance (500-1500km sweet spot)
   - Competition (fewer airlines = better)

### Phase 3: Fleet Management (Steps 8-12)
**Goal**: Guide first aircraft purchase

8. **Aircraft Intro** - Explain aircraft role and variety
9. **Fleet Tab Highlight** - Show where to buy aircraft
10. **Aircraft Config Intro** - Explain seat customization:
    - All Economy = max capacity, lower revenue/seat
    - Mixed = balanced approach
    - Premium = fewer seats, higher revenue
11. **Wait for Purchase** (ACTION) - Player must buy an aircraft
12. **Aircraft Purchased** - Congratulate and transition

### Phase 4: Route Operations (Steps 13-16)
**Goal**: Create first profitable route

13. **Route Intro** - Explain route requirements:
    - Sufficient demand
    - Low competition
    - Proper pricing
    - Aircraft range
14. **Route Opportunities** - Show how to find profitable routes
15. **Wait for Route Creation** (ACTION) - Player creates route
16. **Route Created** - Confirm and transition to simulation

### Phase 5: Simulation & Analysis (Steps 17-21)
**Goal**: Understand weekly simulation and results

17. **Simulation Intro** - Explain simulation mechanics:
    - Passenger choice (price/quality/reputation)
    - Revenue from ticket sales
    - Costs (fuel/crew/maintenance/fees)
    - Aircraft degradation
    - Auto loan payments
18. **Play Button Highlight** - Show simulation controls
19. **Wait for Simulation** (ACTION) - Player runs first week
20. **Results Analysis** - Explain how to read results
21. **Optimization Intro** - Teach route improvement:
    - Adjust pricing for load factor
    - Increase frequency if full
    - Add aircraft for capacity
    - Monitor competition

### Phase 6: Advanced Concepts (Steps 22-25)
**Goal**: Introduce competition and strategy

22. **Competition Intro** - Explain AI airlines:
    - Global Wings (Aggressive)
    - Pacific Air (Balanced)
    - Euro Express (Conservative)
    - TransContinental (Balanced)
23. **Market Tab Intro** - Show competitor intelligence tools
24. **Finances Intro** - Explain loan system:
    - Credit limits based on performance
    - Interest rates (8% New → 2% Mythic)
    - Weekly payments
25. **Growth Strategies** - Present strategic options:
    - Budget Airline
    - Premium Carrier
    - Market Gap
    - Competitive

### Phase 7: Completion (Step 26)
**Goal**: Reward player and transition to free play

26. **Tutorial Complete + Reward** - Give **$50M bonus** and congratulate

---

## Step Types

### MESSAGE
Simple informational message, auto-advances when player continues.

```gdscript
TutorialStep.StepType.MESSAGE
```

### HIGHLIGHT_UI
Highlights a specific UI element with a message.

```gdscript
step.step_type = TutorialStep.StepType.HIGHLIGHT_UI
step.ui_element_path = "MarginContainer/VBoxContainer/TopPanel"
step.highlight_message = "This is your dashboard"
```

### WAIT_FOR_ACTION
Blocks progression until player performs required action.

```gdscript
step.step_type = TutorialStep.StepType.WAIT_FOR_ACTION
step.required_action = "purchase_aircraft"  # or "create_route", "run_simulation"
step.action_hint = "Click an aircraft and purchase it"
```

Triggers:
- `purchase_aircraft` - Fired when player buys aircraft
- `create_route` - Fired when player creates route
- `run_simulation` - Fired after week simulation

### REWARD
Automatically applies rewards and advances.

```gdscript
step.step_type = TutorialStep.StepType.REWARD
step.reward_money = 50000000.0  # $50M
```

---

## Objective System

After tutorial completion, players receive **7 progressive objectives** with monetary rewards.

### Objectives List

| ID | Title | Description | Target | Reward |
|----|-------|-------------|--------|--------|
| first_aircraft | Fleet Builder | Purchase first aircraft | 1 | $5M |
| first_route | Route Pioneer | Create first route | 1 | $5M |
| transport_1000_pax | People Mover | Transport 1,000 passengers | 1,000 | $10M |
| earn_10m_profit | Profitable Operation | Earn $10M cumulative profit | $10M | $20M |
| own_5_aircraft | Fleet Expansion | Own 5 aircraft | 5 | $25M |
| operate_10_routes | Network Builder | Operate 10 routes | 10 | $30M |
| reach_reputation_100 | Respected Carrier | Reach reputation 100 | 100 | $50M |

**Total Possible Rewards**: $145M

### Automatic Progress Tracking

Objectives update automatically:
- **After aircraft purchase** - Updates fleet objectives
- **After route creation** - Updates route objectives
- **After weekly simulation** - Updates passengers, profit, reputation

---

## Console Commands

### Tutorial Control

```gdscript
# Start tutorial
tutorial_start()

# Advance to next step
tutorial_next()
# or
continue_tutorial()

# Skip tutorial entirely
skip_tutorial()

# View current step
show_current_tutorial_step()

# Show all commands
help_tutorial()
```

### Objective Tracking

```gdscript
# View all objectives
show_objectives()

# Update and view progress
check_objective_progress()
```

### Quick Actions (During Tutorial)

```gdscript
# Find profitable routes from airport
var jfk = GameData.get_airport_by_iata("JFK")
show_route_opportunities(jfk)

# Analyze existing route
var my_route = GameData.player_airline.routes[0]
analyze_existing_route(my_route)
```

---

## Integration Points

### GameData Hooks

**Aircraft Purchase**:
```gdscript
func purchase_aircraft(...):
    # ... purchase logic ...
    if airline == player_airline and tutorial_manager:
        tutorial_manager.on_action_performed("purchase_aircraft")
    if airline == player_airline and objective_system:
        objective_system.check_objectives_from_game_state()
```

**Route Creation**:
```gdscript
func create_route_for_airline(...):
    # ... route creation ...
    if airline == player_airline and tutorial_manager:
        tutorial_manager.on_action_performed("create_route")
    if airline == player_airline and objective_system:
        objective_system.check_objectives_from_game_state()
```

**Week Simulation** (in SimulationEngine):
```gdscript
func simulate_week():
    # ... simulation logic ...
    if GameData.objective_system:
        GameData.objective_system.check_objectives_from_game_state()
    if GameData.tutorial_manager:
        GameData.tutorial_manager.on_action_performed("run_simulation")
```

---

## Customization Guide

### Adding New Tutorial Steps

```gdscript
# In TutorialManager.create_tutorial_sequence()
var new_step = TutorialStep.new(
    "step_id",
    "Step Title",
    "Step message text explaining the concept",
    TutorialStep.StepType.MESSAGE
)
tutorial_steps.append(new_step)
```

### Adding New Objectives

```gdscript
# In ObjectiveSystem.create_beginner_objectives()
var new_objective = Objective.new(
    "objective_id",
    "Objective Title",
    "Description of what to accomplish",
    target_value,  # numeric target
    reward_money   # $ reward on completion
)
active_objectives.append(new_objective)
```

### Custom Action Triggers

1. **Define action name** in tutorial step:
```gdscript
step.required_action = "my_custom_action"
```

2. **Trigger in game code**:
```gdscript
if GameData.tutorial_manager:
    GameData.tutorial_manager.on_action_performed("my_custom_action")
```

---

## UI Integration (Future)

### Visual Tutorial Overlays

**To add visual highlights** (currently console-based):

1. Connect to signals in GameUI:
```gdscript
GameData.tutorial_manager.highlight_ui_element.connect(_on_highlight_ui)
GameData.tutorial_manager.clear_ui_highlights.connect(_on_clear_highlights)
```

2. Implement highlight functions:
```gdscript
func _on_highlight_ui(node_path: String, message: String):
    var node = get_node(node_path)
    # Add visual highlight (border, glow, arrow, etc.)
    # Show tooltip with message

func _on_clear_highlights():
    # Remove all visual highlights
```

### Tutorial Dialog Box

Create a modal dialog that:
- Shows current step title and message
- Displays "Continue" button (except for action steps)
- Shows "Skip Tutorial" option
- Tracks step progress (e.g., "Step 5/26")

### Objective HUD Widget

Display active objectives in a corner widget:
- Show 1-3 nearest incomplete objectives
- Progress bars
- Checkmarks for completed objectives
- Reward amounts

---

## Testing the Tutorial

### Full Playthrough Test

```gdscript
# Start fresh game
tutorial_start()

# Follow tutorial to completion:
# 1. Read each step
# 2. Purchase aircraft when prompted
# 3. Create route when prompted
# 4. Run simulation when prompted
# 5. Complete all 26 steps

# Verify $50M reward received
```

### Skip Test

```gdscript
tutorial_start()
skip_tutorial()
# Verify tutorial stopped
# Verify no reward given
```

### Objective Progression Test

```gdscript
# Complete tutorial
tutorial_start()
# ... complete all steps ...

# Check objectives initialized
show_objectives()

# Perform actions and verify updates
# - Buy aircraft → check first_aircraft, own_5_aircraft
# - Create route → check first_route, operate_10_routes
# - Run simulation → check transport_1000_pax, earn_10m_profit, reputation
```

---

## Design Philosophy

### Progressive Complexity

- **Early steps**: Simple, hand-holding
- **Middle steps**: Introduce complexity
- **Late steps**: Strategic concepts and freedom

### Learning by Doing

- **3 action steps** require player interaction:
  1. Purchase aircraft
  2. Create route
  3. Run simulation
- Reinforces muscle memory and UI familiarity

### Reward Motivation

- **$50M tutorial completion bonus** - 50% of starting capital
- **$145M objective rewards** - Encourages continued engagement
- **Monetary rewards** - Directly enable game progression (buy more aircraft/routes)

### Respect Player Time

- **Skippable** - Experienced players can skip
- **Clear progress** - "Step X/26" tracking
- **Concise messages** - No walls of text
- **Auto-advance** - Message steps don't require action

---

## Future Enhancements

### Interactive Tutorials

- **Guided route creation**: Click-through with arrows pointing to UI elements
- **Simulated first route**: Pre-configured route that guarantees profit
- **Undo/redo**: Let players experiment without consequences

### Contextual Help

- **Tooltips**: Hover over UI elements for explanations
- **Help button**: Access tutorial steps on-demand
- **Video clips**: Short animated explanations

### Advanced Tutorials

After completing basic tutorial:
- **Loan management tutorial**
- **Competition strategies tutorial**
- **Hub development tutorial**
- **Long-haul vs short-haul tutorial**

### Analytics

Track tutorial completion rates:
- Which steps have highest drop-off?
- Average time per step
- Skip rate
- Objective completion rates

---

## Summary

The FTUE system provides a **26-step comprehensive tutorial** with:
- ✅ Gradual introduction to all game systems
- ✅ 3 interactive action steps for engagement
- ✅ $50M completion reward
- ✅ 7 progressive objectives worth $145M
- ✅ Skip option for experienced players
- ✅ Console commands for testing
- ✅ Automatic progress tracking

New players go from **zero knowledge** to **ready to compete** in a structured, rewarding learning experience!
