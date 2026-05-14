# Project conventions

## Stack (latest as of May 2026)
- Runtime: Cloudflare Workers
- Framework: Hono `^4.12.18`
- Database: D1 (migrations in `migrations/`)
- Dev server / bundler: Vite + `@cloudflare/vite-plugin` (runs Worker code inside `workerd` during dev — matches production)
- Testing: Vitest `^4.1.6` + `@cloudflare/vitest-pool-workers` `^0.16.3`
- CLI: Wrangler `^4` (current latest is in the 4.61.x range)
- Config: `wrangler.toml` (default for this project)

## Hard requirements
- Always use the latest version of the documentation when making suggestions.
- `compatibility_date` should be set to **today's date** when starting a project (e.g. `"2026-05-13"`). Update deliberately; the runtime supports old dates forever.
- Vitest **4.1+** is required by `@cloudflare/vitest-pool-workers` (the pool dropped support for Vitest 2 and 3 in 0.13).
- Keep Wrangler current — if your installed `workerd` is older than your `compatibility_date`, recent Wrangler warns and silently falls back to an older date, which changes runtime behavior.
- Run `wrangler types` to regenerate the `Env` type — never hand-maintain it. Output goes to `worker-configuration.d.ts` by default and includes both binding types and runtime types.
- Declare `interface ProvidedEnv extends Env {}` so `cloudflare:test` bindings (and `env` from `cloudflare:workers`) are typed.
- **TypeScript 5.5+ with `strict: true`** is required. `tsconfig.json` must have `"strict": true` (which enables `noImplicitAny`, `strictNullChecks`, `strictFunctionTypes`, `strictBindCallApply`, `strictPropertyInitialization`, `noImplicitThis`, `useUnknownInCatchVariables`, `alwaysStrict`). Don't disable individual strict flags to silence errors — fix the code instead.
- **Node.js 24 (Active LTS)** is required for local dev. Pin via `.nvmrc` containing `24` and an `engines.node: ">=24"` field in `package.json`. Don't use Node 22 (Maintenance LTS) or Node 26 (Current, not yet LTS — promotes Oct 2026).
- **pnpm** is the package manager for this project. Pin it via `"packageManager": "pnpm@<version>"` in `package.json` (Corepack picks this up automatically). Don't use `npm` or `yarn`. Lockfile is `pnpm-lock.yaml`; commit it.

## Config files
- Use `wrangler.toml` as the default config format for this project. The Cloudflare Vite plugin auto-discovers `wrangler.toml`, `wrangler.jsonc`, or `wrangler.json` in the project root, so no extra config is needed.
- When using the Vite plugin, the `wrangler.toml` you author is the **input** config. `vite build` produces an **output** `wrangler.json` in the build directory that's used for `preview` and `wrangler deploy`. Don't hand-edit the output file; don't commit it (gitignore the build dir).

## Vite config (dev + build)
Use `@cloudflare/vite-plugin`'s `cloudflare()` plugin. No options needed by default — it picks up `wrangler.toml` automatically.

```ts
// vite.config.ts
import { defineConfig } from "vite";
import { cloudflare } from "@cloudflare/vite-plugin";

export default defineConfig({
  plugins: [cloudflare()],
});
```

Commands once this is in place:
- `vite` / `vite dev` — dev server with Worker code running in `workerd` and HMR
- `vite build` — outputs client assets + a deploy-ready `wrangler.json`
- `vite preview` — preview the build output in the Workers runtime locally
- `wrangler deploy` — deploys the Vite build output directly (no extra bundling)

## Vitest config (current shape)
Use the `cloudflareTest()` Vite plugin from `@cloudflare/vitest-pool-workers` inside Vitest's own `defineConfig`. **Do not** use `defineWorkersConfig` or `defineWorkersProject` — those were removed in pool 0.13.

```ts
// vitest.config.ts
import { cloudflareTest } from "@cloudflare/vitest-pool-workers";
import { defineConfig } from "vitest/config";

export default defineConfig({
  plugins: [
    cloudflareTest({
      wrangler: { configPath: "./wrangler.toml" },
    }),
  ],
});
```

If migrating from an older config, run the codemod:
`pnpm dlx jscodeshift -t node_modules/@cloudflare/vitest-pool-workers/dist/codemods/vitest-v3-to-v4.mjs vitest.config.ts`

