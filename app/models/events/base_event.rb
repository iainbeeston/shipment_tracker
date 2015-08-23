require 'active_record'

module Events
  class BaseEvent < ActiveRecord::Base
    self.table_name = 'events'

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

    def self.between(id, up_to: nil)
      query = up_to ? where(arel_table['created_at'].lteq(up_to)) : self
      BatchedRelation.new(query, from_id: id + 1)
    end
  end
end
