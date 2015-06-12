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

  def approval?
    changelog_items.any? { |item|
      item['field'] == 'status' &&
        approved_status?(item['toString']) &&
        !approved_status?(item['fromString'])
    }
  end

  def unapproval?
    changelog_items.any? { |item|
      item['field'] == 'status' &&
        approved_status?(item['fromString']) &&
        !approved_status?(item['toString'])
    }
  end

  private

  def changelog_items
    details.fetch('changelog', 'items' => []).fetch('items')
  end

  def approved_status?(status)
    Ticket::APPROVED_STATUSES.include?(status)
  end
end
