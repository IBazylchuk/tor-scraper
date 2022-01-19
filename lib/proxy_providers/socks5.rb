# frozen_string_literal: true

require 'socksify/http'

module ProxyProviders
  module Socks5
    class InvalidProxyError < StandardError; end

    module_function

    TOR_CHECK_URL = 'https://check.torproject.org'
    TOR_CHECK_RESPONSE_KEY_STRING = 'Congratulations. This browser is configured to use Tor.'
    TOR_CHECK_TIMEOUT = 10

    def random_valid_tor_proxy_url
      available_tor_ports = ((tor_proxy_config[:first_port])..(tor_proxy_config[:last_port])).to_a

      loop do
        if available_tor_ports.empty?
          puts 'No valid TOR proxies available'
          return nil
        end

        proxy_port = available_tor_ports.sample

        return proxy_url("#{tor_proxy_config[:host]}:#{proxy_port}") if is_tor_proxy_port_working?(proxy_port)

        available_tor_ports -= [proxy_port]
      end
    end

    def is_tor_proxy_port_working?(proxy_port)
      response = Timeout.timeout(TOR_CHECK_TIMEOUT) do
        Net::HTTP.SOCKSProxy(tor_proxy_config[:host], proxy_port).get(URI.parse(TOR_CHECK_URL))
      end
      unless response.include?(TOR_CHECK_RESPONSE_KEY_STRING)
        raise InvalidProxyError, 'Proxy is not a member of TOR-network'
      end

      true
    rescue StandardError => e
      puts "TOR proxy-port #{proxy_port} is not available #{e.inspect}"
      false
    end

    def proxy_url(proxy)
      "socks5://#{proxy}"
    end

    def tor_proxy_config
      @tor_proxy_config ||= {
        host: 'localhost',
        first_port: 9100,
        last_port: 9200
      }
    end
  end
end
