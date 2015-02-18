require 'spec_helper'
require 'open-uri'

describe Sunbro::Page do

  before :each do
    @http = Sunbro::HTTP.new(verbose: true)
    @body = "<html><head><title>Title</title></head><body><p>Body text</p></body></html>"

    Mocktra("www.retailer.com") do
      get '/1.html' do
        "<html><head><title>Title</title></head><body><p>Body text</p></body></html>"
      end
    end
  end

  describe "#initialize" do
    it "it scrubs invalid UTF-8 from @body by converting to UTF-16, then back again" do
      # See http://stackoverflow.com/a/8873922/1169868
      pending "Example"
      fail
    end
  end

  describe "#fetch_page" do
    it "fetches a single page" do
      url = "http://www.retailer.com/1.html"

      res = open(url).read
      page = @http.fetch_page(url)
      expect(page.body).to eq(@body)
      expect(page.url.to_s).to eq(url)
      expect(page.redirect_to).to be_nil
      expect(page.redirect_from).to be_nil

    end

    it "preserves the original url in redirect_from after a redirect" do
      pending "Figure out how to make this work with Mocktra"
      fail
    end

  end

  describe "#doc" do
    it "uses the correct Nokogiri parser to parse html or xml, or lets Nokogiri guess" do
      pending "Example"
      fail
    end
  end


  describe "#should_parse_as?", no_es: true do
    it "returns true if Nokogiri should try to parse the page with the supplied format, false otherwise" do
      url = "http://www.retailer.com/1.html"

      page = @http.fetch_page(url)
      expect(page.send(:should_parse_as?, :xml)).to eq(false)
      expect(page.send(:should_parse_as?, :html)).to eq(true)

      page = @http.fetch_page(url, force_format: :html)
      expect(page.send(:should_parse_as?, :xml)).to eq(false)
      expect(page.send(:should_parse_as?, :html)).to eq(true)

      page = @http.fetch_page(url, force_format: :xml)
      expect(page.send(:should_parse_as?, :xml)).to eq(true)
      expect(page.send(:should_parse_as?, :html)).to eq(false)
    end
  end
end
