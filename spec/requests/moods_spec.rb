require 'rails_helper'
require 'securerandom'

RSpec.describe "Moods", type: :request do
  before do
    @user = User.create!(email: "u#{SecureRandom.hex(4)}@example.test", password: 'password')
    allow_any_instance_of(ApplicationController).to receive(:authenticate_user_with_line_support!).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)
    @record = @user.checkinout_records.create!(checkin_time: Time.current)
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

  describe 'GET /checkinout_records/:checkinout_record_id/moods/mood_check' do
    it '録画されているかを返すこと' do
      get mood_check_checkinout_record_moods_path(checkinout_record_id: @record.id), as: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['recorded']).to be false
    end
  end

  describe 'POST /checkinout_records/:checkinout_record_id/moods' do
    it '気分を作成して json を返すこと' do
      expect {
        post checkinout_record_moods_path(checkinout_record_id: @record.id), params: { mood: { feeling: 'happy', comment: 'ok' } }, as: :json
      }.to change { Mood.count }.by(1)

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['status']).to eq('success')
      expect(json['mood_emoji']).to eq('😊')
    end
  end
end
