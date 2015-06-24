module Sections
  class ShortCommitSha < Virtus::Attribute
    def coerce(value)
      value[0...7]
    end
  end
end
