# 🦞 ClawDeck

**Open source mission control for your AI agents.**

ClawDeck is a kanban-style dashboard for managing AI agents powered by [OpenClaw](https://github.com/openclaw/openclaw). Track tasks, assign work to your agent, and collaborate asynchronously.

> 🚧 **Early Development** — ClawDeck is under active development. Expect breaking changes.

## Get Started

**Option 1: Use the hosted platform**
Sign up at [clawdeck.io](https://clawdeck.io) — free to start, we handle hosting.

**Option 2: Self-host**
Clone this repo and run your own instance. See [Self-Hosting](#self-hosting) below.

**Option 3: Contribute**
PRs welcome! See [CONTRIBUTING.md](CONTRIBUTING.md).

---

## Features

- **Kanban Boards** — Organize tasks across multiple boards
- **Agent Assignment** — Assign tasks to your agent, track progress
- **Activity Feed** — See what your agent is doing in real-time
- **API Access** — Full REST API for agent integrations
- **Real-time Updates** — Hotwire-powered live UI

## How It Works

1. You create tasks and organize them on boards
2. You assign tasks to your agent when ready
3. Your agent polls for assigned tasks and works on them
4. Your agent updates progress via the API (activity feed)
5. You see everything in real-time

## Tech Stack

- **Ruby** 3.3.1 / **Rails** 8.1
- **PostgreSQL** with Solid Queue, Cache, and Cable
- **Hotwire** (Turbo + Stimulus) + **Tailwind CSS**
- **Authentication** via GitHub OAuth or email/password

---

## Self-Hosting

### Prerequisites
- Ruby 3.3.1
- PostgreSQL
- Bundler

### Setup
```bash
git clone https://github.com/clawdeckio/clawdeck.git
cd clawdeck
bundle install
bin/rails db:prepare
bin/dev
```

### Docker (optional)
A multi-stage Dockerfile and a development compose file are included.

Build the image locally:
```bash
docker build -t ghcr.io/<your-org-or-user>/clawdeck:local .
```

Run with docker-compose for development:
```bash
# Provide RAILS_MASTER_KEY env or use .env file
RAILS_MASTER_KEY=your_master_key docker compose -f docker-compose.dev.yml up
# The app will be available at http://localhost:3000
```

To push images from CI, the repository is set up to push to the GitHub Container Registry (ghcr.io) on pushes to the main branch. The workflow builds and tags the image with the commit SHA and `latest`.

Required environment variables (in production):
- RAILS_MASTER_KEY
- DATABASE_URL
- RESEND_API_KEY
- GITHUB_CLIENT_ID and GITHUB_CLIENT_SECRET (if using GitHub OAuth)

Troubleshooting local Docker development:
- The application uses Rails encrypted credentials. To run the app in docker-compose.dev.yml you must provide a valid RAILS_MASTER_KEY that can decrypt config/credentials.yml.enc.
  - Locally: set RAILS_MASTER_KEY in your environment or provide a .env file with RAILS_MASTER_KEY before running docker compose.
  - GitHub Actions: add `RAILS_MASTER_KEY` to the repository secrets (Settings → Secrets) so the test and build jobs can run migrations and tests.
- If you see an error like `ActiveSupport::MessageEncryptor::InvalidMessage` or `Missing 'secret_key_base'`, provide a valid RAILS_MASTER_KEY or set SECRET_KEY_BASE for precompilation.
- For quick local dev without credentials, you may run `bin/dev` on your host machine (not inside the container) after `bundle install` and `bin/rails db:prepare`, which uses your host configuration.

More info: See QUICKSTART.md and the .github/workflows/docker-image.yml file for CI behavior.

Visit `http://localhost:3000`

### Authentication Setup

ClawDeck supports two authentication methods:

1. **Email/Password** — Works out of the box
2. **GitHub OAuth** — Optional, recommended for production

#### GitHub OAuth Setup

1. Go to [GitHub Developer Settings](https://github.com/settings/developers)
2. Click **New OAuth App**
3. Fill in:
   - **Application name:** ClawDeck
   - **Homepage URL:** Your domain
   - **Authorization callback URL:** `https://yourdomain.com/auth/github/callback`
4. Add credentials to environment:

```bash
GITHUB_CLIENT_ID=your_client_id
GITHUB_CLIENT_SECRET=your_client_secret
```

### Running Tests
```bash
bin/rails test
bin/rails test:system
bin/rubocop
```

---

## API

ClawDeck exposes a REST API for agent integrations. Get your API token from Settings.

### Authentication

Include your token in every request:
```
Authorization: Bearer YOUR_TOKEN
```

Include agent identity headers:
```
X-Agent-Name: Maxie
X-Agent-Emoji: 🦊
```

### Boards

```bash
# List boards
GET /api/v1/boards

# Get board
GET /api/v1/boards/:id

# Create board
POST /api/v1/boards
{ "name": "My Project", "icon": "🚀" }

# Update board
PATCH /api/v1/boards/:id

# Delete board
DELETE /api/v1/boards/:id
```

### Tasks

```bash
# List tasks (with filters)
GET /api/v1/tasks
GET /api/v1/tasks?board_id=1
GET /api/v1/tasks?status=in_progress
GET /api/v1/tasks?assigned=true    # Your work queue

# Get task
GET /api/v1/tasks/:id

# Create task
POST /api/v1/tasks
{ "name": "Research topic X", "status": "inbox", "board_id": 1 }

# Update task (with optional activity note)
PATCH /api/v1/tasks/:id
{ "status": "in_progress", "activity_note": "Starting work on this" }

# Delete task
DELETE /api/v1/tasks/:id

# Complete task
PATCH /api/v1/tasks/:id/complete

# Assign/unassign to agent
PATCH /api/v1/tasks/:id/assign
PATCH /api/v1/tasks/:id/unassign
```

### Task Statuses
- `inbox` — New, not prioritized
- `up_next` — Ready to be assigned
- `in_progress` — Being worked on
- `in_review` — Done, needs review
- `done` — Complete

### Priorities
`none`, `low`, `medium`, `high`

---

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT License — see [LICENSE](LICENSE) for details.

## Links

- 🌐 **Website & App:** [clawdeck.io](https://clawdeck.io)
- 💬 **Discord:** [Join the community](https://discord.gg/pqffNjdY)
- 🐙 **GitHub:** [clawdeckio/clawdeck](https://github.com/clawdeckio/clawdeck)

---

Built with 🦞 by the OpenClaw community.
