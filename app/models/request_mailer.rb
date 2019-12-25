class RequestMailer < Mailer

  def request_add(user, requests)
    @requests = requests
    @uses = user
    #@request_url = url_for(:controller => 'change_deadlines', :action => 'show', :id => request)
    mail :to => user.mail, :subject => "New request to change deadline"
  end

  def self.deliver_request_add(users, requests)
    users.each do |user|
      request_add(user, requests).deliver_now
    end

  end
end