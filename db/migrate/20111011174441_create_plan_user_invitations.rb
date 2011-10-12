class CreatePlanUserInvitations < ActiveRecord::Migration
  def self.up
    create_table :plan_user_invitations do |t|
      t.references :user
      t.references :plan
      t.boolean :accepted

      t.timestamps
    end

    add_index :plan_user_invitations, [:user_id]
    add_index :plan_user_invitations, [:plan_id]
    add_index :plan_user_invitations, [:accepted]
  end

  def self.down
    drop_table :plan_user_invitations
  end
end
