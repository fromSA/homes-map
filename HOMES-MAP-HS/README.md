# HOMES-MAP-HS

Haskell rebuild of homes-map.

Goal: simplify interaction between tenants, landlords, and the bank around a property.

## Domain framing

- Stocks: property, units, people, ownership, money, contracts.
- Flows: ownership transfer, payment transfer, maintenance and information transfer.
- Flow rates: payment timeliness, maintenance resolution speed, energy efficiency.

## Tech

- GHC + Cabal
- Servant + Warp for HTTP API
- Aeson for JSON
- Hspec for tests

## Run

1. Build:

   cabal build

2. Run API:

   cabal run homes-map-hs

3. Run tests:

   cabal test

By default the API starts on port 8080.

## API routes

- GET /health
- GET /properties
- GET /properties/:id/flow-rates

The current implementation ships with sample in-memory data to validate the model and API shape.
