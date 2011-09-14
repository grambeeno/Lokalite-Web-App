class AddSuiteToLocation < ActiveRecord::Migration
  def self.up
    add_column :locations, :suite, :string
    add_column :locations, :user_given_street, :string
  end

  def self.down
    remove_column :locations, :user_given_street
    remove_column :locations, :suite
  end
end
