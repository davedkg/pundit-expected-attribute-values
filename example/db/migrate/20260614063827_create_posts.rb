class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.string :title
      t.string :status
      t.text :tags, default: "[]", null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
