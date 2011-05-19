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
