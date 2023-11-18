class AddStarsToRepositories < ActiveRecord::Migration[7.1]
  def change
    add_column :repositories, :stars, :integer, null: false, default: 0
  end
end
