set -o errexit

# 依存関係をインストール
bundle install
# CSS/JS のアセットを事前コンパイル
bundle exec rails assets:precompile
# 古いアセットを削除
bundle exec rails assets:clean
# DB マイグレーションを実行
bundle exec rails db:migrate