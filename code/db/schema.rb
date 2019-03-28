# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20190328210729) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "instructors", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin"
    t.boolean "activated"
    t.string "reset_digest"
    t.datetime "reset_sent_at"
    t.index ["email"], name: "index_instructors_on_email", unique: true
  end

  create_table "links", force: :cascade do |t|
    t.text "link"
    t.bigint "problem_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["problem_id"], name: "index_links_on_problem_id"
  end

  create_table "options", force: :cascade do |t|
    t.text "answer"
    t.boolean "is_answer"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "problem_id"
    t.index ["problem_id"], name: "index_options_on_problem_id"
  end

  create_table "problems", force: :cascade do |t|
    t.text "question"
    t.text "answer"
    t.text "remark"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "topic_id"
    t.bigint "question_type_id"
    t.bigint "num_of_attempts"
    t.bigint "correct_attempts"
    t.index ["question_type_id"], name: "index_problems_on_question_type_id"
    t.index ["topic_id"], name: "index_problems_on_topic_id"
  end

  create_table "question_types", force: :cascade do |t|
    t.text "question_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "topics", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "email"
    t.string "password_digest"
    t.boolean "activated"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "links", "problems"
  add_foreign_key "options", "problems"
  add_foreign_key "problems", "question_types"
  add_foreign_key "problems", "topics"
end
