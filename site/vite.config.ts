import { defineConfig, loadEnv } from "vite";
import react from "@vitejs/plugin-react";
import tailwindcss from "@tailwindcss/vite";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import pkg from "./package.json" with { type: "json" };

const root = dirname(fileURLToPath(import.meta.url));

// Landing owns bucket root only (ADR 0001). Never emit <app>/ prefixes
// from here; apps deploy their own prefix from their own repos.
export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), "");
  const siteName =
    process.env["VITE_APP_SITE_NAME"] ??
    env["VITE_APP_SITE_NAME"] ??
    "https://docs.lucasvmigotto.me";

  return {
    base: "/",
    plugins: [
      tailwindcss(),
      react(),
      {
        name: "html-app-site-name",
        transformIndexHtml(html) {
          return html.replaceAll("%APP_SITE_NAME%", siteName);
        },
      },
    ],
    resolve: {
      alias: {
        "@": resolve(root, "src"),
      },
    },
    define: {
      __APP_VERSION__: JSON.stringify(pkg.version),
      __APP_SITE_NAME__: JSON.stringify(siteName),
    },
  };
});
