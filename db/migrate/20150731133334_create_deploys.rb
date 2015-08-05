class CreateDeploys < ActiveRecord::Migration
  def change
    create_table :deploys do |t|
      t.string :app_name
      t.string :server
      t.string :version
      t.string :deployed_by
      t.datetime :event_created_at
    end
  end
end
