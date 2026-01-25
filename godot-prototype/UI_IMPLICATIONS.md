# UI/UX Implications for New Features

**Analysis Date:** January 2026  
**Purpose:** Identify all panels, dialogs, and scenes that need to be added or modified for implementing features from Airline Club

---

## 📋 Current UI Structure

### Main Components
- **`GameUI.gd`** - Main controller, manages all panels and dialogs
- **`DashboardUI.gd`** - Dashboard layout (header, sidebar, main content, bottom bar)
- **`WorldMap.gd`** - Interactive world map visualization
- **`Sidebar.gd`** - Navigation sidebar with tabs

### Existing Panels
- **`FleetManagementPanel.gd`** - Fleet management tab
- **Routes Panel** - Route list (created in GameUI)
- **Finances Panel** - Financial dashboard (created in GameUI)
- **Market Panel** - Market analysis (created in GameUI)

### Existing Dialogs
- **`RouteConfigDialog.gd`** - Configure route (aircraft, frequency, pricing)
- **`RouteOpportunityDialog.gd`** - Browse route opportunities from hub
- **`HubPurchaseDialog.gd`** - Purchase hub airports
- **`AircraftPurchaseDialog.gd`** - Purchase aircraft

### Existing Cards/Components
- **`FleetCard.gd`** - Individual aircraft card
- **`RouteCard.gd`** - Individual route card

---

## 🎯 Feature-by-Feature UI Requirements

---

## 1. DELEGATES SYSTEM ⭐⭐⭐

### New Panels Required

#### **`DelegatesPanel.gd`** (NEW)
**Location:** New sidebar tab "Delegates"
**Purpose:** Main delegates management interface

**UI Elements:**
- **Header Section:**
  - Total delegates count (e.g., "5/5 Available")
  - Delegates per grade indicator
  - Base delegates + bonus delegates breakdown
  
- **Active Tasks List:**
  - List of busy delegates with:
    - Task type (Country, Negotiation, Campaign)
    - Target (country name, route, campaign location)
    - Progress/level indicator
    - Time remaining/completion date
    - Cancel button (with cooldown warning)
  
- **Available Delegates Section:**
  - "Assign Delegate" button
  - Empty slots indicator

- **Task Assignment Dialog (embedded or separate):**
  - Task type selector (Country/Negotiation/Campaign)
  - Target selection (country dropdown, route selector, campaign selector)
  - Duration/cooldown display
  - Confirm button

**Integration:**
- Add "Delegates" button to `Sidebar.gd` navigation
- Add delegates panel to `GameUI.gd` content panels
- Connect to `DashboardUI.gd` tab system

---

#### **`DelegateAssignmentDialog.gd`** (NEW)
**Type:** ConfirmationDialog
**Purpose:** Assign delegate to a task

**UI Elements:**
- Task type tabs/selector:
  - Country Relationship
  - Link Negotiation
  - Campaign
- Target selection:
  - Country: Dropdown of all countries
  - Route: Airport pair selector
  - Campaign: Campaign location selector
- Task details:
  - Current relationship level (for country)
  - Expected difficulty
  - Duration/cooldown
  - Benefits preview
- Confirm/Cancel buttons

**Integration:**
- Called from `DelegatesPanel.gd`
- Also accessible from route creation flow (for negotiation)

---

### Modified Panels

#### **`RouteConfigDialog.gd`** (MODIFY)
**Changes:**
- Add "Negotiation" section before route creation
- Show route difficulty score
- Show available negotiation discounts
- "Use Delegate for Negotiation" checkbox/button
- Display negotiation cost reduction if delegate assigned
- Show delegate cooldown if recently used

**New Fields:**
```gdscript
var negotiation_section: VBoxContainer
var difficulty_label: Label
var delegate_negotiation_button: Button
var negotiation_cost_label: Label
```

---

#### **`RouteOpportunityDialog.gd`** (MODIFY)
**Changes:**
- Add difficulty indicator to each opportunity
- Show if delegate negotiation available
- Display relationship bonuses
- Color-code by difficulty (green/yellow/red)

**New Fields:**
```gdscript
var difficulty_column: ColumnContainer  # New column in opportunity list
```

---

#### **`WorldMap.gd`** (MODIFY)
**Changes:**
- Show country relationship indicators on airports
- Tooltip shows relationship level when hovering
- Visual indicator (colored border?) for countries with active delegates

---

#### **`DashboardUI.gd`** (MODIFY)
**Changes:**
- Add "Delegates" tab to sidebar navigation
- Add delegates count to header (optional, or keep in delegates panel only)

---

### New Data Display Components

