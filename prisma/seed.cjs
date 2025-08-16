// ------------------------------
// prisma/seed.cjs
// ------------------------------
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  // Use a string for decimals to avoid float issues
  const fiatAmount = "100.00";
  const cashRefHash = 'mock-hmac-hash'; // replace with real HMAC in prod

  await prisma.deal.upsert({
    where: { cashRefHash },
    update: {},
    create: {
      fiatAmount,
      cashRefHash,
      status: 'INIT',
      eventLogs: {
        create: {
          type: 'CREATED',
          idempotency: 'seed-init',
          actor: 'system',
          payload: { note: 'Baseline deal for ops validation' },
        },
      },
    },
  });

  console.log('Seed complete: baseline deal ensured');
}

main()
  .catch((e) => { console.error(e); process.exit(1); })
  .finally(() => prisma.$disconnect());
