class Role < ActiveRecord::Base
  has_many :user_role_joins, :dependent => :destroy
  has_many :users, :through => :user_role_joins

  def Role.for(value)
    return value if value.is_a?(Role)
    find(:first, :conditions => {:name => value.to_s})
  end

  Names = %w[
    root
    admin
    user
  ]

  Names.each do |name|
    module_eval <<-__, __FILE__, __LINE__ - 1

      def Role.#{ name }
        Role.find_by_name('#{ name }') || Role.create!(:name => '#{ name }')
      end

      def #{ name }?
        name=='#{ name }'
      end

    __
  end

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
