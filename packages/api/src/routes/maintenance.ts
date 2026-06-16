import type { FastifyInstance } from "fastify";
import { prisma } from "../lib/prisma.js";

export async function maintenanceRoutes(fastify: FastifyInstance) {
  fastify.get("/", async (request) => {
    const { propertyId, status, priority } = request.query as Record<string, string>;
    const data = await prisma.maintenanceRequest.findMany({
      where: {
        ...(propertyId ? { propertyId } : {}),
        ...(status ? { status: status as never } : {}),
        ...(priority ? { priority: priority as never } : {}),
      },
      include: { requestedBy: true, assignedTo: true },
      orderBy: { createdAt: "desc" },
    });
    return { data };
  });

  fastify.post<{ Body: Record<string, unknown> }>("/", async (request, reply) => {
    const request_ = await prisma.maintenanceRequest.create({ data: request.body as never });
    return reply.status(201).send({ data: request_ });
  });

  fastify.patch<{ Params: { id: string }; Body: Record<string, unknown> }>("/:id", async (request, reply) => {
    const updated = await prisma.maintenanceRequest.update({
      where: { id: request.params.id },
      data: request.body as never,
    });
    return { data: updated };
  });
}
