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

# Copy full .next output (server + static) and runtime deps.
# Using the full build instead of output: 'standalone' because
# Next.js 16 doesn't generate .next/standalone reliably.
COPY --from=builder --chown=nextjs:nodejs /app/.next ./.next
COPY --from=builder --chown=nextjs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nextjs:nodejs /app/package.json ./package.json
COPY --from=builder --chown=nextjs:nodejs /app/next.config.js ./next.config.js

USER nextjs

EXPOSE 20983
ENV PORT=20983
ENV HOSTNAME="0.0.0.0"

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD wget -q --spider http://localhost:20983 || exit 1

CMD ["npx", "next", "start", "-p", "20983"]
