require 'factory'

module SmppTools
  class Producer
    include Factory

    attr_reader :name

    def initialize(name)
      @name = name
    end

    def to_str
      "Send msgs througth #{@name} gateway"
    end


  end
end
