class CreateWorkerLock < ActiveRecord::Migration
  def change
    create_table :worker_locks do |t|
      t.string :name, unique: true
    end
  end
end
