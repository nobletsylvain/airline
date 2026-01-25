# Airliner - Art Bible & Style Guide

**Version:** 0.2  
**Date:** January 2026  
**Companion to:** Game Design Document v0.7

---

## Overview

This document defines the visual language, aesthetic targets, and production specifications for Airliner. It bridges the design intent from the GDD to actionable guidance for art, UI, and development teams.

**Core Directive:** The Terminal is the Controller. The Map and Scenes are the Reward.

**Aesthetic Identity:** "Glass Cockpit" — Professional, industrial, expensive. Not "retro," but "mission critical."

---

## 1. Visual Language

### 1.1 Color Palette

Three palette families define the visual hierarchy:

#### Deep Space (Backgrounds)
The foundation. Dark, professional, recessive.

| Name | Hex | Usage |
|------|-----|-------|
| Void | `#0a0e14` | Primary background |
| Charcoal | `#1a1f2e` | Panel backgrounds |
| Navy | `#162032` | Secondary surfaces |
| Slate | `#2a3244` | Elevated elements |

#### Avionics (Data & Information)
The working layer. Clear, readable, functional.

| Name | Hex | Usage |
|------|-----|-------|
| Cyan Primary | `#00d4ff` | Primary data, active routes |
| Cyan Dim | `#0099b8` | Secondary data, labels |
| Amber Primary | `#ffb000` | Warnings, attention items |
| Amber Dim | `#b87a00` | Secondary warnings |
| White | `#e8eaed` | Primary text |
| Gray | `#8b9098` | Secondary text, disabled |

#### Alert (Status & Feedback)
The signal layer. Immediate, unambiguous.

| Name | Hex | Usage |
|------|-----|-------|
| Crimson | `#ff3b4f` | Critical alerts, losses, danger |
| Gold | `#ffd700` | Success highlights, profits, achievements |
| Green | `#00c853` | Positive status, operational, profit |
| Red | `#ff1744` | Negative status, grounded, loss |

### 1.2 Typography

| Role | Font | Weight | Size Range |
|------|------|--------|------------|
| Data Display | `JetBrains Mono` or `IBM Plex Mono` | Regular | 12-16px |
| UI Labels | `Inter` or `IBM Plex Sans` | Medium | 11-14px |
| Headers | `Inter` or `IBM Plex Sans` | Semibold | 16-24px |
| Large Numbers | `JetBrains Mono` | Bold | 24-48px |

**Rationale:** Monospace for data ensures alignment and scannability. Sans-serif for UI ensures readability at small sizes.

### 1.3 Texture & Material

| Surface | Treatment |
|---------|-----------|
| UI Panels | Matte finish, subtle noise texture (2-3% opacity) |
| Glass overlays | Semi-transparent (`rgba` with 85-92% opacity), blur backdrop |
| 3D Assets (Aircraft) | High-gloss PBR, realistic materials |
| 3D Environments | Mixed — matte for architecture, gloss for glass/metal |

### 1.4 Visual Hierarchy

```
┌─────────────────────────────────────────────────────────┐
│  BACKGROUND LAYER (Deep Space)                          │
│  ┌───────────────────────────────────────────────────┐  │
│  │  CONTENT LAYER (3D viewport, map, visuals)        │  │
│  │  ┌─────────────────────────────────────────────┐  │  │
│  │  │  UI LAYER (Glass panels, data overlays)     │  │  │
│  │  │  ┌───────────────────────────────────────┐  │  │  │
│  │  │  │  ALERT LAYER (Notifications, crises)  │  │  │  │
│  │  │  └───────────────────────────────────────┘  │  │  │
│  │  └─────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

---

## 2. Scene Specifications

### 2.1 Ops Center Map

**Target Reference:** Plague Inc. meets SpaceX Mission Control

**Concept:** A dark-mode satellite view. Not a flat paper map — a digital twin of Earth. The UI frame is the "Terminal," but the center viewport is the "Juice."

#### Visual Requirements

| Element | Specification |
|---------|---------------|
| Globe | 3D sphere with custom shader |
| Surface | Satellite imagery texture, muted colors |
| Day/Night | Real-time terminator line with city lights on dark side |
| Atmosphere | Subtle glow at horizon edge |
| Clouds | Volumetric, slow-moving, semi-transparent |
| Routes | Geodesic arcs (curved, not straight) |
| Route animation | Pulse/flow based on traffic density |
| Hubs | Glow intensity based on operations volume |
| Aircraft | Small icons moving along routes at appropriate speed |

#### UI Overlay

| Element | Specification |
|---------|---------------|
| Side panels | Semi-transparent glass (`rgba(26, 31, 46, 0.9)`), blur backdrop |
| Panel borders | 1px subtle line (`#2a3244`) |
| Data readouts | Cyan primary for values, gray for labels |
| Zoom controls | Minimal, bottom-right corner |

