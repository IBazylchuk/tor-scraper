# frozen_string_literal: true

require 'bundler/setup'
require 'hanami/api'

require './lib/rest/client'
require './lib/rest/user_agent'

require 'debug'

class App < Hanami::API
  get '/' do
    url = params[:url]

    url = CGI.unescape(url)

    response = Rest::Client.get(
      url: url,
      options: { adapter: :net_http_socks, user_agent: Rest::UserAgent.random }
    )

    [200, {}, response.body]
  end
end

run App.new
