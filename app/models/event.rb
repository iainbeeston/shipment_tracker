class Event < ActiveRecord::Base
  def self.in_order_of_creation
    order(created_at: :asc)
  end
end
