require "sunbro/version"

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
      page = conn.fetch_page(link, opts)
      sleep 1
    end until page.try(:present?) || (tries -= 1).zero?
    page.discard_doc! unless page.is_valid?
    page
  end

  def close_http_connections
    @http.close if @http
    @dhttp.close if @dhttp
  rescue IOError
  end

  class Test
    extend PageUtils

    def self.fetch_page(link, opts={})
      get_page(link, opts)
    end
  end
end
