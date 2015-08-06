require 'active_support/core_ext/hash/keys'
require 'addressable/uri'
require 'rack/utils'
require 'uri'

class FeatureReviewLocation
  def self.from_text(text)
    URI.extract(text)
      .map { |uri| parse_uri(uri) }
      .compact
      .select { |url| url.path == '/feature_reviews' }
      .map { |url| new(url) }
  end

  def self.parse_uri(uri)
    URI.parse(uri)
  rescue URI::InvalidURIError
    nil
  end
  private_class_method :parse_uri

  def initialize(url)
    @url = URI(url)
  end

  def app_versions
    query_hash.fetch('apps', {}).select { |_name, version| version.present? }
  end

  def uat_url
    uat_uri.to_s if uat_uri.present?
  end

  def uat_host
    uat_uri.try(:host)
  end

  def versions
    app_versions.values
  end

  def ==(other)
    app_versions == other.app_versions && uat_url == other.uat_url
  end

  def path
    @url.request_uri
  end

  def url
    @url.to_s
  end

  private

  def uat_uri
    @uat_uri ||= Addressable::URI.heuristic_parse(query_hash.fetch('uat_url', nil), scheme: 'http')
  end

  def query_hash
    @query_hash ||= Rack::Utils.parse_nested_query(@url.query)
  end
end
