class Signup < ActiveRecord::Base
  has_one :token, :as => :context
  belongs_to :user

  before_validation(:on => :create) do |signup|
    signup.token ||= Token.new(:context => signup)
  end

  validates_presence_of :email
  validates_presence_of :token
  validates_uniqueness_of :email
  validates_format_of :email, :with => %r/^[^@]+@[^@]+$/
  validates_length_of :password, :minimum => 3


  def Signup.signup!(*args, &block)
    options = args.extract_options!.to_options!
    email = args.shift || options[:email] or raise(ArgumentError, 'no email')
    password = args.shift || options[:password] or raise(ArgumentError, 'no password')
    email = Util.normalize_email(email)

    attributes = {
      'email' => email, 'password' => password
    }
    conditions = {
      'email' => email
    }

    signup = 
      begin
        create!(attributes)
      rescue
        find(:first, :conditions => conditions) || create!(attributes) 
      end

    raise unless signup

    signup.deliver! unless options[:deliver]==false

    signup
  end

  def Signup.for_token(token)
    token = Token.where('uuid' => token.to_s).includes(:context).first
    return false if token.expired?
    signup = token.context
  end

  def deliver!
    mail = Mailer.signup(self).deliver
    increment!(:delivery_count, 1)
    reload
    mail
  end

  def activated?
    !!user_id
  end

  def activate!
  end

  def password=(password)
    password = password.to_s
    password = BCrypt::Password.create(password) unless password[0] == '$'
    write_attribute(:password, password)
  end

  def password
    password = read_attribute(:password)
    BCrypt::Password.new(password) if password
  end
end

# == Schema Information
#
# Table name: signups
#
#  id             :integer         not null, primary key
#  email          :string(255)
#  password       :string(255)
#  user_id        :integer
#  delivery_count :integer         default(0)
#  created_at     :datetime
#  updated_at     :datetime
#

