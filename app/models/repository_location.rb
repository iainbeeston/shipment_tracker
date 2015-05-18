class RepositoryLocation < ActiveRecord::Base
  def self.app_names
    all.order(name: :asc).pluck(:name)
  end
end
