import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="liff"
export default class extends Controller {
  static values = { liffId: String }
  static targets = ["name", "image"]

  async connect() {
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
    } catch (error) {
      console.error("LIFF error:", error)
      if (this.hasNameTarget) this.nameTarget.textContent = "LIFFの初期化に失敗しました"
    }
  }
}
