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
      @sunbro_configuration ||= SettingsData.new
      yield @sunbro_configuration
    end

    def self.proxy_url
      return unless configured?
      @sunbro_configuration.proxy_url
    end

    def self.proxy_host
      return unless configured?
      if @sunbro_configuration.proxy_url
        @sunbro_configuration.proxy_host = URI.parse(proxy_url).host
      else
        @sunbro_configuration.proxy_host
      end
    end

    def self.proxy_port
      return unless configured?
      if @sunbro_configuration.proxy_url
        @sunbro_configuration.proxy_port = URI.parse(proxy_url).port
      else
        @sunbro_configuration.proxy_port
      end
    end

    def self.user_agent
      return DEFAULTS[:user_agent] unless configured?
      @sunbro_configuration.user_agent
    end

    def self.phantomjs_user_agent
      return DEFAULTS[:phantomjs_user_agent] unless configured?
      @sunbro_configuration.phantomjs_user_agent
    end

    def self.page_format
      return DEFAULTS[:page_format] unless configured?
      @sunbro_configuration.page_format
    end

    def self.configured?
      !!@sunbro_configuration
    end
  end
end
