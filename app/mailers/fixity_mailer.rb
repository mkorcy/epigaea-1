# frozen_string_literal: true

class FixityMailer < ActionMailer::Base
  default from: 'mike.korcynski@tufts.edu'
  def fixity_email(user, subject, message)
    @user = user
    @message = message
    @subject = subject

    send_mail
  end

  def send_mail
    mail(
      to: @user,
      subject: @subject,
      body: @message
    )
  end
end
