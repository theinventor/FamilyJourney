# FamilyJourney Build Plan

A family-scoped badge-earning web app where parents define badges (optionally with challenges), assign them to groups of kids, and review submissions. Kids track progress, submit proof, and earn badges + points that can be redeemed for prizes.

---

## Design Reference

**Template repo:** `~/family-fun-tracker` (React/Tailwind, but copy the styling patterns to Rails views)

### Color Palette & Gradients

Use these gradient classes for cards, badges, and stat blocks:

```css
/* Warm coral-pink (primary actions, stats) */
.gradient-coral { background: linear-gradient(135deg, hsl(15 90% 60%), hsl(350 85% 65%)); }

/* Teal-cyan (secondary, chores category) */
.gradient-teal { background: linear-gradient(135deg, hsl(175 60% 50%), hsl(195 70% 55%)); }

/* Purple-violet (accent, homework category) */
.gradient-purple { background: linear-gradient(135deg, hsl(270 70% 60%), hsl(290 65% 55%)); }

/* Yellow-orange (warnings, streaks, points) */
.gradient-yellow { background: linear-gradient(135deg, hsl(45 95% 55%), hsl(35 90% 60%)); }

/* Green (success, completed) */
.gradient-green { background: linear-gradient(135deg, hsl(145 65% 45%), hsl(160 60% 50%)); }

/* Pink-rose (skills category) */
.gradient-pink { background: linear-gradient(135deg, hsl(330 80% 65%), hsl(350 75% 60%)); }
```

### Typography
- **Font:** Nunito (Google Fonts) - friendly, rounded
- **Weights:** 400, 600, 700, 800
- **Big numbers:** `text-3xl font-extrabold`
- **Labels:** `text-sm font-medium`

### Card Patterns

**Stat Card (points, badges earned, etc.):**
```html
<div class="p-5 rounded-2xl gradient-coral text-white shadow-lg hover:-translate-y-1 transition">
  <div class="flex items-start justify-between">
    <div>
      <p class="text-sm opacity-90">Total Points</p>
      <p class="text-3xl font-extrabold mt-1">450</p>
      <p class="text-xs mt-1 opacity-80">Keep going!</p>
    </div>
    <div class="p-3 rounded-xl bg-white/20">
      <!-- icon -->
    </div>
  </div>
</div>
```

**Badge Card (earned vs locked):**
```html
<!-- Earned badge -->
<div class="relative p-4 rounded-2xl gradient-purple text-white hover:scale-105 hover:rotate-2 transition">
  <div class="flex flex-col items-center text-center">
    <div class="p-3 rounded-full bg-white/20 mb-2"><!-- icon --></div>
    <h4 class="font-bold text-sm">Badge Title</h4>
    <p class="text-xs mt-1 opacity-90">Description</p>
  </div>
  <div class="absolute -top-2 -right-2 w-6 h-6 rounded-full bg-green-500 flex items-center justify-center text-white text-xs">✓</div>
</div>

<!-- Locked badge -->
<div class="relative p-4 rounded-2xl bg-gray-100 text-gray-400">
  <!-- same structure but muted colors -->
  <div class="absolute inset-0 flex items-center justify-center bg-white/30 rounded-2xl backdrop-blur-sm">
    <span class="text-2xl">🔒</span>
  </div>
</div>
```

### Layout
- **Sidebar:** Fixed left navigation with family member avatars
- **Main content:** Scrollable, `p-6 space-y-8`
- **Grid:** `grid-cols-1 lg:grid-cols-3 gap-6` for dashboard
- **Border radius:** `rounded-2xl` for cards, `rounded-full` for avatars/icons

### Animations
```css
.hover\:scale-105:hover { transform: scale(1.05); }
.hover\:-translate-y-1:hover { transform: translateY(-0.25rem); }
.hover\:rotate-2:hover { transform: rotate(2deg); }
```

### Shadows
```css
.shadow-card { box-shadow: 0 4px 20px -4px rgba(255, 107, 107, 0.15); }
.shadow-float { box-shadow: 0 12px 40px -12px rgba(30, 30, 60, 0.2); }
```

### Background
- Warm cream: `hsl(35 100% 98%)` for page background
- White cards on cream background
- Dark mode support optional (defined in template)

