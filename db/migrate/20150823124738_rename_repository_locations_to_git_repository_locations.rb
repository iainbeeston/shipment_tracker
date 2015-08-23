class RenameRepositoryLocationsToGitRepositoryLocations < ActiveRecord::Migration
  def change
    rename_table :repository_locations, :git_repository_locations
  end
end
