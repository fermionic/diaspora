class GroupsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show]

  # respond_to :html, :except => [:tag_index]
  # respond_to :json, :only => [:index, :show]
  # respond_to :js, :only => [:tag_index]

  rescue_from ActiveRecord::RecordNotFound do
    render :file => "#{Rails.root}/public/404.html", :layout => false, :status => 404
  end

  def show
    if params[:id]
      @group = Group.find_by_id( params[:id].to_i )
    elsif params[:identifier]
      @group = Group.find_by_identifier( params[:identifier] )
    end
    if @group.nil?
      return redirect(:back)
    end

    @stream = Stream::Group.new(current_user, @group.identifier, :max_time => max_time, :page => params[:page])
  end
end
