class CreateUserDetails < ActiveRecord::Migration[7.1]
  def change
    create_view :user_details, materialized: true
  end
end
