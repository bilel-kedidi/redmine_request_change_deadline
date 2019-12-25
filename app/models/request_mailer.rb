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

  def request_approved(request)
    @request = request
    @user = request.user
    mail :to => @user.mail, :subject => "Request Approved"
  end

  def self.deliver_request_approved(request)
    request_approved(request).deliver_now
  end

  def request_rejected(request)
    @request = request
    @user = request.user
    mail :to => @user.mail, :subject => "Request Rejected"
  end

  def self.deliver_request_rejected(request)
    request_rejected(request).deliver_now
  end


end