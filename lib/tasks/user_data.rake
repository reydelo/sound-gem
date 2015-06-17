desc "Pull in new data from user"
task :user_data => :environment do
  puts "pull in new information"
  UserCleanupWorker.new.perform
  puts "done"
end
