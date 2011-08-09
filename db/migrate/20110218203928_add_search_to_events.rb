class AddSearchToEvents < ActiveRecord::Migration
  def self.up
    unless column_exists?(:events, :search)
      add_column(:events, :search, :text)
    end
  end

  def self.down
  end
end
