require 'scenic'

# Model for the user_details view
class UserDetail < ApplicationRecord
  belongs_to :userable, polymorphic: true

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: false, cascade: false)
  end

  def readonly?
    true
  end
end
