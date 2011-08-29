class AddTrendWeightToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :trend_weight, :decimal, :default => 0
    add_column :events, :anonymous_trend_count, :integer, :default => 0

    Event.reset_column_information

    for e in Event.all
      e.save
    end
  end

  def self.down
    remove_column :events, :anonymous_trend_count
    remove_column :events, :trend_weight
  end
end
