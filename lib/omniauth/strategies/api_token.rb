require 'omniauth'

module OmniAuth
  module Strategies
    class ApiToken
      include OmniAuth::Strategy

      option :prefix

      uid do
        token = (callback_uri.query_values || {})['token']
        if options[:prefix] == '/events'
          source = current_path.sub(%r{^#{options[:prefix]}/}, '')
        else
          source = current_path.sub(%r{^/}, '')
        end
        source if Token.valid?(source, token)
      end

      def callback_uri
        Addressable::URI.parse(callback_url)
      end

      def on_callback_path?
        current_path.starts_with? options[:prefix]
      end
    end
  end
end
