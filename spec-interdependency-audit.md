# Specification Interdependency Audit v2

**Date:** January 2026  
**Status:** ✅ ALL DEPENDENCIES RESOLVED

---

## Dependency Matrix

### Legend
- ✅ = Dependency satisfied
- 🔗 = Cross-reference exists
- ➡️ = One-way dependency (row depends on column)

### Core Documents

|  | GDD | Data Model | Art Bible | Econ Params |
|--|-----|------------|-----------|-------------|
| **GDD** | — | 🔗 | 🔗 | 🔗 |
| **Data Model** | ➡️ | — | | |
| **Art Bible** | ➡️ | | — | |
| **Econ Params** | ➡️ | 🔗 | | — |

### System Specifications

| Spec | Depends On | Provides To |
|------|------------|-------------|
| cabin-designer | GDD §15.8, data-model | service-suppliers, living-flight |
| service-suppliers | data-model | cabin-designer, route-economics |
| network-scheduler | data-model, route-economics | crew-management, maintenance |
| route-economics | data-model, econ-params | financial-model, ai-competitors |
| financial-model | data-model, econ-params, route-economics | governance |
| fleet-market | data-model, econ-params | financial-model, maintenance |
| maintenance | data-model, fleet-market | network-scheduler |
| crew-management | data-model | network-scheduler, living-flight |
| ai-competitors | data-model, route-economics | world-events |
| brand-marketing | data-model | route-economics |
| governance | data-model, financial-model | executive-delegation |
| executive-delegation | data-model, governance | all delegation-aware specs |
| living-flight | cabin-designer, crew-management, service-suppliers | — (observation only) |
| world-events | data-model, ai-competitors, financial-model | all gameplay specs |
| tutorial | GDD, FTUE | — (meta-system) |

---

## Cross-Reference Verification

### cabin-designer-spec.md
| Reference | Target | Status |
|-----------|--------|--------|
| AircraftConfiguration entity | data-model.md | ✅ |
| SeatType enum | data-model.md | ✅ |
| Service profiles | service-suppliers-spec.md | ✅ |

### service-suppliers-spec.md
| Reference | Target | Status |
|-----------|--------|--------|
| SupplierContract entity | data-model.md | ✅ |
| ServiceProfile entity | data-model.md | ✅ |
| Cabin classes | cabin-designer-spec.md | ✅ |

### network-scheduler-spec.md
| Reference | Target | Status |
|-----------|--------|--------|
| Route, Schedule, Flight entities | data-model.md | ✅ |
| Slot entity (extended) | data-model-addendum.md | ✅ |
| CrewPool constraints | crew-management-spec.md | ✅ |
| Maintenance windows | maintenance-spec.md | ✅ |

### route-economics-spec.md
| Reference | Target | Status |
|-----------|--------|--------|
| Route, DemandSnapshot entities | data-model.md | ✅ |
| CompetitorRoute entity | data-model-addendum.md | ✅ |
| AncillaryProduct, AncillaryPolicy | data-model-addendum.md | ✅ |
| CargoContract entity | data-model-addendum.md | ✅ |
| Era-specific pricing | economic-parameters.md | ✅ |

### financial-model-spec.md
| Reference | Target | Status |
|-----------|--------|--------|
| FinancialStatement, Loan entities | data-model.md | ✅ |
| FuelHedge entity (extended) | data-model-addendum.md | ✅ |
| Revenue inputs | route-economics-spec.md | ✅ |
| Cost inputs | economic-parameters.md | ✅ |

### fleet-market-spec.md
| Reference | Target | Status |
|-----------|--------|--------|
| Aircraft, Order, Lease entities | data-model.md | ✅ |
| AircraftListing entity | data-model-addendum.md | ✅ |
| ManufacturerRelationship entity | data-model-addendum.md | ✅ |
| Aircraft pricing | economic-parameters.md | ✅ |

### maintenance-spec.md
| Reference | Target | Status |
|-----------|--------|--------|
| MaintenanceEvent, MaintenanceSchedule | data-model.md | ✅ |
| Aircraft condition | fleet-market-spec.md | ✅ |
| Schedule integration | network-scheduler-spec.md | ✅ |

### crew-management-spec.md
| Reference | Target | Status |
|-----------|--------|--------|
| CrewPool entity | data-model.md | ✅ |
| KeyCrewMember entity | data-model-addendum.md | ✅ |
| Duty time rules | network-scheduler-spec.md | ✅ |

