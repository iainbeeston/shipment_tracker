class AddEventCreatedAtToFeatureReviews < ActiveRecord::Migration
  def change
    add_column :feature_reviews, :event_created_at, :datetime
  end
end
