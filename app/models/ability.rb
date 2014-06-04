class Ability
  include CanCan::Ability

  def initialize(user)
    if user.admin?
      can :manage, :all
    else
      can :create, :all
      can [:read, :update, :destroy], :all, :user_id => user.id
    end
  end
end
