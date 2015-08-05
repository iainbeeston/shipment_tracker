class CreateManualTest < ActiveRecord::Migration
  def change
    create_table :manual_tests do |t|
      t.string :email
      t.string :versions, array: true
      t.boolean :accepted
      t.text :comment
      t.datetime :created_at
    end
  end
end
