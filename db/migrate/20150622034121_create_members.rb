class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.string :first_name
      t.string :last_name
      t.string :address_line_one
      t.string :address_line_two
      t.float :latitude
      t.float :longitude
      t.boolean :active
      t.references :user, index: true

      t.timestamps null: false
    end
    add_foreign_key :members, :users
    add_index :members, [:user_id, :created_at]
  end
end
