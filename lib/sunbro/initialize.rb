if Sunbro::Settings.proxy_url
  puts "## Setting RestClient proxy to #{Sunbro::Settings.proxy_url}"
  RestClient.proxy = Sunbro::Settings.proxy_url
end
