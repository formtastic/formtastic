ActiveRecord::Schema.define(version: 20170208011723) do

  create_table "posts", force: :cascade do |t|
    t.integer "author_id",  limit: 4,     null: false
  end

  create_table "authors", force: :cascade do |t|
    t.integer "age",   limit: 4,     null: false
    t.string  "name",  limit: 255,   null: false
    t.string  "surname",  limit: 255,   null: false
    t.string  "login", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  #non-rails foreign id convention
  create_table "legacy_posts", force: :cascade do |t|
    t.integer "post_author",  limit: 4,     null: false
  end

end
