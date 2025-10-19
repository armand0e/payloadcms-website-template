FROM node:20-bookworm AS builder
WORKDIR /app
ENV NODE_ENV=production
RUN corepack enable && corepack prepare pnpm@10.18.0 --activate
COPY package.json pnpm-lock.yaml .npmrc* ./
RUN pnpm install --frozen-lockfile
COPY . .
# Build-time environment variables required by PayloadCMS
ARG PAYLOAD_SECRET
ARG POSTGRES_URI
ARG NEXT_PUBLIC_SERVER_URL
ENV PAYLOAD_SECRET=${PAYLOAD_SECRET}
ENV POSTGRES_URI=${POSTGRES_URI}
ENV NEXT_PUBLIC_SERVER_URL=${NEXT_PUBLIC_SERVER_URL}
RUN pnpm build

FROM node:20-bookworm-slim AS runner
WORKDIR /app
ENV NODE_ENV=production
ENV PORT=3000
EXPOSE 3000
RUN groupadd --system nodejs && useradd --system --gid nodejs nextjs
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/.next/BUILD_ID ./.next/BUILD_ID
RUN mkdir -p /app/public/media && chown -R nextjs:nodejs /app/public
USER nextjs
CMD ["node", "server.js"]
