module FeatureReviewsHelper
  def panel(heading:, status: :info, klass: nil, &block)
    haml_tag('.panel', class: [klass, panel_class(status)]) do
      haml_tag('.panel-heading') do
        haml_tag('h2') do
          icon(classes: icon_class(status))
          haml_concat heading
        end
      end
      block.call
    end
  end

  def icon(classes:, **attributes)
    return unless classes
    haml_tag('span.glyphicon', '', attributes.merge(class: classes, aria: { hidden: true }))
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

  def panel_class(status)
    "panel-#{item_class(status)}"
  end

  def text_class(status)
    "text-#{item_class(status)}"
  end

  def icon_class(status)
    return nil if status == :info
    "icon-#{item_class(status)}"
  end

  def item_status_icon_class(status)
    "#{icon_class(status)} status #{text_class(status)}"
  end

  def item_class(status)
    case status && status.to_sym
    when :success, :yes
      'success'
    when :failure, :failed, :no
      'danger'
    when :info
      'info'
    else
      'warning'
    end
  end

  def short_sha(full_sha)
    full_sha[0...7]
  end

  def to_link(url, options = {})
    link_to url, Addressable::URI.heuristic_parse(url).to_s, options
  end
end
