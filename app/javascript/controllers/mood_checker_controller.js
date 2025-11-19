import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["moodStatus", "comment", "commentStatus", "counter", "saveButton"]
  static values = { recordId: Number }

  connect() {
    console.log("MoodChecker接続:", this.recordIdValue)
    this.initCounter()
  }

  // 気分選択
  async select(event) {
    const button = event.currentTarget;
    document.querySelectorAll('.mood-btn').forEach(btn => btn.classList.remove('mood-selected'));
    button.classList.add('mood-selected');
    const mood = button.dataset.mood

    this.disableMoodButtons()

    await this.saveMoodData(mood, null)
  }

  // メモ保存
  async saveComment(event) {
    event.preventDefault()
    const comment = this.commentTarget.value.trim()
    if (!comment) {
      alert("メモを入力してください")
      return
    }

    this.disableCommentButton()

    await this.saveMoodData(null, comment)
  }

  // 統合保存（JSONベース）
  async saveMoodData(mood, comment) {
    try {
      const formData = new FormData()
      if (mood) formData.append('mood[feeling]', mood)
      if (comment) formData.append('mood[comment]', comment)

      const response = await fetch(`/checkinout_records/${this.recordIdValue}/moods`, {
        method: 'POST',
        headers: {
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
          'Accept': 'application/json'
        },
        body: formData,
        credentials: 'same-origin'
      })

      if (response.ok) {
        const data = await response.json()
        if (data.status === 'success' || data.status === 'complete' || data.status === 'feeling_only' || data.status === 'comment_only') {
          this.applySuccessState(data)
        } else {
          // 既に記録済みなどのカスタムステータス
          alert(data.message || '記録に失敗しました')
          this.enableButtons()
        }
      } else {
        // 非200系：サーバーエラー or forbidden
        const data = await response.json().catch(() => null)
        alert(data?.errors?.join?.(", ") || data?.message || '通信エラーが発生しました')
        this.enableButtons()
      }
    } catch (error) {
      console.error('通信エラー:', error)
      alert("通信エラーが発生しました")
      this.enableButtons()
    }
  }

  applySuccessState(data) {
    // data: { status, mood_emoji, comment, mood_complete, feeling_present, comment_present }
    // 気分があるならボタンを無効化して表示を更新
    if (data.feeling_present) {
      // disable mood buttons and visually mark selected one (if you included mood in response, use it)
      document.querySelectorAll('.mood-btn').forEach(btn => {
        btn.disabled = true
        btn.style.opacity = '0.5'
        if (data.feeling && btn.dataset.mood === data.feeling) {
          btn.classList.add('mood-selected')
        }
      })
      if (this.hasMoodStatusTarget) {
        this.moodStatusTarget.classList.remove('hidden')
        this.moodStatusTarget.textContent = `${data.mood_emoji || ''} 記録されました`
      }
    }

    if (data.comment_present) {
      if (this.hasSaveButtonTarget) {
        this.saveButtonTarget.disabled = true
        this.saveButtonTarget.style.opacity = '0.5'
        this.saveButtonTarget.textContent = '保存済み'
      }
      if (this.hasCommentTarget) {
        this.commentTarget.disabled = true
        this.commentTarget.style.opacity = '0.5'
      }
      if (this.hasCommentStatusTarget) {
        this.commentStatusTarget.classList.remove('hidden')
        this.commentStatusTarget.textContent = 'メモを保存しました'
      }
    }

    // コメント文字列を更新（サーバーの値を反映）
    if (data.comment !== undefined && this.hasCommentTarget) {
      this.commentTarget.value = data.comment
      if (this.hasCounterTarget) this.counterTarget.textContent = data.comment.length
    }

    // 完了フラグがある場合（両方完了）、optionally replace the whole checker with complete partial
    if (data.mood_complete) {
      // 単純に文言を切り替える例。部分テンプレートをサーバからHTMLで取得する方法もあります。
      if (this.hasMoodStatusTarget) {
        this.moodStatusTarget.textContent = '完了しました！'
      }
    }
  }

  disableMoodButtons() {
    document.querySelectorAll('.mood-btn').forEach(button => {
      button.disabled = true
      button.style.opacity = '0.5'
    })
  }

  disableCommentButton() {
    if (this.hasSaveButtonTarget) {
      this.saveButtonTarget.disabled = true
      this.saveButtonTarget.style.opacity = '0.5'
      this.saveButtonTarget.textContent = '投稿しました！'
    }
    if (this.hasCommentTarget) {
      this.commentTarget.disabled = true
      this.commentTarget.style.opacity = '0.5'
    }
  }

  enableButtons() {
    document.querySelectorAll('.mood-btn').forEach(button => {
      button.disabled = false
      button.style.opacity = '1'
    })
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

  initCounter() {
    if (this.hasCommentTarget && this.hasCounterTarget) {
      this.commentTarget.addEventListener('input', () => {
        this.counterTarget.textContent = this.commentTarget.value.length
      })
    }
  }
}
