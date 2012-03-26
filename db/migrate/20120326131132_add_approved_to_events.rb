class AddApprovedToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :created_by_id, :integer
    add_column :events, :approved, :boolean, :default => false

    Event.reset_column_information

    Event.update_all(:created_by_id => 1, :approved => true)
  end

  def self.down
    remove_column :events, :approved
    remove_column :events, :created_by_id
  end
end
