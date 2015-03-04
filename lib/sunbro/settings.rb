require 'hashie'

module Sunbro
  module Settings

    DEFAULTS = {
      user_agent:           "Mozilla/5.0 (Windows NT 6.2; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1667.0 Safari/537.36",
      phantomjs_user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X)",
      page_format:          :auto
    }
    
    class SettingsData < Struct.new(:user_agent, :proxy_url, :proxy_host, :proxy_port, :phantomjs_user_agent, :page_format);end

    def self.configure
      @configuration ||= SettingsData.new
      yield @configuration
    end

    def self.proxy_url
      return unless configured?
      if @configuration.proxy_url
        @configuration.proxy_url
      elsif @configuration.proxy_host
        if @configuration.proxy_port
          "http://#{@configuration.proxy_host}:#{@configuration.proxy_port}/"
        else
          "http://#{@configuration.proxy_host}/"
        end
      end
    end

    def self.proxy_host
      return unless configured?
      if @configuration.proxy_url
        @configuration.proxy_host = URI.parse(proxy_url).host
      else
        @configuration.proxy_host
      end
    end

    def self.proxy_port
      return unless configured?
      if @configuration.proxy_url
        @configuration.proxy_port = URI.parse(proxy_url).port
      else
        @configuration.proxy_port
      end
    end

    def self.user_agent
      return DEFAULTS[:user_agent] unless configured?
      @configuration.user_agent || DEFAULTS[:user_agent]
    end

    def self.phantomjs_user_agent
      return DEFAULTS[:phantomjs_user_agent] unless configured?
      @configuration.phantomjs_user_agent || DEFAULTS[:phantomjs_user_agent]
    end

    def self.page_format
      return DEFAULTS[:page_format] unless configured?
      @configuration.page_format
    end

    def self.configured?
      !!@configuration
    end
  end
end
