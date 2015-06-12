class JiraEvent < Event
  def key
    details.fetch('issue').fetch('key')
  end

  def issue?
    details.fetch('webhookEvent', '').start_with?('jira:issue_')
  end

  def issue_id
    details.fetch('issue').fetch('id')
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

  def comment
    details.fetch('comment', {}).fetch('body', '')
  end

  def status_changed_from?(previous_status)
    changelog_items.any? { |item| item['field'] == 'status' && item['fromString'] == previous_status }
  end

  def status_changed_to?(new_status)
    changelog_items.any? { |item| item['field'] == 'status' && item['toString'] == new_status }
  end

  private

  def changelog_items
    details.fetch('changelog', 'items' => []).fetch('items')
  end
end
