import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="liff"
export default class extends Controller {
  static values = { liffId: String }
  static targets = ["name", "image"]

  async connect() {
    if (!liff.isInClient()) {
      console.log('🌐 外部ブラウザからのアクセス')
      this.handleExternalAccess()
      return
    }

    try {
      await liff.init({ liffId: this.liffIdValue })
      console.log("✅ LIFF initialized")

      if (!liff.isLoggedIn()) {
        liff.login()
        return
      }

      const profile = await liff.getProfile()
      console.log("👤 Profile:", profile)

      if (this.hasNameTarget) this.nameTarget.textContent = `こんにちは、${profile.displayName} さん！`
      if (this.hasImageTarget) this.imageTarget.src = profile.pictureUrl

      // 🆕 認証処理を追加
      await this.sendUserDataToRails(profile)

    } catch (error) {
      console.error("LIFF error:", error)
      if (this.hasNameTarget) this.nameTarget.textContent = "LIFFの初期化に失敗しました"
    }
  }

  handleExternalAccess() {
    // LINE公式アカウント誘導（STEP 9で使用）
    if (this.hasNameTarget) {
      this.nameTarget.innerHTML = `
        <div class="external-access-message">
          <h3>📱 このアプリはLINE内でご利用ください</h3>
          <p>LINE公式アカウントを友だち追加してアクセスしてください</p>
          <a href="/line_guide" class="btn btn-success">LINE公式アカウントを開く</a>
        </div>
      `
    }
  }

    // 🆕 Rails認証処理を追加
    async sendUserDataToRails(profile) {
      try {
        const userData = {
          line_user_id: profile.userId,
          avatar_url: profile.pictureUrl
          // display_nameは削除（先ほどの設計通り）
        }

        const response = await fetch('/line_sessions', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
          },
          body: JSON.stringify(userData)
        })

        const data = await response.json()

        if (data.success) {
          if (data.redirect_to_nickname_setup) {
            // 初回ユーザー → ニックネーム設定画面へ
            window.location.href = '/users/setup_nickname'
          } else {
            // 既存ユーザー → メイン画面へ
            window.location.href = '/checkin'
          }
        } else {
          console.error('認証エラー:', data.error)
          alert('ログインに失敗しました')
        }
      } catch (error) {
        console.error('通信エラー:', error)
        alert('通信エラーが発生しました')
      }
    }
  }
