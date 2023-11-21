class AddBytesToLanguagesUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :language_users, :bytes, :integer, null: false, default: 0
  end
end
