class GroupMembersController < ApplicationController
  before_filter :authenticate_user!

  rescue_from ActiveRecord::RecordNotFound do
    render :file => "#{Rails.root}/public/404.html", :layout => false, :status => 404
  end

  def destroy
    group = Group.find_by_id( params[:group_id].to_i )
    if group
      if current_user.admin_of?(group)
        target = group.group_members.find_by_person_id( params[:id].to_i )
        if target
          target.destroy
        end
      end
    end

    redirect_to :back
  end

end
