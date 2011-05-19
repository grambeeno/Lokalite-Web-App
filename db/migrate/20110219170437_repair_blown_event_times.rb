class RepairBlownEventTimes < ActiveRecord::Migration
  def self.up
    Event.find_in_batches do |events|
      events.each do |event|
        if event.ends_at.blank? or event.ends_at < event.starts_at
          event.ends_at = event.starts_at + 1.hour
          event.save!
          puts "repaired event.#{ event.id }..."
        end
      end
    end
  end

  def self.down
  end
end
