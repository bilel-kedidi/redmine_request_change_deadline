require_dependency 'issue'

module RedmineRequestChangeDeadline
  module IssuePatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        attr_accessor :is_due_date_changed
      end
    end

    module InstanceMethods

    end
  end
end