#### Technical Notes (Dev Team)

- Routes must be geodesic curves (great circle paths), not straight lines
- Route pulse rate = f(weekly_frequency) — busier routes pulse faster
- Day/night cycle syncs to in-game time
- Cloud layer updates based on weather events
- Performance target: 60fps with 200+ visible routes

---

### 2.2 The Hangar (Inspection Mode)

**Target Reference:** Gran Turismo showroom

**Concept:** The "Glorification of the Plane." Where the player falls in love with the asset. Dramatic, moody lighting. Minimal UI to let the 3D model shine.

#### Visual Requirements

| Element | Specification |
|---------|---------------|
| Environment | Dark hangar interior, concrete floor |
| Lighting | Dramatic 3-point setup, key light from above-front |
| Aircraft position | Center frame, slight angle (3/4 view) |
| Aircraft LOD | Highest detail model |
| Reflections | Floor reflection (subtle), aircraft surface reflections |
| Background | Hangar doors slightly open, hint of exterior light |

#### Aircraft Detail (3D Artists)

**Imperfections are mandatory.** Aircraft must show:

| Wear Type | Visual Treatment |
|-----------|------------------|
| Service life 0-2 years | Factory fresh, glossy, perfect |
| Service life 2-8 years | Minor exhaust staining, slight paint fade |
| Service life 8-15 years | Visible wear patterns, oil streaks near engines |
| Service life 15+ years | Heavy patina, touched-up paint visible, "survivor" character |

Specific details:
- Oil streaks on engine cowling
- Exhaust staining behind APU
- Scuffing on landing gear doors
- Slight fade on upper fuselage (sun exposure)
- Touch-up paint patches (color slightly off)

#### UI Overlay

| Element | Specification |
|---------|---------------|
| Biography Panel | Right side, semi-transparent, scrollable |
| Stats | Minimal, hover-to-reveal |
| Camera behavior | Lerp (smooth transition) to focus on hovered component |
| Actions | Bottom bar: `[View flight log]` `[Configure cabin]` `[Schedule maintenance]` |

#### Technical Notes (Dev Team)

- Camera lerp duration: 0.5s ease-out
- Hover on "Engines" → camera moves to engine close-up
- Hover on "Cabin" → camera moves to fuselage cross-section view
- Aircraft rotation: slow auto-rotate when idle, stops on interaction

---

### 2.3 Cabin Designer

**Target Reference:** CAD Software / Engineering Blueprints

**Concept:** A visual editor, not a spreadsheet. Technical schematic aesthetic. This is a productivity tool.

#### Visual Requirements

| Element | Specification |
|---------|---------------|
| Background | Dark with technical grid lines (subtle cyan, `#0099b8` at 10% opacity) |
| Fuselage | Top-down cross-section view, clean white outline |
| Grid | Snap-to-grid divisions matching seat pitch increments |
| Seats | Distinct icons per class (see below) |

#### Seat Icons (Top-Down)

| Class | Shape | Color |
|-------|-------|-------|
| First | Large rectangle with details | Gold outline |
| Business | Medium rectangle, lie-flat indicator | Cyan outline |
| Premium Economy | Medium rectangle | Amber outline |
| Economy | Small rectangle | White outline |

#### Interaction

| Action | Feedback |
|--------|----------|
| Place seat | Mechanical "click" sound + small dust particle burst |
| Remove seat | Soft "pop" sound |
| Invalid placement | Red flash on grid cell, error tone |
| Pitch adjustment | Visual seat spacing updates in real-time |

#### UI Elements

| Element | Specification |
|---------|---------------|
| Toolbar | Left side, vertical, icon-based |
| Properties panel | Right side, shows selected seat/section details |
| Capacity counter | Top bar, updates live |
| Pitch slider | Shows passenger comfort indicator |

#### Technical Notes (Dev Team)

- Snap-to-grid is mandatory
- Undo/redo support (Ctrl+Z, Ctrl+Y)
- Drag selection for multi-seat operations
- Export configuration to `AircraftConfiguration` entity

---

### 2.4 Network Scheduler

**Target Reference:** Modern Gantt Chart / TV Broadcast Schedule

