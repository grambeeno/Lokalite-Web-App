class AddRequestIdToPlanUserInvitation < ActiveRecord::Migration
  def self.up
    add_column :plan_user_invitations, :request_id, :string
  end

  def self.down
    remove_column :plan_user_invitations, :request_id
  end
end
