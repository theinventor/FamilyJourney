# Seed data for FamilyJourney
# Credentials come from ENV vars or Rails credentials

# Only seed in development/test unless explicitly enabled
unless Rails.env.development? || Rails.env.test? || ENV["SEED_DATA"] == "true"
  puts "Skipping seed data in #{Rails.env}. Set SEED_DATA=true to force."
  exit
end

# Get password from ENV or Rails credentials, with development fallback
seed_password = ENV.fetch("SEED_PASSWORD") do
  if Rails.env.development? || Rails.env.test?
    "password123"
  else
    Rails.application.credentials.dig(:seed, :password) || raise("SEED_PASSWORD required in production")
  end
end

puts "Creating test family and users..."

family = Family.find_or_create_by!(name: "Anderson Family")

# Parent account
parent = User.find_or_initialize_by(email: "parent@test.com")
parent.update!(
  password: seed_password,
  name: "Test Parent",
  role: "parent",
  family: family
)
puts "  Created parent: #{parent.email}"

# Kid accounts
kid1 = User.find_or_initialize_by(email: "kid1@test.com")
kid1.update!(
  password: seed_password,
  name: "Emma",
  role: "kid",
  family: family
)
puts "  Created kid: #{kid1.email}"

kid2 = User.find_or_initialize_by(email: "kid2@test.com")
kid2.update!(
  password: seed_password,
  name: "Jack",
  role: "kid",
  family: family
)
puts "  Created kid: #{kid2.email}"

puts "Creating groups..."

all_kids = Group.find_or_create_by!(name: "All Kids", family: family)
all_kids.update!(description: "All children in the family")
all_kids.users = [kid1, kid2]

older_kids = Group.find_or_create_by!(name: "Older Kids", family: family)
older_kids.update!(description: "Kids 10 and up")
older_kids.users = [kid1]

puts "  Created #{family.groups.count} groups"

puts "Creating badge categories..."

chores = BadgeCategory.find_or_create_by!(name: "Chores", family: family)
learning = BadgeCategory.find_or_create_by!(name: "Learning", family: family)
skills = BadgeCategory.find_or_create_by!(name: "Life Skills", family: family)
fitness = BadgeCategory.find_or_create_by!(name: "Fitness", family: family)

puts "  Created #{family.badge_categories.count} categories"

puts "Creating badges..."

# Simple badges (no challenges)
badge1 = Badge.find_or_create_by!(title: "Make Your Bed", family: family) do |b|
  b.description = "Make your bed neatly every morning for a week"
  b.instructions = "1. Pull up sheets and straighten them\n2. Fluff and arrange pillows\n3. Smooth out any wrinkles"
  b.points = 25
  b.badge_category = chores
  b.created_by = parent
  b.status = :published
  b.published_at = Time.current
end
badge1.groups = [all_kids]

badge2 = Badge.find_or_create_by!(title: "Clean Room Champion", family: family) do |b|
  b.description = "Keep your room clean and organized for a full week"
  b.instructions = "Room must pass inspection each day:\n- Floor clear\n- Desk organized\n- Closet neat\n- No clutter"
  b.points = 50
  b.badge_category = chores
  b.created_by = parent
  b.status = :published
  b.published_at = Time.current
end
badge2.groups = [all_kids]

badge3 = Badge.find_or_create_by!(title: "Homework Hero", family: family) do |b|
  b.description = "Complete all homework on time for two weeks"
  b.points = 40
  b.badge_category = learning
  b.created_by = parent
  b.status = :published
  b.published_at = Time.current
end
badge3.groups = [all_kids]

# Multi-challenge badge
reading_badge = Badge.find_or_create_by!(title: "Reading Explorer", family: family) do |b|
  b.description = "Read 5 books and share what you learned"
  b.instructions = "Complete all 5 book challenges. After each book, write a short summary and share your favorite part."
  b.points = 100
  b.badge_category = learning
  b.created_by = parent
  b.status = :published
  b.published_at = Time.current
end
reading_badge.groups = [all_kids]

# Add challenges to reading badge
if reading_badge.badge_challenges.empty?
  5.times do |i|
    BadgeChallenge.create!(
      badge: reading_badge,
      title: "Book #{i + 1}",
      description: "Read a book and write a short summary",
      position: i + 1
    )
  end
end

# More badges
Badge.find_or_create_by!(title: "Kitchen Helper", family: family) do |b|
  b.description = "Help prepare dinner 5 times"
  b.points = 35
  b.badge_category = skills
  b.created_by = parent
  b.status = :published
  b.published_at = Time.current
