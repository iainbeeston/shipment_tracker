class CommentEvent < Event
  def name
    details['name']
  end

  def message
    details['message']
  end

  def version
    details['version']
  end
end