## Test imports (current shape)
- `env` and `exports` come from `cloudflare:workers` (NOT `cloudflare:test` — that import was removed).
- `SELF.fetch()` is gone; use `exports.default.fetch()` for integration tests against the default export.
- `applyD1Migrations`, `readD1Migrations`, `createExecutionContext`, `waitOnExecutionContext`, etc. still come from `cloudflare:test`.

```ts
import { env, exports } from "cloudflare:workers";
import { applyD1Migrations } from "cloudflare:test";
```

## Hono conventions
- Type the app with bindings: `new Hono<{ Bindings: Env }>()`.
- For tests, use Hono's `testClient(app)` or `app.request(path, init, env)` with `env` as the third arg. Don't rely on globals.

## D1 conventions
- Migrations are SQL files in `migrations/`.
- Apply in test setup via `applyD1Migrations(env.DB, await readD1Migrations('./migrations'))` (read from `@cloudflare/vitest-pool-workers/config` in Node-side setup; apply from `cloudflare:test` inside the Workers runtime).
- Use prepared statements: `env.DB.prepare(sql).bind(...).all()` / `.first()` / `.run()`.
- Push DB logic into functions that take `D1Database` as a parameter — easier to test than handlers that pull from `c.env` directly.

## What I want from you (Claude)
- Default to `wrangler.toml` for new config; don't switch me to `wrangler.jsonc` without asking.
- Default to using `@cloudflare/vite-plugin` for dev/build. Don't suggest plain `wrangler dev` unless I ask.
- Don't suggest `defineConfig` from vitest *alone* — it needs the `cloudflareTest()` plugin to load the Workers runtime.
- Don't suggest `defineWorkersConfig` or `defineWorkersProject` — both were removed in pool 0.13.
- Don't suggest importing `env` or `SELF` from `cloudflare:test` — they moved to `cloudflare:workers` (and `SELF` is now `exports.default`).
- Don't invent the `Env` type — assume `wrangler types` has been run and the generated type is available.
- **Always use TypeScript 5.5 or later with `strict: true`.** No JavaScript files for source code. Don't disable strict flags individually. Don't reach for `any` — use `unknown` and narrow, or define the type properly. Use `satisfies` for config-like objects where you want both inference and a shape check.
- Prefer `app.request()` with explicit `env` over global mocks when writing tests.
- **Always use `pnpm`** for install/run/exec commands. Never suggest `npm install`, `npm run`, `npx`, `yarn add`, or `yarn`. Use `pnpm add`, `pnpm add -D`, `pnpm run <script>` (or `pnpm <script>` for shortcut), `pnpm dlx`, `pnpm exec`.
- **Never use `npx`.** Use `pnpm dlx` to run a one-off package (the `npx` equivalent — downloads and executes without permanent install) or `pnpm exec` to run a binary already in `node_modules/.bin`. Examples: `pnpm dlx wrangler login`, `pnpm exec wrangler types`, `pnpm dlx jscodeshift ...`.
- Keep handlers small.

## Commands
- `pnpm dev` — Vite dev server (Worker runs in `workerd` with HMR)
- `pnpm build` — `vite build`, produces deploy-ready output
- `pnpm preview` — `vite preview`, runs the build output in `workerd` locally
- `pnpm deploy` — `wrangler deploy` against the Vite build output
- `pnpm test` — vitest (workers pool runs automatically via the plugin)
- `pnpm exec wrangler types` — regenerate Env type after binding changes
- `pnpm exec wrangler d1 migrations apply <DB_NAME> --local` — apply migrations locally
- `pnpm exec wrangler d1 migrations apply <DB_NAME> --remote` — apply to production

## Versions reference (pin or use carets — your call)
- `hono`: `^4.12.18`
- `vitest`: `^4.1.6`
- `@cloudflare/vitest-pool-workers`: `^0.16.3`
- `@cloudflare/vite-plugin`: latest
- `vite`: `^6` (required by the Cloudflare Vite plugin's Environment API integration)
- `wrangler`: `^4`
- `typescript`: `^5.5` (with `strict: true` in `tsconfig.json`)
- Node.js: **24** (Active LTS; pinned via `.nvmrc` and `engines.node`)
