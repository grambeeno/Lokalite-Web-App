class Image < ActiveRecord::Base
  has_many :image_context_joins, :dependent => :destroy

  mount_uploader :image, ImageUploader

  def url(*args)
    image.url(*args)
  end

  def Image.for(arg)
    arg = open(arg) unless arg.respond_to?(:read)
    new(:image => arg)
  end

  def basename
    read_attribute(:image)
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

