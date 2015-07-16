class Event < ActiveRecord::Base
  class BatchedRelation
    include Enumerable

    def initialize(relation, from_id: 0)
      @relation = relation
      @from_id = from_id
    end

    def each(&block)
      @relation.find_each(start: @from_id, &block)
    end
  end

  def self.in_order_of_creation
    BatchedRelation.new(self)
  end

  def self.after_id(id)
    BatchedRelation.new(self, from_id: id + 1)
  end
end
