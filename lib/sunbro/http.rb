module Sunbro
  class HTTP
    # Maximum number of redirects to follow on each get_response
    REDIRECT_LIMIT = 5

    class RestResponse < Struct.new(:body, :headers, :code, :location); end

    def initialize(opts = {})
      @connections = {}
      @opts = opts
    end

    def close
      # Deprecated with move to RestClient
      true
    end

    #
    # Fetch a single Page from the response of an HTTP request to *url*.
    # Just gets the final destination page.
    #
    def fetch_page(url, opts={})
      original_url = url.dup
      pages = fetch_pages(url, opts)
      if pages.count == 1
        page = pages.first
        page.url = original_url
        page
      else
        page = pages.last
        page.redirect_from = original_url
        page
      end
    end

    #
    # Create new Pages from the response of an HTTP request to *url*,
    # including redirects
    #
    def fetch_pages(url, opts={})
      referer, depth = opts[:referer], opts[:depth]
      force_format = opts[:force_format] || default_page_format
      begin
        url = convert_to_uri(url) unless url.is_a?(URI)
        pages = []
        get(url) do |response, code, location, redirect_to, response_time|
          pages << Page.new(location, :body          => response.body.dup,
                                      :code          => code,
                                      :headers       => response.headers.stringify_keys,
                                      :referer       => referer,
                                      :depth         => depth,
                                      :redirect_to   => redirect_to,
                                      :response_time => response_time,
                                      :force_format  => force_format)
        end

        return pages
      rescue Exception => e
        if verbose?
          puts e.inspect
          puts e.backtrace
        end
        return [Page.new(url, :error => e)]
      end
    end

    #
    # Convert the link to a valid URI if possible
    #
    def convert_to_uri(url)
      URI(url)
    rescue URI::InvalidURIError
      URI(URI.escape(url))
    end

    #
    # The maximum number of redirects to follow
    #
    def redirect_limit
      @opts[:redirect_limit] || REDIRECT_LIMIT
    end

    #
    # The user-agent string which will be sent with each request,
    # or nil if no such option is set
    #
    def user_agent
      @opts[:agent] || Settings.user_agent
    end

    #
    # Does this HTTP client accept cookies from the server?
    #
    def accept_cookies?
      @opts[:accept_cookies]
    end

    #
    # The proxy address string
    #
    def proxy_host
      @opts[:proxy_host]
    end

    #
    # The proxy port
    #
    def proxy_port
      @opts[:proxy_port]
    end

    #
    # HTTP read timeout in seconds
    #
    def read_timeout
      @opts[:read_timeout]
    end

    private

    #
    # Retrieve HTTP responses for *url*, including redirects.
    # Yields the response object, response code, and URI location
    # for each response.
    #
    def get(url)
      limit = redirect_limit
      loc = url
      begin
          # if redirected to a relative url, merge it with the host of the original
          # request url
          loc = url.merge(loc) if loc.relative?

          response, response_time = get_response(loc)
          code = Integer(response.code)
          redirect_to = 300.upto(307).include?(response['code']) ? URI(response['location']).normalize : nil
          yield response, code, loc, redirect_to, response_time
          limit -= 1
      end while (loc = redirect_to) && allowed?(redirect_to, url) && limit > 0
    end

    #
    # Get an HTTPResponse for *url*, sending the appropriate User-Agent string
    #
    def get_response(url, referer = nil)
      full_path = url.query.nil? ? url.path : "#{url.path}?#{url.query}"

      opts = {}
      opts[:headers] = {
          user_agent: user_agent
      } if user_agent

      retries = 0
      begin
        start = Time.now()
        response = RestResponse.new

        # This causes RestClient to skip following the redirect automatically
        connection(url)[full_path].get(opts) do |res, request, result|
          response.body     = res.body
          response.headers  = res.headers
          response.code     = res.code
          response.location = res.headers[:location]
        end

        response.body.encode!("UTF-8", invalid: :replace, undef: :replace, :replace=>"?") if response.body

        finish = Time.now()
        response_time = ((finish - start) * 1000).round
        return response, response_time
      rescue Timeout::Error, Net::HTTPBadResponse, EOFError => e
        puts e.inspect if verbose?
        refresh_connection(url)
        retries += 1
        retry unless retries > 3
      end
    end

    def connection(url)
      @connections[url.host] ||= {}

      if conn = @connections[url.host][url.port]
        return conn
      end

      refresh_connection url
    end

    def refresh_connection(url)
      @connections[url.host][url.port] = RestClient::Resource.new(
          "#{url.scheme}://#{url.host}",
          timeout:    read_timeout || 5,
          verify_ssl: OpenSSL::SSL::VERIFY_NONE
      )

    end

    def verbose?
      @opts[:verbose]
    end

    #
    # Allowed to connect to the requested url?
    #
    def allowed?(to_url, from_url)
      to_url.host.nil? || (to_url.host.sub("www.","") == from_url.host.sub("www.",""))
    rescue
      true
    end

    private

    def default_page_format
      # Don't force the page format if the default format is set to :any
      return unless [:xml, :html].include? Settings.page_format
      Settings.page_format
    end

  end
end
