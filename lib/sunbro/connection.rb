class Connection
  extend Sunbro
  attr_reader :http, :dhttp

  def close
    close_http_connections
  end
end

