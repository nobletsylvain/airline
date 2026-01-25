# Financial Model — Detailed Specification

**Version:** 0.1  
**Date:** January 2026  
**Companion to:** Game Design Document v0.7, Economic Parameters v0.1

---

## Overview

This document specifies how money works in Airliner — revenue generation, cost structures, cash flow timing, financing, and the conditions that lead to success or bankruptcy.

**Design Philosophy:** Finances should feel consequential but not spreadsheet-intensive. Players make strategic financial decisions; the system handles accounting. Bankruptcy is a real threat, but always feels fair and preventable.

**Core Loop:** Operate → Generate revenue → Pay costs → Manage cash → Finance growth → Repeat

---

## 1. Financial Statements

### 1.1 Income Statement (P&L)

Weekly/Monthly/Quarterly summary:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  INCOME STATEMENT · Q3 2026                                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  REVENUE                                                                    │
│    Passenger revenue              $42,850,000     ████████████████ 82%     │
│    Cargo revenue                   $4,120,000     ███░░░░░░░░░░░░░  8%     │
│    Ancillary revenue               $5,230,000     ████░░░░░░░░░░░░ 10%     │
│    Other revenue                     $420,000     ░░░░░░░░░░░░░░░░  1%     │
│  TOTAL REVENUE                    $52,620,000                              │
│                                                                             │
│  OPERATING EXPENSES                                                         │
│    Fuel                           $14,210,000     ████████░░░░░░░░ 30%     │
│    Labor                          $12,840,000     ███████░░░░░░░░░ 27%     │
│    Aircraft ownership              $8,940,000     █████░░░░░░░░░░░ 19%     │
│    Maintenance                     $3,680,000     ██░░░░░░░░░░░░░░  8%     │
│    Landing & handling              $2,840,000     ██░░░░░░░░░░░░░░  6%     │
│    Sales & distribution            $2,120,000     █░░░░░░░░░░░░░░░  4%     │
│    General & admin                 $1,890,000     █░░░░░░░░░░░░░░░  4%     │
│    Other operating                   $940,000     █░░░░░░░░░░░░░░░  2%     │
│  TOTAL OPERATING EXPENSES         $47,460,000                              │
│                                                                             │
│  OPERATING INCOME (EBIT)           $5,160,000     Margin: 9.8%             │
│                                                                             │
│    Interest expense               ($1,240,000)                              │
│    Interest income                    $85,000                               │
│                                                                             │
│  PRE-TAX INCOME                    $4,005,000                              │
│    Income tax                     ($1,001,000)    25%                       │
│                                                                             │
│  NET INCOME                        $3,004,000     Margin: 5.7%    ● Good   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 1.2 Balance Sheet

