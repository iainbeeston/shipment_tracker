class CreateUatest < ActiveRecord::Migration
  def change
    create_table :uatests do |t|
      t.string :server
      t.boolean :success
      t.string :test_suite_version
      t.jsonb :versions
      t.datetime :event_created_at
    end
  end
end
