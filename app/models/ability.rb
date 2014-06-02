class Ability
  include CanCan::Ability

  def initialize(user)
    if user.admin?
      can :manage, :all
    else
      can :create, :all
      can [:read, :update, :destroy], :all, :owned? => true
    end
  end
end