Snapshot of financial position:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  BALANCE SHEET · September 30, 2026                                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ASSETS                              LIABILITIES & EQUITY                   │
│                                                                             │
│  Current Assets                      Current Liabilities                    │
│    Cash              $8,420,000        Accounts payable    $4,210,000      │
│    Receivables       $3,840,000        Accrued expenses    $2,840,000      │
│    Inventory           $920,000        Deferred revenue   $12,400,000      │
│    Prepaid expenses  $1,240,000        Current debt        $3,600,000      │
│  Total Current      $14,420,000      Total Current       $23,050,000      │
│                                                                             │
│  Non-Current Assets                  Non-Current Liabilities               │
│    Aircraft (owned) $82,400,000        Long-term debt     $48,200,000      │
│    Less: depreciation(18,200,000)      Lease obligations  $24,800,000      │
│    Other PP&E        $4,200,000        Other liabilities   $2,400,000      │
│    Intangibles       $2,800,000      Total Non-Current   $75,400,000      │
│  Total Non-Current  $71,200,000                                            │
│                                      EQUITY                                 │
│                                        Common stock       $12,000,000      │
│                                        Retained earnings ($24,830,000)     │
│                                      Total Equity        ($12,830,000)     │
│                                                                             │
│  TOTAL ASSETS       $85,620,000      TOTAL L&E          $85,620,000      │
│                                                                             │
│  KEY RATIOS                                                                 │
│  Current ratio: 0.63    Debt/Equity: N/A (negative equity)                 │
│  Cash runway: 8.2 weeks                                                    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 1.3 Cash Flow Statement

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  CASH FLOW · Q3 2026                                                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  OPERATING ACTIVITIES                                                       │
│    Net income                      $3,004,000                               │
│    Depreciation                    $2,840,000                               │
│    Change in receivables            ($420,000)                              │
│    Change in payables                $380,000                               │
│    Change in deferred revenue      $1,200,000                               │
│  Net Cash from Operations          $7,004,000                               │
│                                                                             │
│  INVESTING ACTIVITIES                                                       │
│    Aircraft purchases            ($24,000,000)                              │
│    Aircraft sales                  $8,400,000                               │
│    Other capital expenditures        ($840,000)                             │
│  Net Cash from Investing         ($16,440,000)                              │
│                                                                             │
│  FINANCING ACTIVITIES                                                       │
│    Debt proceeds                  $12,000,000                               │
│    Debt repayments                ($3,200,000)                              │
│    Lease payments                 ($2,400,000)                              │
│  Net Cash from Financing           $6,400,000                               │
│                                                                             │
│  NET CHANGE IN CASH               ($3,036,000)                              │
│  Beginning cash                   $11,456,000                               │
│  ENDING CASH                       $8,420,000                               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Revenue Categories

### 2.1 Passenger Revenue

Primary revenue source (75-90% of total):

| Component | Description | Timing |
|-----------|-------------|--------|
| Ticket sales | Base fare | Recognized at flight completion |
| Fare classes | Premium vs economy | Varies by class mix |
| Yield management | Dynamic pricing effects | Depends on booking curve |

### 2.2 Ancillary Revenue

Growing secondary source (5-25%):

| Category | Examples | Margin |
|----------|----------|--------|
| Baggage fees | Checked bags, overweight | 90%+ |
| Seat selection | Premium seats, extra legroom | 95%+ |
| Onboard sales | Food, duty-free | 40-60% |
| Change/cancel fees | Booking modifications | 100% |
| FFP revenue | Miles sales to partners | 70-80% |

### 2.3 Cargo Revenue

Belly cargo on passenger aircraft (5-15%):

| Factor | Impact |
|--------|--------|
| Aircraft type | Widebody > Narrowbody |
| Route type | Long-haul > Short-haul |
| Competition | Dedicated freighters reduce rates |
| Seasonality | Peaks in Q4 |

### 2.4 Other Revenue

Miscellaneous sources:

| Source | Notes |
|--------|-------|
| Codeshare fees | Revenue from partner bookings |
| Wet lease income | Leasing aircraft with crew |
| Maintenance services | MRO for other airlines |
| Catering sales | To other carriers |

---

## 3. Cost Categories

### 3.1 Variable Costs

Scale with operations:

| Category | Driver | % of Total | Notes |
|----------|--------|------------|-------|
| **Fuel** | Block hours × consumption | 20-35% | Most volatile |
| **Landing fees** | Departures × airport rate | 3-6% | Varies by airport |
| **Navigation fees** | Distance × rate | 2-4% | Regional variations |
| **Ground handling** | Turnarounds × rate | 3-5% | Outsourced typically |
| **Passenger services** | Pax × per-pax cost | 2-5% | Catering, supplies |
| **Crew variable** | Block hours × rate | 5-8% | Per-diem, overtime |

### 3.2 Semi-Variable Costs

Step-function with capacity:

| Category | Driver | Notes |
|----------|--------|-------|
| **Crew fixed** | Fleet size × crew ratio | Hiring is lumpy |
| **Maintenance** | Hours + cycles | Predictable scheduling |
| **Sales & distribution** | Revenue × rate | GDS fees, commissions |

