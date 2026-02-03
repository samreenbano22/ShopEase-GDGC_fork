import { PrismaClient } from '@prisma/client';
import { PrismaLibSql } from '@prisma/adapter-libsql';
import { createClient } from '@libsql/client';
import path from 'path';
import { config } from 'dotenv';

config({ path: path.resolve(process.cwd(), ".env") });

const libsql = createClient({
  url: process.env.DATABASE_URL || "file:./dev.db",
});

const adapter = new PrismaLibSql({ url: process.env.DATABASE_URL || "file:./dev.db" });

const prismaClientSingleton = () => {
  return new PrismaClient({ adapter });
};

declare global {
  var prisma: undefined | ReturnType<typeof prismaClientSingleton>;
}

const prisma = globalThis.prisma ?? prismaClientSingleton();

export default prisma;

if (process.env.NODE_ENV !== 'production') globalThis.prisma = prisma;
