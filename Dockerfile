# ------------------------------
# Dockerfile
# ------------------------------
FROM node:20-alpine AS deps
WORKDIR /app
# Prisma needs these on Alpine
RUN apk add --no-cache openssl libc6-compat
COPY package*.json ./
COPY prisma ./prisma
RUN npm ci
# Generate Prisma client now to cache it
RUN npx prisma generate

FROM node:20-alpine AS build
WORKDIR /app
RUN apk add --no-cache openssl libc6-compat
COPY --from=deps /app/node_modules ./node_modules
COPY --from=deps /app/prisma ./prisma
COPY tsconfig.json ./
COPY . .
# Compile TS to JS
RUN npm run build

FROM node:20-alpine AS runtime
WORKDIR /app
RUN apk add --no-cache openssl libc6-compat
ENV NODE_ENV=production
# Bring runtime deps + compiled app + prisma schema
COPY --from=deps /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY --from=build /app/prisma ./prisma
COPY package*.json ./

# Migrate, optional seed (set SEED=true), then start
CMD sh -c "npx prisma migrate deploy && if [ \"$$SEED\" = \"true\" ]; then npm run seed; fi && node dist/index.js"
