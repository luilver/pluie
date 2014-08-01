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
# NOTE
# If a name is repeated as the hash key, then it will overwrite the value of that key
# because the hash is shared among all the classes that mix in the Factory module.
# T overcome this, the ,key is built usgig the name of the class that include the module
module Factory

  PREFIX_NAME = :@__prefix_base_class__

  def self.get_key_value(klass, name)
    until prefix = klass.instance_variable_get(PREFIX_NAME)
      klass = klass.superclass
      break unless klass
    end
    "#{prefix}_#{name}"
  end

  module ClassMethods

  @@classes = {}

    def create(name, *args)
      key = Factory.get_key_value(self, name)
      klass = @@classes[key]
      if klass
        klass.new(*args)
      else
        raise "Class #{name} is not registered with prefix #{self}"
      end
    end

    def register_subclass(name)
      key = Factory.get_key_value(self, name)
      @@classes[key] = self
    end

    def inspect_registered
      @@classes.inspect
    end
  end

  module InstanceMethods

  end

  def self.included(receiver)

    receiver.instance_variable_set(PREFIX_NAME, receiver.to_s)

    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end
