
class Github
  include HTTParty

  class PushEvent
    def initialize(hash)
      @commits     = hash['payload']['commits']
      @created_at  = hash['created_at'].to_time(:utc)
      @tracker     = Tracker.get("commit")
    end

    def trackers
      @commits.map do |_|
        { :created_at => @created_at, :tracker_id => @tracker.id }
      end
    end
  end

  class PullRequestReviewCommentEvent
    def initialize(hash)
      @created_at  = hash['created_at'].to_time(:utc)
      @tracker     = Tracker.get("pr-comment")
    end

    def trackers
      [{ :created_at => @created_at, :tracker_id => @tracker.id }]
    end
  end

  class PullRequestEvent
    def initialize(hash)
      @action      = hash['payload']['action']
      @created_at  = hash['created_at'].to_time(:utc)
      @tracker     = Tracker.get("pull-request-#{@action}")
    end

    def trackers
      [{ :created_at => @created_at, :tracker_id => @tracker.id }]
    end
  end

  class ActivityParser < HTTParty::Parser
    def json
      JSON(body)
    end
  end

  base_uri "https://api.github.com"
  parser ActivityParser

  def initialize(coder, token)
    @coder = coder
    @token = token
  end

  # TODO: Filter by organisation!
  def activities(options = {})
    query = { :access_token => @token, :page => options[:page] || 1 }
    results = self.class.get("/users/#{@coder}/events", :query => query)
    [].tap do |trackers|
      results.each do |entry|
        organisation = entry['org'].try(:[], 'login')
        p organisation
        if options[:org].blank? || options[:org] == organisation
          puts "comparing #{options[:since].inspect} to #{entry['created_at'].to_time.inspect}"
          if options[:since].blank? || options[:since] < entry['created_at'].to_time
            p entry['type']
            case entry['type']
              when 'PushEvent'
                trackers.concat(PushEvent.new(entry).trackers)
              when 'PullRequestReviewCommentEvent'
                trackers.concat(PullRequestReviewCommentEvent.new(entry).trackers)
              when 'PullRequestEvent'
                trackers.concat(PullRequestEvent.new(entry).trackers)
            end
          end
        end
      end
    end
  end
end
