# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2023_11_18_153603) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "language_users", force: :cascade do |t|
    t.bigint "language_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["language_id"], name: "index_language_users_on_language_id"
    t.index ["user_id"], name: "index_language_users_on_user_id"
  end

  create_table "languages", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_languages_on_name", unique: true
  end

  create_table "repositories", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "stars", default: 0, null: false
    t.integer "language_id", default: 0, null: false
    t.index ["user_id"], name: "index_repositories_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.integer "stars", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_users_on_name", unique: true
  end

  add_foreign_key "language_users", "languages"
  add_foreign_key "language_users", "users"
  add_foreign_key "repositories", "languages"
  add_foreign_key "repositories", "users"

  create_view "user_details", materialized: true, sql_definition: <<-SQL
      SELECT u.id,
      u.name,
      count(DISTINCT lu.id) AS language_count,
      count(DISTINCT r.id) AS repository_count,
      u.stars
     FROM ((users u
       LEFT JOIN language_users lu ON ((u.id = lu.user_id)))
       LEFT JOIN repositories r ON ((u.id = r.user_id)))
    GROUP BY u.id;
  SQL
end
