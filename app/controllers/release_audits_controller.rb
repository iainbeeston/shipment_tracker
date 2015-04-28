# require 'git_loader'

class ReleaseAuditsController < ApplicationController
  def show
    @authors = []
    return unless params[:to]

    uri = look_up_repo_uri
    repo = checkout_repo(uri)
    commits = get_commits(repo)
    @authors = compile_unique_authors(commits)
  end

  private

  def look_up_repo_uri
    Repository.find_by_name(params[:id]).uri
  end
  def checkout_repo(uri)
    dir = Dir.mktmpdir
    repo = Rugged::Repository.clone_at(
      uri,
      File.join(dir, String(params[:id]))
    )
  end
  def get_commits(repo)
    walker = Rugged::Walker.new(repo)
    walker.sorting(Rugged::SORT_TOPO | Rugged::SORT_REVERSE) # optional
    walker.push(params[:to])
    walker.hide(params[:from]) unless params[:from].empty?
    walker.map
  end
  def compile_unique_authors(commits)
    commits.map {|c| c.author[:name] }.uniq
  end
end
