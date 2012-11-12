
PivotalTracker::Client.token = '84d76421cfe2beb2550c5f66ac628286'

class Pivotal
  def self.process_activity
    since = Activity.newest.pivotal.first.try(:created_at)
    activity = PivotalTracker::Activity.all(nil, :limit => 100, :occurred_since_date => since)
    activity.each do |event|
      user = User.where(:name => event.author).first
      if user.present?
        tracker_code, points = nil, nil

        if event.event_type == 'story_update'
          if /(?<pt_action>started|finished|accepted|rejected|added)/ =~ event.description
            tracker_code = "pt-story-#{pt_action}"

            # Set the points on the activity in this case
            if pt_action = 'finished'
              points = event.stories.first.estimate
            end
          end
        else
          tracker_code = "pt-#{event.event_type}"
        end
        if tracker_code
          tracker = Tracker.get(tracker_code)
          user.activities.create(
            :created_at => event.occurred_at,
            :tracker_id => tracker.id,
            :provider   => 'pivotal',
            :points     => points
          )
        end
      end
    end
  end
end
