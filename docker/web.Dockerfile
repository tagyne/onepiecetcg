FROM node:22-alpine AS build

WORKDIR /app

ENV CI=true

RUN corepack enable
RUN corepack prepare pnpm@11.13.1 --activate

COPY . .

RUN pnpm install --frozen-lockfile
RUN pnpm build:packages
RUN pnpm --dir apps/web build

FROM node:22-alpine

WORKDIR /app

ENV NODE_ENV=production

COPY --from=build /app/apps/web/.output/ ./.output/

EXPOSE 3001

CMD ["node", ".output/server/index.mjs"]
