class AddRepeatsToEvents < ActiveRecord::Migration
  def self.up
    add_column(:events, :repeats, :string)
  end

  def self.down
    remove_column(:events, :repeats)
  end
end
