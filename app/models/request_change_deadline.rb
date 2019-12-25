class RequestChangeDeadline < ActiveRecord::Base

  include Redmine::SafeAttributes

  belongs_to :user
  belongs_to :issue

  delegate :project, :due_date, :subject, :assigned_to, :author, :priority, :done_ratio, to: :issue

  acts_as_customizable

  safe_attributes 'reason',
                  'new_deadline'

  scope :visible, -> { (User.current.allowed_to_globally?(:approve_deadline_request, {}) ||  User.current.allowed_to_globally?(:reject_deadline_request, {}) )? where(nil) : where(user_id: User.current.id) }

  def status
    s = super
    case s
    when '0', 0  then 'Pending'
    when '1', 1  then 'Approved'
    when '2', 2  then 'Rejected'
    when '3', 3  then 'Submitted'
    else
      '-'
    end
  end

end
