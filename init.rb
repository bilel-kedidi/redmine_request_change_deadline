Redmine::Plugin.register :redmine_request_change_deadline do
  name 'Redmine Request Change Deadline plugin'
  author 'Bilel KEDIDI'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'https://www.github.com/bilel-kedidi/redmine_request_change_deadline'
  author_url 'https://www.biz-solution.pro'

  menu :top_menu, :request_change_deadline, {:controller => 'change_deadlines', :action => 'index' },
       :caption => 'Requests to change deadline', html: {class: 'icon icon-list'},  :if => Proc.new {
        User.current.allowed_to_globally?(:view_deadline_request, {}) or
            User.current.allowed_to_globally?(:view_deadline_request, {})
      }

  project_module :deadline_change do
    permission :view_deadline_request, :change_deadlines => [:index, :show]
    permission :edit_deadline_request, :change_deadlines => [:edit, :update]
    permission :delete_deadline_request, :change_deadlines => :destroy
    permission :approve_deadline_request, :change_deadlines => :approve_request
    permission :reject_deadline_request, :change_deadlines => :reject_request
    permission :create_deadline_request, :change_deadlines => [:create, :new, :submit_request]
  end

  module RedmineRequestChangeDeadline
    class Hooks < Redmine::Hook::ViewListener
      render_on :view_issues_context_menu_end, :partial => 'issues/hooks/view_issues_context_menu_end'

      def controller_issues_edit_before_save(context={})
        issue = context[:issue]
        cf_setting = Setting.plugin_redmine_request_change_deadline['custom_field']
        request_issue_status = Setting.plugin_redmine_request_change_deadline['issue_status']
        if request_issue_status.include?(issue.status_id.to_s) && issue.due_date_changed?
          issue.is_due_date_changed = true
        end
      end

      def controller_issues_edit_after_save(context={})
        issue = context[:issue]
        cf_setting = Setting.plugin_redmine_request_change_deadline['custom_field']
        request_issue_status = Setting.plugin_redmine_request_change_deadline['issue_status']
        if request_issue_status.include?(issue.status_id.to_s) && issue.is_due_date_changed
          cfv = issue.custom_values.detect { |cv|
            cv.custom_field_id == cf_setting.first.to_i
          }
          if cfv
            cfv.value = issue.due_date
            cfv.save
          end
        end
      end
    end
  end
  settings :default => {'empty' => true}, :partial => 'settings/request_settings'
end

Rails.application.config.to_prepare do
  QueriesController.send(:include, RedmineRequestChangeDeadline::QueriesControllerPatch)
  ContextMenusController.send(:include, RedmineRequestChangeDeadline::ContextMenusControllerPatch)
  Issue.send(:include, RedmineRequestChangeDeadline::IssuePatch)
end