### 3.3 Fixed Costs

Don't change with short-term operations:

| Category | Driver | Notes |
|----------|--------|-------|
| **Aircraft ownership** | Fleet × (depreciation + interest) | Or lease payments |
| **Overhead** | Organization size | HQ, IT, insurance |
| **Slots & gates** | Airport commitments | Use-it-or-lose-it |
| **Training** | Fleet complexity + growth | Required investment |

### 3.4 Cost Structure by Airline Type

| Cost Category | Legacy | LCC | Regional |
|---------------|--------|-----|----------|
| Fuel | 25% | 30% | 20% |
| Labor | 30% | 22% | 28% |
| Aircraft | 18% | 20% | 22% |
| Maintenance | 10% | 8% | 12% |
| Distribution | 8% | 4% | 6% |
| Other | 9% | 16% | 12% |

---

## 4. Cash Flow Timing

### 4.1 Revenue Timing

| Event | Cash Impact | Timing |
|-------|-------------|--------|
| Booking | Deferred revenue (liability) | Immediate |
| Flight operated | Revenue recognized | Flight date |
| Refund request | Cash outflow | 7-30 days |
| Cargo payment | Revenue | 30-60 days after |
| Partner settlements | Net cash | Monthly |

### 4.2 Cost Timing

| Cost | Payment Terms | Cash Impact |
|------|---------------|-------------|
| Fuel | 7-30 days | Quick drain |
| Crew payroll | Bi-weekly | Steady outflow |
| Landing fees | Monthly invoice | 30 days |
| Lease payments | Monthly | Fixed outflow |
| Maintenance | On completion | Lumpy |
| Insurance | Quarterly/annual | Large periodic |
| Debt service | Monthly | Fixed outflow |

### 4.3 Working Capital

```
Working Capital = Current Assets - Current Liabilities
```

**Key insight:** Airlines often have negative working capital because:
- Tickets are paid before travel (deferred revenue = liability)
- Suppliers are paid after services (accounts payable)

This means growth can be self-funding... until demand drops.

---

## 5. Financing Options

### 5.1 Debt Financing

| Type | Use Case | Terms | Covenants |
|------|----------|-------|-----------|
| **Bank loan** | Working capital, general | Prime + 2-4%, 5-7 years | Debt/EBITDA, minimum cash |
| **Aircraft loan** | Aircraft purchase | Prime + 1-3%, 10-12 years | Aircraft as collateral |
| **Revolving credit** | Liquidity buffer | Prime + 2-5%, draw as needed | Utilization limits |
| **Bonds** | Large capital needs | Fixed rate, 7-15 years | Coverage ratios |

### 5.2 Lease Financing

| Type | Description | Accounting | Typical Terms |
|------|-------------|------------|---------------|
| **Operating lease** | Rent aircraft, return at end | Off-balance sheet* | 3-12 years |
| **Finance lease** | Effective ownership transfer | On balance sheet | 12-20 years |
| **Sale-leaseback** | Sell owned, lease back | Cash injection | 8-15 years |

*Note: Modern accounting (IFRS 16) puts operating leases on balance sheet

### 5.3 Equity Financing

| Type | Description | Cost | Control Impact |
|------|-------------|------|----------------|
| **Private placement** | Sell shares to investors | 15-25% expected return | Dilution |
| **IPO** | Public stock offering | 12-20% expected return | Board oversight |
| **Rights issue** | Offer to existing shareholders | Below market | Proportional |
| **Strategic investor** | Industry partner | Value-add expected | Alliance implications |

### 5.4 Government Support

| Type | When Available | Strings Attached |
|------|----------------|------------------|
| **Loan guarantee** | Crisis periods | Route obligations |
| **Direct loan** | Strategic importance | Employment, hub commitments |
| **Subsidy** | Regional connectivity | PSO routes, reporting |
| **Bailout** | Too-big-to-fail | Management changes, restrictions |

