class User < ActiveRecord::Base
  DefaultTimeZone = 'Mountain Time (US & Canada)'

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable

  # def self.new_with_session(params, session)
  #   super.tap do |user|
  #     if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["user_hash"]
  #       user.email = data["email"]
  #     end
  #   end
  # end

  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
    data = access_token['extra']['user_hash']
    if user = User.find_by_email(data["email"])
      user
    else # Create a user with a stub password.
      User.create(:email => data["email"], :password => Devise.friendly_token[0,20])
    end
  end

  # Setup accessible (or protected) attributes for your model
  # attr_accessible :email, :password, :password_confirmation, :remember_me

  has_many(:user_organization_joins, :dependent => :destroy)
  has_many(:organizations, :through => :user_organization_joins)

  has_many :plans

  has_many :user_event_joins
  has_many :events, :through => :user_event_joins do
    def << event
      super unless include?(event)
      self
    end

    def remove(event)
      user = proxy_owner
      event.user_event_joins.find_by_user_id(user.id).try('destroy')
      self
    end
  end

  def has_event?(event_id)
    self.user_event_joins.find_by_event_id(event_id)
  end

  has_many(:user_role_joins, :dependent => :destroy)
  has_many(:roles, :through => :user_role_joins) do
    def user
      proxy_owner
    end

    def joins
      user.user_role_joins(:include => :role)
    end

    def roles
      self
    end

    def primary
      @primary ||= (
        join = joins.select{|join| join.primary}.first
        join ? join.role : first
      )
    end

    def primary= role
      transaction do
        push(role) unless include?(role)
        joins.each do |join|
          boolean = join.role == role
          join.update_attributes :primary => boolean
          @primary = role if boolean
        end
      end
    end

    def << role
      super unless include?(role)
      self
    end

    def push role
      super unless include?(role)
      role
    end

    alias_method 'add', 'push'
  end

  validates_presence_of :uuid

  before_validation(:on => :create) do |user|
    user.uuid ||= App.uuid
  end

  # before_validation do |user|
  #   if user.email
  #     user.email = user.email.downcase.strip
  #     user.handle ||= user.default_handle
  #   end
  # end

  def add_role(role)
    roles.push(role) unless roles.include?(role)
    save!
    reload
    roles
  end

  def remove_role(role)
    roles.delete(role) if roles.include?(role)
    save!
    reload
    roles
  end

  Role.names.each do |name|
    module_eval <<-__, __FILE__, __LINE__ - 1

      def #{ name }?
        roles.include?(Role.#{ name })
      end

      def #{ name }!
        add_role(Role.#{ name })
      end

    __
  end

  def default_handle
    email.to_s.scan(/\w+/).first
  end

  # def User.root
  #   @root ||= User.find(0)
  # end

  # def root?
  #   User.root.uuid == self.uuid
  # end

  def User.for(arg)
    return arg if arg.is_a?(User)
    arg = arg.to_s
    conditions =
      case arg
        when %r/^\d+$/
          {:id => arg}
        when %r/^[\w-]+$/
          {:uuid => arg}
        when %r/@/
          {:email => arg.strip.downcase}
        else
          raise(ArgumentError, arg)
      end
    User.where(conditions).first
  end

  def User.[](arg)
    User.for(arg)
  end

  def can_edit_event?(event)
    event = Event.find(event) unless event.is_a?(Event)
    organizations.detect{|organization| event.organization_id == organization.id}
  end

  def self.to_dao(*args)
    super(*args).reject{|arg| %w[password].include?(arg)}
  end

end

# == Schema Information
#
# Table name: users
#
#  id         :integer         not null, primary key
#  uuid       :string(255)     not null
#  email      :string(255)
#  password   :string(255)
#  time_zone  :string(255)     default("Mountain Time (US & Canada)")
#  handle     :string(255)
#  created_at :datetime
#  updated_at :datetime
#

