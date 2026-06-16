import type { FastifyInstance } from "fastify";
import { prisma } from "../lib/prisma.js";

export async function propertiesRoutes(fastify: FastifyInstance) {
  // GET /api/properties
  fastify.get("/", async (request, reply) => {
    const { page = "1", pageSize = "20" } = request.query as Record<string, string>;
    const skip = (Number(page) - 1) * Number(pageSize);
    const [data, total] = await Promise.all([
      prisma.property.findMany({ skip, take: Number(pageSize), include: { units: true } }),
      prisma.property.count(),
    ]);
    return { data, meta: { total, page: Number(page), pageSize: Number(pageSize) } };
  });

  // GET /api/properties/:id
  fastify.get<{ Params: { id: string } }>("/:id", async (request, reply) => {
    const property = await prisma.property.findUnique({
      where: { id: request.params.id },
      include: { units: true, ownerships: { include: { owner: true } } },
    });
    if (!property) return reply.status(404).send({ code: "NOT_FOUND", message: "Property not found" });
    return { data: property };
  });

  // POST /api/properties
  fastify.post<{ Body: Record<string, unknown> }>("/", async (request, reply) => {
    const property = await prisma.property.create({ data: request.body as never });
    return reply.status(201).send({ data: property });
  });

  // PATCH /api/properties/:id
  fastify.patch<{ Params: { id: string }; Body: Record<string, unknown> }>("/:id", async (request, reply) => {
    const property = await prisma.property.update({
      where: { id: request.params.id },
      data: request.body as never,
    });
    return { data: property };
  });

  // GET /api/properties/:id/flow-rates
  fastify.get<{ Params: { id: string } }>("/:id/flow-rates", async (request, reply) => {
    const id = request.params.id;

    const [payments, maintenance, energyReadings, property] = await Promise.all([
      prisma.payment.findMany({ where: { contract: { propertyId: id } } }),
      prisma.maintenanceRequest.findMany({ where: { propertyId: id } }),
      prisma.energyReading.findMany({ where: { propertyId: id }, orderBy: { readingDate: "asc" } }),
      prisma.property.findUnique({ where: { id } }),
    ]);

    if (!property) return reply.status(404).send({ code: "NOT_FOUND", message: "Property not found" });

    const completed = payments.filter((p) => p.status === "completed" && p.paidAt);
    const onTime = completed.filter((p) => p.paidAt! <= p.dueDate).length;
    const rentOnTimePct = completed.length ? (onTime / completed.length) * 100 : 0;

    const resolved = maintenance.filter((m) => m.resolvedAt);
    const avgResolutionMs = resolved.length
      ? resolved.reduce((sum, m) => sum + (m.resolvedAt!.getTime() - m.createdAt.getTime()), 0) / resolved.length
      : 0;

    const latestEnergy = energyReadings.at(-1);
    const energyEfficiency = latestEnergy ? latestEnergy.readingKWh / property.totalAreaM2 : null;

    return {
      data: {
        propertyId: id,
        rentPaymentOnTimePct,
        avgMaintenanceResolutionHours: avgResolutionMs / 1000 / 60 / 60,
        energyEfficiencyKWhPerM2: energyEfficiency,
      },
    };
  });
}
