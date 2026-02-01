# FamilyJourney API Documentation

This document describes how to use the FamilyJourney REST API to programmatically manage all parent-side functionality. The API is designed to be used by AI agents or other automated systems.

## Authentication

The API uses token-based authentication with Bearer tokens.

### Getting Your API Token

1. Your API token is automatically generated when you create a parent account
2. To retrieve your token, log into the Rails console or web interface as a parent
3. For testing, you can use the temporary script:

```bash
rails runner tmp/generate_api_token.rb
```

### Using Your Token

Include your token in the `Authorization` header of all API requests:

```bash
Authorization: Bearer YOUR_TOKEN_HERE
```

### Example Login (Alternative)

You can also authenticate via the login endpoint:

```bash
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "parent@example.com",
  "password": "your_password"
}
```

Response:
```json
{
  "token": "3e3101065c8d37bc988683e06df9d4ebc41a9e63492ef4547fa6c43b050a3fea",
  "user": {
    "id": 1,
    "email": "parent@example.com",
    "name": "Parent Name",
    "role": "parent",
    "family_id": 1
  }
}
```

## Base URL

All API endpoints are prefixed with `/api/v1`:

```
http://localhost:3000/api/v1
```

## API Endpoints

### Authentication

#### Get Current User
```bash
GET /api/v1/auth/me
```

#### Logout (Regenerate Token)
```bash
POST /api/v1/auth/logout
```

### Family

#### Get Family Overview
```bash
GET /api/v1/family
```

Response includes family stats like total kids, badges, pending reviews, etc.

### Badges

#### List All Badges
```bash
GET /api/v1/badges
```

#### Get Single Badge
```bash
GET /api/v1/badges/:id
```

#### Create Badge
```bash
POST /api/v1/badges
Content-Type: application/json

{
  "badge": {
    "title": "New Badge",
    "description": "Badge description",
    "points": 50,
    "badge_category_id": 1,
    "group_ids": [1, 2],
    "badge_challenges_attributes": [
      {
        "description": "Challenge 1",
        "position": 1
      },
      {
        "description": "Challenge 2",
        "position": 2
      }
    ]
  }
}
```

#### Update Badge
```bash
PATCH /api/v1/badges/:id
Content-Type: application/json

{
  "badge": {
    "title": "Updated Badge",
    "points": 75
  }
}
```

#### Delete Badge
```bash
DELETE /api/v1/badges/:id
```

#### Publish Badge
```bash
POST /api/v1/badges/:id/publish
```

#### Unpublish Badge
```bash
POST /api/v1/badges/:id/unpublish
```

### Badge Categories

#### List All Categories
```bash
GET /api/v1/badge_categories
```

#### Get Single Category
```bash
GET /api/v1/badge_categories/:id
```

#### Create Category
```bash
POST /api/v1/badge_categories
Content-Type: application/json

{
  "badge_category": {
    "name": "New Category",
    "description": "Optional description"
  }
}
```

#### Update Category
```bash
PATCH /api/v1/badge_categories/:id
```

#### Delete Category
```bash
DELETE /api/v1/badge_categories/:id
```

#### Move Category Up
```bash
POST /api/v1/badge_categories/:id/move_up
```

#### Move Category Down
```bash
POST /api/v1/badge_categories/:id/move_down
```

### Badge Submissions (Reviews)

#### List All Submissions
```bash
GET /api/v1/badge_submissions
```

Filter by status:
```bash
GET /api/v1/badge_submissions?status=pending_review
GET /api/v1/badge_submissions?status=approved
GET /api/v1/badge_submissions?status=denied
```

#### Get Single Submission
```bash
GET /api/v1/badge_submissions/:id
```

#### Approve Submission
```bash
POST /api/v1/badge_submissions/:id/approve
```

#### Deny Submission
```bash
POST /api/v1/badge_submissions/:id/deny
Content-Type: application/json

{
  "reason": "Please provide more detail"
}
```

### Challenges

#### List All Challenges
```bash
GET /api/v1/challenges
GET /api/v1/challenges?badge_id=1
```

#### Get Single Challenge
```bash
GET /api/v1/challenges/:id
```

#### Create Challenge
```bash
POST /api/v1/challenges
Content-Type: application/json

{
  "badge_id": 1,
  "challenge": {
    "description": "Challenge description",
    "position": 1
  }
}
```

#### Update Challenge
```bash
PATCH /api/v1/challenges/:id
```

#### Delete Challenge
```bash
DELETE /api/v1/challenges/:id
```

### Prizes

#### List All Prizes
```bash
GET /api/v1/prizes
```

#### Get Single Prize
```bash
GET /api/v1/prizes/:id
```

#### Create Prize
```bash
POST /api/v1/prizes
Content-Type: application/json

{
  "prize": {
    "name": "Ice Cream Trip",
    "description": "Trip to favorite ice cream shop",
    "point_cost": 100,
    "status": "active",
    "group_ids": [1, 2]
  }
}
```

#### Update Prize
```bash
PATCH /api/v1/prizes/:id
```

#### Delete Prize
```bash
DELETE /api/v1/prizes/:id
```

### Redemptions

#### List All Redemptions
```bash
GET /api/v1/redemptions
```

Filter by status:
```bash
GET /api/v1/redemptions?status=pending
GET /api/v1/redemptions?status=approved
GET /api/v1/redemptions?status=denied
```

