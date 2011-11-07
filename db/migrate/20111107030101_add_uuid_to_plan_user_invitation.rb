class AddUuidToPlanUserInvitation < ActiveRecord::Migration
  def self.up
    add_column :plan_user_invitations, :uuid, :string
  end

  def self.down
    remove_column :plan_user_invitations, :uuid
  end
end
