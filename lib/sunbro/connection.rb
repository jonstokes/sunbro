module Sunbro
  class Connection
    attr_reader :http, :dhttp

    MAX_RETRIES = 3

    def fetch_page(link, opts={})
      conn = opts[:force_format] == (:dhtml || 'dhtml') ? dhttp : http
      tries = opts[:tries] || MAX_RETRIES
      sleep_interval = opts[:sleep] || 1

      page = Retryable.retryable(sleep: sleep_interval, tries: tries) do
        web_retry(opts) do
          conn.fetch_page(link, opts)
        end
      end
      page.discard_doc! unless page.valid?
      page
    end

    def session
      @dhttp.try(:session)
    end

    def http
      @http ||= HTTP.new
    end

    def dhttp
      @dhttp ||= DynamicHTTP.new
    end

    def close
      @http.try(:close)
      @dhttp.try(:close)
    rescue IOError
    end

    def web_retry(opts)
      page, tries, sleep_interval = nil, opts[:tries], opts[:sleep]
      begin
        page = yield
        sleep(sleep_interval) unless page.valid?
      end until page.valid? || (tries -= 1).zero?
      page
    end
  end
end
