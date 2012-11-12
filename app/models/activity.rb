class Activity < ActiveRecord::Base
  attr_accessible :created_at, :tracker_id, :provider, :points
  belongs_to :user
  belongs_to :tracker

  scope :pivotal, where(:provider => 'pivotal')
  scope :github,  where(:provider => 'github')

  scope :newest, :order => "activities.created_at desc"
end
