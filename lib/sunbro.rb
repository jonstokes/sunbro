require 'nokogiri'
require 'capybara/poltergeist'
require 'rest-client'
require 'webrick/cookie'
require 'active_support/all'
require 'retryable'

%w(
  sunbro/version
  sunbro/settings
  sunbro/dynamic_http
  sunbro/http
  sunbro/page
).each do |f|
  require f
end

module Sunbro
  MAX_RETRIES = 5

  def get_page(link, opts={})
    fetch_with_connection(http, link, opts)
  end

  def render_page(link, opts={})
    fetch_with_connection(dhttp, link, opts)
  end

  def fetch_with_connection(conn, link, opts)
    page, tries = nil, MAX_RETRIES
    begin
      page = conn.fetch_page(link, opts)
      sleep 1
    end until page.try(:present?) || (tries -= 1).zero?
    page.discard_doc! unless page.is_valid?
    page
  end

  def http
    @http ||= HTTP.new
  end

  def dhttp
    @dhttp ||= DynamicHTTP.new
  end

  def close_http_connections
    @http.close if @http
    @dhttp.close if @dhttp
  rescue IOError
  end
end
