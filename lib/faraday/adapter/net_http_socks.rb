# frozen_string_literal: true

require 'socksify'
require 'socksify/http'
require 'faraday'

module Faraday
  class Adapter
    class NetHttpSocks < NetHttp
      SOCKS_SCHEMES = %w[socks socks4 socks5 socks5h].freeze

      def net_http_connection(env)
        proxy = env[:request][:proxy]
        port = env[:url].port || (env[:url].scheme == 'https' ? 443 : 80)

        net_http_class = if proxy
                           if SOCKS_SCHEMES.include?(proxy[:uri].scheme)
                             Net::HTTP::SOCKSProxy(proxy[:uri].host, proxy[:uri].port)
                           else
                             Net::HTTP::Proxy(proxy[:uri].host, proxy[:uri].port, proxy[:user], proxy[:password])
                           end
                         else
                           Net::HTTP
                         end

        net_http_class.new(env[:url].hostname, port, nil)
      end
    end
  end
end

Faraday::Adapter.register_middleware(net_http_socks: :NetHttpSocks)
