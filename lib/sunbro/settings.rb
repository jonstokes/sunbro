require 'hashie'

module Sunbro
  module Settings

    DEFAULTS = {
      user_agent:           "Mozilla/5.0 (Windows NT 6.2; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1667.0 Safari/537.36",
      phantomjs_user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X)",
      page_format:          :auto
    }

    def self.configure
      $sunbro_configuration ||= Hashie::Mash.new
      yield $sunbro_configuration
    end

    def self.user_agent
      return DEFAULTS[:user_agent] unless configured?
      $sunbro_configuration.user_agent
    end

    def self.phantomjs_user_agent
      return DEFAULTS[:phantomjs_user_agent] unless configured?
      $sunbro_configuration.phantomjs_user_agent
    end

    def self.page_format
      return DEFAULTS[:page_format] unless configured?
      $sunbro_configuration.page_format
    end

    def self.configured?
      !!$sunbro_configuration
    end
  end
end
