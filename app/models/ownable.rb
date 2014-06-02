module Ownable
  def owned?
    self.user == User.current
  end
end
