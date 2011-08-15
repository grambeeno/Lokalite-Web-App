class EventImage < ActiveRecord::Base
  belongs_to :organization
  has_many :events, :foreign_key => 'image_id'

  mount_uploader :image, ImageUploader

  def url(*args)
    image.url(*args)
  end
end


# == Schema Information
#
# Table name: event_images
#
#  id              :integer         not null, primary key
#  image           :string(255)
#  organization_id :integer
#  created_at      :datetime
#  updated_at      :datetime
#

