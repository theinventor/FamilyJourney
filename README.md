# FamilyJourney

> ⚠️ **WARNING: CLAW-CODED**
> 
> I not only didn't write a line of code, I didn't even look at it once. Clawdbot built this using our spec and Claude Code and a lot of nudging via Telegram. No warranty!

A gamified family task management app that makes chores and achievements fun for kids. Parents create badges for tasks and skills, kids complete them to earn points, and redeem points for customizable prizes.

## Features

- **Badge System**: Create badges with point values for chores, skills, learning goals, and achievements
- **Multi-Challenge Badges**: Complex badges with multiple steps (e.g., "Read 5 books")
- **Badge Categories**: Organize badges by type (Chores, Learning, Life Skills, Fitness, etc.)
- **Group Assignments**: Assign badges to specific groups of kids (e.g., "Older Kids", "All Kids")
- **Photo/Evidence Upload**: Kids can attach photos as proof of completion
- **Parent Review Workflow**: Approve or deny badge submissions with feedback
- **Points & Prizes**: Kids earn points and redeem them for family-defined prizes
- **Email Notifications**: Get notified when kids submit badges or request prize redemptions
- **Separate Dashboards**: Tailored views for parents (management) and kids (earning)

## Tech Stack

- **Ruby on Rails 8.1** with Hotwire (Turbo + Stimulus)
- **SQLite** database
- **Tailwind CSS** via CDN (no build step)
- **Devise** for authentication
- **Active Storage** for file uploads
- **Postmark** for transactional emails
- **Sentry** for error tracking
- **Rack::Attack** for rate limiting

## Getting Started

### Prerequisites

- Ruby 3.2+
- SQLite 3
- Node.js (for asset compilation if needed)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/FamilyJourney.git
   cd FamilyJourney
   ```

2. Install dependencies:
   ```bash
   bundle install
   ```

3. Set up the database:
   ```bash
   bin/rails db:create db:migrate db:seed
   ```

4. Start the server:
   ```bash
   bin/rails server
   ```

5. Visit `http://localhost:3000`

### Environment Variables

For production, configure the following:

| Variable | Description |
|----------|-------------|
| `POSTMARK_API_TOKEN` | Postmark API key for emails |
| `SENTRY_DSN` | Sentry DSN for error tracking |
| `SEED_PASSWORD` | Password for seeded test accounts |
| `SECRET_KEY_BASE` | Rails secret key |

## Test Accounts

After running `db:seed`, you can log in with these accounts:

| Role | Email | Password |
|------|-------|----------|
| Parent | `parent@test.com` | `password123` |
| Kid (Tommy) | `kid1@test.com` | `password123` |
| Kid (Sally) | `kid2@test.com` | `password123` |

All test accounts belong to the "Smith Family" with sample badges, prizes, and submissions.

## Project Structure

```
app/
├── controllers/
│   ├── admin/           # Parent admin controllers (badges, reviews, prizes)
│   ├── dashboard_controller.rb
│   └── ...
├── models/
│   ├── user.rb          # Parent/Kid roles
│   ├── family.rb        # Family grouping
│   ├── badge.rb         # Badge definitions
│   ├── badge_submission.rb  # Kid submissions
│   ├── prize.rb         # Redeemable prizes
│   └── redemption.rb    # Prize redemptions
└── views/
    ├── dashboard/       # Role-specific dashboards
    ├── admin/           # Parent management views
    └── ...
```

## Key Workflows

### For Parents
1. Create badge categories to organize badges
2. Create badges with descriptions, instructions, and point values
3. Assign badges to groups of kids
4. Review submitted badges (approve/deny with feedback)
5. Create prizes kids can redeem points for
6. Approve prize redemptions

### For Kids
1. View available badges on dashboard
2. Complete badge requirements
3. Submit with optional notes and photo evidence
4. Earn points when approved
5. Browse and redeem prizes

## Email Notifications

The app sends transactional emails for key events:

| Email | Recipient | Triggered When |
|-------|-----------|----------------|
| **Badge Submitted** | All parents in family | Kid submits a badge for review |
| **Badge Approved** | Kid | Parent approves their badge submission |
| **Badge Denied** | Kid | Parent denies their badge (includes feedback) |
| **Redemption Requested** | All parents in family | Kid requests a prize redemption |
| **Redemption Approved** | Kid | Parent approves their prize request |
| **Redemption Denied** | Kid | Parent denies their prize request (includes feedback) |

### Email Previews

Preview all emails in development at:

```
http://localhost:3000/rails/mailers/notification_mailer
```

Individual previews:
- `/rails/mailers/notification_mailer/badge_submitted`
- `/rails/mailers/notification_mailer/badge_approved`
- `/rails/mailers/notification_mailer/badge_denied`
- `/rails/mailers/notification_mailer/redemption_requested`
- `/rails/mailers/notification_mailer/redemption_approved`
- `/rails/mailers/notification_mailer/redemption_denied`

## API Access

FamilyJourney includes a REST API for programmatic access. Parents can find their API key in their dashboard under "API Access".

### Authentication

Include your API token in the `Authorization` header:
```bash
curl -H "Authorization: Bearer YOUR_API_TOKEN" http://localhost:3000/api/v1/kids
```

### Endpoints

| Resource | Endpoints |
|----------|-----------|
| **Kids** | `GET/POST /api/v1/kids`, `GET/PATCH/DELETE /api/v1/kids/:id` |
| **Badges** | `GET/POST /api/v1/badges`, `POST /api/v1/badges/:id/publish` |
| **Submissions** | `GET /api/v1/badge_submissions`, `POST .../approve`, `POST .../deny` |
| **Prizes** | Full CRUD at `/api/v1/prizes` |
| **Redemptions** | `GET /api/v1/redemptions`, `POST .../approve`, `POST .../deny` |
| **Family** | `GET /api/v1/family` |

Full API documentation: `/api/docs`

## Clawdbot Skill

A [Clawdbot](https://github.com/clawdbot/clawdbot) skill is included in `skill/` for AI assistant integration. This lets parents manage FamilyJourney via text or chat:

```bash
# Install the skill
cp -r skill/familyjourney ~/.clawdbot/skills/

# Add your API key to TOOLS.md
```

Example commands your AI assistant can handle:
- "How many points does Tommy have?"
- "Approve Sally's homework badge submission"
- "Add a new prize called Movie Night for 50 points"
- "What badges are pending review?"

## Development

### Running Tests
```bash
bin/rails test
```

### Code Quality
```bash
bundle exec rubocop
bundle exec brakeman
bundle exec bundler-audit check
```

### Background Jobs
Uses Solid Queue for background job processing:
```bash
bin/rails solid_queue:start
```

## Deployment

This app is configured for deployment with Kamal. See `config/deploy.yml` for configuration.

```bash
kamal setup
kamal deploy
```

## License

MIT License - see [LICENSE](LICENSE) for details.