---

## Development Workflow (How Claudito Works on This)

### Running Claude Code
Use the local Claude Code CLI (runs on Max plan, free):
```bash
# Start a task
cd ~/FamilyJourney && claude "Your task here"

# Continue last session
cd ~/FamilyJourney && claude -c

# Resume specific session
cd ~/FamilyJourney && claude -r
```

Run in background with `exec` + `pty:true` + `background:true`, then poll with `process action:log`.

### Rails Server
Have Claude Code start the server bound to all interfaces so I can browse it:
```bash
rails server -b 0.0.0.0 -p 3000
```

Then I (Claudito) can use my browser tool to visit `http://localhost:3000` and verify the UI.

### Test Users
Create seed data with known credentials:
```ruby
# db/seeds.rb
family = Family.create!(name: "Anderson Family")

# Parent account
User.create!(
  email: "parent@test.com",
  password: "password123",
  name: "Test Parent",
  role: "parent",
  family: family
)

# Kid accounts
User.create!(
  email: "kid1@test.com",
  password: "password123",
  name: "Test Kid 1",
  role: "kid",
  family: family
)

User.create!(
  email: "kid2@test.com",
  password: "password123",
  name: "Test Kid 2",
  role: "kid",
  family: family
)
```

Run `rails db:seed` after migrations.

### Verification Flow
After each phase:
1. Have Claude Code run the server
2. Open browser to localhost:3000
3. Log in as parent → verify admin features
4. Log in as kid → verify kid dashboard
5. Check for visual match with family-fun-tracker template

### Session Continuity
This section exists so I (Claudito) remember how to pick up work between sessions:
- Project lives at `~/FamilyJourney`
- Design reference at `~/family-fun-tracker`
- Use `claude -c` to continue Claude Code sessions
- Check `git log` for recent progress
- Check this PLAN.md for next phase

---

## Tech Stack

- **Framework:** Rails 8
- **Database:** SQLite
- **Views:** ERB (vanilla), Tailwind CSS for styling
- **Components:** Phlex optional for reusable components
- **Storage:** ActiveStorage (local disk initially)
- **Email:** Postmark
- **Error Tracking:** Sentry
- **Hosting:** Hatchbox (git push deploy)

---

## Rails Conventions (IMPORTANT)

When building each phase, use these Rails patterns:

```bash
# Generate models with associations
rails generate model User name:string email:string role:string family:references

# Generate scaffold for full CRUD
rails generate scaffold Badge title:string description:text points:integer

# Run migrations after generating
rails db:migrate

# Generate controller only
rails generate controller Dashboard index

# Use rails console to test models
rails console
```

- Always run `rails db:migrate` after creating migrations
- Use `rails routes` to verify routes
- Use `belongs_to`, `has_many`, `has_many :through` for associations
- Use scopes for common queries
- Use callbacks sparingly (prefer service objects for complex logic)
- Use `rails test` to run tests

---

## Phase 1: Rails Setup & Authentication

**Goal:** Fresh Rails 8 app with working auth and family structure

### Steps:
1. Create new Rails 8 app
   ```bash
   rails new . --database=sqlite3 --css=tailwind --skip-test
   ```
2. Add gems to Gemfile:
   - `devise` (authentication)
   - `sentry-ruby` + `sentry-rails`
   - `postmark-rails`
3. Run `bundle install`
4. Generate Devise install: `rails generate devise:install`
5. Generate User model with Devise: `rails generate devise User`
6. Add to User migration:
   - `name:string`
   - `role:string` (parent/kid)
   - `family_id:references`
7. Generate Family model:
   ```bash
   rails generate model Family name:string
   ```
8. Run migrations: `rails db:migrate`
9. Set up associations:
   - Family `has_many :users`
   - User `belongs_to :family`
10. Create seeds with a test family, parent, and kid
11. Configure Sentry in `config/initializers/sentry.rb`
12. Configure Postmark in `config/environments/production.rb`

### Verify:
- Can sign up/sign in
- Users belong to a family
- Role distinguishes parent vs kid

---

## Phase 2: Groups & Membership

**Goal:** Parents can create groups and assign kids to them

### Steps:
1. Generate Group model:
   ```bash
   rails generate model Group name:string description:text family:references
   ```
