module ApplicationHelper
  def default_meta_tags
    {
      site: "green_time",
      title: "デジタル観葉植物×簡単出退勤記録アプリ",
      reverse: true,
      charset: "utf-8",
      description: "デジタル観葉植物を愛でながら、ボタンタップ一つで出退勤を打刻・記録できます。",
      keywords: "観葉植物,出勤,退勤,記録,勤怠管理",
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
end
