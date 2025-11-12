import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="liff"
export default class extends Controller {
  static values = { liffId: String }
  static targets = ["name", "image"]

  async connect() {
    try {
      await liff.init({ liffId: this.liffIdValue })
      console.log("✅ LIFF initialized")

      if (!liff.isInClient()) {
        console.log('🌐 外部ブラウザからのアクセス')
        this.handleExternalAccess()
        return
      }

      if (!liff.isLoggedIn()) {
        liff.login()
        return
      }

      const loggedInMeta = document.querySelector("meta[name='logged-in']")
      const alreadyLoggedIn = loggedInMeta && loggedInMeta.content === "true"
      if (alreadyLoggedIn) {
        console.log("🟢 Railsセッションが存在するため、LINE再認証をスキップ")
        return
      }

      const profile = await liff.getProfile()
      console.log("👤 Profile:", profile)

      if (this.hasNameTarget) this.nameTarget.textContent = `こんにちは、${profile.displayName} さん！`
      if (this.hasImageTarget) this.imageTarget.src = profile.pictureUrl

      await this.sendUserDataToRails(profile)

    } catch (error) {
      console.error("LIFF error:", error)
      if (this.hasNameTarget) this.nameTarget.textContent = "LIFFの初期化に失敗しました"
    }
  }


  handleExternalAccess() {
    // LINE公式アカウント誘導
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
          display_name: profile.displayName,
          avatar_url: profile.pictureUrl
        }

    // 🔧 formを使って送信（ブラウザが自動的にリダイレクトに追従）
      const form = document.createElement('form')
      form.method = 'POST'
      form.action = '/line_sessions'

      // CSRF Token
      const csrfInput = document.createElement('input')
      csrfInput.type = 'hidden'
      csrfInput.name = 'authenticity_token'
      csrfInput.value = document.querySelector('[name="csrf-token"]').content
      form.appendChild(csrfInput)

      // データ
      Object.keys(userData).forEach(key => {
        const input = document.createElement('input')
        input.type = 'hidden'
        input.name = key
        input.value = userData[key]
        form.appendChild(input)
      })

      document.body.appendChild(form)
      form.submit()

    } catch (error) {
      console.error('通信エラー:', error)
      alert('通信エラーが発生しました')
    }
  }
}
