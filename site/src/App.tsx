import { APPS } from "./apps";

declare const __APP_VERSION__: string;

export function App() {
  return (
    <main className="mx-auto flex min-h-screen w-full max-w-3xl flex-col gap-10 px-6 py-16">
      <header className="flex flex-col gap-3">
        <p className="text-sm text-sky-300">docs.lucasvmigotto.me</p>
        <h1 className="text-4xl font-bold tracking-tight">Project documentation</h1>
        <p className="text-slate-400">
          One hub for every project's docs. Pick a project below — each lives under its own path (v
          {__APP_VERSION__}).
        </p>
      </header>

      <ul className="grid gap-4 sm:grid-cols-2">
        {APPS.map((app) => (
          <li
            key={app.slug}
            className="flex flex-col gap-3 rounded-xl border border-slate-800 bg-slate-900/60 p-5 transition-colors hover:border-sky-400"
          >
            <a href={`/${app.slug}/`} className="flex flex-col gap-2">
              <span className="text-xl font-semibold text-slate-100">{app.name}</span>
              <span className="text-sm text-slate-400">{app.description}</span>
              <span className="text-sm text-sky-300">Open docs →</span>
            </a>
            <ul aria-label="Technologies" className="flex flex-wrap gap-2">
              {app.tags.map((tag) => (
                <li
                  key={tag}
                  className="rounded-full border border-slate-700 px-2.5 py-0.5 text-xs text-slate-300"
                >
                  {tag}
                </li>
              ))}
            </ul>
            <a
              href={app.source}
              className="text-xs text-slate-400 underline-offset-4 hover:text-sky-300 hover:underline"
              rel="noopener noreferrer"
              target="_blank"
            >
              Source ↗
            </a>
          </li>
        ))}
      </ul>

      <footer className="mt-auto text-sm text-slate-500">
        Missing a project? It hasn't published its docs prefix yet.
      </footer>
    </main>
  );
}
