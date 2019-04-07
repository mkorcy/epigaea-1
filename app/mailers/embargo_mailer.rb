class EmbargoMailer < ApplicationMailer
  default from: 'dlsystems@elist.tufts.edu'
  def embargo_email(user, subject, body)
    @user = user
    @subject = subject
    @body = body
    mail(to: @user.email, subject: @subject, body: @body)
  end
end
