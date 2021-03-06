require 'ostruct'

module Boards

  class Config < OpenStruct
  end

  class << self
    def config
      @config ||= Config.new
    end

    def configure
      yield config
    end
  end

end
