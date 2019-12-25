class UpdateRequestChangeDeadlines < ActiveRecord::Migration[5.2]
  def change
    add_column :request_change_deadlines, :token, :string
  end
end
