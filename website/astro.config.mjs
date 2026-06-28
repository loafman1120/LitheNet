// @ts-check
import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';

const runtime = /** @type {{ process?: { env?: { SITE_URL?: string; BASE_PATH?: string } } }} */ (globalThis);
const env = runtime.process?.env ?? {};

// https://astro.build/config
export default defineConfig({
  site: env.SITE_URL || 'https://lithe.loafman.top',
  base: env.BASE_PATH || '/',
  output: 'static',
  compressHTML: true,
  vite: {
    plugins: [tailwindcss()],
  },
  i18n: {
    defaultLocale: 'en',
    locales: ['en', 'zh'],
    routing: {
      prefixDefaultLocale: true,
    },
  },
});
