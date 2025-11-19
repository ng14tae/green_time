require 'rails_helper'
require 'securerandom'

RSpec.describe "CheckinoutRecords", type: :request do
  before do
    @user = User.create!(email: "u#{SecureRandom.hex(4)}@example.test", password: 'password')
    # stub authentication & current_user
    allow_any_instance_of(ApplicationController).to receive(:authenticate_user_with_line_support!).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)
    # Prevent asset pipeline (SassC) processing in request specs which can
    # fail on modern CSS features; stub asset helpers used in layouts.
    allow_any_instance_of(ActionView::Helpers::AssetTagHelper).to receive(:stylesheet_link_tag).and_return('')
    allow_any_instance_of(ActionView::Helpers::AssetTagHelper).to receive(:javascript_include_tag).and_return('')
    allow_any_instance_of(ActionView::Helpers::AssetTagHelper).to receive(:image_tag).and_return('')
    allow_any_instance_of(ActionView::Helpers::AssetTagHelper).to receive(:favicon_link_tag).and_return('')
    allow_any_instance_of(ActionView::Helpers::AssetTagHelper).to receive(:asset_path).and_return('')
    # Prevent meta-tags helper from attempting to resolve asset URLs (ogp.png etc.)
    allow_any_instance_of(ApplicationHelper).to receive(:default_meta_tags).and_return({})
    allow_any_instance_of(ActionView::Helpers::AssetUrlHelper).to receive(:image_url).and_return('')
    allow_any_instance_of(ActionView::Helpers::AssetUrlHelper).to receive(:asset_url).and_return('')
    # Stub Sprockets asset lookup to avoid SassC compilation in tests
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

  describe 'GET /checkin_page' do
    it '表示されること' do
      get checkin_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /checkin' do
    it 'チェックインを作成し turbo_stream を返すこと' do
      expect {
        post checkin_path, headers: { "ACCEPT" => "text/vnd.turbo-stream.html" }
      }.to change { CheckinoutRecord.where(user: @user).count }.by(1)

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include('turbo-stream')
    end
  end
end
