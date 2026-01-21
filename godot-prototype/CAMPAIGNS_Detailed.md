# Airline Tycoon PC - Campaign Specifications

**Document Type:** Detailed Campaign Design  
**Parent Document:** GDD_AirlineTycoon.md  
**Last Updated:** January 21, 2026  
**Version:** 0.1

---

## Table of Contents

1. [Campaign 1: The Deregulation Gamble](#campaign-1-the-deregulation-gamble)
2. [Campaign 2: Silk Road Revival](#campaign-2-silk-road-revival)
3. [Campaign 3: Island Empire](#campaign-3-island-empire)

---

# Campaign 1: The Deregulation Gamble

## Overview

| Attribute | Value |
|-----------|-------|
| **Region** | United States (Midwest focus) |
| **Start Date** | January 1, 1979 |
| **End Date** | December 31, 1985 |
| **Duration** | 7 in-game years |
| **Difficulty** | Medium |
| **Playtime** | 4-6 hours |

## Win Conditions

| Condition | Type | Description |
|-----------|------|-------------|
| **Route Empire** | Primary Victory | Operate 50 profitable routes by Dec 31, 1985 |
| **Golden Exit** | Alternate Victory | Sell airline for 3x initial valuation ($9M+) |
| **Survivor** | Minor Victory | Remain operational and profitable by end date |
| **Bankruptcy** | Failure | Cash reserves hit zero with no credit available |
| **Deadline Miss** | Failure | Reach end date with fewer than 20 routes |

## Historical Context

### The Deregulation Era (1978-1985)

The Airline Deregulation Act of 1978 removed federal control over fares, routes, and market entry. This created both chaos and opportunity:

**Before Deregulation:**
- Civil Aeronautics Board controlled all routes and fares
- Airlines needed government permission to serve new cities
- Competition was limited, prices were high but stable
- "Big Four" (American, Eastern, TWA, United) dominated

**After Deregulation:**
- Airlines free to set their own prices
- New carriers can enter any market
- Price wars begin immediately
- Hub-and-spoke systems develop rapidly

## Global Events Timeline

| Date | Event | Gameplay Impact |
|------|-------|-----------------|
| **Jan 1979** | Iranian Revolution begins | Fuel prices begin rising (+15% over 6 months) |
| **Apr 1979** | Second Oil Crisis peaks | Fuel costs spike (+40%), demand drops 10% |
| **1979-1980** | US Recession | Passenger demand down 15%, business travel hit hardest |
| **May 1982** | Braniff bankruptcy | Routes become available, used aircraft flood market (prices -30%) |
| **Aug 1981** | PATCO Strike | Flight capacity reduced 30% industry-wide for 3 months, then gradual recovery; hiring opportunities as competitors struggle |
| **1982-1983** | Recession deepens | Fuel prices begin falling, demand slowly recovers |
| **1984** | Oil glut begins | Fuel prices drop 25%, expansion becomes profitable again |
| **1985** | Consolidation wave | Major carriers begin acquisition sprees, buyout offers increase |

### Event: PATCO Strike (August 1981)
- Air Traffic Controllers go on strike
- Reagan fires 11,345 controllers
- Industry capacity reduced by 30%
- Effect on player: Fewer available slots at major airports, but competitors also constrained
- Opportunity: Airlines with efficient operations gain market share

### Event: Braniff Collapse (May 1982)
- First major airline failure post-deregulation
- 62 aircraft grounded, 9,000 employees laid off
- Effect on player: Cheap used aircraft available, abandoned routes open for entry
- Opportunity: Hire experienced pilots at lower wages, acquire routes

## Starting Setup

| Asset | Details |
|-------|---------|
| **Cash** | $3,000,000 |
| **Credit Line** | $1,000,000 (8% interest) |
| **Aircraft** | 2x Beechcraft 99 (15 seats each) |
| **Home Base** | Player choice: Kansas City (MCI), St. Louis (STL), or Indianapolis (IND) |
| **Staff** | 12 employees (4 pilots, 4 crew, 4 ground) |
| **Reputation** | Neutral (unknown carrier) |

## Available Aircraft

### Turboprops (Available from Start)

| Aircraft | Seats | Range (nm) | Cruise (kts) | Fuel (gal/hr) | New Price | Used Price | Introduced |
|----------|-------|------------|--------------|---------------|-----------|------------|------------|
| Beechcraft 99 | 15 | 1,000 | 240 | 90 | $850,000 | $400,000 | 1968 |
| Beechcraft C99 | 15 | 1,050 | 250 | 95 | $1,200,000 | N/A | 1981 |
| Swearingen Metro II | 19 | 600 | 290 | 120 | $1,800,000 | $900,000 | 1974 |
| Swearingen Metro III | 19 | 750 | 310 | 125 | $2,400,000 | N/A | 1981 |
| de Havilland DHC-6 Twin Otter | 19 | 700 | 170 | 80 | $1,500,000 | $700,000 | 1966 |
| Fokker F27 | 44 | 1,200 | 260 | 200 | $4,500,000 | $2,000,000 | 1958 |
| Convair 580 | 52 | 1,500 | 300 | 280 | N/A | $1,500,000 | 1960 |

### Regional Jets (Unlock: 5+ profitable routes)

| Aircraft | Seats | Range (nm) | Cruise (kts) | Fuel (gal/hr) | New Price | Used Price | Introduced |
|----------|-------|------------|--------------|---------------|-----------|------------|------------|
| Douglas DC-9-10 | 90 | 1,500 | 490 | 650 | N/A | $3,500,000 | 1965 |
| Douglas DC-9-30 | 115 | 1,700 | 490 | 700 | $12,000,000 | $5,000,000 | 1967 |
| Boeing 737-200 | 130 | 2,400 | 450 | 850 | $15,000,000 | $7,000,000 | 1968 |
| BAC One-Eleven | 89 | 1,700 | 470 | 600 | N/A | $2,500,000 | 1965 |

### Mainline Jets (Unlock: 15+ routes, $10M+ revenue)

| Aircraft | Seats | Range (nm) | Cruise (kts) | Fuel (gal/hr) | New Price | Used Price | Introduced |
|----------|-------|------------|--------------|---------------|-----------|------------|------------|
| Boeing 727-100 | 131 | 2,300 | 500 | 1,200 | N/A | $4,000,000 | 1964 |
| Boeing 727-200 | 189 | 2,600 | 500 | 1,300 | $22,000,000 | $8,000,000 | 1967 |
| Douglas DC-10-10 | 270 | 3,800 | 530 | 2,200 | N/A | $15,000,000 | 1971 |
| Boeing 757-200 | 200 | 3,900 | 500 | 900 | $40,000,000 | N/A | 1983 |

*Note: "N/A" for new price means no longer in production; used only.*

## Playable Airports

### Tier 1: Major Hubs (High demand, high competition)

| Code | City | State | Slots | Notes |
|------|------|-------|-------|-------|
| ORD | Chicago O'Hare | IL | Limited | United/American fortress |
| DFW | Dallas-Fort Worth | TX | Medium | American hub developing |
| ATL | Atlanta | GA | Medium | Delta/Eastern hub |
| DEN | Denver Stapleton | CO | Available | Continental hub |
| MSP | Minneapolis | MN | Available | Northwest hub |
| DTW | Detroit | MI | Available | Republic hub |

### Tier 2: Secondary Cities (Good demand, moderate competition)

| Code | City | State | Slots | Notes |
|------|------|-------|-------|-------|
| MCI | Kansas City | MO | Open | Potential player hub |
| STL | St. Louis | MO | Medium | TWA hub (weakening) |
| IND | Indianapolis | IN | Open | Underserved |
| CVG | Cincinnati | OH | Open | Delta developing |
| MKE | Milwaukee | WI | Open | Underserved |
| OMA | Omaha | NE | Open | Frontier territory |
| CLE | Cleveland | OH | Medium | United focus city |
| PIT | Pittsburgh | PA | Medium | Allegheny/USAir hub |

### Tier 3: Regional Markets (Lower demand, minimal competition)

| Code | City | State | Slots | Notes |
|------|------|-------|-------|-------|
| DSM | Des Moines | IA | Open | Subsidy eligible |
| ICT | Wichita | KS | Open | Subsidy eligible |
| TUL | Tulsa | OK | Open | Oil industry traffic |
| OKC | Oklahoma City | OK | Open | Growing market |
| LIT | Little Rock | AR | Open | Subsidy eligible |
| SGF | Springfield | MO | Open | Subsidy eligible |
| FSD | Sioux Falls | SD | Open | Subsidy eligible |
| FAR | Fargo | ND | Open | Subsidy eligible |
| BIS | Bismarck | ND | Open | Subsidy eligible |

### Tier 4: Destination Markets (Expansion targets)

| Code | City | State | Slots | Notes |
|------|------|-------|-------|-------|
| LAX | Los Angeles | CA | Limited | High yield |
| SFO | San Francisco | CA | Limited | High yield |
| JFK | New York JFK | NY | Very Limited | Prestige route |
| MIA | Miami | FL | Limited | Vacation traffic |
| MCO | Orlando | FL | Available | Tourism boom |
| PHX | Phoenix | AZ | Available | Growing market |
| LAS | Las Vegas | NV | Available | Tourism/gaming |

## AI Competitors

| Airline | Strategy | Aggression | Home Base | Threat Level |
|---------|----------|------------|-----------|--------------|
| **American** | Premium pricing | Medium | DFW | High on trunk routes |
| **TWA** | Full service | Low (declining) | STL | Medium, vulnerable |
| **United** | Hub dominance | High | ORD/DEN | High at hubs |
| **Continental** | Cost cutter | High | DEN | Direct competitor |
| **Republic** | Regional growth | Medium | DTW/MSP | Direct competitor |
| **Frontier** | Regional niche | Low | DEN | Low |
| **Ozark** | Regional legacy | Low | STL | Low |
| **New Entrant AI** | Aggressive LCC | Very High | Various | Spawns mid-game |

## Mission Structure (Detailed)

### Phase 1: "Getting Off the Ground" (1979)

**Objectives:**
1. Establish 5 profitable routes within first year
2. Achieve 60% average load factor
3. Maintain positive cash flow for 3 consecutive months

**Rewards:**
- Unlock used jet aircraft purchases
- Bank increases credit line to $2M
- Reputation boost: "Promising new carrier"

**Guidance:**
- Focus on underserved city pairs
- Price 15-20% below competition
- Avoid direct competition with majors

### Phase 2: "Weathering the Storm" (1980-1981)

**Objectives:**
1. Survive the fuel crisis without bankruptcy
2. Maintain at least 70% of routes operational
3. Reach $500K monthly profit

**Rewards:**
- Access to new aircraft financing
- Government subsidy eligibility
- Reputation: "Resilient operator"

**Challenges:**
- Fuel costs spike 40%
- Demand drops 15%
- PATCO strike reduces industry capacity

### Phase 3: "Seizing Opportunity" (1982-1983)

**Objectives:**
1. Expand to 25 routes
2. Acquire at least 3 routes from collapsed carriers
3. Begin service to one major hub (ORD/DFW/ATL)

**Rewards:**
- Acquisition offers from major carriers
- Premium slot access at congested airports
- Media coverage: "Rising star of deregulation"

**Opportunities:**
- Braniff collapse releases routes and aircraft
- Used aircraft prices drop 30%
- Experienced staff available

### Phase 4: "Go Big or Go Home" (1984-1985)

**Objectives:**
1. Reach 50 profitable routes OR
2. Accept buyout offer at 3x initial valuation OR
3. Establish hub presence at 2+ major airports

**Rewards:**
- Campaign victory
- Unlock sandbox mode with earned aircraft/reputation
- Historical achievement: "Deregulation Winner"

---

# Campaign 2: Silk Road Revival

## Overview

| Attribute | Value |
|-----------|-------|
| **Region** | Central Asia (Kazakhstan focus) |
| **Start Date** | January 1, 2005 |
| **End Date** | December 31, 2015 |
| **Duration** | 11 in-game years |
| **Difficulty** | Hard |
| **Playtime** | 5-7 hours |

## Win Conditions

| Condition | Type | Description |
|-----------|------|-------------|
| **Silk Road Hub** | Primary Victory | Achieve #1 market share on Europe-Asia transit traffic |
| **Alliance Champion** | Alternate Victory | Join a global alliance and become primary Central Asian partner |
| **State Success** | Minor Victory | Achieve profitability for 5 consecutive years |
| **State Abandonment** | Failure | Negative profits for 3 consecutive years (funding withdrawn) |
| **Safety Crisis** | Failure | 2+ accidents result in EU flight ban |

## Historical Context

### Central Asia in 2005

Kazakhstan became independent in 1991 when the Soviet Union collapsed. By 2005:

- Kazakhstan Airlines collapsed in 1996 after mid-air collision disaster
- Air Kazakhstan (successor) went bankrupt in 2004
- Air Astana (founded 2002) emerging as new national carrier
- Infrastructure aging, Soviet-era aircraft still common
- China's economy booming, creating east-west cargo demand
- Oil wealth funding modernization

**Geographic Advantage:**
- Kazakhstan sits between Europe and Asia
- 5-hour flight to both Moscow and Beijing
- Natural stopover point for long-haul flights
- Underserved but growing market

## Global Events Timeline

| Date | Event | Gameplay Impact |
|------|-------|-----------------|
| **2005** | Oil prices rising | Government funding stable, cargo demand strong |
| **2006** | Kazakhstan GDP growth 10%+ | Domestic travel demand increases |
| **2007** | EU blacklist concerns | Safety investments required or face European ban |
| **2008** | Global Financial Crisis | Demand drops 20%, fuel prices volatile |
| **2009** | Recovery begins | Gradual demand recovery, government stimulus |
| **2010** | Shanghai Expo | China traffic spikes, cargo boom |
| **2011** | Arab Spring | Middle East routing disrupted, opportunity for alternatives |
| **2012** | Putin returns | Russia traffic stable, visa requirements ease |
| **2014** | Oil price crash | Government funding uncertain, must prove profitability |
| **2015** | China Belt & Road Initiative | Massive cargo opportunities, infrastructure investment |

### Event: EU Safety Concerns (2006-2007)
- European Union reviews safety standards of Central Asian carriers
- Many Kazakh airlines banned from EU airspace
- Effect on player: Must invest in safety, maintenance, modern aircraft
- Opportunity: Compliance opens lucrative European routes

### Event: Global Financial Crisis (2008)
- Global economic meltdown
- Business travel collapses 30%
- Effect on player: Revenue drops, government funding tightens
- Opportunity: Weakened competitors, cheaper aircraft

## Starting Setup

| Asset | Details |
|-------|---------|
| **Cash** | $8,000,000 (government investment) |
| **Credit Line** | $5,000,000 (state-backed, 5% interest) |
| **Aircraft** | 3x Tupolev Tu-154M (164 seats, aging) |
| **Home Base** | Almaty (ALA) - commercial capital |
| **Staff** | 85 employees (many ex-Soviet aviation) |
| **Reputation** | Low internationally, moderate domestically |
| **Government Relations** | Strong (state backing) |

## Available Aircraft

### Soviet/Russian Aircraft (Available from Start, Cheap)

| Aircraft | Seats | Range (nm) | Cruise (kts) | Fuel (gal/hr) | Purchase | Lease/mo | Notes |
|----------|-------|------------|--------------|---------------|----------|----------|-------|
| Tupolev Tu-154M | 164 | 2,400 | 470 | 1,800 | $2,000,000 | $40,000 | Aging, high fuel use |
| Tupolev Tu-134 | 84 | 1,200 | 420 | 900 | $800,000 | $20,000 | Noisy, domestic only |
| Antonov An-24 | 48 | 600 | 250 | 300 | $300,000 | $8,000 | Regional workhorse |
| Ilyushin Il-76 (Cargo) | N/A | 2,200 | 430 | 2,500 | $3,000,000 | $60,000 | Heavy cargo |
| Yakovlev Yak-42 | 120 | 1,400 | 400 | 700 | $1,500,000 | $30,000 | Decent efficiency |

### Western Aircraft (Require EU compliance certification)

| Aircraft | Seats | Range (nm) | Cruise (kts) | Fuel (gal/hr) | New Price | Lease/mo | Available |
|----------|-------|------------|--------------|---------------|-----------|----------|-----------|
| Boeing 737-300 | 149 | 2,500 | 450 | 750 | N/A | $200,000 | Used from 2005 |
| Boeing 737-700 | 149 | 3,200 | 450 | 650 | $55,000,000 | $350,000 | New from 2005 |
| Boeing 757-200 | 200 | 3,900 | 490 | 900 | $65,000,000 | $400,000 | New/Used |
| Boeing 767-300ER | 269 | 5,900 | 490 | 1,200 | $130,000,000 | $700,000 | Long-haul |
| Airbus A320 | 150 | 2,700 | 450 | 650 | $75,000,000 | $350,000 | New |
| Airbus A321 | 185 | 2,700 | 450 | 700 | $90,000,000 | $400,000 | New |
| Fokker 50 | 50 | 1,000 | 280 | 200 | N/A | $80,000 | Regional |
| Embraer E190 | 100 | 2,100 | 450 | 500 | $40,000,000 | $250,000 | From 2006 |

### Cargo Aircraft

| Aircraft | Capacity | Range (nm) | New Price | Lease/mo | Notes |
|----------|----------|------------|-----------|----------|-------|
| Boeing 747-400F | 120 tons | 4,400 | $200,000,000 | $1,200,000 | Premium cargo |
| Boeing 767-300F | 52 tons | 3,200 | $100,000,000 | $500,000 | Mid-size cargo |
| Ilyushin Il-76TD | 48 tons | 2,200 | $5,000,000 | $80,000 | Budget cargo |

## Playable Airports

### Home Region: Kazakhstan

| Code | City | Type | Infrastructure | Notes |
|------|------|------|----------------|-------|
| ALA | Almaty | International | Good | Commercial capital, main hub |
| TSE | Astana (Nur-Sultan) | International | Medium | Political capital, growing |
| CIT | Shymkent | Domestic | Basic | Southern gateway |
| GUW | Atyrau | Regional | Basic | Oil industry hub |
| AKT | Aktau | Regional | Basic | Caspian oil/gas |
| URA | Oral | Regional | Basic | Western gateway |
| SCO | Aktobe | Regional | Basic | Mining region |

### Central Asia Neighbors

| Code | City | Country | Notes |
|------|------|---------|-------|
| TAS | Tashkent | Uzbekistan | Regional rival, Uzbekistan Airways hub |
| FRU | Bishkek | Kyrgyzstan | Small market, transit potential |
| DYU | Dushanbe | Tajikistan | Limited infrastructure |
| ASB | Ashgabat | Turkmenistan | Restricted market |

### Europe Destinations (Require EU certification)

| Code | City | Demand | Competition | Notes |
|------|------|--------|-------------|-------|
| FRA | Frankfurt | High | High | Star Alliance hub |
| LHR | London Heathrow | Very High | Very High | Premium slots required |
| AMS | Amsterdam | High | Medium | KLM hub |
| CDG | Paris | High | High | SkyTeam hub |
| IST | Istanbul | Medium | Medium | Turkish hub, gateway |

### Asia Destinations

| Code | City | Demand | Competition | Notes |
|------|------|--------|-------------|-------|
| PEK | Beijing | Very High | Medium | Growing rapidly |
| PVG | Shanghai | Very High | Medium | Cargo hub |
| URC | Urumqi | Medium | Low | Western China gateway |
| ICN | Seoul | High | Medium | Korean traffic |
| BKK | Bangkok | Medium | Medium | Tourism/cargo |
| DEL | Delhi | Medium | Low | India gateway |
| DXB | Dubai | High | High | Emirates hub |

### Russia/CIS

| Code | City | Demand | Competition | Notes |
|------|------|--------|-------------|-------|
| SVO | Moscow Sheremetyevo | Very High | High | Aeroflot hub |
| DME | Moscow Domodedovo | High | Medium | Alternative Moscow |
| LED | St. Petersburg | Medium | Medium | European Russia |
| AER | Sochi | Seasonal | Low | Resort traffic |
| EKB | Yekaterinburg | Medium | Low | Ural gateway |

## AI Competitors

| Airline | Strategy | Aggression | Threat Level |
|---------|----------|------------|--------------|
| **Air Astana** | Full service, western fleet | Medium | High - direct competitor |
| **SCAT Airlines** | Budget domestic | Low | Medium on domestic |
| **Uzbekistan Airways** | Regional flag carrier | Low | Medium on regional |
| **Aeroflot** | Russian dominance | Medium | High on Russia routes |
| **Turkish Airlines** | Hub competition | High | High on Europe connection |
| **Emirates** | Premium transit | Very High | Very High on hub strategy |
| **China Southern** | Asia gateway | Medium | High on China routes |

## Mission Structure (Detailed)

### Phase 1: "Building the Bridge" (2005-2006)

**Objectives:**
1. Connect Almaty to Moscow, Dubai, and Beijing
2. Achieve 50% load factor on international routes
3. Begin EU safety certification process

**Rewards:**
- Codeshare offers from regional carriers
- Government grants additional $3M funding
- European route licenses (pending certification)

### Phase 2: "Safety First" (2007-2008)

**Objectives:**
1. Acquire minimum 3 western aircraft (B737/A320 or better)
2. Pass EU safety audit
3. Achieve 20% transit passenger ratio at Almaty hub

**Rewards:**
- EU airspace access (Frankfurt, London routes available)
- Hub status bonus (reduced airport fees)
- Reputation: "Modern Central Asian carrier"

### Phase 3: "Cargo Silk Road" (2009-2011)

**Objectives:**
1. Launch dedicated cargo division
2. Operate minimum 2 freighter aircraft
3. Achieve $5M annual cargo revenue

**Rewards:**
- Cargo handling priority at Almaty
- Belt & Road partnerships
- Government cargo contracts

### Phase 4: "Alliance Ascension" (2012-2013)

**Objectives:**
1. Partner with Star Alliance, SkyTeam, or Oneworld
2. Achieve top-3 transit carrier between Europe and Asia
3. Maintain 5% profit margin for 2 years

**Rewards:**
- Alliance traffic feed
- Joint venture opportunities
- Codeshares with major carriers

### Phase 5: "Silk Road Champion" (2014-2015)

**Objectives:**
1. Achieve #1 market share on Europe-Asia transit
2. Operate to 5+ European and 5+ Asian destinations
3. Sustain profitability through oil price crash

**Rewards:**
- Campaign victory
- Unlock sandbox with established network
- Achievement: "Master of the Crossroads"

---

# Campaign 3: Island Empire

## Overview

| Attribute | Value |
|-----------|-------|
| **Region** | Indonesia (Archipelago-wide) |
| **Start Date** | January 1, 1990 |
| **End Date** | December 31, 2000 |
| **Duration** | 11 in-game years |
| **Difficulty** | Easy |
| **Playtime** | 6-8 hours |

## Win Conditions

| Condition | Type | Description |
|-----------|------|-------------|
| **Island Connector** | Primary Victory | Serve 100 unique islands with scheduled flights |
| **Market Leader** | Alternate Victory | Achieve 30% domestic market share |
| **Tourism Champion** | Alternate Victory | Become #1 carrier to Bali from 5+ origins |
| **Family Legacy** | Minor Victory | Remain operational with positive reputation |
| **Bankruptcy** | Failure | Cash depleted, no credit available |
| **Reputation Collapse** | Failure | Safety incidents cause government license revocation |

## Historical Context

### Indonesia in 1990

Indonesia is an archipelago of 17,000+ islands spanning 5,000 km. Aviation is essential for national unity and economic development.

**Market Structure:**
- Garuda Indonesia: State airline, dominates Jakarta trunk routes
- Merpati Nusantara: State airline for "pioneer" (remote) routes
- Mandala Airlines: First private carrier (since 1969)
- Bouraq Airlines: Private regional (since 1970)
- Sempati Air: Rising competitor (backed by Suharto family)

**The Opportunity:**
- Only Garuda allowed to operate jets (until 1989 deregulation)
- Tourism to Bali growing rapidly (1M visitors in 1990)
- Government subsidies available for underserved routes
- Infrastructure improving with oil wealth

**Challenges:**
- Geography: extreme distances, remote airstrips
- Weather: monsoons, volcanic ash clouds
- Infrastructure: many grass/gravel strips, limited navigation aids

## Global Events Timeline

| Date | Event | Gameplay Impact |
|------|-------|-----------------|
| **1990** | Tourism boom | Bali demand surging, premium pricing possible |
| **1991** | Mt. Pinatubo eruption (Philippines) | Ash disrupts regional flights for 2 months |
| **1992** | Deregulation expands | Private airlines can now operate jets |
| **1993** | "Visit Indonesia Year" | Government tourism push, demand +20% |
| **1994** | Garuda fleet expansion | Competition intensifies on trunk routes |
| **1995** | Bali growth peaks | 3M visitors, infrastructure strain |
| **1997** | Asian Financial Crisis | Currency collapse, demand crashes 40%, fuel costs spike |
| **1998** | Suharto falls | Political instability, riots, tourism collapses |
| **1999** | Democratic transition | Uncertainty continues, slow recovery begins |
| **2000** | Recovery begins | Tourism returning, economy stabilizing |

### Event: Asian Financial Crisis (July 1997)
- Indonesian Rupiah loses 80% of value
- Unemployment soars, poverty doubles
- Tourism drops 50%, domestic travel collapses
- Effect on player: Revenue plummets, fuel (priced in USD) becomes expensive
- Opportunity: Weaker competitors fail, routes available for survivors

### Event: Suharto Resignation (May 1998)
- 32-year rule ends amid riots
- Ethnic violence affects Chinese-Indonesian business
- Travel warnings issued by foreign governments
- Effect on player: Tourism revenue near zero for months
- Opportunity: Airlines with domestic focus survive better

### Volcanic Events (Recurring)
- Indonesia has 130+ active volcanoes
- Eruptions disrupt flights periodically
- Effect on player: Routes closed temporarily, diversions required
- Opportunity: Flexible carriers can capture diverted traffic

## Starting Setup

| Asset | Details |
|-------|---------|
| **Cash** | $1,500,000 (Rupiah equivalent) |
| **Credit Line** | $500,000 (high interest: 15%) |
| **Aircraft** | 1x Fokker F27-500 (44 seats) |
| **Home Base** | Surabaya (SUB) - East Java |
| **Staff** | 25 employees (family business atmosphere) |
| **Reputation** | Local recognition in East Java |
| **Government Relations** | Neutral |

## Available Aircraft

### Small Turboprops (Island Hopping - Available from Start)

| Aircraft | Seats | Range (nm) | Cruise (kts) | Runway Req | New Price | Used Price | Notes |
|----------|-------|------------|--------------|------------|-----------|------------|-------|
| de Havilland DHC-6 Twin Otter | 19 | 700 | 170 | 1,200 ft | $3,000,000 | $1,200,000 | STOL champion |
| CASA C-212 | 26 | 480 | 190 | 1,300 ft | $4,000,000 | $1,500,000 | Utility |
| Dornier 228 | 19 | 650 | 230 | 1,500 ft | $3,500,000 | $1,400,000 | Reliable |
| Pilatus PC-6 | 10 | 500 | 140 | 650 ft | $1,200,000 | $500,000 | Extreme STOL |
| Cessna Caravan | 14 | 900 | 180 | 1,500 ft | $1,800,000 | $800,000 | Versatile |

### Regional Turboprops (Medium Routes)

| Aircraft | Seats | Range (nm) | Cruise (kts) | Runway Req | New Price | Used Price | Notes |
|----------|-------|------------|--------------|------------|-----------|------------|-------|
| Fokker F27-500 | 44 | 1,200 | 260 | 4,000 ft | $7,000,000 | $2,500,000 | Workhorse |
| Fokker F50 | 50 | 1,500 | 280 | 4,500 ft | $12,000,000 | $5,000,000 | Modern replacement |
| ATR 42-300 | 48 | 900 | 265 | 3,600 ft | $10,000,000 | $4,000,000 | Fuel efficient |
| ATR 72-200 | 70 | 1,000 | 280 | 4,000 ft | $15,000,000 | N/A | From 1989 |

### Regional Jets (Unlock: After 1992 deregulation)

| Aircraft | Seats | Range (nm) | Cruise (kts) | Runway Req | New Price | Used Price | Notes |
|----------|-------|------------|--------------|------------|-----------|------------|-------|
| Fokker F28-4000 | 85 | 1,500 | 420 | 5,000 ft | N/A | $3,000,000 | Proven design |
| Fokker 100 | 109 | 1,500 | 430 | 5,500 ft | $25,000,000 | $10,000,000 | Modern |
| BAe 146-200 | 100 | 1,600 | 420 | 4,500 ft | N/A | $8,000,000 | Quiet, STOL |

### Mainline Jets (Unlock: 50+ routes OR Garuda codeshare)

| Aircraft | Seats | Range (nm) | Cruise (kts) | Runway Req | New Price | Used Price | Notes |
|----------|-------|------------|--------------|------------|-----------|------------|-------|
| Boeing 737-300 | 149 | 2,500 | 450 | 6,000 ft | $35,000,000 | $12,000,000 | Trunk route |
| Boeing 737-400 | 168 | 2,500 | 450 | 6,500 ft | $40,000,000 | $15,000,000 | Stretch |
| McDonnell Douglas MD-82 | 155 | 2,400 | 450 | 7,000 ft | N/A | $8,000,000 | Common type |
| Airbus A300B4 | 266 | 3,500 | 470 | 8,000 ft | N/A | $15,000,000 | Wide-body |

## Playable Airports

### Major Hubs (High demand, Garuda dominates)

| Code | City | Island | Runway | Competition | Notes |
|------|------|--------|--------|-------------|-------|
| CGK | Jakarta Soekarno-Hatta | Java | 12,000 ft | Extreme | National gateway |
| SUB | Surabaya Juanda | Java | 10,000 ft | High | Player start |
| DPS | Denpasar Ngurah Rai | Bali | 10,000 ft | High | Tourism mecca |
| UPG | Makassar Hasanuddin | Sulawesi | 9,000 ft | Medium | Eastern gateway |
| MES | Medan Kuala Namu | Sumatra | 10,000 ft | Medium | Northern hub |

### Secondary Cities (Moderate demand)

| Code | City | Island | Runway | Competition | Notes |
|------|------|--------|--------|-------------|-------|
| BDO | Bandung | Java | 7,000 ft | Medium | Mountain resort |
| JOG | Yogyakarta | Java | 6,000 ft | Medium | Cultural tourism |
| SRG | Semarang | Java | 6,500 ft | Low | Central Java |
| BPN | Balikpapan | Kalimantan | 8,000 ft | Medium | Oil industry |
| PLM | Palembang | Sumatra | 8,000 ft | Low | Southern Sumatra |
| MDC | Manado | Sulawesi | 8,000 ft | Low | Diving tourism |
| AMQ | Ambon | Maluku | 7,500 ft | Low | Spice Islands |

### Pioneer Routes (Remote, subsidy eligible)

| Code | City | Island | Runway | Competition | Subsidy |
|------|------|--------|--------|-------------|---------|
| TIM | Timika | Papua | 6,000 ft | None | Yes |
| DJJ | Jayapura | Papua | 7,000 ft | Minimal | Yes |
| MKW | Manokwari | Papua | 5,000 ft | None | Yes |
| SOQ | Sorong | Papua | 5,500 ft | None | Yes |
| KOE | Kupang | Timor | 7,000 ft | Low | Yes |
| MOF | Maumere | Flores | 4,500 ft | None | Yes |
| LBJ | Labuan Bajo | Flores | 4,000 ft | None | Yes (Komodo) |
| WGP | Waingapu | Sumba | 4,000 ft | None | Yes |
| TMC | Tambolaka | Sumba | 4,500 ft | None | Yes |
| ENE | Ende | Flores | 4,000 ft | None | Yes |
| RTI | Roti | Roti | 3,000 ft | None | Yes |
| SWQ | Sumbawa | Sumbawa | 4,500 ft | None | Yes |
| BMU | Bima | Sumbawa | 5,000 ft | None | Yes |

### Tourism Destinations

| Code | City | Island | Runway | Tourism Type | Seasonality |
|------|------|--------|--------|--------------|-------------|
| DPS | Bali | Bali | 10,000 ft | Beach/Culture | Year-round |
| LOP | Lombok | Lombok | 8,000 ft | Beach/Hiking | Year-round |
| LBJ | Labuan Bajo | Flores | 4,000 ft | Komodo dragons | Dry season |
| MDC | Manado | Sulawesi | 8,000 ft | Diving | Year-round |
| JOG | Yogyakarta | Java | 6,000 ft | Temples | Year-round |
| PDG | Padang | Sumatra | 8,000 ft | Surfing | Apr-Oct |

## AI Competitors

| Airline | Type | Strategy | Home Base | Threat |
|---------|------|----------|-----------|--------|
| **Garuda Indonesia** | State | Premium trunk | Jakarta | Very High |
| **Merpati Nusantara** | State | Pioneer routes | Jakarta | Medium |
| **Sempati Air** | Private | Aggressive growth | Jakarta | High |
| **Bouraq** | Private | Regional | Makassar | Medium |
| **Mandala** | Private | Budget | Jakarta | Medium |

## Mission Structure (Detailed)

### Phase 1: "Air Bridge Builder" (1990-1991)

**Objectives:**
1. Establish subsidized service to 10 remote islands
2. Maintain government subsidy contract
3. Achieve 70% reliability (on-time departures)

**Rewards:**
- Government subsidy renewal ($200K/year)
- Pioneer route protection (no competition for 2 years)
- Reputation: "Lifeline of the islands"

**Guidance:**
- Focus on Twin Otter operations
- Target underserved Nusa Tenggara islands
- Build local community relationships

### Phase 2: "Proving Profitability" (1992-1993)

**Objectives:**
1. Achieve profitability on 5 routes without subsidies
2. Upgrade to at least 3 aircraft
3. Enter the tourism market (Bali connection)

**Rewards:**
- Jet aircraft licenses (deregulation benefit)
- Bank financing at improved rates
- Tourism board partnership

**Unlocks:**
- Regional jet purchases available
- Bali route rights

### Phase 3: "Tourism Takeoff" (1994-1996)

**Objectives:**
1. Establish Bali service from 5+ origins
2. Achieve premium pricing on tourist routes
3. Launch seasonal charter operations

**Rewards:**
- Hotel partnership deals
- International codeshare eligibility
- Reputation: "Gateway to Paradise"

### Phase 4: "Crisis Survival" (1997-1998)

**Objectives:**
1. Survive Asian Financial Crisis without bankruptcy
2. Maintain at least 50% of routes operational
3. Avoid any safety incidents

**Rewards:**
- Government support package
- Failed competitor routes available
- Reputation: "Survivor"

**Challenges:**
- Revenue drops 40%
- Fuel costs spike (priced in USD)
- Tourism collapses
- Political instability

### Phase 5: "Island Empire" (1999-2000)

**Objectives:**
1. Reach 100 islands served with scheduled flights
2. Achieve 30% domestic market share
3. Recover to pre-crisis profitability

**Rewards:**
- Campaign victory
- Unlock sandbox with established network
- Achievement: "Archipelago Champion"

---

# Appendix: Worth Exploring

## Additional Campaign Ideas

1. **"The Gulf Tigers"** (Middle East, 1985-2000)
   - Play as early Emirates/Qatar Airways
   - Transform desert stopover into global hub
   - Key mechanics: Luxury positioning, transit traffic

2. **"Atlantic Bridge"** (Europe, 1990-2005)
   - Low-cost revolution in Europe
   - Play as Ryanair/EasyJet-style disruptor
   - Key mechanics: Secondary airports, no frills

3. **"Dragon Rising"** (China, 2000-2015)
   - Explosive growth of Chinese domestic aviation
   - Navigate state control while growing
   - Key mechanics: Government relations, rapid scaling

## Cross-Campaign Features

- **Unlock System:** Complete campaigns to unlock aircraft, liveries, or sandbox bonuses
- **Historical Achievements:** Special recognition for historically accurate play
- **What-If Scenarios:** Alternative history paths (e.g., "What if Braniff survived?")
- **Difficulty Modifiers:** Adjust economic volatility, competitor aggression, event frequency

## Seasonal Events (All Campaigns)

Consider adding rotating seasonal events:
- **Hajj Season** (Indonesia): Massive spike in Middle East demand
- **Chinese New Year** (Silk Road): Asia travel surge
- **Summer Vacation** (USA): Leisure travel peaks
- **Holiday Season** (All): November-December traffic boom

---

**Document End**
