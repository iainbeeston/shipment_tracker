require 'omniauth'

module OmniAuth
  module Strategies
    class EventToken
      include OmniAuth::Strategy

      option :event_prefix

      uid do
        token = (callback_uri.query_values || {})['token']
        source = current_path.sub(%r{^#{options[:event_prefix]}/}, '')
        source if Token.valid?(source, token)
      end

      def callback_uri
        Addressable::URI.parse(callback_url)
      end

      def on_callback_path?
        current_path.starts_with? options[:event_prefix]
      end
    end
  end
end
