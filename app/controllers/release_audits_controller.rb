class ReleaseAuditsController < ApplicationController
  def show
    @authors = GitRepository.author_names_for(
      repository_name: clean_params[:id],
      from: clean_params[:from],
      to:   clean_params[:to]
    )
  end

  private

  def clean_params
    @clean_params ||= params.select { |_k, v| v.present? }
  end
end
