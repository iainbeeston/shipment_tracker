class JiraEvent < Event
  def key
    details.fetch('issue').fetch('key')
  end

  def summary
    details.fetch('issue').fetch('fields').fetch('summary')
  end

  def status
    details.fetch('issue').fetch('fields').fetch('status').fetch('name')
  end

  def user_email
    details.fetch('user').fetch('emailAddress')
  end

  def status_changed_to?(final_status)
    status_changed? && status == final_status
  end

  def updated
    details.fetch('issue').fetch('fields').fetch('updated')
  end

  private

  def status_changed?
    changelog = details.fetch('changelog', 'items' => [])
    changelog.fetch('items').any? { |item| item['field'] == 'status' }
  end
end
