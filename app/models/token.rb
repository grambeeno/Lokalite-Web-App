class Token < ActiveRecord::Base
  belongs_to(:context, :polymorphic => true)
  serialize(:data, Hash)

  before_validation(:on => :create) do |token|
    token.uuid ||= App.uuid
  end

  def to_s
    uuid
  end

  def signup
    context if context.is_a?(Signup)
  end

  def user
    context if context.is_a?(User)
  end

  def expired?
    expires_at ? expires_at < Time.now : nil
  end

  def expire!
    update_attributes!(:expires_at => (Time.now - 1))
  end
end

# == Schema Information
#
# Table name: tokens
#
#  id           :integer         not null, primary key
#  uuid         :string(255)
#  kind         :string(255)
#  context_id   :integer
#  context_type :string(255)
#  counter      :integer         default(0)
#  expires_at   :datetime
#  data         :text            default("--- {}\n\n")
#  created_at   :datetime
#  updated_at   :datetime
#

