class CreateWeights < ActiveRecord::Migration
  def change
    create_table :weights do |t|
      t.integer :weight
      t.references :user, index: true
      t.references :member, index: true

      t.timestamps null: false
    end
    add_foreign_key :weights, :users
    add_foreign_key :weights, :members
  end
end
