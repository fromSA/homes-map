# homes-map

> **Simplify the interaction between tenants, landlords, and banks about a property.**

homes-map models a property ecosystem as a system of **stocks**, **flows**, and **flow rates** — making it transparent, fast, and auditable for every party involved.

---

## Concept

### Stocks (what exists)
| Stock | Description |
|---|---|
| **Property** | House, apartment, hybel, studio, etc. |
| **People** | Tenants, landlords, bank officers |
| **Ownership** | Who holds title or lease on a unit |
| **Money** | Accounts, balances, escrow |
| **Contracts** | Lease agreements, mortgage terms |
| **Rooms / Units** | Sub-units within a property |

### Flows (what moves between stocks)
| Flow | Description |
|---|---|
| **Ownership transfer** | Title moves from owner → buyer, or landlord assigns lease |
| **Rent / mortgage payment** | Money moves tenant → landlord → bank |
| **Maintenance request** | Work order created, assigned, resolved |
| **Information / documents** | Lease docs, inspection reports, energy readings |
| **Energy readings** | Consumption data flows from property to all parties |

### Flow Rates (how fast things move)
| Rate | Description |
|---|---|
| **Payment cadence** | Monthly, weekly, one-off; automated or manual |
| **Ownership transfer speed** | Days from offer to title change |
| **Maintenance response time** | Time from request to resolution |
| **Energy efficiency index** | kWh/m² — how optimally the property uses energy |

---

## Architecture

```
homes-map/
├── packages/
│   ├── api/          # Fastify + Prisma REST/WebSocket API
│   ├── web/          # React + Vite frontend
│   └── shared/       # Shared TypeScript types & domain constants
├── docs/
│   ├── domain-model.md
│   └── adr/          # Architecture Decision Records
└── .github/
    ├── workflows/    # CI / CD
    └── ISSUE_TEMPLATE/
```

## Tech Stack

| Layer | Technology |
|---|---|
| API | Node.js · TypeScript · Fastify · Prisma ORM |
| Database | PostgreSQL |
| Frontend | React · TypeScript · Vite · TailwindCSS |
| Auth | JWT (access + refresh tokens) |
| Monorepo | pnpm workspaces |
| CI/CD | GitHub Actions |

---

## Getting Started

### Prerequisites
- Node.js ≥ 20
- pnpm ≥ 9
- PostgreSQL ≥ 15 (or Docker)

### Install

```bash
pnpm install
```

### Configure environment

```bash
cp packages/api/.env.example packages/api/.env
# Edit DATABASE_URL, JWT_SECRET, etc.
```

### Database

```bash
pnpm --filter @homes-map/api db:migrate
pnpm --filter @homes-map/api db:seed
```

### Dev

```bash
pnpm dev          # starts API + web in parallel
```

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Issues and PRs are welcome.

## License

MIT
