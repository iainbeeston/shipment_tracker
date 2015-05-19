class Event < ActiveRecord::Base
  class BatchedRelation
    include Enumerable

    def initialize(relation)
      @relation = relation
    end

    def each(&block)
      @relation.find_each(&block)
    end
  end

  def self.in_order_of_creation
    BatchedRelation.new(self)
  end
end
