class User < ActiveRecord::Base
  attr_accessible :github_handle, :github_token, :name
  has_many :activities, :order => "created_at desc"

  validates :github_handle, :github_token, :name, :presence => true

  # Only user oriented activities such as Github
  def process_activities
    gh = Github.new(self.github_handle, self.github_token)
    since = self.activities.github.first.try(:created_at)

    10.downto(1) do |page|
      gh.activities(:page => page, :org => 'echannel', :since => since).each do |activity|
        self.activities.build(
          :created_at => activity[:created_at],
          :tracker_id => activity[:tracker_id],
          :provider   => 'github'
        )
      end
    end
  end

  def process_activities!
    process_activities
    save!
  end
end
