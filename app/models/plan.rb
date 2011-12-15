class Plan < ActiveRecord::Base
  # the user that created the plan
  belongs_to :user

  has_many :invitations, :class_name => 'PlanUserInvitation'#, :source => 'plan_user_invitations'
  has_many :accepted_invitations, :class_name => 'PlanUserInvitation', :conditions => {:accepted => true}
  has_many :attendees, :through => :accepted_invitations, :source => :user

  serialize :event_list

  validates_presence_of :uuid
  validates_presence_of :user_id
  validates_presence_of :title
  validates_presence_of :description

  before_validation(:on => :create) do |plan|
    plan.uuid ||= App.uuid
  end
  # We would use:
  # validates_length_of :description, :maximum => 140
  # but it counts line breaks as 2 chars. Need to do it ourselves.
  validate :check_description_length
  def check_description_length
    return if description.blank?
    stripped = description.gsub /\r\n/, ' '
    if stripped.length > 140
      errors.add(:description, 'is too long (maximum is 140 characters)')
    end
  end

  scope :by_date, order('starts_at')
  scope(:after, lambda{|time|
    where('ends_at > ?', time)
  })
  scope(:before, lambda{|time|
    where('starts_at < ?', time)
  })
  scope :upcoming, by_date().after(Time.now)

  before_save :cache_event_data
  def cache_event_data
    self.starts_at = events.map(&:starts_at).min
    self.ends_at = events.map(&:ends_at).max
  end

  def event_ids
    return '' if event_list.blank?
    event_list.join(',')
  end

  def event_ids=(ids)
    self.event_list = ids.split(', ')
  end

  def events
    list = Event.find(event_list)
    # need to return them correctly sorted
    sorted = []
    for id in event_list
      sorted << list.select{|e| e.id == id.to_i}.first
    end
    sorted
  end

  def is_editable_by?(a_user)
    a_user.id == user_id
  end

  def to_param
    uuid
  end
end


# == Schema Information
#
# Table name: plans
#
#  id          :integer         not null, primary key
#  user_id     :integer
#  uuid        :string(255)
#  title       :string(255)
#  public      :boolean         default(FALSE)
#  description :text
#  event_list  :text
#  starts_at   :datetime
#  ends_at     :datetime
#  created_at  :datetime
#  updated_at  :datetime
#

