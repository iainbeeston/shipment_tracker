module ApplicationHelper
  def title(title_text = nil, &block)
    haml_tag('h1.title', title_text, &block)
  end
end
