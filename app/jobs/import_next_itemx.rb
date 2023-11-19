# Job: ImportNextItem will try to import the next user in the schedule.
class ImportNextItem < ApplicationJob
  def perform
    Rails.logger.info('Add import code here')
  end
end
