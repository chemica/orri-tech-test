# Import the next user in the schedule.
class ImportNextItemJob < ApplicationJob
  queue_as :default

  def perform(*_)
    current_hour = Time.new.utc.hour
    slot = ImportSlot.for_hour(position: current_hour)
    Rails.logger.info("Importing slot: #{slot ? slot.id : 'none'}")
    return unless slot

    user = slot.user
    Rails.logger.info("Importing user: #{user ? user.id : 'none'}")
    return unless user

    Rails.logger.info("Github import on user: #{user.id}")
    GithubImport.new.update_user(user)
  end
end
