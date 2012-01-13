class GroupMembersController < ApplicationController
  before_filter :authenticate_user!

  rescue_from ActiveRecord::RecordNotFound do
    render :file => "#{Rails.root}/public/404.html", :layout => false, :status => 404
  end

  def create
    # {"group_members"=>{"handles"=>"hh"}, "group_id"=>"4",}

    group = Group.find_by_id( params['group_id'].to_i )
    if group.nil? || ! params['group_members'].respond_to?(:[])
      return redirect_to(:back)
    end

    handles_not_found = []
    num_added = 0

    params['group_members']['handles'].split(/[ ,;]+/).each do |handle|
      person = Person.find_by_diaspora_handle(handle)
      if person.nil?
        handles_not_found << handle
      else
        begin
          group.members << person
          num_added += 1
          # TODO: Notify new member
        rescue ActiveRecord::RecordNotUnique
          # quietly ignore
        end
      end
    end

    if handles_not_found.empty?
      flash[:notice] = t('groups.members.add.success', :num => num_added)
    else
      flash[:error] = t('groups.members.add.failure')
    end
    redirect_to :back
  end

  def destroy
    group = Group.find_by_id( params[:group_id].to_i )
    if group
      if current_user.admin_of?(group)
        target = group.group_members.find_by_person_id( params[:id].to_i )
        if target
          target.destroy
          # TODO: Notify removed person
        end
      end
    end

    redirect_to :back
  end

end
