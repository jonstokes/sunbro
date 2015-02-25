require 'spec_helper'
require 'open-uri'

describe Sunbro::Settings do

  before :each do
    @proxy_url = 'http://proxy1.oddwonout.com:8888/'
    Sunbro::Settings.configure {|c| c.proxy_url = @proxy_url}
  end

  describe '::proxy_url' do
    it 'returns the proxy url' do
      expect(Sunbro::Settings.proxy_url).to eq(@proxy_url)
    end
  end

  describe '::proxy_host' do
    it 'returns the proxy host' do
      expect(Sunbro::Settings.proxy_host).to eq('proxy1.oddwonout.com')
    end
  end

  describe '::proxy_port' do
    it 'returns the proxy port' do
      expect(Sunbro::Settings.proxy_port).to eq(8888)
    end
  end

end
