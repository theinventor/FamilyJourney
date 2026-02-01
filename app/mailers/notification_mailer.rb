class NotificationMailer < ApplicationMailer
  def badge_submitted(submission)
    @submission = submission
    @badge = submission.badge
    @kid = submission.user
    @family = @kid.family

    parent_emails = @family.parents.pluck(:email)
    return if parent_emails.empty?

    mail(
      to: parent_emails,
      subject: "#{@kid.name} submitted #{@badge.title} for review"
    )
  end

  def badge_approved(submission)
    @submission = submission
    @badge = submission.badge
    @kid = submission.user

    mail(
      to: @kid.email,
      subject: "Congratulations! You earned the #{@badge.title} badge!"
    )
  end

  def badge_denied(submission)
    @submission = submission
    @badge = submission.badge
    @kid = submission.user
    @feedback = submission.parent_feedback

    mail(
      to: @kid.email,
      subject: "#{@badge.title} badge needs revision"
    )
  end

  def redemption_requested(redemption)
    @redemption = redemption
    @prize = redemption.prize
    @kid = redemption.user
    @family = @kid.family

    parent_emails = @family.parents.pluck(:email)
    return if parent_emails.empty?

    mail(
      to: parent_emails,
      subject: "#{@kid.name} requested #{@prize.name}"
    )
  end

  def redemption_approved(redemption)
    @redemption = redemption
    @prize = redemption.prize
    @kid = redemption.user

    mail(
      to: @kid.email,
      subject: "Your #{@prize.name} prize was approved!"
    )
  end

  def redemption_denied(redemption)
    @redemption = redemption
    @prize = redemption.prize
    @kid = redemption.user
    @feedback = redemption.parent_feedback

    mail(
      to: @kid.email,
      subject: "#{@prize.name} prize request denied"
    )
  end
end
