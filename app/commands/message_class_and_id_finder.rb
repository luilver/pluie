class MessageClassAndIdFinder < ClassAndIdFinder
  def initialize(collection)
    super(collection) {|kind| "#{kind}_message"}
  end
end
