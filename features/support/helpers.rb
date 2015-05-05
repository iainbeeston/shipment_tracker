module Helpers
  # Returns an array of strings given a string delimited by "and" and commas.
  # Note that it does not support the oxford comma.
  #
  # Example:
  #
  #   arguments_array("John, Bob and Joe")
  #   # => ["John", "Bob", "Joe"]
  def argument_array(string)
    string.gsub(' and ', ', ').split(', ')
  end
end

World(Helpers)
