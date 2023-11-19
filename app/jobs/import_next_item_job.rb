# Import the next user in the schedule.
class ImportNextItemJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Rails.logger.info('Add import code here')
  end
end
