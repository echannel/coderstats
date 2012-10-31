class User < ActiveRecord::Base
  attr_accessible :github_handle, :github_token, :name, :pivotal_id
  has_many :activities, :order => "created_at desc"

  def process_activities
    gh = Github.new(self.github_handle, self.github_token)
    since = self.activities.first.try(:created_at)

    10.downto(1) do |page|
      gh.activities(:page => page, :org => 'echannel', :since => since).each do |activity|
        self.activities.build(
          :created_at => activity[:created_at],
          :tracker_id => activity[:tracker_id]
        )
      end
    end
  end

  def process_activities!
    process_activities
    save!
  end
end
