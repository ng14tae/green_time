import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["moodStatus", "comment", "commentStatus", "counter", "saveButton"]
  static values = { recordId: Number }

  connect() {
    console.log("MoodChecker接続:", this.recordIdValue)
    this.initCounter()
  }

  // 気分選択（統合版）
  async select(event) {
    const mood = event.target.dataset.mood
    console.log("気分選択:", mood)

    // 即座にボタン無効化を追加
    this.disableMoodButtons()

    await this.saveMoodData(mood, null) // currentCommentをnullに変更
  }

  // メモ保存（統合版）
  async saveComment(event) {
    event.preventDefault() // 追加
    const comment = this.commentTarget.value.trim()
    console.log("送信データ:", comment, "文字数:", comment.length)

    if (!comment) {
      alert("メモを入力してください")
      return
    }

    // 即座にボタン無効化を追加
    this.disableCommentButton()

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
            'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
            'Accept': 'text/vnd.turbo-stream.html'
          },
          body: formData
        })
        if (response.ok) {
              // Turbo Stream が自動でページをリダイレクト
              console.log('気分記録成功')
            } else {
              const data = await response.json()
              alert(data.status === 'already_recorded' ?
                    '既に記録済みです' : '記録に失敗しました')
            }
          } catch (error) {
            // エラー時にボタンを再有効化
            this.enableButtons()
            console.error('通信エラー:', error)
            alert("通信エラーが発生しました")
          }
        }

        disableMoodButtons() {
          const moodButtons = document.querySelectorAll('.mood-btn')
          moodButtons.forEach(button => {
            button.disabled = true
            button.style.opacity = '0.5'
          })
        }

        // コメントボタン無効化
        disableCommentButton() {
          if (this.hasSaveButtonTarget) {
            this.saveButtonTarget.disabled = true
            this.saveButtonTarget.style.opacity = '0.5'
            this.saveButtonTarget.textContent = '保存中...'
          }

          if (this.hasCommentTarget) {
            this.commentTarget.disabled = true
            this.commentTarget.style.opacity = '0.5'
          }
        }

        // 全ボタン再有効化（エラー時用）
        enableButtons() {
          // 気分選択ボタン
          const moodButtons = document.querySelectorAll('.mood-btn')
          moodButtons.forEach(button => {
            button.disabled = false
            button.style.opacity = '1'
          })

          // コメントボタン
          if (this.hasSaveButtonTarget) {
            this.saveButtonTarget.disabled = false
            this.saveButtonTarget.style.opacity = '1'
            this.saveButtonTarget.textContent = '💭 気分メモを保存'
          }

          if (this.hasCommentTarget) {
            this.commentTarget.disabled = false
            this.commentTarget.style.opacity = '1'
          }
        }

  // 文字数カウンター
  initCounter() {
    if (this.hasCommentTarget && this.hasCounterTarget) {
      this.commentTarget.addEventListener('input', () => {
        this.counterTarget.textContent = this.commentTarget.value.length
      })
    }
  }
}