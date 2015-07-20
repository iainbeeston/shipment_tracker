class RepositoryLocation < ActiveRecord::Base
  def self.app_names
    all.order(name: :asc).pluck(:name)
  end

  def self.update_from_github_notification(payload)
    repository_location = find_by_github_ssh_url(payload['repository']['ssh_url'])
    return unless repository_location
    repository_location.update(remote_head: payload['after'])
  end

  def self.find_by_github_ssh_url(url)
    path = Addressable::URI.parse(url).path
    find_by('uri LIKE ?', "%#{path}")
  end
  private_class_method :find_by_github_ssh_url
end
