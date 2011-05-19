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
