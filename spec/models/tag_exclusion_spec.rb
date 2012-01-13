require 'spec_helper'

describe TagExclusion do
  before do
    @tag = ActsAsTaggableOn::Tag.create(:name => "partytimeexcellent")
    TagExclusion.create!(:tag => @tag, :user => alice)
  end

  it 'validates uniqueness of tag_exclusion scoped through user' do
    TagExclusion.new(:tag => @tag, :user => alice).valid?.should be_false
  end

  it 'allows multiple tag exclusions for different users' do
    TagExclusion.new(:tag => @tag, :user => bob).valid?.should be_true
  end
end
