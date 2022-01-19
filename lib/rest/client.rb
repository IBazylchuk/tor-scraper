# frozen_string_literal: true

require './lib/proxy_providers/socks5'
require './lib/faraday/adapter/net_http_socks'
require 'faraday_middleware'
require 'multi_json'
require 'oj'

module Rest
  class Client
    def self.client(url, options = {})
      Faraday.new(url: url, ssl: { verify: false, verify_mode: 0 }) do |faraday|
        faraday.response :logger if options[:show_log]

        unless options[:ignore_redirects]
          faraday.use(FaradayMiddleware::FollowRedirects,
                      { limit: options[:max_redirects] || 10 })
        end

        faraday.options[:open_timeout] = options[:open_timeout] || 20
        faraday.options[:timeout] = options[:open_timeout] || 20
        faraday.adapter options[:adapter]&.to_sym || :net_http

        faraday.proxy = if faraday.adapter.name == 'Faraday::Adapter::NetHttpSocks'
                          { uri: URI.parse(ProxyProviders::Socks5.random_valid_tor_proxy_url) }
                        else
                          options[:proxy]
                        end

        faraday.headers[:user_agent] = options[:user_agent] || 'Apple-PubSub'
      end
    end

    def self.get(**args)
      do_request(method: :get, **args)
    end

    def self.post(**args)
      do_request(method: :post, **args)
    end

    def self.head(**args)
      do_request(method: :head, **args)
    end

    def self.do_request(method:, url:, params: {}, headers: {}, options: {})
      safe_url = URI::Parser.new.escape(url.strip)
      client = Rest::Client.client(safe_url, options)

      client.send(method) do |request|
        request.url safe_url
        request.headers = request.headers.merge(headers)
        if options[:as_params]
          request.params = params
        elsif params.any?
          request.body = headers[:content_type]&.include?('json') ? MultiJson.dump(params) : params
        end
      end
    end
  end
end