#### **`DelegateTaskCard.gd`** (NEW)
**Type:** PanelContainer (similar to FleetCard/RouteCard)
**Purpose:** Display individual delegate task

**UI Elements:**
- Task icon (country flag, route icon, campaign icon)
- Task name/description
- Progress bar or level indicator
- Time remaining
- Cancel button

---

### Scenes to Create
- `scenes/DelegatesPanel.tscn` (optional, if using scene-based approach)
- `scenes/DelegateAssignmentDialog.tscn` (optional)

---

## 2. LINK DIFFICULTY & NEGOTIATION ⭐⭐⭐

### New Panels Required

#### **`RouteDifficultyPanel.gd`** (NEW)
**Type:** Embedded panel in RouteConfigDialog
**Purpose:** Show route creation difficulty breakdown

**UI Elements:**
- Difficulty score (0-100) with color coding
- Difficulty factors breakdown:
  - Country relationship: +X/-X
  - Market share: +X
  - Airport features: +X/-X
  - Delegate negotiation: -X (discount)
- Base creation cost
- Final creation cost (after discounts)
- "Cannot Create Route" warning if difficulty too high

**Integration:**
- Embedded in `RouteConfigDialog.gd`
- Also shown in `RouteOpportunityDialog.gd` for each opportunity

---

### Modified Panels

#### **`RouteConfigDialog.gd`** (MODIFY - Major)
**Changes:**
- Add difficulty panel at top (before aircraft selection)
- Show creation cost prominently
- Disable "Create Route" button if:
  - Difficulty too high
  - Insufficient funds
  - No delegate available (if negotiation required)
- Add "Negotiate with Delegate" button
- Show negotiation discount preview

**New Sections:**
```gdscript
var difficulty_panel: RouteDifficultyPanel
var negotiation_section: VBoxContainer
var creation_cost_label: Label
var delegate_negotiate_button: Button
```

---

#### **`RouteOpportunityDialog.gd`** (MODIFY)
**Changes:**
- Add difficulty column to opportunity list
- Sort by difficulty (easiest first) as option
- Filter by difficulty range
- Show relationship status for each route
- Color-code rows by difficulty

**New UI Elements:**
```gdscript
var difficulty_filter: OptionButton  # Easy/Medium/Hard/All
var difficulty_column_header: Label
var sort_by_difficulty_button: Button
```

---

#### **`WorldMap.gd`** (MODIFY)
**Changes:**
- Show route difficulty when hovering over potential routes
- Visual indicator for blocked routes (red X?)
- Show country relationship on airport tooltips
- Highlight routes that are easy to create (green glow?)

---

### New Components

#### **`DifficultyIndicator.gd`** (NEW)
**Type:** Control (reusable component)
**Purpose:** Visual difficulty indicator (bar + number)

**UI Elements:**
- ProgressBar styled as difficulty meter
- Label with difficulty score
- Color coding (green/yellow/red)

---

## 3. LOUNGES SYSTEM ⭐⭐

### New Panels Required

#### **`LoungesPanel.gd`** (NEW)
**Location:** New sidebar tab "Lounges" or sub-tab under "Hubs"
**Purpose:** Manage airport lounges

**UI Elements:**
- **Header:**
  - Total lounges count
  - Total upkeep cost
  - Total revenue (last week)
  
- **Lounges List:**
  - List of all lounges with:
    - Airport name
    - Lounge level (1-3)
    - Status (Active/Inactive)
    - Upkeep cost
    - Revenue
    - Visitor count
    - "Manage" button
  
- **Create Lounge Section:**
  - "Build New Lounge" button
  - Filter by hub airports only
  - Show scale requirement (must be scale 3+)

**Integration:**
- Add to sidebar (or as sub-tab under Hubs)
- Connect to `GameUI.gd`

---

#### **`LoungeManagementDialog.gd`** (NEW)
**Type:** ConfirmationDialog
**Purpose:** Create or manage individual lounge

**UI Elements:**
- Airport selector (filtered to hubs with scale 3+)
- Lounge level selector (1-3)
- Lounge name input
- Cost display (based on level)
- Upkeep cost preview
- Benefits preview:
  - Price reduction factor
  - Revenue potential
  - Alliance sharing option
- Create/Upgrade/Close buttons

**Integration:**
- Called from `LoungesPanel.gd`
- Also accessible from hub management (if hubs panel exists)

---

#### **`LoungeCard.gd`** (NEW)
**Type:** PanelContainer
**Purpose:** Display individual lounge in list

**UI Elements:**
- Airport name and IATA code
- Lounge level indicator (stars or level number)
- Status badge (Active/Inactive)
- Financial summary:
  - Upkeep: $X/week
  - Revenue: $X/week
  - Profit: $X/week
