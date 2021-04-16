require_relative "../lib/config.rb"

class BaseService
  def initialize
    @config = Config.instance
  end
end