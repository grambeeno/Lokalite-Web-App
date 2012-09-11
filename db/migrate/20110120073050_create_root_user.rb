class CreateRootUser < ActiveRecord::Migration
  def self.up
    # user = User.create!(:email => App.email)
    # User.update_all('id=0', ['id=?', user.id])
    # user = User.find(0)
  end

  def self.down
    User.find(0).destroy
  end
end
