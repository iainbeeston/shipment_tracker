module FeatureReviewsHelper
  def panel_class(success_state)
    success_state ? 'panel-success' : 'panel-danger'
  end

  def panel_icon_class(success_state)
    success_state ? 'glyphicon-ok' : 'glyphicon-alert'
  end

  def summary_item_classes(status)
    if status == 'success'
      'text-success glyphicon-ok'
    elsif status == 'failed'
      'text-danger glyphicon-remove'
    else
      'text-warning glyphicon-alert'
    end
  end

  def short_sha(full_sha)
    full_sha[0...7]
  end

  def to_link(url, options = {})
    link_to url, Addressable::URI.heuristic_parse(url).to_s, options
  end
end
