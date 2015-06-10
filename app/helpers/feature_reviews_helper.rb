module FeatureReviewsHelper
  def panel_class(status)
    case status
    when :success
      'panel-success'
    when :failure
      'panel-danger'
    else
      'panel-warning'
    end
  end

  def panel_icon_class(status)
    case status
    when :success
      'glyphicon-ok'
    when :failure
      'glyphicon-remove'
    else
      'glyphicon-alert'
    end
  end

  def deploy_status_icon_class(status)
    case status
    when :yes
      'text-success glyphicon-ok'
    when :no
      'text-danger glyphicon-remove'
    when :ignore
      ''
    end
  end

  def build_status_icon_class(status)
    case status
    when 'success'
      'text-success glyphicon-ok'
    when 'failed'
      'text-danger glyphicon-remove'
    else
      'text-warning glyphicon-alert'
    end
  end

  def summary_item_classes(status)
    case status
    when :success
      'text-success glyphicon-ok'
    when :failure
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
