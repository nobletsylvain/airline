# Godot Developer Reference

## Project Structure

```
godot-prototype/
├── project.godot          # Project config, autoloads
├── data/                   # JSON data files
│   ├── prototype-airports.json
│   └── prototype-aircraft.json
├── scenes/
│   ├── Main.tscn          # Game scene
│   └── MainMenu.tscn      # Menu scene
├── scripts/
│   ├── audio/             # Sound system
│   ├── utils/             # Utility classes
│   └── *.gd               # Core scripts
├── shaders/               # Visual effects
└── assets/                # Images, icons
```

## Key Autoloads

| Name | Script | Purpose |
|------|--------|---------|
| DataLoader | `scripts/DataLoader.gd` | Load JSON data |
| GameData | `scripts/GameData.gd` | Game state singleton |
| UISoundManager | `scripts/audio/UISoundManager.gd` | UI audio feedback |

## Core Resource Classes

### Airport
```gdscript
class_name Airport
extends Resource

var iata_code: String
var airport_name: String
var city: String
var country: String
var latitude: float
var longitude: float
var population: int
var position_2d: Vector2  # Map pixel position
```

### AircraftModel
```gdscript
class_name AircraftModel
extends Resource

var manufacturer: String
var model_name: String
var seats_economy: int
var range_km: float
var speed_kmh: float
var price: float
var daily_operating_cost: float
```

### AircraftInstance
```gdscript
class_name AircraftInstance
extends Resource

var id: int
var model: AircraftModel
var registration: String
var condition: float
var assigned_route_id: int
```

### Route
```gdscript
class_name Route
extends Resource

var id: int
var from_airport: Airport
var to_airport: Airport
var frequency: int  # Flights per week
var price_economy: float
var aircraft_assignments: Array[AircraftInstance]

# Simulation results
var passengers_transported: int
var local_passengers: int
var connecting_passengers: int
var revenue_generated: float
var weekly_profit: float
```

### Airline
```gdscript
class_name Airline
extends Resource

var id: int
var name: String
var balance: float
var aircraft: Array[AircraftInstance]
var routes: Array[Route]
var hubs: Array[Airport]
var weekly_revenue: float
var weekly_expenses: float
```

## Common UI Patterns

### Creating a Card Panel
```gdscript
func _create_card(title: String, parent: Control) -> VBoxContainer:
    var card = PanelContainer.new()
    card.add_theme_stylebox_override("panel", UITheme.create_card_panel_style())
    parent.add_child(card)
    
    var vbox = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 8)
    card.add_child(vbox)
    
    var title_label = Label.new()
    title_label.text = title
    title_label.add_theme_font_size_override("font_size", 16)
    title_label.add_theme_color_override("font_color", UITheme.TEXT_WHITE)
    vbox.add_child(title_label)
    
    return vbox
```

### Creating Buttons
```gdscript
var btn = Button.new()
btn.text = "Click Me"
btn.add_theme_stylebox_override("normal", UITheme.create_primary_button_style())
btn.pressed.connect(_on_button_pressed)
parent.add_child(btn)
```

### Scroll Container Setup
```gdscript
var scroll = ScrollContainer.new()
scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
parent.add_child(scroll)

var content = VBoxContainer.new()
content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
scroll.add_child(content)
```

## Market Analysis

### Demand Calculation
```gdscript
var distance = MarketAnalysis.calculate_great_circle_distance(from_airport, to_airport)
var demand = MarketAnalysis.calculate_potential_demand(from_airport, to_airport, distance)
```

### Price Elasticity
```gdscript
var baseline_price = distance * SimulationEngine.BASELINE_PRICE_PER_KM
var elasticity = pow(baseline_price / actual_price, SimulationEngine.ELASTICITY_FACTOR)
var adjusted_demand = base_demand * elasticity
```

## Geodesic Utilities

```gdscript
# Get arc points for a route
var points = GeodesicUtils.calculate_geodesic_points(
    from_airport.latitude, from_airport.longitude,
    to_airport.latitude, to_airport.longitude
)

# Points are Vector2(longitude, latitude) in degrees
for point in points:
    var pixel_pos = world_map.lat_lon_to_pixel(point.y, point.x)
```

## Sound System

```gdscript
# Play sounds
UISoundManager.play_click()
UISoundManager.play_purchase()
UISoundManager.play_navigate()
UISoundManager.play_error()
UISoundManager.play_success()
UISoundManager.play_alert()
UISoundManager.play_money_tally(amount)
```

## Common Errors and Fixes

### "Invalid access to property or key"
The property doesn't exist on the resource. Check the actual property name in the Resource class definition.

### "Nonexistent function"
The function doesn't exist on the object. Verify the method exists in the class or its base classes.

### "Out of bounds get index"
Array access with invalid index. Check array size before accessing.

### Dialog Properties (Godot 4)
- Use `ok_button_text` not `cancel_button_text` on AcceptDialog
- Use `ConfirmationDialog` for cancel buttons
- Access buttons: `get_ok_button()`, but AcceptDialog doesn't have `get_cancel_button()`