**Concept:** Visualizing time and efficiency. Blocks represent flights. Gaps represent wasted money.

#### Visual Requirements

| Element | Specification |
|---------|---------------|
| Background | Dark, horizontal time grid |
| Time axis | Top, 24-hour or week view |
| Aircraft rows | Left side labels, one row per aircraft |
| Flight blocks | Rounded rectangles on timeline |

#### Block Colors

| State | Color | Notes |
|-------|-------|-------|
| Flying | Green (`#00c853`) | Active revenue time |
| Turnaround | Yellow/Amber (`#ffb000`) | Ground time between flights |
| Maintenance | Red (`#ff3b4f`) | Scheduled downtime |
| Available | Gray (`#2a3244`) | Unutilized time |

#### Conflict Visualization

**Critical feature:** Overlapping incompatible blocks must alert the player.

| Conflict Type | Visual Treatment |
|---------------|------------------|
| Maintenance overlaps flight | Intersection zone pulses red |
| Turnaround too short | Yellow warning border, pulse |
| Crew legality violation | Amber highlight on affected block |

#### Technical Notes (Dev Team)

- Drag-and-drop block repositioning
- Zoom levels: Day / Week / Month
- Hover shows flight details tooltip
- Click opens flight/maintenance detail panel
- Conflict detection runs on every change

---

### 2.5 The Office (Progression Scene)

**Target Reference:** First-person environmental storytelling

**Concept:** Background for Main Menu and meta-gameplay. Evolves with company growth. The computer screen anchors the transition to gameplay.

#### Three Variants

##### Bootstrap Stage
| Element | Description |
|---------|-------------|
| Space | Cramped backroom, possibly in hangar |
| Lighting | Harsh fluorescent, slight flicker/buzz |
| Desk | Metal, cluttered, papers everywhere |
| Window | None, or small frosted glass |
| Details | Whiteboard with route sketches, coffee cups, cheap chair |
| Computer | Old monitor, maybe CRT aesthetic |
| Sound | Fluorescent hum, distant aircraft |

##### National Stage
| Element | Description |
|---------|-------------|
| Space | Proper office, glass walls to ops floor |
| Lighting | Professional, warm desk lamp |
| Desk | Wooden, organized, some personal items |
| Window | Overlooking tarmac, rainy weather |
| Details | Industry awards on wall, model aircraft |
| Computer | Modern monitor, clean setup |
| Sound | Rain on window, muffled airport ambiance |

##### Empire Stage
| Element | Description |
|---------|-------------|
| Space | Corner penthouse office, panoramic view |
| Lighting | Natural light, subtle accent lighting |
| Desk | Executive, minimal, expensive |
| Window | City skyline or airport from height |
| Details | Art on walls, premium furniture, bar cart |
| Computer | Sleek, integrated into desk |
| Sound | Subtle HVAC, distant city |

#### Interaction

- Computer screen is the anchor point
- Clicking computer "boots up" the Terminal UI
- Transition: camera pushes into screen, UI fades in
- Return: UI fades, camera pulls back to office

#### Technical Notes (Dev Team)

- Office variant loads based on `Airline.stage`
- Transition animation: 1.5s push-in with slight motion blur
- Office renders at lower priority (background only)
- Time-of-day lighting matches in-game time

---

## 3. UI Component Library ("AeroOS")

### 3.1 Buttons

| Type | Background | Border | Text | Hover | Active |
|------|------------|--------|------|-------|--------|
| Primary | `#00d4ff` | none | `#0a0e14` | lighten 10% | darken 10% |
| Secondary | transparent | 1px `#00d4ff` | `#00d4ff` | fill 10% | fill 20% |
| Danger | `#ff3b4f` | none | `#ffffff` | lighten 10% | darken 10% |
| Ghost | transparent | none | `#8b9098` | text `#e8eaed` | text `#00d4ff` |

### 3.2 Input Fields

| State | Background | Border | Text |
|-------|------------|--------|------|
| Default | `#1a1f2e` | 1px `#2a3244` | `#e8eaed` |
| Focus | `#1a1f2e` | 1px `#00d4ff` | `#e8eaed` |
| Error | `#1a1f2e` | 1px `#ff3b4f` | `#e8eaed` |
| Disabled | `#0a0e14` | 1px `#1a1f2e` | `#8b9098` |

### 3.3 Toggles & Switches

- Track: `#2a3244` (off), `#00d4ff` (on)
- Thumb: `#e8eaed`
- Animation: 150ms ease-out

