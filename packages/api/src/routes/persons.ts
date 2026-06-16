import type { FastifyInstance } from "fastify";
import { prisma } from "../lib/prisma.js";

export async function personsRoutes(fastify: FastifyInstance) {
  fastify.get("/", async (request) => {
    const { role } = request.query as { role?: string };
    const data = await prisma.person.findMany({
      where: role ? { role: role as never } : undefined,
    });
    return { data };
  });

  fastify.get<{ Params: { id: string } }>("/:id", async (request, reply) => {
    const person = await prisma.person.findUnique({ where: { id: request.params.id } });
    if (!person) return reply.status(404).send({ code: "NOT_FOUND", message: "Person not found" });
    return { data: person };
  });

  fastify.post<{ Body: Record<string, unknown> }>("/", async (request, reply) => {
    const person = await prisma.person.create({ data: request.body as never });
    return reply.status(201).send({ data: person });
  });
}
