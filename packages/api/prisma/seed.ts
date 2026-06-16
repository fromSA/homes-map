import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

async function main() {
  // Seed a landlord
  const landlord = await prisma.person.upsert({
    where: { email: "landlord@example.com" },
    update: {},
    create: {
      firstName: "Kari",
      lastName: "Nordmann",
      email: "landlord@example.com",
      role: "landlord",
    },
  });

  // Seed a tenant
  const tenant = await prisma.person.upsert({
    where: { email: "tenant@example.com" },
    update: {},
    create: {
      firstName: "Ola",
      lastName: "Hansen",
      email: "tenant@example.com",
      role: "tenant",
    },
  });

  // Seed a property
  const property = await prisma.property.upsert({
    where: { id: "seed-property-1" },
    update: {},
    create: {
      id: "seed-property-1",
      name: "Markveien 12",
      street: "Markveien 12",
      city: "Oslo",
      postalCode: "0554",
      country: "NO",
      type: "apartment",
      totalAreaM2: 65,
      energyRating: "C",
    },
  });

  // Seed ownership
  await prisma.ownership.upsert({
    where: { id: "seed-ownership-1" },
    update: {},
    create: {
      id: "seed-ownership-1",
      propertyId: property.id,
      ownerId: landlord.id,
      type: "freehold",
      sharePercent: 100,
      acquiredAt: new Date("2020-01-01"),
    },
  });

  // Seed a unit
  const unit = await prisma.unit.upsert({
    where: { id: "seed-unit-1" },
    update: {},
    create: {
      id: "seed-unit-1",
      propertyId: property.id,
      label: "Leilighet 1",
      areaM2: 65,
      floor: 2,
      bedroomCount: 2,
    },
  });

  // Seed a contract
  await prisma.contract.upsert({
    where: { id: "seed-contract-1" },
    update: {},
    create: {
      id: "seed-contract-1",
      propertyId: property.id,
      unitId: unit.id,
      landlordId: landlord.id,
      tenantId: tenant.id,
      status: "active",
      rentAmount: 12500,
      rentCurrency: "NOK",
      depositAmount: 37500,
      depositCurrency: "NOK",
      startDate: new Date("2024-01-01"),
      noticePeriodDays: 30,
    },
  });

  console.log("✅ Seed complete");
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
