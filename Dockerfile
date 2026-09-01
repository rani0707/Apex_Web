# ---- Base: Node.js runtime ----
FROM node:20-alpine AS base
WORKDIR /app

# ---- Stage 1: Dependencies ----
# Cache bust with COPY --chmod so re-runs are fast when only code changes
FROM base AS deps
COPY package.json package-lock.json* ./
RUN npm ci --ignore-scripts;

# ---- Stage 2: Builder ----
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

ENV NEXT_TELEMETRY_DISABLED=1
ENV NODE_ENV=production

RUN npm run build;

# ---- Stage 3: Production runner ----
FROM base AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

RUN addgroup --system --gid 1001 nodejs \
    && adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public

RUN mkdir .next && chown nextjs:nodejs .next

COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 20983
ENV PORT=20983
ENV HOSTNAME="0.0.0.0"

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD wget -q --spider http://localhost:20983 || exit 1

CMD ["node", "server.js"]
