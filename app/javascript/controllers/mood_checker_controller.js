import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["moodStatus", "comment", "commentStatus", "counter", "saveButton"]
  static values = { recordId: Number }

  connect() {
    this.initCounter()
    this.highlightSelectedMood()
  }

  // 初期状態で選択済みボタンをハイライト
  highlightSelectedMood() {
    const selectedButton = Array.from(document.querySelectorAll('.mood-btn'))
      .find(btn => btn.dataset.mood === this.commentTarget?.dataset.feeling)
    if (selectedButton) selectedButton.classList.add('mood-selected')
  }

  // 気分選択
  async select(event) {
    const button = event.currentTarget
    document.querySelectorAll('.mood-btn').forEach(btn => btn.classList.remove('mood-selected'))
    button.classList.add('mood-selected')

    const mood = button.dataset.mood
    await this.saveMoodData(mood, null)
  }

  // コメント保存
  async saveComment(event) {
    event.preventDefault()
    const comment = this.commentTarget.value.trim()
    if (!comment) return alert("メモを入力してください")
    await this.saveMoodData(null, comment)
  }

  // 保存共通
  async saveMoodData(mood, comment) {
    try {
      const formData = new FormData()
      if (mood) formData.append('mood[feeling]', mood)
      if (comment) formData.append('mood[comment]', comment)

      const response = await fetch(`/checkinout_records/${this.recordIdValue}/moods`, {
        method: 'POST',
        headers: { 'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content },
        body: formData
      })

      if (response.ok) {
        this.moodStatusTarget.textContent = "記録されました！チェックアウトする前までは編集できます！"
        this.moodStatusTarget.classList.remove('hidden')
      } else {
        const data = await response.json()
        alert(data.status === 'already_recorded' ? '既に記録済みです' : '記録に失敗しました')
      }
    } catch (error) {
      console.error("通信エラー:", error)
      alert("通信エラーが発生しました")
    }
  }

  // 文字数カウンター
  initCounter() {
    if (!this.hasCommentTarget || !this.hasCounterTarget) return
    this.commentTarget.addEventListener('input', () => {
      this.counterTarget.textContent = this.commentTarget.value.length
    })
  }
}