2. Generate GroupMembership join table:
   ```bash
   rails generate model GroupMembership group:references user:references
   ```
3. Run migrations: `rails db:migrate`
4. Set up associations:
   - Group `belongs_to :family`
   - Group `has_many :group_memberships`
   - Group `has_many :users, through: :group_memberships`
   - User `has_many :group_memberships`
   - User `has_many :groups, through: :group_memberships`
5. Generate groups controller (admin):
   ```bash
   rails generate controller Admin::Groups index new create edit update destroy
   ```
6. Create views for group management
7. Add member add/remove functionality

### Verify:
- Parents can CRUD groups
- Kids can be added/removed from groups

---

## Phase 3: Badge Categories

**Goal:** Parents can create sortable badge categories

### Steps:
1. Generate BadgeCategory model:
   ```bash
   rails generate model BadgeCategory name:string position:integer family:references
   ```
2. Run migration: `rails db:migrate`
3. Set up associations:
   - BadgeCategory `belongs_to :family`
   - Family `has_many :badge_categories`
4. Add `acts_as_list` gem OR manual position management
5. Generate admin controller:
   ```bash
   rails generate controller Admin::BadgeCategories index new create edit update destroy
   ```
6. Create views with drag-to-reorder (or simple position field)
7. Add default ordering scope: `default_scope { order(position: :asc) }`

### Verify:
- Parents can CRUD categories
- Categories display in sort order

---

## Phase 4: Badges (Simple)

**Goal:** Parents can create/publish badges with points

### Steps:
1. Generate Badge model:
   ```bash
   rails generate model Badge title:string description:text instructions:text points:integer status:string published_at:datetime badge_category:references family:references created_by:references
   ```
2. Run migration: `rails db:migrate`
3. Set up associations:
   - Badge `belongs_to :family`
   - Badge `belongs_to :badge_category, optional: true`
   - Badge `belongs_to :created_by, class_name: 'User'`
4. Add status enum: `enum status: { draft: 'draft', published: 'published' }`
5. Generate admin controller:
   ```bash
   rails generate controller Admin::Badges index new create edit update destroy
   ```
6. Create views with:
   - Title, description, instructions fields
   - Point value field
   - Category dropdown
   - Publish/unpublish toggle
7. Add publish/unpublish actions

### Verify:
- Parents can CRUD badges
- Badges have point values
- Badges can be published/unpublished

---

## Phase 5: Badge Assignments

**Goal:** Parents can assign badges to groups

### Steps:
1. Generate BadgeAssignment model:
   ```bash
   rails generate model BadgeAssignment badge:references group:references assigned_by:references active:boolean assigned_at:datetime
   ```
2. Run migration: `rails db:migrate`
3. Set up associations:
   - BadgeAssignment `belongs_to :badge`
   - BadgeAssignment `belongs_to :group`
   - Badge `has_many :badge_assignments`
   - Badge `has_many :groups, through: :badge_assignments`
4. Add multi-select group assignment to badge edit form
5. Add scope for active assignments

### Verify:
- Parents can assign badges to multiple groups
- Assignments can be activated/deactivated

---

## Phase 6: Kid Dashboard - Badge Visibility

**Goal:** Kids see available badges based on their groups

### Steps:
1. Generate dashboard controller:
   ```bash
   rails generate controller Dashboard index
   ```
2. Create Badge scopes:
   - `available_for(user)` - published, assigned to user's groups, not yet earned
   - `in_progress_for(user)` - has pending challenges or submission
   - `earned_by(user)` - has approved submission
3. Build dashboard view showing:
   - Current points balance (placeholder for now)
   - Available badges by category
   - In-progress badges
   - Earned badges
4. Style with Tailwind - cards, gradients, progress indicators

### Verify:
- Kids only see badges assigned to their groups
- Unpublished badges never appear
- Badges grouped by category in sort order

---

## Phase 7: Badge Submissions (Simple)

**Goal:** Kids can submit simple badges for review

### Steps:
1. Generate BadgeSubmission model:
   ```bash
   rails generate model BadgeSubmission badge:references user:references status:string submitted_at:datetime reviewed_at:datetime reviewed_by:references kid_notes:text parent_feedback:text
   ```
