require 'rack/utils'
require 'active_support/core_ext/hash/keys'

class FeatureReviewLocation
  def initialize(url)
    @url = URI(url)
  end

  def self.from_text(text)
    URI.extract(text)
      .map { |uri| URI.parse(uri) }
      .select { |url| url.path == '/feature_reviews' }
      .map { |url| new(url) }
  end

  def app_versions
    query_hash.fetch('apps', {}).symbolize_keys
  end

  def uat_url
    query_hash.fetch('uat_url')
  end

  def versions
    app_versions.values
  end

  def ==(other)
    url == other.url
  end

  def path
    @url.request_uri
  end

  def url
    @url.to_s
  end

  private

  def query_hash
    @query_hash ||= Rack::Utils.parse_nested_query(@url.query)
  end
end
