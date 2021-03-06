# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160404143724) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "c_ll_ratings", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "comment_ll_id"
    t.integer  "score"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "c_ll_ratings", ["comment_ll_id"], name: "index_c_ll_ratings_on_comment_ll_id", using: :btree
  add_index "c_ll_ratings", ["user_id"], name: "index_c_ll_ratings_on_user_id", using: :btree

  create_table "c_ratings", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "comment_id"
    t.integer  "score"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "c_ratings", ["comment_id"], name: "index_c_ratings_on_comment_id", using: :btree
  add_index "c_ratings", ["user_id"], name: "index_c_ratings_on_user_id", using: :btree

  create_table "comment_lls", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "leaders",                 array: true
    t.text     "comment"
    t.integer  "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "comment_lls", ["user_id"], name: "index_comment_lls_on_user_id", using: :btree

  create_table "comments", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "leader_id"
    t.integer  "sub_id"
    t.text     "comment"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["leader_id"], name: "index_comments_on_leader_id", using: :btree
  add_index "comments", ["sub_id"], name: "index_comments_on_sub_id", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "dungeon_groups", force: :cascade do |t|
    t.string   "name"
    t.string   "dungeon_type"
    t.integer  "order"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "dungeons", force: :cascade do |t|
    t.integer  "dungeon_group_id"
    t.string   "name"
    t.integer  "stamina"
    t.integer  "floors"
    t.integer  "coins"
    t.integer  "exp"
    t.string   "img"
    t.string   "dungeon_type"
    t.integer  "order"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "dungeons", ["dungeon_group_id"], name: "index_dungeons_on_dungeon_group_id", using: :btree

  create_table "ml_ratings", force: :cascade do |t|
    t.integer  "monster_link_id"
    t.integer  "user_id"
    t.integer  "score"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "ml_ratings", ["monster_link_id"], name: "index_ml_ratings_on_monster_link_id", using: :btree
  add_index "ml_ratings", ["user_id"], name: "index_ml_ratings_on_user_id", using: :btree

  create_table "monster_links", force: :cascade do |t|
    t.string   "url"
    t.integer  "user_id"
    t.integer  "monster_id"
    t.string   "link_type"
    t.string   "title"
    t.string   "version_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "monster_links", ["monster_id"], name: "index_monster_links_on_monster_id", using: :btree
  add_index "monster_links", ["user_id"], name: "index_monster_links_on_user_id", using: :btree
  add_index "monster_links", ["version_id"], name: "index_monster_links_on_version_id", using: :btree

  create_table "monsters", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "votes_count"
  end

  create_table "news", force: :cascade do |t|
    t.text     "title"
    t.text     "news"
    t.integer  "user_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "pinned",     default: false, null: false
  end

  add_index "news", ["user_id"], name: "index_news_on_user_id", using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "padherder"
    t.string   "username"
    t.integer  "votes_count"
    t.integer  "vote_lls_count"
    t.boolean  "admin",                  default: false, null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "number"
    t.text     "notes"
    t.date     "na_date"
    t.date     "jp_date"
    t.integer  "last_modified_by"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "vote_lls", force: :cascade do |t|
    t.integer  "leaders",                 array: true
    t.integer  "user_id"
    t.integer  "score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "vote_lls", ["user_id"], name: "index_vote_lls_on_user_id", using: :btree

  create_table "votes", force: :cascade do |t|
    t.integer  "score"
    t.integer  "leader_id"
    t.integer  "sub_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["leader_id"], name: "index_votes_on_leader_id", using: :btree
  add_index "votes", ["sub_id"], name: "index_votes_on_sub_id", using: :btree
  add_index "votes", ["user_id"], name: "index_votes_on_user_id", using: :btree

end