### 3.4 Sliders

- Track: `#2a3244`
- Fill: `#00d4ff`
- Thumb: `#e8eaed`, 12px circle
- Value tooltip: appears on drag

### 3.5 Progress Bars

| Type | Fill Color | Background |
|------|------------|------------|
| Standard | `#00d4ff` | `#2a3244` |
| Success | `#00c853` | `#2a3244` |
| Warning | `#ffb000` | `#2a3244` |
| Danger | `#ff3b4f` | `#2a3244` |

### 3.6 Cards & Panels

```
┌─────────────────────────────────────┐
│  Background: #1a1f2e                │
│  Border: 1px #2a3244                │
│  Border-radius: 4px                 │
│  Padding: 16px                      │
│  Shadow: 0 4px 12px rgba(0,0,0,0.3) │
└─────────────────────────────────────┘
```

Glass variant:
```
│  Background: rgba(26, 31, 46, 0.85) │
│  Backdrop-filter: blur(12px)        │
```

### 3.7 Data Tables

| Element | Specification |
|---------|---------------|
| Header row | Background `#162032`, text `#8b9098`, uppercase, 11px |
| Data rows | Background alternating `#1a1f2e` / `#0a0e14` |
| Row hover | Background `#2a3244` |
| Borders | 1px `#2a3244` between rows |
| Numbers | Right-aligned, monospace |
| Positive values | `#00c853` |
| Negative values | `#ff3b4f` |

---

## 4. Audio Direction

### 4.1 UI Sounds

| Action | Sound Character | Duration |
|--------|-----------------|----------|
| Button click | Soft mechanical click | 50ms |
| Major purchase | Heavy "thunk" / stamp | 200ms |
| Navigation | Subtle whoosh | 100ms |
| Error | Low buzz / rejection tone | 150ms |
| Success | Bright chime, ascending | 200ms |
| Money tally | Soft ticking, satisfying | Variable |
| Alert | Attention tone, not harsh | 300ms |

### 4.2 Ambient Sound

| Scene | Ambient |
|-------|---------|
| Office (Bootstrap) | Fluorescent hum, distant aircraft |
| Office (National) | Rain, muffled airport |
| Office (Empire) | Subtle HVAC, distant city |
| Hangar | Echo, aircraft systems, distant activity |
| Map | Subtle data processing hum |

### 4.3 Crisis Audio

| State | Treatment |
|-------|-----------|
| Warning | Audio filter: slight low-pass |
| Crisis | Audio filter: more aggressive, heartbeat undertone |
| Resolution | Filter release, relief tone |

---

## 5. Animation Principles

### 5.1 Timing

| Animation Type | Duration | Easing |
|----------------|----------|--------|
| Button state | 150ms | ease-out |
| Panel open/close | 250ms | ease-in-out |
| Page transition | 400ms | ease-in-out |
| Data update | 200ms | ease-out |
| Camera movement | 500ms | ease-out |
| Alert appearance | 300ms | ease-out with overshoot |

### 5.2 Motion Principles

- **Purposeful:** Every animation communicates something
- **Quick:** Respect player time, never block interaction
- **Consistent:** Same action = same animation everywhere
- **Interruptible:** Player can cancel/override animations

### 5.3 Juice Effects

| Trigger | Effect |
|---------|--------|
| Route turns profitable | Brief gold bloom on route line |
| Major milestone | Subtle screen flash, particle burst |
| Crisis begins | Screen edge vignette, slight chromatic aberration |
| Crisis resolved | Vignette fade, color normalization |
| Aircraft delivery | Spotlight sweep in hangar |

---

## 6. Technical Specifications

### 6.1 Resolution Targets

| Aspect | Minimum | Target | Maximum |
|--------|---------|--------|---------|
| Resolution | 1280x720 | 1920x1080 | 3840x2160 |
| UI Scale | 100% | 100% | 200% |
| Frame Rate | 30fps | 60fps | 144fps |

### 6.2 Asset Formats

| Asset Type | Format | Notes |
|------------|--------|-------|
| UI Textures | PNG / WebP | 2x for HiDPI |
| 3D Models | glTF 2.0 | With embedded materials |
| Textures | PNG (diffuse), KTX2 (compressed) | PBR workflow |
| Audio | OGG (music), WAV (SFX) | 44.1kHz |
| Fonts | WOFF2 / TTF | Subset for performance |

### 6.3 LOD Strategy

