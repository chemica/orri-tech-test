class AddLanguageToRepositories < ActiveRecord::Migration[7.1]
  def change
    add_column :repositories, :language_id, :integer, null: false, default: 0
    add_foreign_key :repositories, :languages
  end
end
