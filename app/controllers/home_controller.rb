class HomeController < ApplicationController
  #before_action :become
  def index

    #@user = User.find(10) # Find the user depending on the params
    #@current_user=@user
  end

  def mask_user
    User.all.each do |u|
      u.nested_reseller=0 if u.nested_reseller==current_user.id
      u.save
    end
    user=User.find(params[:mask_user_id].to_i)
    user.nested_reseller=current_user.id
    user.save
    redirect_to root_path, :notice => "current user is #{user.email}"
  end

  def mask_out
    User.all.each do |u|
      u.nested_reseller=0 if u.nested_reseller==current_user.id
      u.save
    end
    redirect_to root_path, :notice => "clean user mask"
  end
end
