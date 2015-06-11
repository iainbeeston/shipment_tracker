module FeatureReviewsHelper
  def panel(heading:, status: :undefined, klass: nil, &block)
    haml_tag('.panel', class: [klass, panel_class(status)]) do
      haml_tag('.panel-heading') do
        haml_tag('h2') do
          haml_tag('span.glyphicon', class: panel_icon_class(status), 'aria-hidden' => true)
          haml_concat heading
        end
      end
      block.call
    end
  end

  def icon(status)
    haml_tag('span.status.glyphicon', '', class: status, 'aria-hidden' => true)
  end

  def panel_class(status)
    case status
    when :success
      'panel-success'
    when :failure
      'panel-danger'
    when :undefined
      'panel-info'
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
    when :undefined
      nil
    else
      'glyphicon-alert'
    end
  end

  def table(headers: [], &block)
    haml_tag('table.table.table-striped') do
      haml_tag('thead') do
        haml_tag('tr') do
          headers.each do |header|
            haml_tag('th', header)
          end
        end
      end
      haml_tag('tbody', &block)
    end
  end

  def deploy_status_icon_class(status)
    case status
    when :yes
      'text-success glyphicon-ok'
    when :no
      'text-danger glyphicon-remove'
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
