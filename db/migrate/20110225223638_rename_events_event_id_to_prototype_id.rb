class RenameEventsEventIdToPrototypeId < ActiveRecord::Migration
  def self.up
    unless column_exists?(:events, :prototype_id)
      if column_exists?(:events, :event_id)
        rename_column(:events, :event_id, :prototype_id)
      end
    end

    unless column_exists?(:events, :clone_count)
      add_column(:events, :clone_count, :integer, :default => 0)
    end

    Event.update_clone_counts!
  end

  def self.down
  end
end
