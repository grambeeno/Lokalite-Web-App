class RemoveSignupAndTokenTables < ActiveRecord::Migration
  def self.up
    drop_table :signups
    drop_table :tokens
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
