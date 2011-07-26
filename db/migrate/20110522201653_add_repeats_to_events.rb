class AddRepeatsToEvents < ActiveRecord::Migration
  def self.up
    add_column(:events, :repeats, :string)

    # How do we know whether a repeating event is daily or weekly if we're
    # filling in the repeats field for the first time?
    # Well, we can count the number of repeats.  Since events are always
    # created in three month blocks, the number of repeats should be:
    #     daily: about 90 * 7 / 7 = about 90 events 
    #  weekdays: about 90 * 5 / 7 = about 64 events
    #  weekends: about 90 * 2 / 7 = about 26 events
    #    weekly: about 90 * 1 / 7 = about 13 events
    # That count is approximate because the number of days in a month varies,
    # and the starting/ending dates might fall or not fall on a weekend.
    # execute "update events set repeats = 'daily'
    #   where id in (select prototype_id from events
    #     where prototype_id is not null
    #     group by prototype_id having count(*) > 85 and count(*) < 95);"
    # execute "update events set repeats = 'daily'
    #   where prototype_id in (select prototype_id from events
    #     where prototype_id is not null
    #     group by prototype_id having count(*) > 85 and count(*) < 95);"
    # execute "update events set repeats = 'weekdays'
    #   where id in (select prototype_id from events
    #     where prototype_id is not null
    #     group by prototype_id having count(*) > 55 and count(*) < 75);"
    # execute "update events set repeats = 'weekdays'
    #   where prototype_id in (select prototype_id from events
    #     where prototype_id is not null
    #     group by prototype_id having count(*) > 55 and count(*) < 75);"
    # execute "update events set repeats = 'weekends'
    #   where id in (select prototype_id from events
    #     where prototype_id is not null
    #     group by prototype_id having count(*) > 15 and count(*) < 35);"
    # execute "update events set repeats = 'weekends'
    #   where prototype_id in (select prototype_id from events
    #     where prototype_id is not null
    #     group by prototype_id having count(*) > 15 and count(*) < 35);"
    # execute "update events set repeats = 'weekly'
    #   where id in (select prototype_id from events
    #     where prototype_id is not null
    #     group by prototype_id having count(*) > 11 and count(*) < 15);"
    # execute "update events set repeats = 'weekly'
    #   where prototype_id in (select prototype_id from events
    #     where prototype_id is not null
    #     group by prototype_id having count(*) > 11 and count(*) < 15);"
  end

  def self.down
    remove_column(:events, :repeats)
  end
end