---

## 6. Financial Health Metrics

### 6.1 Liquidity Ratios

| Metric | Formula | Healthy | Warning | Critical |
|--------|---------|---------|---------|----------|
| **Current ratio** | Current Assets / Current Liabilities | >1.0 | 0.7-1.0 | <0.7 |
| **Cash ratio** | Cash / Current Liabilities | >0.3 | 0.15-0.3 | <0.15 |
| **Cash runway** | Cash / Weekly Cash Burn | >12 weeks | 6-12 weeks | <6 weeks |

### 6.2 Leverage Ratios

| Metric | Formula | Healthy | Warning | Critical |
|--------|---------|---------|---------|----------|
| **Debt/Equity** | Total Debt / Equity | <2.0 | 2.0-4.0 | >4.0 |
| **Debt/EBITDA** | Total Debt / EBITDA | <3.0 | 3.0-5.0 | >5.0 |
| **Interest coverage** | EBIT / Interest Expense | >3.0 | 1.5-3.0 | <1.5 |

### 6.3 Profitability Ratios

| Metric | Formula | Good | Average | Poor |
|--------|---------|------|---------|------|
| **Operating margin** | EBIT / Revenue | >10% | 5-10% | <5% |
| **Net margin** | Net Income / Revenue | >5% | 2-5% | <2% |
| **ROIC** | EBIT × (1-tax) / Invested Capital | >10% | 5-10% | <5% |

### 6.4 Airline-Specific Metrics

| Metric | Formula | Target |
|--------|---------|--------|
| **CASK** | Operating Cost / ASK | Lower is better |
| **RASK** | Revenue / ASK | Higher is better |
| **PRASK** | Passenger Revenue / ASK | Core revenue measure |
| **Breakeven load factor** | (CASK × Seats) / (Yield × Distance) | Lower is better |

---

## 7. Debt Covenants

### 7.1 Common Covenants

| Covenant | Typical Threshold | Consequence if Breached |
|----------|-------------------|------------------------|
| **Minimum cash** | $X million or X months expenses | Default trigger |
| **Maximum leverage** | Debt/EBITDA < 4.0x | Default trigger |
| **Interest coverage** | EBIT/Interest > 2.0x | Default trigger |
| **Minimum net worth** | Equity > $X million | Default trigger |
| **Asset coverage** | Assets > 1.25x debt | Accelerated repayment |

### 7.2 Covenant Monitoring

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  COVENANT STATUS                                                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  FIRST NATIONAL BANK FACILITY ($25M)                                       │
│                                                                             │
│  Covenant                 Required    Actual      Status                   │
│  Minimum cash             $5.0M       $8.4M       ● Compliant (+68%)       │
│  Debt/EBITDA              <4.0x       3.2x        ● Compliant (20% buffer) │
│  Interest coverage        >2.0x       4.2x        ● Compliant              │
│                                                                             │
│  AIRCRAFT MORTGAGE - F-GKXA                                                 │
│                                                                             │
│  Covenant                 Required    Actual      Status                   │
│  Aircraft value coverage  >1.25x      1.42x       ● Compliant              │
│  Insurance maintained     Yes         Yes         ● Compliant              │
│                                                                             │
│  ⚠ WARNING: Debt/EBITDA projected to reach 3.8x next quarter              │
│  [View projections] [Covenant calculator]                                  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 8. Financial Distress

### 8.1 Warning Stages

| Stage | Indicators | Time to Crisis |
|-------|------------|----------------|
| **Watch** | Declining margins, rising debt | 6-12 months |
| **Concern** | Covenant pressure, cash tightening | 3-6 months |
| **Distress** | Covenant breach, payment delays | 1-3 months |
| **Crisis** | Cash exhausted, creditor action | Days-weeks |