end.tap { |badge| badge.groups = [all_kids] }

Badge.find_or_create_by!(title: "10K Steps", family: family) do |b|
  b.description = "Walk 10,000 steps in a single day"
  b.points = 30
  b.badge_category = fitness
  b.created_by = parent
  b.status = :published
  b.published_at = Time.current
end.tap { |badge| badge.groups = [all_kids] }

# Draft badge (not visible to kids)
Badge.find_or_create_by!(title: "Super Helper", family: family) do |b|
  b.description = "Coming soon!"
  b.points = 200
  b.created_by = parent
  b.status = :draft
end

puts "  Created #{family.badges.count} badges"

puts "Creating some earned badges..."

# Emma earns a badge
submission1 = BadgeSubmission.find_or_create_by!(badge: badge1, user: kid1) do |s|
  s.kid_notes = "I made my bed every day this week! It's becoming a habit now."
  s.status = :approved
  s.submitted_at = 3.days.ago
  s.reviewed_at = 2.days.ago
  s.reviewed_by = parent
  s.parent_feedback = "Great job Emma! Your bed looked perfect every day."
end

# Jack earns a badge
submission2 = BadgeSubmission.find_or_create_by!(badge: badge2, user: kid2) do |s|
  s.kid_notes = "My room is so clean! I can find everything now."
  s.status = :approved
  s.submitted_at = 5.days.ago
  s.reviewed_at = 4.days.ago
  s.reviewed_by = parent
end

# Emma has a pending submission
BadgeSubmission.find_or_create_by!(badge: badge3, user: kid1) do |s|
  s.kid_notes = "All my homework is done for the past two weeks!"
  s.status = :pending_review
  s.submitted_at = 1.hour.ago
end

puts "  Created badge submissions"

# Emma completes some reading challenges
reading_badge.badge_challenges.limit(3).each do |challenge|
  ChallengeCompletion.find_or_create_by!(badge_challenge: challenge, user: kid1) do |c|
    c.kid_notes = "I read this book and loved it!"
    c.completed_at = rand(1..10).days.ago
  end
end

puts "  Created challenge completions"

puts "Creating prizes..."

Prize.find_or_create_by!(name: "Movie Night", family: family) do |p|
  p.description = "Pick any movie for family movie night + popcorn!"
  p.point_cost = 50
  p.active = true
end

Prize.find_or_create_by!(name: "Ice Cream Trip", family: family) do |p|
  p.description = "A trip to the ice cream shop - get any size!"
  p.point_cost = 75
  p.active = true
end

Prize.find_or_create_by!(name: "30 Min Extra Screen Time", family: family) do |p|
  p.description = "30 extra minutes of screen time on any day"
  p.point_cost = 25
  p.active = true
end

Prize.find_or_create_by!(name: "Stay Up Late", family: family) do |p|
  p.description = "Stay up 1 hour past bedtime on a weekend"
  p.point_cost = 100
  p.active = true
end

Prize.find_or_create_by!(name: "Friend Sleepover", family: family) do |p|
  p.description = "Have a friend sleep over (parent approval of date required)"
  p.point_cost = 200
  p.active = true
end

puts "  Created #{family.prizes.count} prizes"

puts "Creating redemptions..."

Redemption.find_or_create_by!(prize: Prize.find_by(name: "30 Min Extra Screen Time"), user: kid2) do |r|
  r.kid_note = "I want to use it on Saturday!"
  r.status = :approved
  r.requested_at = 1.week.ago
  r.reviewed_at = 6.days.ago
  r.reviewed_by = parent
  r.parent_feedback = "Approved! Use it wisely."
  r.points_spent = 25
end

puts "  Created redemptions"

puts ""
puts "Seed complete!"
puts "  Family: #{family.name}"
puts "  Users: #{family.users.count} (#{family.parents.count} parents, #{family.kids.count} kids)"
puts "  Groups: #{family.groups.count}"
puts "  Badge Categories: #{family.badge_categories.count}"
puts "  Badges: #{family.badges.count} (#{family.badges.published.count} published)"
puts "  Prizes: #{family.prizes.count}"
puts ""
puts "Test accounts:"
puts "  Parent: parent@test.com / #{seed_password}"
puts "  Kid 1 (Emma): kid1@test.com / #{seed_password}"
puts "  Kid 2 (Jack): kid2@test.com / #{seed_password}"
