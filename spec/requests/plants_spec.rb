require 'rails_helper'
require 'securerandom'

RSpec.describe "Plants", type: :request do
  before do
    @user = User.create!(email: "u#{SecureRandom.hex(4)}@example.test", password: 'password')
    allow_any_instance_of(ApplicationController).to receive(:authenticate_user_with_line_support!).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)
    # Prevent asset pipeline processing in layout
    allow_any_instance_of(ActionView::Helpers::AssetTagHelper).to receive(:stylesheet_link_tag).and_return('')
    allow_any_instance_of(ActionView::Helpers::AssetTagHelper).to receive(:javascript_include_tag).and_return('')
  allow_any_instance_of(ActionView::Helpers::AssetTagHelper).to receive(:image_tag).and_return('')
  allow_any_instance_of(ActionView::Helpers::AssetTagHelper).to receive(:favicon_link_tag).and_return('')
  allow_any_instance_of(ActionView::Helpers::AssetTagHelper).to receive(:asset_path).and_return('')
  # Prevent meta-tags helper from attempting to resolve asset URLs (ogp.png etc.)
  allow_any_instance_of(ApplicationHelper).to receive(:default_meta_tags).and_return({})
  allow_any_instance_of(ActionView::Helpers::AssetUrlHelper).to receive(:image_url).and_return('')
  allow_any_instance_of(ActionView::Helpers::AssetUrlHelper).to receive(:asset_url).and_return('')
    # ensure plant exists (don't call the private create_plant method on User)
    @plant = @user.plant || Plant.create!(user: @user)
    # Stub Sprockets asset lookup to avoid SassC compilation
    if defined?(Sprockets)
      begin
        allow_any_instance_of(Sprockets::Environment).to receive(:find_asset).and_return(double(source: '', pathname: '/dev/null'))
      rescue NameError
      end
      begin
        allow_any_instance_of(Sprockets::Manifest).to receive(:find).and_return([])
      rescue NameError
      end
    end
  end

  describe 'GET /plants' do
    it '表示されること' do
      get plants_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH /plants' do
    it '植物名を更新してリダイレクトすること' do
      patch plant_path(@plant), params: { plant: { plant_name: 'NewName' } }
      expect(response).to have_http_status(302)
      expect(@user.plant.reload.plant_name).to eq 'NewName'
    end
  end
end
