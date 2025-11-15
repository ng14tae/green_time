module ApplicationHelper
  def default_meta_tags
    {
      site: "cheers_timer",
      title: "簡単！活動時間記録アプリ",
      reverse: true,
      charset: "utf-8",
      description: "ボタンタップ一つで活動時間を記録するアプリ。パートナーの観葉植物があなたの一日を応援します",
      keywords: "観葉植物,出勤,退勤,記録,活動時間記録",
      canonical: root_url,
      separator: "|",
      og: {
        site_name: :site,
        title: :title,
        description: :description,
        type: "website",
        url: root_url,
        image: image_url("ogp.png"),
        locale: "ja_JP"
      },
      twitter: {
        card: "summary_large_image",
        site: "@sss__727",
        image: image_url("ogp.png")
      }
    }
  end

  def current_plant_name
    return "MIDORI" unless user_signed_in?

    current_user.plant&.display_name || "MIDORI"
  end
end
