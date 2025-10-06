import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["moodStatus", "comment", "commentStatus", "counter", "saveButton"]
  static values = { recordId: Number }

  connect() {
    console.log("MoodChecker接続:", this.recordIdValue)
    this.initCounter()
    this.checkMoodStatus()
  }

  async checkMoodStatus() {
    try {
      const response = await fetch(`/checkinout_records/${this.recordIdValue}/moods/mood_check`)
      const data = await response.json()

      if (data.recorded) {
        document.querySelectorAll('[data-mood]').forEach(btn => btn.disabled = true)
        this.moodStatusTarget.classList.remove("hidden")
      }
    } catch (error) {
      console.log("気分状態の確認に失敗")
    }
  }

  // 気分選択（統合版）
  async select(event) {
    const mood = event.target.dataset.mood
    console.log("気分選択:", mood)

    // 既存のメモを取得
    const currentComment = this.hasCommentTarget ? this.commentTarget.value.trim() : null

    await this.saveMoodData(mood, currentComment)
  }

  // メモ保存（統合版）
  async saveComment(event) {
    const comment = this.commentTarget.value.trim()
    console.log("送信データ:", comment, "文字数:", comment.length)

    if (!comment) {
      alert("メモを入力してください")
      return
    }

    await this.saveMoodData(null, comment)
  }

  // 統合された保存メソッド
  async saveMoodData(mood, comment) {
    try {
      const formData = new FormData()

        if (mood) {
          formData.append('mood[feeling]', mood)
        }
        if (comment) {
          formData.append('mood[comment]', comment)
        }

        const response = await fetch(`/checkinout_records/${this.recordIdValue}/moods`, {
          method: 'POST',
          headers: {
            'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
            // Content-Typeは削除
          },
          body: formData  // FormDataに変更
        })

        const data = await response.json()

        if (data.status === 'success') {
          if (mood) {
            this.moodStatusTarget.classList.remove("hidden")
            document.querySelectorAll('[data-mood]').forEach(btn => btn.disabled = true)
          }
          if (comment) {
            this.commentStatusTarget.classList.remove("hidden")
          }
        }
      } catch (error) {
        alert("通信エラーが発生しました")
      }
    }

  // 文字数カウンター（そのまま）
  initCounter() {
    if (this.hasCommentTarget && this.hasCounterTarget) {
      this.commentTarget.addEventListener('input', () => {
        this.counterTarget.textContent = this.commentTarget.value.length
      })
    }
  }
}