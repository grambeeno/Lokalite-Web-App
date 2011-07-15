class Session < ActiveRecord::Base
  belongs_to :user
  serialize(:data, Hash)

  def update!(hash)
    data.update(hash)
  ensure
    save!
  end

  def [](key)
    data[key]
  end

  def []=(key, val)
    update!(key => val)
  end
end

# == Schema Information
#
# Table name: sessions
#
#  id         :integer         not null, primary key
#  data       :text            default("--- {}\n\n")
#  user_id    :integer         not null
#  created_at :datetime
#  updated_at :datetime
#