### 8.2 Distress Indicators

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  ⚠ FINANCIAL HEALTH WARNING                                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  RISK LEVEL: ELEVATED                                                       │
│                                                                             │
│  Concerns:                                                                  │
│  ⚠ Cash runway: 7.2 weeks (target: >12)                                    │
│  ⚠ Operating losses: 3 consecutive months                                  │
│  ⚠ Debt/EBITDA: 3.8x (covenant limit: 4.0x)                               │
│                                                                             │
│  Projected outcomes if unchanged:                                           │
│  • Covenant breach in ~6 weeks                                             │
│  • Cash exhaustion in ~9 weeks                                             │
│                                                                             │
│  Recommended actions:                                                       │
│  1. Reduce capacity on unprofitable routes                                 │
│  2. Defer non-essential capital expenditure                                │
│  3. Negotiate extended payment terms with suppliers                        │
│  4. Consider asset sales or equity raise                                   │
│                                                                             │
│  [View turnaround options] [Request lender meeting] [Dismiss]              │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 8.3 Bankruptcy

When cash runs out or covenants breach without cure:

| Outcome | Trigger | Result |
|---------|---------|--------|
| **Restructuring** | Negotiate with creditors | Continue with new terms |
| **Sale** | Strategic buyer interested | Airline absorbed |
| **Liquidation** | No viable path forward | Game over |

---

## 9. Taxes

### 9.1 Corporate Tax

| Element | Rate | Notes |
|---------|------|-------|
| **Base rate** | 20-30% | Varies by jurisdiction |
| **Loss carryforward** | Unlimited | Offset future profits |
| **Depreciation shield** | Accelerated | Reduces taxable income |
| **Interest deduction** | Limited | Caps on interest expense |

### 9.2 Tax Planning

| Strategy | Effect | Risk |
|----------|--------|------|
| **Accelerated depreciation** | Defer taxes | Reverses later |
| **Lease vs buy** | Different treatment | Complexity |
| **Hub jurisdiction** | Lower rates | Regulatory scrutiny |
| **Transfer pricing** | Allocate profits | Audit risk |

---

## 10. Budgeting & Forecasting

### 10.1 Budget Process

Player can set annual budgets:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  BUDGET 2027                                                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  REVENUE ASSUMPTIONS                                                        │
│  Passenger growth:      [+8%  ]  (2026: +5%)                               │
│  Yield change:          [-2%  ]  (competitive pressure)                    │
│  Ancillary growth:      [+15% ]  (new products)                            │
│                                                                             │
│  COST ASSUMPTIONS                                                           │
│  Fuel price:            [$2.85] /gallon (current: $2.80)                   │
│  Labor inflation:       [+4%  ]                                            │
│  Fleet change:          [+2 aircraft]                                      │
│                                                                             │
│  PROJECTED RESULTS                                                          │
│  Revenue:               $228M    (+6% YoY)                                 │
│  Operating costs:       $208M    (+8% YoY)                                 │
│  Operating income:       $20M    (margin: 8.8%)                            │
│  Net income:             $12M    (margin: 5.3%)                            │
│                                                                             │
│  CAPITAL BUDGET                                                             │
│  Aircraft deliveries:   $65M     (2 × A320neo)                             │
│  Cabin refits:           $4M     (3 aircraft)                              │
│  Other CapEx:            $2M                                               │
│                                                                             │
│  FINANCING NEEDS                                                            │
│  Debt drawdown:         $45M     (aircraft loans)                          │
│  Cash from operations:  $22M                                               │
│                                                                             │
│  [Scenario analysis] [Approve budget] [Adjust]                             │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 10.2 Variance Tracking

System tracks actual vs budget:

| Metric | Budget | Actual | Variance | Alert |
|--------|--------|--------|----------|-------|
| Revenue | $52M | $50M | -4% | ⚠ |
| Fuel cost | $14M | $15M | +7% | ⚠ |
| Labor | $13M | $13M | 0% | ● |
| EBIT | $5M | $3M | -40% | ⚠ |

