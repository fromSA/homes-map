import type { FastifyInstance } from "fastify";
import { prisma } from "../lib/prisma.js";

export async function paymentsRoutes(fastify: FastifyInstance) {
  fastify.get("/", async (request) => {
    const { contractId, status } = request.query as Record<string, string>;
    const data = await prisma.payment.findMany({
      where: {
        ...(contractId ? { contractId } : {}),
        ...(status ? { status: status as never } : {}),
      },
      orderBy: { dueDate: "asc" },
    });
    return { data };
  });

  fastify.post<{ Body: Record<string, unknown> }>("/", async (request, reply) => {
    const payment = await prisma.payment.create({ data: request.body as never });
    return reply.status(201).send({ data: payment });
  });

  fastify.patch<{ Params: { id: string }; Body: { status: string; paidAt?: string } }>(
    "/:id/status",
    async (request, reply) => {
      const payment = await prisma.payment.update({
        where: { id: request.params.id },
        data: {
          status: request.body.status as never,
          paidAt: request.body.paidAt ? new Date(request.body.paidAt) : undefined,
        },
      });
      return { data: payment };
    }
  );
}
