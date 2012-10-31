class Activity < ActiveRecord::Base
  attr_accessible :created_at, :tracker_id
  belongs_to :user
  belongs_to :tracker
end
