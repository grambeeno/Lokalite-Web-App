class User < ActiveRecord::Base
  DefaultTimeZone = 'Mountain Time (US & Canada)'

  has_many(:user_organization_joins, :dependent => :destroy)
  has_many(:organizations, :through => :user_organization_joins)

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
  validates_presence_of :email
  validates_uniqueness_of :email
  ### validates_presence_of :email
  ### validates_length_of :password, :minimum => 3

  before_validation(:on => :create) do |user|
    user.uuid ||= App.uuid
  end

  before_validation do |user|
    if user.email
      user.email = user.email.downcase.strip
      user.handle ||= user.default_handle
    end
  end


  ### PasswordReset = '________PASSWORD_RESET________'
  #
  
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

  def session
    @session ||= (Session.find(:first, :conditions => {:user_id => id}) || Session.create!(:user_id => id))
  end

  def api
    Api.new(user=self)
  end

  def default_handle
    email.to_s.scan(/\w+/).first
  end

  def User.root
    @root ||= User.find(0)
  end

  def root?
    User.root.uuid == self.uuid
  end

  def User.authenticate(options = {})
    options.to_options!
    email = options[:email]
    password = options[:password]

    user = User.where(:email => email.strip.downcase).first

    return nil unless user
    return nil unless user.password

    if BCrypt::Password.new(user.password) == password
      user
    else
      false
    end
  end

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

  def User.password_token_for(user)
    user = User.for(user)
    conditions = {:kind => 'password', :context_type => User.name, :context_id => user.id}
    Token.create!(conditions)
  end

  def password_token
    User.password_token_for(self)
  end

  def User.deliver_password_email(options)
    options = {:user => options} if options.is_a?(User)
    options.to_options!
    user = User.for(options[:user])
    options[:token] ||= user.password_token
    mail = Mailer.password(options).deliver
  end

  def deliver_password_email(options = {})
    options.to_options!
    options[:user] ||= self
    User.deliver_password_email(options)
  end

  def User.deliver_invitation_email(options)
    options = {:user => options} if options.is_a?(User)
    options.to_options!
    user = User.for(options[:user])
    options[:token] ||= user.password_token
    mail = Mailer.invitation(options).deliver
  end

  def deliver_invitation_email(options = {})
    options.to_options!
    options[:user] ||= self
    User.deliver_invitation_email(options)
  end

  def perishable_token(options = {})
    options.to_options!
    options[:data] = uuid
    App.token_for(options)
  end

  def User.parse_token(value)
    token = App.parse_token(value)
    uuid = token.data
    if uuid
      token.fattr(:user)
      token.user = User[uuid]
      token.valid = !!token.user
    else
      token.valid = false
    end
    token
  end

  def password=(password)
    password = password.to_s
    password = BCrypt::Password.create(password) unless password[0,1] == '$'
    write_attribute(:password, password)
  end

  def password
    password = read_attribute(:password)
    BCrypt::Password.new(password) if password
  end

  def api
    Api.new(self)
  end

  def can_edit_event?(event)
    event = Event.find(event) unless event.is_a?(Event)
    organizations.detect{|organization| event.organization_id == organization.id}
  end
end




__END__
# TODO - put this is memcache *with* roles *and* handle expiration.  as it
# stands now expiration is simple: all instances of the app have all users and
# restarting the app clears cache.  this is nice while we are still dropping
# the db occasionally
#
  Cache = {} unless defined?(Cache)

  def User.cached(user)
    return nil unless user

    if user.is_a?(User)
      user
    else
      id = Integer(user)
      Cache[id] ||= (
        User.find(:first, :conditions => {:id => id}, :include => [:roles])
      )
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