- Visitor count
- "Manage" button

---

### Modified Panels

#### **`RouteConfigDialog.gd`** (MODIFY)
**Changes:**
- Show lounge benefits if route has lounge at either airport
- Display price reduction factor
- Show lounge visitor revenue potential

**New Fields:**
```gdscript
var lounge_benefits_section: VBoxContainer
var lounge_price_reduction_label: Label
```

---

#### **`HubPurchaseDialog.gd`** (MODIFY)
**Changes:**
- Show lounge eligibility (scale 3+ requirement)
- Display existing lounges at airport
- "View Lounges" button if scale 3+

---

#### **`WorldMap.gd`** (MODIFY)
**Changes:**
- Show lounge icon on airports with lounges
- Tooltip shows lounge level and status
- Visual indicator for lounge-eligible airports

---

### New Scenes
- `scenes/LoungesPanel.tscn` (optional)
- `scenes/LoungeManagementDialog.tscn` (optional)

---

## 4. COUNTRY RELATIONSHIPS ⭐⭐

### New Panels Required

#### **`CountryRelationsPanel.gd`** (NEW)
**Location:** New sidebar tab "Diplomacy" or sub-tab
**Purpose:** View and manage country relationships

**UI Elements:**
- **Home Country Display:**
  - Current home country
  - "Change Home Country" button (if allowed)
  
- **Relationships List:**
  - All countries with:
    - Country flag/icon
    - Country name
    - Relationship level (bar + number)
    - Relationship factors breakdown:
      - Home country relationship: +X
      - Market share: +X
      - Delegate level: +X
      - Titles: +X
    - "View Details" button
  
- **Filters:**
  - Sort by relationship level
  - Filter by region
  - Search by country name

**Integration:**
- Add to sidebar
- Connect to `GameUI.gd`

---

#### **`CountryRelationshipDialog.gd`** (NEW)
**Type:** AcceptDialog or Window
**Purpose:** Detailed view of country relationship

**UI Elements:**
- Country name and flag
- Overall relationship score
- Relationship factors breakdown:
  - Home country relationship: "Friendly" (+15)
  - Market share: "5.2%" (+20)
  - Delegate level: "Level 3" (+6)
  - Titles: "None" (0)
- Effects on route creation:
  - Difficulty modifier
  - Example routes affected
- "Assign Delegate" button (if delegates system exists)

---

### Modified Panels

#### **`WorldMap.gd`** (MODIFY)
**Changes:**
- Color-code countries by relationship level
- Tooltip shows relationship when hovering over airports
- Visual indicator for countries with poor relationships (red border?)

---

#### **`RouteConfigDialog.gd`** (MODIFY)
**Changes:**
- Show country relationship for both airports
- Display relationship impact on difficulty
- Warning if relationship too poor

---

#### **`RouteOpportunityDialog.gd`** (MODIFY)
**Changes:**
- Show relationship indicator for each route
- Filter by relationship level
- Sort by relationship (best first)

---

### New Components

#### **`RelationshipIndicator.gd`** (NEW)
**Type:** Control (reusable)
**Purpose:** Visual relationship indicator

**UI Elements:**
- ProgressBar (negative to positive)
- Label with relationship score
- Color coding (red = hostile, green = friendly)

---

## 5. AIRPORT ASSETS (SIMPLIFIED) ⭐⭐

### New Panels Required

#### **`AirportAssetsPanel.gd`** (NEW)
**Location:** New sidebar tab "Assets" or accessible from airport/hub view
**Purpose:** Manage airport assets

**UI Elements:**
- **Airport Selector:**
  - Dropdown of airports where player has hubs/assets
  
- **Assets List:**
  - List of assets at selected airport:
    - Asset name and type
    - Level
    - Status (Blueprint/Under Construction/Completed)
    - Construction progress (if under construction)
    - Revenue/Expense
    - ROI
    - "Manage" button
  
- **Build New Asset Section:**
  - Asset type selector (Hotel, Convention Center, etc.)
  - Cost display
  - Requirements check (airport size, etc.)
  - "Build" button

**Integration:**
- Add to sidebar or as sub-panel
- Connect to `GameUI.gd`

---

#### **`AssetManagementDialog.gd`** (NEW)
**Type:** ConfirmationDialog
**Purpose:** Build or manage asset

**UI Elements:**
- Airport selector
- Asset type selector (with icons)
- Asset name input
- Level selector (if upgrading)
- Cost breakdown:
  - Base cost
  - Construction duration
  - Upkeep cost
