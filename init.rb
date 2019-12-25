Redmine::Plugin.register :redmine_request_change_deadline do
  name 'Redmine Request Change Deadline plugin'
  author 'Bilel KEDIDI'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'https://www.github.com/bilel-kedidi/redmine_request_change_deadline'
  author_url 'https://www.biz-solution.pro'

  menu :admin_menu, :request_change_deadline, {:controller => 'change_deadlines', :action => 'index' },
       :caption => 'Requests to change deadline', html: {class: 'icon icon-list'}

  project_module :deadline_change do
    permission :view_deadline_request, :change_deadlines => :show
    permission :edit_deadline_request, :change_deadlines => :edit
    permission :delete_deadline_request, :change_deadlines => :destroy
    permission :approve_deadline_request, :change_deadlines => :approve_request
    permission :reject_deadline_request, :change_deadlines => :reject_request
    permission :create_deadline_request, :change_deadlines => :create
  end

  #permission :approve_requests, :change_deadlines => :approve_request
  #permission :reject_requests, :change_deadlines => :reject_request

  settings :default => {'empty' => true}, :partial => 'settings/request_settings'
end

Rails.application.config.to_prepare do
  QueriesController.send(:include, RedmineRequestChangeDeadline::QueriesControllerPatch)
   ContextMenusController.send(:include, RedmineRequestChangeDeadline::ContextMenusControllerPatch)
end


