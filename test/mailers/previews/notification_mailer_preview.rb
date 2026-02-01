# Preview all emails at http://localhost:3000/rails/mailers/notification_mailer
class NotificationMailerPreview < ActionMailer::Preview
  # Preview: http://localhost:3000/rails/mailers/notification_mailer/badge_submitted
  def badge_submitted
    submission = BadgeSubmission.pending_review.first || create_sample_submission(:pending_review)
    NotificationMailer.badge_submitted(submission)
  end

  # Preview: http://localhost:3000/rails/mailers/notification_mailer/badge_approved
  def badge_approved
    submission = BadgeSubmission.approved.first || create_sample_submission(:approved)
    NotificationMailer.badge_approved(submission)
  end

  # Preview: http://localhost:3000/rails/mailers/notification_mailer/badge_denied
  def badge_denied
    submission = BadgeSubmission.denied.first || create_sample_submission(:denied)
    NotificationMailer.badge_denied(submission)
  end

  # Preview: http://localhost:3000/rails/mailers/notification_mailer/redemption_requested
  def redemption_requested
    redemption = Redemption.pending.first || create_sample_redemption(:pending)
    NotificationMailer.redemption_requested(redemption)
  end

  # Preview: http://localhost:3000/rails/mailers/notification_mailer/redemption_approved
  def redemption_approved
    redemption = Redemption.approved.first || create_sample_redemption(:approved)
    NotificationMailer.redemption_approved(redemption)
  end

  # Preview: http://localhost:3000/rails/mailers/notification_mailer/redemption_denied
  def redemption_denied
    redemption = Redemption.denied.first || create_sample_redemption(:denied)
    NotificationMailer.redemption_denied(redemption)
  end

  private

  def create_sample_submission(status)
    family = Family.first || Family.create!(name: "Preview Family")
    parent = family.users.parents.first || family.users.create!(
      email: "preview-parent@example.com",
      password: "password123",
      name: "Preview Parent",
      role: :parent
    )
    kid = family.users.kids.first || family.users.create!(
      email: "preview-kid@example.com",
      password: "password123",
      name: "Preview Kid",
      role: :kid
    )
    badge = Badge.first || Badge.create!(
      family: family,
      title: "Preview Badge",
      description: "A sample badge for email previews",
      points: 10
    )
    BadgeSubmission.create!(
      user: kid,
      badge: badge,
      status: status,
      notes: "Sample submission notes",
      parent_feedback: status == :denied ? "Please try again with more detail." : nil
    )
  end

  def create_sample_redemption(status)
    family = Family.first || Family.create!(name: "Preview Family")
    kid = family.users.kids.first || family.users.create!(
      email: "preview-kid@example.com",
      password: "password123",
      name: "Preview Kid",
      role: :kid,
      points: 100
    )
    prize = Prize.first || Prize.create!(
      family: family,
      name: "Preview Prize",
      description: "A sample prize for email previews",
      points_required: 50
    )
    Redemption.create!(
      user: kid,
      prize: prize,
      status: status,
      parent_feedback: status == :denied ? "Not available right now." : nil
    )
  end
end
