class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :top ]
  def top; end

  def how_to_use
    # 使い方説明ページ
  end

  def terms
    # 利用規約ページ
  end

  def contact
    # お問い合わせページ
  end

  def privacy
    # プライバシーポリシーページ
  end
end
