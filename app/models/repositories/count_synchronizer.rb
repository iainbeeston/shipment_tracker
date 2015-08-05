module Repositories
  class CountSynchronizer
    def initialize(name, count)
      @name = name
      @count = count
    end

    def update(&block)
      ActiveRecord::Base.transaction do
        last_id = 0
        new_events.each do |event|
          last_id = event.id
          block.call(event)
        end
        update_count(last_id)
      end
    end

    def new_events(up_to: nil)
      Event.between(last_id, up_to: up_to)
    end

    private

    attr_reader :name, :count

    def last_id
      count.find_by_snapshot_name(name).try(:event_id) || 0
    end

    def update_count(id)
      record = count.find_or_create_by(snapshot_name: name)
      record.event_id = id
      record.save!
    end
  end
end
