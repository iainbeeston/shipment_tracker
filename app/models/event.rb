class Event < ActiveRecord::Base
  class BatchedRelation
    delegate :to_a, to: :@relation

    def initialize(relation)
      @relation = relation
    end

    def each(&block)
      @relation.find_each(&block)
    end
  end

  def self.in_order_of_creation
    BatchedRelation.new(order(created_at: :asc))
  end
end
