class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.jsonb :details

      t.timestamps null: false
    end
  end
end
