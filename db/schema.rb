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

ActiveRecord::Schema[8.1].define(version: 2026_02_01_165658) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "badge_assignments", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "assigned_at"
    t.integer "assigned_by_id"
    t.integer "badge_id", null: false
    t.datetime "created_at", null: false
    t.integer "group_id", null: false
    t.datetime "updated_at", null: false
    t.index ["assigned_by_id"], name: "index_badge_assignments_on_assigned_by_id"
    t.index ["badge_id", "group_id"], name: "index_badge_assignments_on_badge_id_and_group_id", unique: true
    t.index ["badge_id"], name: "index_badge_assignments_on_badge_id"
    t.index ["group_id"], name: "index_badge_assignments_on_group_id"
  end

  create_table "badge_categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "family_id", null: false
    t.string "name"
    t.integer "position"
    t.datetime "updated_at", null: false
    t.index ["family_id"], name: "index_badge_categories_on_family_id"
  end

  create_table "badge_challenges", force: :cascade do |t|
    t.integer "badge_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "position"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["badge_id"], name: "index_badge_challenges_on_badge_id"
  end

  create_table "badge_submissions", force: :cascade do |t|
    t.integer "badge_id", null: false
    t.datetime "created_at", null: false
    t.text "kid_notes"
    t.text "parent_feedback"
    t.datetime "reviewed_at"
    t.integer "reviewed_by_id"
    t.string "status", default: "pending_review", null: false
    t.datetime "submitted_at"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["badge_id", "user_id", "status"], name: "index_badge_submissions_on_badge_id_and_user_id_and_status"
    t.index ["badge_id"], name: "index_badge_submissions_on_badge_id"
    t.index ["reviewed_by_id"], name: "index_badge_submissions_on_reviewed_by_id"
    t.index ["user_id"], name: "index_badge_submissions_on_user_id"
  end

  create_table "badges", force: :cascade do |t|
    t.integer "badge_category_id"
    t.datetime "created_at", null: false
    t.integer "created_by_id", null: false
    t.text "description"
    t.integer "family_id", null: false
    t.text "instructions"
    t.integer "points", default: 0, null: false
    t.datetime "published_at"
    t.string "status", default: "draft", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["badge_category_id"], name: "index_badges_on_badge_category_id"
    t.index ["created_by_id"], name: "index_badges_on_created_by_id"
    t.index ["family_id", "status"], name: "index_badges_on_family_id_and_status"
    t.index ["family_id"], name: "index_badges_on_family_id"
  end

  create_table "challenge_completions", force: :cascade do |t|
    t.integer "badge_challenge_id", null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.text "kid_notes"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["badge_challenge_id"], name: "index_challenge_completions_on_badge_challenge_id"
    t.index ["user_id"], name: "index_challenge_completions_on_user_id"
  end

  create_table "families", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "group_memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "group_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["group_id"], name: "index_group_memberships_on_group_id"
    t.index ["user_id"], name: "index_group_memberships_on_user_id"
  end

  create_table "groups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "family_id", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["family_id"], name: "index_groups_on_family_id"
  end

  create_table "invites", force: :cascade do |t|
    t.datetime "accepted_at"
    t.integer "accepted_by_id"
    t.datetime "created_at", null: false
    t.string "email"
    t.datetime "expires_at", null: false
    t.integer "family_id", null: false
    t.integer "invited_by_id", null: false
    t.string "status", default: "pending", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.index ["accepted_by_id"], name: "index_invites_on_accepted_by_id"
    t.index ["family_id"], name: "index_invites_on_family_id"
    t.index ["invited_by_id"], name: "index_invites_on_invited_by_id"
    t.index ["token"], name: "index_invites_on_token", unique: true
  end

  create_table "prizes", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "family_id", null: false
    t.string "name", null: false
    t.integer "point_cost", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["family_id"], name: "index_prizes_on_family_id"
  end

  create_table "redemptions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "kid_note"
    t.text "parent_feedback"
    t.integer "points_spent", default: 0, null: false
    t.integer "prize_id", null: false
    t.datetime "requested_at"
    t.datetime "reviewed_at"
    t.integer "reviewed_by_id"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["prize_id"], name: "index_redemptions_on_prize_id"
    t.index ["reviewed_by_id"], name: "index_redemptions_on_reviewed_by_id"
    t.index ["user_id", "status"], name: "index_redemptions_on_user_id_and_status"
    t.index ["user_id"], name: "index_redemptions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "api_token"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "family_id", null: false
    t.string "name", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "role", default: "kid", null: false
    t.datetime "updated_at", null: false
    t.index ["api_token"], name: "index_users_on_api_token"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["family_id"], name: "index_users_on_family_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "badge_assignments", "badges"
  add_foreign_key "badge_assignments", "groups"
  add_foreign_key "badge_assignments", "users", column: "assigned_by_id"
  add_foreign_key "badge_categories", "families"
  add_foreign_key "badge_challenges", "badges"
  add_foreign_key "badge_submissions", "badges"
  add_foreign_key "badge_submissions", "users"
  add_foreign_key "badge_submissions", "users", column: "reviewed_by_id"
  add_foreign_key "badges", "badge_categories"
  add_foreign_key "badges", "families"
  add_foreign_key "badges", "users", column: "created_by_id"
  add_foreign_key "challenge_completions", "badge_challenges"
  add_foreign_key "challenge_completions", "users"
  add_foreign_key "group_memberships", "groups"
  add_foreign_key "group_memberships", "users"
  add_foreign_key "groups", "families"
  add_foreign_key "invites", "families"
  add_foreign_key "invites", "users", column: "accepted_by_id"
  add_foreign_key "invites", "users", column: "invited_by_id"
  add_foreign_key "prizes", "families"
  add_foreign_key "redemptions", "prizes"
  add_foreign_key "redemptions", "users"
  add_foreign_key "redemptions", "users", column: "reviewed_by_id"
  add_foreign_key "users", "families"
end
