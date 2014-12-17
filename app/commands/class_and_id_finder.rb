class ClassAndIdFinder
  attr_reader :collection, :name_builder

  def initialize(collection, &block)
    @collection = collection
    @name_builder = block || lambda { |name| name}
  end

  def execute(&block)
    collection.each do |kind|
      class_name = name_builder.call(kind)
      id = yield class_name
      if id
        return [class_name.camelize, id]
      end
    end
    raise ClassNotFoundError.new
  end

  class ClassNotFoundError < StandardError
  end
end
