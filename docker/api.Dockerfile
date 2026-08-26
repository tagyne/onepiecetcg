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

# pnpm deploy copies local workspace packages but excludes their gitignored
# build output. Copy the compiled application and workspace artifacts explicitly
# so the final image has no dependency on the source workspace.
RUN cp -R apps/api/dist /app/deploy/dist \
  && for package in cards duel-engine effect-engine shared; do \
    target="$(readlink -f "/app/deploy/node_modules/@onepiecetcg/$package")"; \
    mkdir -p "$target/dist"; \
    cp -R "packages/$package/dist/." "$target/dist/"; \
  done

FROM node:22-alpine

WORKDIR /app

ENV NODE_ENV=production

COPY --from=build /app/deploy/ ./

EXPOSE 3000

CMD ["node", "dist/main.js"]