- Benefits preview:
  - Population boost
  - Income boost
  - Tourism boost
  - Revenue potential
- Build/Upgrade/Sell buttons

---

#### **`AssetCard.gd`** (NEW)
**Type:** PanelContainer
**Purpose:** Display individual asset

**UI Elements:**
- Asset icon/type
- Asset name
- Airport location
- Level indicator
- Status badge
- Financial summary
- Construction progress (if applicable)
- "Manage" button

---

### Modified Panels

#### **`HubPurchaseDialog.gd`** (MODIFY)
**Changes:**
- Show existing assets at airport
- "View Assets" button
- Asset eligibility indicators

---

#### **`WorldMap.gd`** (MODIFY)
**Changes:**
- Show asset icons on airports
- Tooltip shows asset list
- Visual indicator for asset-eligible airports

---

## 6. SERVICE QUALITY INVESTMENT ⭐

### Modified Panels

#### **`FinancesPanel.gd`** (MODIFY - in GameUI.gd)
**Changes:**
- Add "Service Quality" section
- Current service quality display (0-100)
- Target service quality selector (slider or input)
- Investment cost calculator
- "Invest in Service Quality" button
- Progress indicator (current → target)
- Weekly cost display

**New Fields:**
```gdscript
var service_quality_section: VBoxContainer
var current_quality_label: Label
var target_quality_slider: HSlider
var investment_cost_label: Label
var invest_button: Button
```

---

#### **`DashboardUI.gd`** (MODIFY)
**Changes:**
- Add service quality to header (optional, or keep in finances panel)

---

## 7. OFFICE STAFF REQUIREMENTS ⭐

### New Panels Required

#### **`StaffManagementPanel.gd`** (NEW)
**Location:** New sidebar tab "Staff" or sub-tab under "Operations"
**Purpose:** Manage office staff

**UI Elements:**
- **Staff Summary:**
  - Current staff count
  - Required staff (based on routes)
  - Overtime status
  - Total staff costs
  
- **Staff Breakdown:**
  - Staff by route (if detailed view)
  - Overtime costs
  - Hiring capacity
  
- **Hiring Section:**
  - "Hire Staff" button
  - Staff cost per unit
  - Hiring capacity limit

**Integration:**
- Add to sidebar
- Connect to `GameUI.gd`

---

### Modified Panels

#### **`RouteConfigDialog.gd`** (MODIFY)
**Changes:**
- Show staff requirement for new route
- Display if staff capacity available
- Warning if insufficient staff (overtime costs)

**New Fields:**
```gdscript
var staff_requirement_label: Label
var staff_warning_label: Label
```

---

#### **`FinancesPanel.gd`** (MODIFY)
**Changes:**
- Add staff costs to expense breakdown
- Show overtime costs separately
- Display staff utilization percentage

---

#### **`RoutesPanel.gd`** (MODIFY - in GameUI.gd)
**Changes:**
- Show staff requirement per route
- Display staff allocation

---

## 8. ALLIANCES SYSTEM ⭐⭐

### New Panels Required

#### **`AlliancesPanel.gd`** (NEW)
**Location:** New sidebar tab "Alliances"
**Purpose:** Manage alliances

**UI Elements:**
- **Current Alliance:**
  - Alliance name
  - Member count
  - Alliance ranking
  - "Leave Alliance" button (if member)
  
- **Alliance List:**
  - All available alliances
  - Member count
  - Ranking
  - "Join" / "Apply" button
  
- **Create Alliance Section:**
  - "Create Alliance" button
  - Alliance name input
  - Creation cost

**Integration:**
- Add to sidebar
- Connect to `GameUI.gd`

---

#### **`AllianceManagementDialog.gd`** (NEW)
**Type:** Window or ConfirmationDialog
**Purpose:** Detailed alliance management

**UI Elements:**
- Alliance info
- Member list
- Alliance missions
- Lounge sharing settings
- Member management (if leader)

---

## 9. OIL PRICE SIMULATION ⭐

### Modified Panels

#### **`FinancesPanel.gd`** (MODIFY)
**Changes:**
- Add "Fuel Costs" section
- Current oil price display
- Oil price chart (historical)
- Fuel cost breakdown by route
- Price trend indicator (↑/↓)

**New Fields:**
```gdscript
var fuel_costs_section: VBoxContainer
var oil_price_label: Label
var oil_price_chart: Control  # Simple line chart
var fuel_cost_breakdown: VBoxContainer
```

---

#### **`RouteConfigDialog.gd`** (MODIFY)
**Changes:**
- Show fuel cost estimate (based on current oil price)
- Display fuel cost sensitivity