---

## 11. Data Model Integration

### 11.1 Financial Entities

**FinancialPeriod** — Period-based financial results

| Field | Type | Purpose |
|-------|------|---------|
| `airline_id` | FK | Airline reference |
| `period_type` | enum | WEEK / MONTH / QUARTER / YEAR |
| `period_start` | date | Period beginning |
| `period_end` | date | Period end |
| `revenue_passenger` | decimal | Pax revenue |
| `revenue_cargo` | decimal | Cargo revenue |
| `revenue_ancillary` | decimal | Ancillary revenue |
| `revenue_other` | decimal | Other revenue |
| `cost_fuel` | decimal | Fuel expense |
| `cost_labor` | decimal | Labor expense |
| `cost_aircraft` | decimal | Ownership/lease |
| `cost_maintenance` | decimal | MRO expense |
| `cost_distribution` | decimal | Sales expense |
| `cost_other` | decimal | Other operating |
| `ebit` | decimal | Operating income |
| `interest_expense` | decimal | Debt service |
| `net_income` | decimal | Bottom line |

**DebtFacility** — Loans and credit lines

| Field | Type | Purpose |
|-------|------|---------|
| `id` | UUID | Primary key |
| `airline_id` | FK | Borrower |
| `lender_name` | string | Bank/institution |
| `facility_type` | enum | TERM_LOAN / REVOLVER / AIRCRAFT_LOAN |
| `principal` | decimal | Original amount |
| `outstanding` | decimal | Current balance |
| `interest_rate` | float | Annual rate |
| `maturity_date` | date | Final payment due |
| `collateral` | json | Security details |
| `covenants` | json | Covenant terms |
| `covenant_status` | enum | COMPLIANT / WARNING / BREACHED |

**CashFlow** — Daily cash position tracking

| Field | Type | Purpose |
|-------|------|---------|
| `airline_id` | FK | Airline reference |
| `date` | date | Position date |
| `opening_cash` | decimal | Start of day |
| `inflows` | json | Cash received |
| `outflows` | json | Cash paid |
| `closing_cash` | decimal | End of day |

### 11.2 New Enumerations

```yaml
FacilityType:
  TERM_LOAN              # Fixed repayment schedule
  REVOLVING_CREDIT       # Draw and repay flexibly
  AIRCRAFT_LOAN          # Secured by aircraft
  BOND                   # Public debt
  CONVERTIBLE            # Converts to equity

CovenantStatus:
  COMPLIANT              # Within limits
  WARNING                # Close to breach
  BREACHED               # Violated
  WAIVED                 # Lender granted exception
  CURED                  # Previously breached, now fixed

FinancialHealth:
  EXCELLENT              # Strong cash, low debt
  GOOD                   # Comfortable position
  ADEQUATE               # Acceptable but tight
  STRESSED               # Concerning trends
  DISTRESSED             # Imminent risk
  CRISIS                 # Immediate action required
```

---

## 12. Fuel Hedging

### 12.1 Overview

Fuel is typically 20-35% of operating costs. Hedging provides cost certainty but may mean paying above market when prices fall.

### 12.2 Hedging Instruments

| Instrument | Complexity | Risk Profile | Cost |
|------------|------------|--------------|------|
| **Fixed-price contract** | Low | Full protection | Premium to spot |
| **Collar** | Medium | Band protection | Lower premium |
| **Call option** | Medium | Upside protection only | Option premium |
| **Swap** | High | Exchange fixed/floating | No upfront cost |

