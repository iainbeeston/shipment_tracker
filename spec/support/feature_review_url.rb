module Support
  class FeatureReviewUrl
    module Helpers
      def feature_review_url(*args)
        Support::FeatureReviewUrl.build(*args)
      end
    end

    def self.build(*args)
      new.build(*args)
    end

    def initialize(host = 'http://test.host')
      @host = URI.parse(host)
    end

    def build(apps_hash = {}, uat_url = nil)
      hash = { apps: apps_hash }
      hash['uat_url'] = uat_url if uat_url
      host.merge("/feature_reviews?#{hash.to_query}").to_s
    end

    private

    attr_reader :host
  end
end
