module ApplicationHelper
  def title(title_text = nil, &block)
    haml_tag('h1.title', title_text, &block)
  end

  def short_sha(full_sha)
    full_sha[0...7]
  end
end
