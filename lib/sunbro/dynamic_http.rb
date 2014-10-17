module Sunbro
  class DynamicHTTP
    attr_reader :session

    def initialize(opts = {})
      @opts = opts
      new_session
    end

    def close
      @session.driver.quit
    end

    def new_session
      Capybara.register_driver :poltergeist do |app|
        Capybara::Poltergeist::Driver.new(
          app,
          js_errors: false,
          phantomjs_options: ['--load-images=no', '--ignore-ssl-errors=yes']
        )
      end
      Capybara.default_driver = :poltergeist
      Capybara.javascript_driver = :poltergeist
      Capybara.run_server = false
      @session = Capybara::Session.new(:poltergeist)
      @session.driver.headers = {
        'User-Agent' => user_agent
      }
      @session
    end

    def user_agent
      @opts[:agent] || Settings.phantomjs_user_agent
    end

    def restart_session
      close
      new_session
    end

    #
    # Create new Pages from the response of an HTTP request to *url*,
    # including redirects
    #
    def fetch_page(url, opts={})
      begin
        tries ||= 5
        get_page(url, opts)
      rescue Capybara::Poltergeist::DeadClient, Errno::EPIPE, NoMethodError, Capybara::Poltergeist::BrowserError => e
        restart_session
        retry unless (tries -= 1).zero?
        close
        raise e
      end
    end

    def get_page(url, opts)
      session.visit(url.to_s)
      page = Page.new(
        session.current_url,
        :body => session.html.dup,
        :code => session.status_code,
        :headers => session.response_headers,
        :force_format => (opts[:force_format] || default_page_format)
      )
      session.reset!
      page
    rescue Capybara::Poltergeist::TimeoutError => e
      restart_session
      return Page.new(url, :error => e)
    end

    private

    def default_page_format
      # Don't force the page format if the default format is set to :any
      return unless [:xml, :html].include? Settings.page_format
      Settings.page_format
    end

  end
end