### 12.3 Hedging Strategy

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  FUEL HEDGING · 2026                                                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  CURRENT EXPOSURE                                                           │
│  Annual fuel consumption:     12.4M gallons                                │
│  Current spot price:          $2.85/gallon                                 │
│  Unhedged annual cost:        $35.3M                                       │
│                                                                             │
│  HEDGE POSITION                                                             │
│           Q1      Q2      Q3      Q4      2026                             │
│  Hedged   80%     65%     40%     20%     51%                              │
│  Avg rate $2.62   $2.68   $2.71   —       $2.66                            │
│  Saving   +$720K  +$410K  +$175K  —       +$1.3M                           │
│                                                                             │
│  HEDGE COVERAGE VISUALIZATION                                               │
│  100%│████████                                                             │
│   75%│████████████                                                         │
│   50%│████████████████                                                     │
│   25%│████████████████████                                                 │
│    0%└───────────────────────────                                          │
│       Q1     Q2     Q3     Q4                                              │
│                                                                             │
│  ADD NEW HEDGE                                                              │
│  Period: [Q4 2026    ▼]  Coverage: [50%       ]                            │
│  Type:   [Fixed price ▼]  Est. rate: $2.82/gal                             │
│  Volume: 1.55M gallons    Cost: $4.37M                                     │
│                                                                             │
│  [Execute hedge] [View market] [Hedge policy]                              │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 12.4 Hedge Policy Settings

| Policy | Coverage Target | Risk Level | Best For |
|--------|-----------------|------------|----------|
| **Conservative** | 70-80% 12mo ahead | Low | Stable cash flow priority |
| **Balanced** | 50-60% 12mo ahead | Medium | Most airlines |
| **Opportunistic** | 20-40% as needed | High | Speculative, cash-rich |
| **Unhedged** | 0% | Very high | Very small or desperate |

### 12.5 Hedging Economics

| Scenario | Hedge Position | Spot Rises 30% | Spot Falls 30% |
|----------|---------------|----------------|----------------|
| **Unhedged** | 0% | Costs +$10.6M | Costs -$10.6M |
| **50% hedged** | 50% @ $2.70 | Costs +$5.3M | Costs -$4.1M* |
| **80% hedged** | 80% @ $2.70 | Costs +$2.1M | Costs -$1.6M* |

*Loss limited by hedge premium already paid

### 12.6 Fuel Hedge Data Model

**FuelHedge entity:**

| Field | Type | Purpose |
|-------|------|---------|
| `id` | UUID | Primary key |
| `airline_id` | FK | Who hedged |
| `instrument_type` | enum | FIXED / COLLAR / CALL / SWAP |
| `coverage_pct` | float | % of consumption hedged |
| `price_per_gallon` | float | Locked/strike price |
| `ceiling_price` | float? | For collars |
| `floor_price` | float? | For collars |
| `premium_paid` | decimal | Upfront cost |
| `start_date` | date | Coverage start |
| `end_date` | date | Coverage end |
| `notional_gallons` | bigint | Volume covered |
| `counterparty` | string | Bank/trader |
| `status` | enum | ACTIVE / EXPIRED / EXERCISED |
| `realized_pnl` | decimal? | Final gain/loss |

---

## 13. Gameplay Implications

### 12.1 Financial Decisions

| Decision | Trade-off |
|----------|-----------|
| **Lease vs buy** | Flexibility vs cost |
| **Debt level** | Growth vs risk |
| **Dividend/reinvest** | Shareholders vs growth |
| **Hedge fuel** | Cost certainty vs opportunity |
| **Cash buffer** | Safety vs deployment |

### 12.2 Financial Events

| Event | Player Response Options |
|-------|------------------------|
| **Profitable quarter** | Reinvest, pay debt, dividend, acquire |
| **Loss quarter** | Cut costs, raise prices, defer capex, seek financing |
| **Covenant warning** | Cure via cash, negotiate waiver, asset sale |
| **Acquisition offer** | Accept, negotiate, reject |
| **Cash crisis** | Emergency financing, asset sale, restructure |

---

## Document History

| Version | Date | Changes |
|---------|------|---------|
| 0.1 | January 2026 | Initial specification |
| 0.2 | January 2026 | Added Section 12: Fuel Hedging |
