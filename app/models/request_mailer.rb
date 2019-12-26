class RequestMailer < Mailer

  def request_add(user, requests)
    @requests = requests
    @user = user
    #@request_url = url_for(:controller => 'change_deadlines', :action => 'show', :id => request)
    mail :to => user.mail, :subject => "New request to change deadline"
  end

  def self.deliver_request_add(users, requests)
    users.each do |user|
      request_add(user, requests).deliver_now
    end
  end

  def request_approved(user, request)
    @request = request
    @user = request.user
    mail :to => @user.mail, :subject => "Request Approved"
  end

  def self.deliver_request_approved(user, request)
    request_approved(user, request).deliver_now
  end

  def request_rejected(user, request)
    @request = request
    @user = request.user
    mail :to => @user.mail, :subject => "Request Rejected"
  end

  def self.deliver_request_rejected(user, request)
    request_rejected(user, request).deliver_now
  end


end