2. Run migration: `rails db:migrate`
3. Add status enum: `pending_review`, `approved`, `denied`
4. Set up ActiveStorage:
   ```bash
   rails active_storage:install
   rails db:migrate
   ```
5. Add to BadgeSubmission: `has_many_attached :attachments`
6. Generate submissions controller:
   ```bash
   rails generate controller Submissions new create show
   ```
7. Create submission form:
   - Rich text area for notes (simple textarea OK)
   - File upload (multiple)
   - Submit button
8. After submit: redirect to badge detail showing "pending review"

### Verify:
- Kids can submit text + attachments
- Submission shows as pending

---

## Phase 8: Parent Review Queue

**Goal:** Parents can review and approve/deny submissions

### Steps:
1. Generate admin review controller:
   ```bash
   rails generate controller Admin::Reviews index show approve deny
   ```
2. Create review queue view:
   - List pending submissions
   - Show kid name, badge title, submitted time
3. Create review detail view:
   - Kid's notes
   - Attachments (preview/download)
   - Parent feedback textarea
   - Approve / Deny buttons
4. Implement approve action:
   - Set status to approved
   - Set reviewed_at, reviewed_by
   - Award points (implement in Phase 11)
5. Implement deny action:
   - Set status to denied
   - Save parent feedback
   - Kid can resubmit

### Verify:
- Parents see pending submissions
- Approve/deny works correctly
- Kid sees feedback on denial

---

## Phase 9: Badge Challenges

**Goal:** Parents can add multi-step challenges to badges

### Steps:
1. Generate BadgeChallenge model:
   ```bash
   rails generate model BadgeChallenge badge:references title:string description:text position:integer
   ```
2. Run migration: `rails db:migrate`
3. Set up associations:
   - Badge `has_many :badge_challenges`
   - BadgeChallenge `belongs_to :badge`
4. Add to Badge: `#multi_challenge?` method (has challenges)
5. Add nested form for challenges in badge edit
6. Order challenges by position

### Verify:
- Parents can add/edit/remove challenges from badges
- Challenges have order

---

## Phase 10: Challenge Completions

**Goal:** Kids can complete challenges (auto-approved checkmarks)

### Steps:
1. Generate ChallengeCompletion model:
   ```bash
   rails generate model ChallengeCompletion badge_challenge:references user:references completed_at:datetime kid_notes:text
   ```
2. Add ActiveStorage: `has_many_attached :attachments`
3. Run migration: `rails db:migrate`
4. Generate completions controller:
   ```bash
   rails generate controller ChallengeCompletions new create
   ```
5. Update badge detail view:
   - Show challenge checklist
   - Green check for completed
   - "Submit" button for incomplete
6. Challenge submission:
   - Text + attachments
   - Auto-marks as complete (no parent review)
7. Track progress: X/Y challenges complete
8. Enable "Submit Badge for Approval" only when all challenges done

### Verify:
- Kids can complete individual challenges
- Progress shows correctly
- Final submit unlocks when all done

---

## Phase 11: Points System

**Goal:** Points awarded on badge approval, tracked per kid

### Steps:
1. Add `current_points` and `lifetime_points` to User (or calculate dynamically)
2. On badge approval:
   - Add badge points to user's balance
3. Create User methods:
   - `#available_points` - earned minus spent
   - `#lifetime_points` - total ever earned
4. Update kid dashboard:
   - Show current points prominently
   - Show points value on each badge

### Verify:
- Points awarded on approval
- Balance calculated correctly
- Dashboard shows points

---

## Phase 12: Prizes

**Goal:** Parents define prizes, kids can browse

### Steps:
1. Generate Prize model:
   ```bash
   rails generate model Prize name:string description:text point_cost:integer active:boolean family:references
   ```
2. Add ActiveStorage: `has_one_attached :image`
3. Run migration: `rails db:migrate`
4. Generate admin controller:
   ```bash
   rails generate controller Admin::Prizes index new create edit update destroy
   ```
5. Create prize management views
6. Add kid-facing prizes page:
   - Show available prizes
   - Show point cost
   - Visual indicator: can afford / need X more points

### Verify:
- Parents can CRUD prizes
- Kids see available prizes
- Affordability shown correctly

---

## Phase 13: Prize Redemption

