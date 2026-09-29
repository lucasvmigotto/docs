export interface DocApp {
  slug: string;
  name: string;
  description: string;
}

// Registry of documented projects. Each slug matches the R2 prefix
// `<slug>/` owned by that app's repo (ADR 0001). Add a row here when a
// new project starts publishing; no rule changes needed (ADR 0002).
export const APPS: DocApp[] = [
  {
    slug: "tasky",
    name: "tasky",
    description: "Task management — app, API and docs.",
  },
  {
    slug: "rusteams",
    name: "rusteams",
    description: "Team management CLI and services in Rust.",
  },
  {
    slug: "devenv",
    name: "devenv",
    description: "Reproducible, non-root DevContainer images.",
  },
];