#### Get Single Redemption
```bash
GET /api/v1/redemptions/:id
```

#### Approve Redemption
```bash
POST /api/v1/redemptions/:id/approve
```

#### Deny Redemption
```bash
POST /api/v1/redemptions/:id/deny
```

### Kids

#### List All Kids
```bash
GET /api/v1/kids
```

#### Get Single Kid
```bash
GET /api/v1/kids/:id
```

Response includes points and badge stats.

#### Create Kid
```bash
POST /api/v1/kids
Content-Type: application/json

{
  "kid": {
    "name": "New Kid",
    "email": "kid@example.com",
    "group_ids": [1]
  }
}
```

Response includes auto-generated password.

#### Update Kid
```bash
PATCH /api/v1/kids/:id
```

#### Delete Kid
```bash
DELETE /api/v1/kids/:id
```

#### Reset Kid Password
```bash
POST /api/v1/kids/:id/reset_password
```

Returns new password in response.

### Groups

#### List All Groups
```bash
GET /api/v1/groups
```

#### Get Single Group
```bash
GET /api/v1/groups/:id
```

#### Create Group
```bash
POST /api/v1/groups
Content-Type: application/json

{
  "group": {
    "name": "Older Kids",
    "description": "Ages 10+"
  }
}
```

#### Update Group
```bash
PATCH /api/v1/groups/:id
```

#### Delete Group
```bash
DELETE /api/v1/groups/:id
```

#### Add Member to Group
```bash
POST /api/v1/groups/:id/add_member
Content-Type: application/json

{
  "user_id": 2
}
```

#### Remove Member from Group
```bash
POST /api/v1/groups/:id/remove_member
Content-Type: application/json

{
  "user_id": 2
}
```

## Example Workflows for AI Agents

### 1. Check for Pending Reviews

```bash
# Get family overview
curl -H "Authorization: Bearer TOKEN" \
  http://localhost:3000/api/v1/family

# Get pending submissions
curl -H "Authorization: Bearer TOKEN" \
  http://localhost:3000/api/v1/badge_submissions?status=pending_review

# Get pending redemptions
curl -H "Authorization: Bearer TOKEN" \
  http://localhost:3000/api/v1/redemptions?status=pending
```

### 2. Create a New Badge

```bash
# List categories
curl -H "Authorization: Bearer TOKEN" \
  http://localhost:3000/api/v1/badge_categories

# List groups
curl -H "Authorization: Bearer TOKEN" \
  http://localhost:3000/api/v1/groups

# Create badge
curl -X POST -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "badge": {
      "title": "Math Master",
      "description": "Complete 10 math worksheets with 90%+ accuracy",
      "points": 75,
      "badge_category_id": 2,
      "group_ids": [1]
    }
  }' \
  http://localhost:3000/api/v1/badges

# Publish the badge
curl -X POST -H "Authorization: Bearer TOKEN" \
  http://localhost:3000/api/v1/badges/8/publish
```

### 3. Review Badge Submissions

```bash
# Get pending submissions
curl -H "Authorization: Bearer TOKEN" \
  http://localhost:3000/api/v1/badge_submissions?status=pending_review

# Get details on a specific submission
curl -H "Authorization: Bearer TOKEN" \
  http://localhost:3000/api/v1/badge_submissions/3

# Approve the submission
curl -X POST -H "Authorization: Bearer TOKEN" \
  http://localhost:3000/api/v1/badge_submissions/3/approve

# Or deny with reason
curl -X POST -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"reason": "Please provide photo evidence"}' \
  http://localhost:3000/api/v1/badge_submissions/3/deny
```

### 4. Manage Kids and Groups

```bash
# Create a new kid
curl -X POST -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "kid": {
      "name": "Sarah",
      "email": "sarah@example.com",
      "group_ids": [1]
    }
  }' \
  http://localhost:3000/api/v1/kids

# Add kid to a group
curl -X POST -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"user_id": 2}' \
  http://localhost:3000/api/v1/groups/2/add_member

# Reset a kid's password
curl -X POST -H "Authorization: Bearer TOKEN" \
  http://localhost:3000/api/v1/kids/2/reset_password
```

## Error Responses

All endpoints return standard HTTP status codes:

- `200 OK` - Successful request
- `201 Created` - Resource created successfully
- `401 Unauthorized` - Invalid or missing token
- `403 Forbidden` - Not a parent account
- `404 Not Found` - Resource not found
- `422 Unprocessable Entity` - Validation errors

Error response format:
```json
{
  "error": "Error message"
}
```

Or for validation errors:
```json
{
  "errors": [
    "Title can't be blank",
    "Points must be greater than or equal to 0"
  ]
}
```

## Tips for AI Agents

1. **Always check family stats first** to understand the current state
2. **Filter submissions by status** to focus on pending items
3. **Use detailed endpoints** (GET /api/v1/badges/:id) when you need full information including groups and challenges
4. **Batch operations** - fetch all resources at once, then process them
5. **Handle errors gracefully** - check response status codes
6. **Store the API token securely** - it provides full parent access

## Security Notes

- API tokens provide full parent access to the family
- Only parent accounts can use the API
- All operations are scoped to the parent's family
- Tokens can be regenerated via the logout endpoint
- Never share your API token publicly
