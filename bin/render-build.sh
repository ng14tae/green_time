set -o errexit

# Ruby依存関係をインストール
bundle install

# JavaScript依存関係をインストール
yarn install

# Tailwind CSSのビルド（重要！）
yarn build:css

# CSS/JSのアセットを事前コンパイル
bundle exec rails assets:precompile

# 古いアセットを削除
bundle exec rails assets:clean

# DBマイグレーションを実行
bundle exec rails db:migrate