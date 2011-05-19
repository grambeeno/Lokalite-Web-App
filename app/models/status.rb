class Status < ActiveRecord::Base
  belongs_to :context, :polymorphic => true

  def to_s
    content
  end
end
