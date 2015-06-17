desc "Pull in new data from user"
task :user_data => :environment do
  puts "pull in new information"
  controller = SoundcloudController.new
  controller.connected
  UserCleanupWorker.perform_async(soundcloud_client.get("/me"))
  puts "done"
end
