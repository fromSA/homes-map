# Contributing to homes-map

Thank you for your interest in contributing!

## Development Setup

```bash
# Install dependencies
pnpm install

# Copy API env
cp packages/api/.env.example packages/api/.env
# Edit DATABASE_URL in .env

# Run database migrations
pnpm --filter @homes-map/api db:migrate

# Seed dev data
pnpm --filter @homes-map/api db:seed

# Start everything
pnpm dev
```

## Workflow

1. Pick or create an issue
2. Create a branch: `git checkout -b feat/your-feature`
3. Make your changes
4. Run `pnpm typecheck` and `pnpm test`
5. Open a pull request against `develop`

## Conventions

- **Branches**: `feat/`, `fix/`, `chore/`, `docs/`
- **Commits**: use conventional commit format — `feat:`, `fix:`, `chore:`, `docs:`
- **Types**: all cross-package types live in `@homes-map/shared`
- **Database changes**: always create a Prisma migration — never edit the DB directly

## Code Style

- TypeScript strict mode everywhere
- `prettier` for formatting — run `pnpm format` before committing
- Avoid `any`; prefer `unknown` at boundaries