| Distance | LOD Level | Polygon Budget |
|----------|-----------|----------------|
| Hangar (close) | LOD0 | 50,000 |
| Map (medium) | LOD1 | 5,000 |
| Map (far) | LOD2 | 500 |
| Icon | LOD3 | Sprite |

---

## 7. Production Milestones

### Phase 1: Foundation
- [ ] "AeroOS" component library (Buttons, Toggles, Sliders)
- [ ] Color palette implemented in code
- [ ] Typography system configured
- [ ] Map widget proof-of-concept (dot on curved line on globe)

### Phase 2: Core Scenes
- [ ] Ops Center Map — full implementation
- [ ] Hangar — "National Stage" office blocked out
- [ ] Hangar — lighting tests complete

### Phase 3: Secondary Scenes
- [ ] Cabin Designer — grid and interaction
- [ ] Network Scheduler — Gantt implementation
- [ ] Office — all three variants

### Phase 4: Polish
- [ ] Audio implementation
- [ ] Animation pass
- [ ] Juice effects
- [ ] Performance optimization

---

## Appendix A: Concept Art & Mockups

This section catalogs the current concept art and mockups. All images located in `/geminiGeneratedMockups/`.

### A.1 Hangar / Aircraft Inspection

| File | Description | Art Bible Alignment |
|------|-------------|---------------------|
| `Gemini_Generated_Image_27seyj27seyj27se.png` | Boeing 787 in hangar with biography panel | ✓ Matches Section 2.2 specs: dramatic lighting, 3/4 view, right-side bio panel, dark environment |

**Notes:**
- Lighting setup matches Gran Turismo reference
- Biography panel uses glass effect with proper color scheme
- Floor reflection present
- Aircraft detail level appropriate for LOD0

---

### A.2 Office Progression

| File | Description | Art Bible Alignment |
|------|-------------|---------------------|
| `Gemini_Generated_Image_4ooqdn4ooqdn4ooq.png` | Four-panel office progression (Bootstrap → National → National variant → Empire) | ✓ Matches Section 2.5 specs |

**Stage Details:**

| Stage | Visual Elements | Matches Spec |
|-------|-----------------|--------------|
| Bootstrap | Cramped storage room, fluorescent lights, cardboard boxes, CRT monitor, metal desk | ✓ "Scrappy, constrained, hopeful" |
| National (1) | Standard airport office, rain outside, framed certificate, view of tarmac, modern monitor | ✓ "Professional, established" |
| National (2) | Similar office, different weather, route map on screen | ✓ Variant of National stage |
| Empire | Corner office, floor-to-ceiling windows, golden hour light, curved display, bar cart, premium furnishings | ✓ "Prestigious, expansive, legacy" |

---

### A.3 Cabin Designer — Blueprint View

| File | Description | Art Bible Alignment |
|------|-------------|---------------------|
| `Gemini_Generated_Image_8bi6eu8bi6eu8bi6.png` | Boeing 777 blueprint, 3-class config, component palette, settings panel | ✓ Matches Section 2.3 specs |
| `Gemini_Generated_Image_nf4c77nf4c77nf4c.png` | Boeing 777 blueprint with seat placement particle effect | ✓ Matches Section 2.3 specs |

**Spec Compliance:**
- ✓ Technical grid lines (cyan at low opacity)
- ✓ Top-down fuselage cross-section
- ✓ Distinct seat icons per class (First=gold, Business=cyan, Premium=amber, Economy=white)
- ✓ Left toolbar with component palette
- ✓ Right settings panel with pitch/width sliders
- ✓ Bottom status bar with comfort indicator and pricing
- ✓ Placement particle effect on seat drop

---

### A.4 Cabin Designer — 3D Walkthrough / Living Flight

| File | Description | Art Bible Alignment |
|------|-------------|---------------------|
| `Gemini_Generated_Image_anryoanryoanryoa.png` | First Class interior, happy passengers, 80" pitch, $8,500 ticket | ✓ Section 2.3 + GDD 15.8 Living Flight |
| `Gemini_Generated_Image_anryoanryoanryoa (1).png` | Business class, happy passengers, 60" pitch, luxurious comfort | ✓ Living Flight visualization |
| `Gemini_Generated_Image_ksrkx6ksrkx6ksrk.png` | Economy, cramped (30" pitch, 17" width), mixed satisfaction (angry front rows, happy rear) | ✓ Living Flight with satisfaction gradient |

