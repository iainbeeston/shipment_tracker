require 'git_loader'

class ReleaseAuditsController < ApplicationController
  def index
    @release_audit = {}
    @release_audit[:authors] = []
    @release_audit[:authors] << {name: 'Bob'}
    @release_audit[:authors] << {name: 'Jane'}

    # git_loader
    #   .get('the repo')
      # .authors(from: params[:from], to: params[:to])
  end
end
