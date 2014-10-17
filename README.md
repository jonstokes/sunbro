# Sunbro

Some code that I use to crawl the web at scale with Poltergeist and
PhantomJS (cf. [stretched.io](https://github.com/jonstokes/stretched.io)). Uses a bunch of code from the venerable [anemone gem](https://github.com/chriskite/anemone). Released in the spirit of jolly cooperation.

## Installation

Add this line to your application's Gemfile:

    gem 'sunbro'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sunbro

## Usage

I use sunbro to crawl the web at scale via Sidekiq on EC2. I've found
that web scraping with capybara/poltergeist + phantomjs is a giant pain
on JRuby (for various reasons that you'll encounter once you try it), 
and this gem is basically my collection of fixes that makes it actually
work. And it works pretty well; I use in production to crawl
230 sites and counting.

Here's an example of a worker that looks something like what you might find in my code:

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
a page that is AJAX-heavy, that's where you'll get the most out of sunbro.
To use phantomjs to scrape a page, you'll want to call `connection.render_page(link)`.
This renders the JS on the page, but doesn't download any images.

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
PhantomJS functionality that I don't use, and you can read more about
what it does and why, in [this blog post](http://jonstokes.com/2014/07/07/monkey-patching-poltergeist-for-web-scraping-with-jruby/).

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