**Living Flight Implementation:**
- ✓ Passenger emoji indicators above heads (green=happy, red=angry)
- ✓ Satisfaction varies by cabin section
- ✓ Component palette overlay (glass panel style)
- ✓ Real-time comfort/price indicator
- ✓ Cyberpunk-style grid overlay on walls/ceiling
- ✓ IFE screens visible on seatbacks

**Satisfaction Mapping (from mockups):**
| Pitch | Width | Comfort Level | Emoji |
|-------|-------|---------------|-------|
| 80" | 30" | Exclusive | 😊 (all green) |
| 60" | 24" | Luxurious | 😊 (all green) |
| 30" | 17" | Cramped | 😠 front / 😊 rear (gradient) |

---

### A.5 Ops Center Map

| File | Description | Art Bible Alignment |
|------|-------------|---------------------|
| `Gemini_Generated_Image_hnm2qwhnm2qwhnm2.png` | Globe with route network, side panels, "Glass Cockpit" header | ✓ Matches Section 2.1 specs |
| `Gemini_Generated_Image_iuwuwiuwuwiuwuwi.png` | Similar globe view, different panel arrangement | ✓ Alternate layout |

**Spec Compliance:**
- ✓ 3D sphere with dark satellite texture
- ✓ Day/night terminator visible (city lights on dark side)
- ✓ Routes as geodesic arcs (curved, not straight)
- ✓ Hub glow intensity based on operations
- ✓ Glass panel overlays (semi-transparent, blur backdrop)
- ✓ Cyan primary color for route lines
- ✓ Amber secondary for warnings/weather
- ✓ Weather overlay panel (radar style)
- ✓ Flight list panel with status colors
- ✓ Charts/graphs in side panels

**Color Usage in Mockups:**
| Element | Color | Matches Palette |
|---------|-------|-----------------|
| Active routes | Cyan (`#00d4ff` approx) | ✓ Avionics Primary |
| City lights | Amber/Gold | ✓ Alert Gold |
| Panel backgrounds | Dark transparent | ✓ Deep Space + glass effect |
| Data text | White/Gray | ✓ Avionics White/Gray |

---

### A.6 Network Scheduler

| File | Description | Art Bible Alignment |
|------|-------------|---------------------|
| `Gemini_Generated_Image_md7zpumd7zpumd7z.png` | Gantt chart with fleet schedule, maintenance blocks, critical conflict highlight | ✓ Matches Section 2.4 specs |

**Spec Compliance:**
- ✓ Dark background with horizontal time grid
- ✓ Aircraft rows (N-registrations)
- ✓ Time axis across top
- ✓ Flight blocks as colored rectangles

**Block Colors (from mockup):**
| State | Color | Matches Spec |
|-------|-------|--------------|
| Flying | Green | ✓ `#00c853` |
| Turnaround | Yellow/Amber | ✓ `#ffb000` |
| Maintenance | Red block | ✓ `#ff3b4f` |
| Conflict | Pulsing red overlay with warning | ✓ Critical alert treatment |

**Conflict Visualization:**
- Red pulsing overlay on overlapping blocks
- "⚠ CRITICAL CONFLICT" label
- Dashed border around conflict zone
- Affects entire row visually (darker background)

---

### A.7 External References

These external references inform the visual direction but are not included in the repository:

#### Map References
- Plague Inc. (globe rendering, dark atmosphere)
- SpaceX Mission Control (UI density, professionalism)
- FlightRadar24 (route visualization, aircraft tracking)

#### Hangar References
- Gran Turismo 7 (dramatic vehicle lighting)
- War Thunder (aircraft hangar environments)
- Microsoft Flight Simulator (aircraft detail fidelity)

#### UI References
- Bloomberg Terminal (data density, information hierarchy)
- Figma (modern productivity UI patterns)
- Alien: Isolation (retro-future aesthetic without being retro)

---

### A.8 Missing Concept Art

The following scenes need concept art:

| Scene | Priority | Notes |
|-------|----------|-------|
| Route Map (2D) | Medium | Flat map alternative to globe |
| Fleet Management | Medium | Grid/list view of all aircraft |
| Financial Dashboard | Low | Charts, P&L, balance sheet |
| Crew Management | Low | Staff roster, training |
| Airport Detail | Low | Gate management, lounges |
| Crisis Event | Medium | Board meeting, emergency UI |

---

## Document History

| Version | Date | Changes |
|---------|------|---------|
| 0.1 | January 2026 | Initial draft from Art Director feedback |
| 0.2 | January 2026 | Appendix A populated with mockup catalog, spec compliance analysis, Living Flight visualization notes |

---

*This is a living document. Update as art direction evolves.*
