#Usage example
#class Base
#  include Factory
#end
#
#class A < Base
#  register_subclass "key_for_A"
#end
#
#class B < Base
#  register_subclass "key_for_B"
#end
#
#When an instance is needed do:
#
# ins_of_A = Base.create("key_for_A", arg1, arg2, ..., argN)
#
# where arg1, ..., argN are the argument given to the initialize method
module Factory

  module ClassMethods

  @@classes = {}

    def create(name, *args)
      klass = @@classes[name]
      if klass
        klass.new(args)
      else
        raise "Class #{name} is not registered"
      end
    end

    def register_subclass(name)
      @@classes[name] = self
    end
  end

  module InstanceMethods

  end

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end
