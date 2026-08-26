FROM node:22-alpine AS build

WORKDIR /app

ENV CI=true

RUN corepack enable
RUN corepack prepare pnpm@11.13.1 --activate

COPY . .

RUN pnpm install --frozen-lockfile
RUN pnpm build:packages
RUN pnpm --dir apps/api build

# Create a self-contained production directory. Workspace dependencies are
# copied into this directory instead of being resolved from /packages at runtime.
RUN pnpm deploy --filter ./apps/api --prod --ignore-scripts /app/deploy

FROM node:22-alpine

WORKDIR /app

ENV NODE_ENV=production

COPY --from=build /app/deploy/ ./

EXPOSE 3000

CMD ["node", "dist/main.js"]
