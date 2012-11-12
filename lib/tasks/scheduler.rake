
desc "This task is called by the Heroku scheduler add-on"
task :process_activity => :environment do
  puts "Processing Pivotal"
  Pivotal.process_activity
  puts "Processing Github for all users"
  User.all.each do |user|
    user.process_activities!
  end
end
