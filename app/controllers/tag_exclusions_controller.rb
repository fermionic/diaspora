class TagExclusionsController < ApplicationController
  before_filter :authenticate_user!

  # POST /tag_exclusions
  def create
    name_normalized = ActsAsTaggableOn::Tag.normalize(params['tag_exclusion']['name'])

    if name_normalized.nil? || name_normalized.empty?
      flash[:error] = I18n.t('tag_exclusions.create.none')
    else
      tag = ActsAsTaggableOn::Tag.find_or_create_by_name(name_normalized)
      tag_exclusion = current_user.tag_exclusions.new(:tag_id => tag.id)

      if tag_exclusion.save
        flash[:notice] = I18n.t('tag_exclusions.create.success', :name => name_normalized)
      else
        flash[:error] = I18n.t('tag_exclusions.create.failure', :name => name_normalized)
      end
    end

    redirect_to :back
  end

  # DELETE /tag_exclusions/1
  def destroy
    @tag_exclusion = current_user.tag_exclusions.where(:id => params['id']).first
    success = @tag_exclusion && @tag_exclusion.destroy

    if params[:remote]
      respond_to do |format|
        format.all {}
        format.js { render 'tags/update' }  # Hmm... this is probably not appropriate
      end
    else
      if success
        flash[:notice] = I18n.t('tag_exclusions.destroy.success', :name => @tag_exclusion.tag.name)
      else
        flash[:error] = I18n.t('tag_exclusions.destroy.failure', :name => @tag_exclusion.tag.name)
      end
      redirect_to filters_path
    end
  end
end
