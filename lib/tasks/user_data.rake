desc "Pull in new data from user"
task :user_data => :environment do
  puts "pull in new information"
  soundcloud_client = User.soundcloud_client
  UserCleanupWorker.perform_async(soundcloud_client.get("/me"))
  puts "done"
end
