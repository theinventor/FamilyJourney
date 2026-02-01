---
name: familyjourney
description: Interact with FamilyJourney badge-earning app API. Use when users ask about kids, badges, points, submissions, prizes, or family activities. Requires API key in TOOLS.md.
---

# FamilyJourney Skill

Manage your family's badge-earning journey via API.

## Setup

Store API keys in `TOOLS.md`:
```markdown
## FamilyJourney API Keys
- **Desiree**: `fj_abc123...` (base URL: http://mac-mini:3000)
```

## Quick Reference

```bash
# All commands use: python3 ~/clawd/skills/familyjourney/scripts/fj.py
FJ="python3 ~/clawd/skills/familyjourney/scripts/fj.py --token TOKEN --url http://mac-mini:3000"

# Kids
$FJ kids list                    # List all kids
$FJ kids show ID                 # Show kid details + points
$FJ kids create --name "Name"    # Add a kid

# Badges
$FJ badges list                  # List available badges
$FJ badges show ID               # Badge details

# Submissions (pending reviews)
$FJ submissions list             # Pending badge submissions
$FJ submissions show ID          # Submission details
$FJ submissions approve ID       # Approve submission
$FJ submissions deny ID --reason "Why"  # Deny with feedback

# Prizes
$FJ prizes list                  # Available prizes
$FJ prizes create --name "Prize" --points 100

# Redemptions (prize requests)
$FJ redemptions list             # Pending redemptions
$FJ redemptions approve ID       # Approve prize redemption
$FJ redemptions deny ID --reason "Why"

# Family overview
$FJ family                       # Family summary + all kids
```

## Common Tasks

**Check pending reviews:**
```bash
$FJ submissions list
```

**Approve a badge submission:**
```bash
$FJ submissions approve 5
```

**See a kid's progress:**
```bash
$FJ kids show 2
```

**Add a new prize:**
```bash
$FJ prizes create --name "Movie Night" --description "Pick any movie" --points 50
```

## Notes

- API is parent-only (kids use the web UI)
- Base URL is typically `http://mac-mini:3000` on local network
- Each parent has their own API key (shown in their dashboard)
