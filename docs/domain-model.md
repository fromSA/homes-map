# Domain Model

homes-map models the property ecosystem using a **stocks & flows** framework, treating the property lifecycle as a dynamic system.

---

## Stocks

Stocks are the *things that accumulate* — they have a measurable quantity at any point in time.

| Stock | Entity | Key attributes |
|---|---|---|
| **Property** | `Property` | type, area, energy rating, address |
| **Unit** | `Unit` | label, area, floor, bedrooms |
| **Person** | `Person` | name, email, role (tenant/landlord/bank/agent) |
| **Ownership** | `Ownership` | owner ↔ property, type (freehold/leasehold/mortgage), share % |
| **Money** | modelled in `Payment`, `Contract.rentAmount`, etc. | amount, currency |
| **Contract** | `Contract` | links landlord, tenant, (bank), property, unit |

---

## Flows

Flows are *movements between stocks* — they cause stocks to increase or decrease.

| Flow | Entity | Moves between |
|---|---|---|
| **Rent payment** | `Payment` (description="rent") | Tenant money → Landlord money |
| **Mortgage payment** | `Payment` (description="mortgage") | Owner money → Bank money |
| **Ownership transfer** | `Ownership` (releasedAt + new record) | Seller ownership → Buyer ownership |
| **Maintenance work** | `MaintenanceRequest` | Property condition stock |
| **Energy consumption** | `EnergyReading` | Property energy stock |
| **Documents / information** | `Document` | Attached to `Contract` |

---

## Flow Rates

Flow rates are *how fast flows happen* — they determine system dynamics.

| Rate | Derived from | Endpoint |
|---|---|---|
| **Payment on-time %** | `Payment.paidAt` vs `dueDate` | `GET /api/properties/:id/flow-rates` |
| **Avg. maintenance resolution** | `MaintenanceRequest.resolvedAt - createdAt` | same |
| **Energy efficiency** | latest `EnergyReading.readingKWh / property.totalAreaM2` | same |
| **Rent cadence** | `Contract.noticePeriodDays`, payment history | future |
| **Ownership transfer speed** | gap between `Ownership.releasedAt` and next `acquiredAt` | future |

---

## Party Roles & Permissions

| Role | Can read | Can write |
|---|---|---|
| `tenant` | Own contracts, payments, maintenance | Create maintenance requests, upload docs |
| `landlord` | All owned properties, all related contracts | Create/update contracts, properties, payments |
| `bank` | Contracts where `bankId = self` | Update payment status |
| `agent` | Assigned properties | Create/update properties, units |

---

## Glossary

| Term | Definition |
|---|---|
| **Hybel** | Norwegian: a small self-contained unit, typically in a shared house |
| **Flow rate** | Speed or frequency at which a flow changes a stock |
| **Freehold** | Outright ownership with no expiry |
| **Leasehold** | Ownership for a defined term |
