import type { FastifyInstance } from "fastify";
import { prisma } from "../lib/prisma.js";

export async function contractsRoutes(fastify: FastifyInstance) {
  fastify.get("/", async (request) => {
    const { status } = request.query as { status?: string };
    const data = await prisma.contract.findMany({
      where: status ? { status: status as never } : undefined,
      include: { property: true, landlord: true, tenant: true },
    });
    return { data };
  });

  fastify.get<{ Params: { id: string } }>("/:id", async (request, reply) => {
    const contract = await prisma.contract.findUnique({
      where: { id: request.params.id },
      include: { property: true, unit: true, landlord: true, tenant: true, payments: true, documents: true },
    });
    if (!contract) return reply.status(404).send({ code: "NOT_FOUND", message: "Contract not found" });
    return { data: contract };
  });

  fastify.post<{ Body: Record<string, unknown> }>("/", async (request, reply) => {
    const contract = await prisma.contract.create({ data: request.body as never });
    return reply.status(201).send({ data: contract });
  });

  fastify.patch<{ Params: { id: string }; Body: { status: string } }>("/:id/status", async (request, reply) => {
    const contract = await prisma.contract.update({
      where: { id: request.params.id },
      data: { status: request.body.status as never },
    });
    return { data: contract };
  });
}
