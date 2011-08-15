class EventImage < ActiveRecord::Base
  belongs_to :organization
  has_many :events

  mount_uploader :image, ImageUploader

  def url(*args)
    image.url(*args)
  end
end

# == Schema Information
#
# Table name: images
#
#  id         :integer         not null, primary key
#  image      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