---

## 10. AIRCRAFT LEASING ⭐

### Modified Panels

#### **`AircraftPurchaseDialog.gd`** (MODIFY)
**Changes:**
- Add "Purchase" vs "Lease" toggle
- Lease terms display:
  - Monthly payment
  - Lease duration
  - Total cost
  - Return policy
- Compare purchase vs lease costs

**New Fields:**
```gdscript
var purchase_lease_toggle: OptionButton
var lease_terms_section: VBoxContainer
var monthly_payment_label: Label
var lease_duration_label: Label
```

---

#### **`FleetManagementPanel.gd`** (MODIFY)
**Changes:**
- Show lease status for aircraft
- Lease expiration dates
- "Return Aircraft" button for leased aircraft
- Filter by owned vs leased

---

## 📊 SUMMARY TABLE

| Feature | New Panels | New Dialogs | Modified Panels | New Components |
|---------|-----------|-------------|----------------|----------------|
| **Delegates** | 1 | 1 | 4 | 1 |
| **Link Difficulty** | 1 | 0 | 3 | 1 |
| **Lounges** | 1 | 1 | 3 | 1 |
| **Country Relations** | 1 | 1 | 3 | 1 |
| **Airport Assets** | 1 | 1 | 2 | 1 |
| **Service Quality** | 0 | 0 | 2 | 0 |
| **Office Staff** | 1 | 0 | 3 | 0 |
| **Alliances** | 1 | 1 | 0 | 0 |
| **Oil Prices** | 0 | 0 | 2 | 0 |
| **Aircraft Leasing** | 0 | 0 | 2 | 0 |

**Total New Panels:** 7  
**Total New Dialogs:** 5  
**Total Modified Panels:** ~20 (some panels modified multiple times)  
**Total New Components:** 5

---

## 🎨 UI/UX CONSIDERATIONS

### Sidebar Navigation
**Current tabs:**
- Map
- Fleet
- Routes
- Finances
- Market

**Proposed additions:**
- Delegates (or under "Operations")
- Lounges (or under "Hubs")
- Country Relations / Diplomacy
- Assets (or under "Hubs")
- Staff (or under "Operations")
- Alliances

**Recommendation:** Use sub-tabs or collapsible sections to avoid sidebar clutter

### Dialog Hierarchy
- **Route Creation Flow:**
  1. RouteOpportunityDialog (select route)
  2. RouteDifficultyPanel (show difficulty)
  3. DelegateAssignmentDialog (optional, if negotiation needed)
  4. RouteConfigDialog (configure route)

### Visual Indicators
- **World Map:**
  - Country relationship colors
  - Lounge icons
  - Asset icons
  - Difficulty indicators
  - Delegate activity indicators

### Information Density
- Use tooltips for detailed info
- Collapsible sections in panels
- Tabbed interfaces for complex panels
- Summary views with "Details" buttons

---

## 🚀 IMPLEMENTATION PRIORITY

### Phase 1 (High Priority Features)
1. **Delegates System**
   - `DelegatesPanel.gd` (NEW)
   - `DelegateAssignmentDialog.gd` (NEW)
   - Modify `RouteConfigDialog.gd`
   - Modify `RouteOpportunityDialog.gd`

2. **Link Difficulty**
   - `RouteDifficultyPanel.gd` (NEW)
   - Modify `RouteConfigDialog.gd` (major)
   - Modify `RouteOpportunityDialog.gd`

3. **Country Relationships**
   - `CountryRelationsPanel.gd` (NEW)
   - `CountryRelationshipDialog.gd` (NEW)
   - Modify `WorldMap.gd`

### Phase 2 (Medium Priority)
4. **Lounges System**
   - `LoungesPanel.gd` (NEW)
   - `LoungeManagementDialog.gd` (NEW)
   - Modify `RouteConfigDialog.gd`

5. **Service Quality Investment**
   - Modify `FinancesPanel.gd` (in GameUI)

6. **Office Staff**
   - `StaffManagementPanel.gd` (NEW)
   - Modify `RouteConfigDialog.gd`
   - Modify `FinancesPanel.gd`

### Phase 3 (Lower Priority)
7. **Airport Assets**
8. **Alliances**
9. **Oil Prices**
10. **Aircraft Leasing**

---

## 📝 NOTES

- Many panels can share similar UI patterns (cards, lists, dialogs)
- Consider creating a base `ManagementPanel` class for consistency
- Reusable components (DifficultyIndicator, RelationshipIndicator) reduce duplication
- World Map modifications should be subtle to avoid clutter
- Sidebar navigation may need reorganization to accommodate new tabs
