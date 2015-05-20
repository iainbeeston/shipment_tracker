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

  def updated
    details.fetch('issue').fetch('fields').fetch('updated')
  end

  def status_changed?
    changelog = details.fetch('changelog', 'items' => [])
    changelog.fetch('items').any? { |item| item['field'] == 'status' }
  end

  def comment
    details.fetch('comment', {}).fetch('body', '')
  end
end
