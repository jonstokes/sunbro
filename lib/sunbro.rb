require 'nokogiri'
require 'capybara/poltergeist'
require 'net/http/persistent'
require 'webrick/cookie'

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
    @http ||= HTTP.new
    fetch_with_connection(@http, link, opts)
  end

  def render_page(link, opts={})
    @dhttp ||= DynamicHTTP.new
    fetch_with_connection(@dhttp, link, opts)
  end

  def fetch_with_connection(conn, link, opts)
    page, tries = nil, MAX_RETRIES
    begin
      page = conn.fetch_pages(link, opts)
      sleep 1
    end until pages.last.try(:present?) || (tries -= 1).zero?
    pages.each { |page| page.discard_doc! unless page.is_valid? }
    pages
  end

  def close_http_connections
    @http.close if @http
    @dhttp.close if @dhttp
  rescue IOError
  end

  class Test
    extend Sunbro
  end
end
