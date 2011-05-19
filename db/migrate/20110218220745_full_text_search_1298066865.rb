class FullTextSearch1298066865 < ActiveRecord::Migration
  def self.up
    execute(<<-'eosql'.strip)
      DROP index IF EXISTS events_fts_idx
    eosql
    execute(<<-'eosql'.strip)
      CREATE index events_fts_idx
      ON events
      USING gin((to_tsvector('english', coalesce("events"."search", ''))))
    eosql
  end

  def self.down
    execute(<<-'eosql'.strip)
      DROP index IF EXISTS events_fts_idx
    eosql
  end
end
