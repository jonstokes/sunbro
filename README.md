# Sunbro

Some code that I use to crawl the web at scale with Poltergeist and
PhantomJS. Uses a bunch of code from the venerable [anemone gem](https://github.com/chriskite/anemone).
Released in the spirit of jolly cooperation.

## Installation

Add this line to your application's Gemfile:

    gem 'sunbro'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sunbro

## Usage

I use sunbro to crawl the web at scale via Sidekiq on EC2. Here's an
example of a worker that looks something like what you might find in my code:

```ruby
class CrawlerWorker

  def perform(opts)
    @connection = Sunbro::Connection.new
    return unless @links = opts[:links]

    links.each do |link|
      next unless page = @connection.get_page(link)
      puts "Page #{page.url} returned code #{page.code} with body size #{page.body.size}"
    end

  ensure
    @connection.close
  end

end
```

The above uses `net-http` to fetch connections, and it pools
them. This is all you need most of the time. However, if you're scraping
a page that is AJAX-heavy, you'll want to call `connection.render_page(link)`,
because that will use PhantomJS to pull and render the page.

The one option to either `get_page` or `render_page` is
`:force_format`, can be one of `:html`, `:xml`, or `:auto`. If the
option is set to `:html`, then `Nokogiri::HTML` will be used to parse
`page.body`; if it's set to `:xml`, then `Nokogiri::XML` is used. If
it's set to `:auto` or `nil`, `Nokogiri.parse` is called.

## Configuration

You can configure a few options in a `config/initializers/sunbro.rb`
file, as follows:

```ruby
Sunbro::Settings.configure do |config|
  config.user_agent = ENV['USER_AGENT_STRING1']
  config.phantomjs_user_agent = ENV['USER_AGENT_STRING2']
  config.page_format = :auto
end
```

## PhantomJS zombie process monkey patch

I use the following monkey patch for PhantomJS, because it has zombie
process issues when it comes to JRuby. This monkey patch kills some minor
PhantomJS functionality that I don't use, but I've been using it so long that I
don't remember exactly what functionality it kills. Use at your own
risk.

I put this in `config/initializers/phantomjs.rb`

```ruby
require "capybara"
require "capybara/poltergeist"
require "capybara/poltergeist/utility"

module Capybara::Poltergeist
  Client.class_eval do
    def start
      @pid = Process.spawn(*command.map(&:to_s), pgroup: true)
      ObjectSpace.define_finalizer(self, self.class.process_killer(@pid))
    end

    def stop
      if pid
        kill_phantomjs
        ObjectSpace.undefine_finalizer(self)
      end
    end
  end
end
```

## Next steps

Right now, this is more of a bag of code than a bona fide user-friendly
gem. One next step would be to add some configuration options for PhantomJS
that get passed via `render_page` to poltergeist and then on to the
command line. Another would be to use `net-http-persistent`, which is
actually included here as a dependency but isn't yet used.

## Contributing

1. Fork it ( http://github.com/<my-github-username>/sunbro/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
