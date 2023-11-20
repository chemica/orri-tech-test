# Represents a slot in the import schedule
class ImportSlot < ApplicationRecord
  belongs_to :user

  def self.for_hour(hour)
    where(hour:).first
  end
end
