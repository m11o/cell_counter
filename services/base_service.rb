require_relative "../lib/config_store"

class BaseService
  def initialize
    @config = ConfigStore.instance
  end
end