### ai-competitors-spec.md
| Reference | Target | Status |
|-----------|--------|--------|
| Airline, AIStrategy entities | data-model.md | ✅ |
| CompetitorRelationship entity | data-model.md | ✅ |
| Alliance, AllianceMembership, Codeshare | data-model-addendum.md | ✅ |
| Route economics inputs | route-economics-spec.md | ✅ |

### brand-marketing-spec.md
| Reference | Target | Status |
|-----------|--------|--------|
| Brand, PassengerSegment entities | data-model.md | ✅ |
| MarketingCampaign, ReputationEvent | data-model-addendum.md | ✅ |
| Service quality | service-suppliers-spec.md | ✅ |

### governance-spec.md
| Reference | Target | Status |
|-----------|--------|--------|
| OwnershipStake, Investor, BoardMember | data-model.md | ✅ |
| Stakeholder entity | data-model.md | ✅ |
| Financial health | financial-model-spec.md | ✅ |

### executive-delegation-spec.md
| Reference | Target | Status |
|-----------|--------|--------|
| Executive entity | data-model.md | ✅ |
| DelegationLevel enum | data-model-addendum.md | ✅ |
| Policy entity | data-model.md | ✅ |
| Board interactions | governance-spec.md | ✅ |

### living-flight-spec.md
| Reference | Target | Status |
|-----------|--------|--------|
| Cabin layout | cabin-designer-spec.md | ✅ |
| Service phases | service-suppliers-spec.md | ✅ |
| Crew display | crew-management-spec.md | ✅ |
| PassengerMood enum | living-flight-spec.md (internal) | ✅ |

### world-events-spec.md
| Reference | Target | Status |
|-----------|--------|--------|
| WorldEvent entity | data-model.md | ✅ |
| EconomicCycle entity | data-model.md | ✅ |
| Competitor actions | ai-competitors-spec.md | ✅ |
| Financial impacts | financial-model-spec.md | ✅ |

### tutorial-spec.md
| Reference | Target | Status |
|-----------|--------|--------|
| FTUE flow | FTUE_Endless_Mode.md | ✅ |
| Progressive disclosure | GDD §9 | ✅ |
| All systems (for tips) | All specs | ✅ |

---

## Entity Ownership

| Entity | Primary Spec | Also Referenced In |
|--------|--------------|-------------------|
| Aircraft | data-model | fleet-market, maintenance |
| Route | data-model | route-economics, network-scheduler |
| Flight | data-model | network-scheduler, living-flight |
| CrewPool | data-model | crew-management |
| KeyCrewMember | data-model-addendum | crew-management |
| FinancialStatement | data-model | financial-model, governance |
| FuelHedge | data-model-addendum | financial-model |
| Slot | data-model-addendum | network-scheduler |
| SupplierContract | data-model | service-suppliers |
| ServiceProfile | data-model | service-suppliers, cabin-designer |
| Executive | data-model | executive-delegation, governance |
| WorldEvent | data-model | world-events |
| CargoContract | data-model-addendum | route-economics |
| Alliance | data-model-addendum | ai-competitors |
| Codeshare | data-model-addendum | ai-competitors |
| MarketingCampaign | data-model-addendum | brand-marketing |

---

## Circular Dependency Check

| Potential Cycle | Resolution |
|-----------------|------------|
| route-economics ↔ ai-competitors | ✅ Resolved: route-economics provides inputs, ai-competitors consumes |
| financial-model ↔ governance | ✅ Resolved: financial-model provides health, governance consumes |
| network-scheduler ↔ maintenance | ✅ Resolved: network reads maintenance windows, maintenance reads schedule gaps |
| cabin-designer ↔ service-suppliers | ✅ Resolved: cabin-designer defines space, service-suppliers fills it |

**No unresolved circular dependencies.**

---

## Missing Dependencies (None)

All specs that need data from other specs have documented cross-references.

---

## Orphaned Content (None)

All entities in data-model.md and data-model-addendum.md are referenced by at least one spec.

---

## Recommendations

### Completed
- ✅ All dependency gaps closed
- ✅ All entity references verified
- ✅ All cross-references documented
- ✅ No orphaned content

### Maintenance Guidelines

1. **When adding a new spec:**
   - Update GDD companion list
   - Add entities to data-model-addendum
   - Document dependencies in this audit

2. **When modifying an entity:**
   - Check "Also Referenced In" column
   - Update all dependent specs

3. **When removing a spec:**
   - Verify no other specs depend on it
   - Remove from GDD companion list
   - Archive rather than delete

---

## Audit History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | January 2026 | Initial interdependency audit |
| 2.0 | January 2026 | Full refresh after SHOULD FIX completion. Added living-flight, world-events, tutorial dependencies. Verified all alliance/cargo/crew entities. |
