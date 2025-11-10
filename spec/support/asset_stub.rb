RSpec.configure do |config|
  # In request specs we don't need full asset pipeline; stub helpers that
  # would otherwise trigger Sprockets/SassC or require precompiled assets.
  config.before(:each, type: :request) do
    allow_any_instance_of(ActionView::Helpers::AssetTagHelper).to receive(:stylesheet_link_tag).and_return('')
    allow_any_instance_of(ActionView::Helpers::AssetTagHelper).to receive(:javascript_include_tag).and_return('')
    allow_any_instance_of(ActionView::Helpers::AssetTagHelper).to receive(:image_tag).and_return('')
    allow_any_instance_of(ActionView::Helpers::AssetTagHelper).to receive(:favicon_link_tag).and_return('')
    allow_any_instance_of(ActionView::Helpers::AssetTagHelper).to receive(:asset_path).and_return('')

    allow_any_instance_of(ApplicationHelper).to receive(:default_meta_tags).and_return({})
    allow_any_instance_of(ActionView::Helpers::AssetUrlHelper).to receive(:image_url).and_return('')
    allow_any_instance_of(ActionView::Helpers::AssetUrlHelper).to receive(:asset_url).and_return('')

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
end
