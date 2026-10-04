export interface DocApp {
  slug: string;
  name: string;
  description: string;
  tags: string[];
  source: string;
}

// Registry of documented projects. Each slug matches the R2 prefix
// `<slug>/` owned by that app's repo (ADR 0001). Add a row here when a
// new project starts publishing; no rule changes needed (ADR 0002).
export const APPS: DocApp[] = [
  {
    slug: "tasky",
    name: "tasky",
    description: "Task management — app, API and docs.",
    tags: ["Java", "Spring Boot", "React", "TypeScript"],
    source: "https://github.com/lucasvmigotto/tasky",
  },
  {
    slug: "rusteams",
    name: "rusteams",
    description: "Team management CLI and services in Rust.",
    tags: ["Rust"],
    source: "https://github.com/lucasvmigotto/rusteams",
  },
  {
    slug: "devenv",
    name: "devenv",
    description: "Reproducible, non-root DevContainer images.",
    tags: ["Docker", "Dev Containers"],
    source: "https://github.com/lucasvmigotto/devenv",
  },
  {
    slug: "dottod",
    name: "dottod",
    description: "Debian workstation bootstrap in plain bash.",
    tags: ["Bash", "Debian", "Dev Containers"],
    source: "https://github.com/lucasvmigotto/dottod",
  },
  {
    slug: "starsky",
    name: "starsky",
    description: "Personalized night-sky poster generator.",
    tags: ["Python", "React", "TypeScript"],
    source: "https://github.com/lucasvmigotto/starsky",
  },
  {
    slug: "dottod",
    name: "dottod",
    description:
      "Reproducible Debian workstation bootstrap — dotfiles, fonts, editor, CLI tooling.",
    tags: ["Bash", "Docker"],
    source: "https://github.com/lucasvmigotto/dottod",
  },
];
