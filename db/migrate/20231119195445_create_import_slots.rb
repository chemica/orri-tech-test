class CreateImportSlots < ActiveRecord::Migration[7.1]
  def change
    create_table :import_slots do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :hour, null: false

      t.timestamps
    end
  end
end