**Goal:** Kids request prizes, parents approve/deny

### Steps:
1. Generate Redemption model:
   ```bash
   rails generate model Redemption prize:references user:references status:string requested_at:datetime reviewed_at:datetime reviewed_by:references kid_note:text parent_feedback:text points_spent:integer
   ```
2. Run migration: `rails db:migrate`
3. Add status enum: `pending`, `approved`, `denied`
4. Generate redemptions controller for kids:
   ```bash
   rails generate controller Redemptions new create index
   ```
5. Generate admin redemptions controller:
   ```bash
   rails generate controller Admin::Redemptions index show approve deny
   ```
6. Kid redemption flow:
   - Request prize (validate sufficient points)
   - Optional note
   - Creates pending redemption
7. Parent review:
   - See pending redemptions
   - Approve (deduct points) or deny
8. Prevent overspending:
   - Re-validate points at approval time
   - Handle concurrent requests

### Verify:
- Kids can request prizes
- Parents approve/deny
- Points deducted correctly
- Can't overspend

---

## Phase 14: Notifications

**Goal:** Email notifications for key events

### Steps:
1. Generate mailer:
   ```bash
   rails generate mailer NotificationMailer
   ```
2. Implement emails:
   - `badge_submitted(submission)` - to all parents
   - `badge_approved(submission)` - to kid (if email set)
   - `badge_denied(submission)` - to kid
   - `redemption_requested(redemption)` - to parents
   - `redemption_approved(redemption)` - to kid
   - `redemption_denied(redemption)` - to kid
3. Add `after_commit` callbacks (or use ActiveJob)
4. Use `deliver_later` for async
5. Test with Postmark in staging

### Verify:
- Emails send on key events
- Parents notified of submissions
- Kids notified of decisions

---

## Phase 15: Polish & UX

**Goal:** Make it feel great

### Steps:
1. Apply family-fun-tracker styling:
   - Colorful gradient cards
   - Progress rings
   - Sidebar navigation
   - Responsive design
2. Add status pills: Available / In Progress / Ready to Submit / Pending / Earned / Denied
3. Add flash messages for actions
4. Add confirmation dialogs for destructive actions
5. Kid profile page:
   - Current points
   - Lifetime points
   - Earned badges
   - Redeemed prizes history
6. Badge detail improvements:
   - Show full state clearly
   - Show challenge progress (7/10 complete)
7. Category filtering on dashboards

### Verify:
- App looks polished
- Clear status at every step
- Responsive on mobile

---

## Phase 16: Final Checks

**Goal:** Production ready

### Steps:
1. Add seed data for demo:
   - Family with parents + kids
   - Categories, badges, challenges
   - Some earned badges
   - Prizes
2. Set up environment variables:
   - `SENTRY_DSN`
   - `POSTMARK_API_TOKEN`
   - `DEFAULT_FROM_EMAIL`
3. Verify Hatchbox deploy works
4. Test full flows:
   - Parent creates badge with challenges
   - Kid completes challenges, submits
   - Parent approves
   - Kid redeems prize
   - Parent approves
5. Security review:
   - Parents can only see their family
   - Kids can only see their data
   - Pundit or manual authorization

---

## Badge State Machine (Reference)

For any kid + badge combination:

| State | Condition |
|-------|-----------|
| **Available** | Published, assigned to kid's group, no submissions |
| **In Progress** | Has completed challenges but not all |
| **Ready to Submit** | All challenges complete (or no challenges), no pending submission |
| **Pending Review** | Submission awaiting parent decision |
| **Denied** | Latest submission denied |
| **Earned** | Has approved submission |

---

## Data Model Summary

```
Family
├── Users (parent/kid)
├── Groups
│   └── GroupMemberships → Users
├── BadgeCategories (sorted)
├── Badges
│   ├── BadgeAssignments → Groups
│   ├── BadgeChallenges (sorted)
│   └── BadgeSubmissions → User
│       └── attachments
├── ChallengeCompletions → User, BadgeChallenge
│   └── attachments
└── Prizes
    └── Redemptions → User
```

---

## Non-Goals (Out of Scope)

- No gamification beyond points/badges
- No streaks or leaderboards
- No cross-family sharing
- No public profiles
- No mobile app
- No Docker deployment
