class Role < ActiveRecord::Base
  has_many :user_role_joins, :dependent => :destroy
  has_many :users, :through => :user_role_joins

  def Role.for(value)
    return value if value.is_a?(Role)
    find_by_name(value.to_s) || Role.create!(:name => value.to_s)
  end

  Names = %w[
    admin
    event_admin
  ]

  def Role.names
    Names
  end

  def to_s
    name.to_s
  end

  def <=> other
    name.to_s <=> (other.is_a?(Role) ? other.name.to_s : other.to_s)
  end

  def === other
    name.to_s === (other.is_a?(Role) ? other.name.to_s : other.to_s)
  end
end

# == Schema Information
#
# Table name: roles
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

