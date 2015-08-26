class NamespaceEventsTypes < ActiveRecord::Migration
  def up
    execute(%{
      UPDATE events
      SET type=('Events::' || type)
    })
  end

  def down
    execute(%{
      UPDATE events
      SET type=ltrim(type, 'Events::')
    })
  end
end
