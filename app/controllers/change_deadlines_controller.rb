class ChangeDeadlinesController < ApplicationController

  helper :queries
  include QueriesHelper
  include ChangeDeadlinesHelper
  helper :change_deadlines

  before_action :authorize_global
  before_action :find_request, only: [:edit, :update, :show]

  before_action :find_requests, :only => [:bulk_edit, :bulk_update, :destroy, :submit_request, :approve_request, :reject_request]

  def new
    params[:back_url] = request.referrer
    @request = RequestChangeDeadline.new
    @issue_ids = params[:issue_ids]
    params[:token] = "#{('A'..'Z').to_a[rand(26)]}#{(1..99).to_a[rand(90)]}-#{Time.now.to_date}"
    @issues = Issue.find @issue_ids
  end

  def create
    new_deadlines = params[:new_deadline]
    issue_ids = []
    new_deadlines.each do |new_deadline|
      issue_ids << new_deadline.first.to_i
    end
    issues = Issue.find issue_ids
    issues.each do |issue|
      @request = RequestChangeDeadline.new
      @request.user_id = User.current.id
      @request.issue_id = issue.id
      @request.project_id = issue.project_id
      @request.new_deadline = params[:new_deadline]["#{issue.id}"]
      @request.reason = params[:reason]["#{issue.id}"]
      @request.token = params[:token]
      @cf_setting = Setting.plugin_redmine_request_change_deadline['custom_field']
      @cfv = issue.custom_values.detect { |cv|
        cv.custom_field_id == @cf_setting.first.to_i
      }
      @request.old_deadline = @cfv.value if @cfv
      @request.save
    end
    redirect_to  params[:back_url].presence || issues_path
  end

  def index
    retrieve_request_change_deadline_query
    @query.group_by = params[:group_by]  || 'token'
    if @query.valid?
      @requests_count = @query.requests_count
      @request_pages = Paginator.new @requests_count, per_page_option, params['page']
      @requests = @query.requests(:offset => @request_pages.offset, :limit => @request_pages.per_page)
    end
  end

  def edit
  end

  def bulk_edit
  end

  def update
    @request.safe_attributes = params_request
    @request.save
    redirect_to change_deadlines_path
  end

  def bulk_update
    @requests.each do |request|
      request.new_deadline = params[:new_deadline]["#{request.issue.id}"]
      request.reason = params[:reason]["#{request.issue.id}"]
      request.save
    end
    redirect_to change_deadlines_path
  end

  def show
  end

  #def destroy
  #  @request.destroy
  #  redirect_to change_deadlines_path
  #end

  def destroy
    @requests.each do |request|
      request.destroy
    end
    redirect_to change_deadlines_path
  end


  def approve_request
    @requests.each do |request|
      request.status = 1
      request.approved_by_id = User.current.id
      issue = Issue.find(request.issue_id)
      cf_setting = Setting.plugin_redmine_request_change_deadline['custom_field']
      cfv = issue.custom_values.detect { |cv|
        cv.custom_field_id == cf_setting.first.to_i
      }
      if cfv
        cfv.value = request.new_deadline
        cfv.save
        request.save
        RequestMailer.deliver_request_approved(request.user, request)
      end
    end
    redirect_to change_deadlines_path
  end

  def submit_request
    @requests.each do |request|
      request.status = 3
      request.save
      RequestMailer.deliver_request_add(User.admin, @requests)
    end
    redirect_to change_deadlines_path
  end

  #def reject_request
  #  @request.status = 2
  #  @request.save
  #  redirect_to change_deadlines_path
  #end

  def reject_request
    @requests.each do |request|
      request.status = 2
      request.save
      RequestMailer.deliver_request_rejected(request.user, request)
    end
    redirect_to change_deadlines_path
  end

  private

  def new_deadline_params
    params.require(:new_deadline).permit!
  end

  def find_request
    @request = RequestChangeDeadline.find params[:id]
  end

  def find_requests
    @requests = RequestChangeDeadline.
        where(:id => (params[:id] || params[:ids])).to_a
    raise ActiveRecord::RecordNotFound if @requests.empty?
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def params_request
    params.require(:request_change_deadline).permit(:reason, :new_deadline)
  end

  def retrieve_request_change_deadline_query
    request_retrieve_query(RequestChangeDeadlineQuery, false, :defaults => @default_columns_names)
  end
  
end
