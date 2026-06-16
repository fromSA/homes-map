import Fastify from "fastify";
import cors from "@fastify/cors";
import jwt from "@fastify/jwt";
import swagger from "@fastify/swagger";
import swaggerUi from "@fastify/swagger-ui";
import { propertiesRoutes } from "./routes/properties.js";
import { personsRoutes } from "./routes/persons.js";
import { contractsRoutes } from "./routes/contracts.js";
import { paymentsRoutes } from "./routes/payments.js";
import { maintenanceRoutes } from "./routes/maintenance.js";
import { healthRoutes } from "./routes/health.js";

const server = Fastify({ logger: true });

await server.register(cors, {
  origin: process.env.CORS_ORIGIN ?? "http://localhost:5173",
});

await server.register(jwt, {
  secret: process.env.JWT_SECRET ?? "dev-secret",
});

await server.register(swagger, {
  openapi: {
    info: {
      title: "homes-map API",
      description: "Property management API — simplifying tenant, landlord, and bank interactions",
      version: "0.1.0",
    },
  },
});

await server.register(swaggerUi, { routePrefix: "/docs" });

// Routes
await server.register(healthRoutes, { prefix: "/health" });
await server.register(propertiesRoutes, { prefix: "/api/properties" });
await server.register(personsRoutes, { prefix: "/api/persons" });
await server.register(contractsRoutes, { prefix: "/api/contracts" });
await server.register(paymentsRoutes, { prefix: "/api/payments" });
await server.register(maintenanceRoutes, { prefix: "/api/maintenance" });

const port = Number(process.env.PORT ?? 3000);
await server.listen({ port, host: "0.0.0.0" });
