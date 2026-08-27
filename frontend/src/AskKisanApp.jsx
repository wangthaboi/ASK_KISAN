import { useState } from 'react'
import Header from './components/Header'
import ResultPanel from './components/ResultPanel'
import SearchBar from './components/SearchBar'

const apiBaseUrl = (import.meta.env.VITE_API_URL || 'http://localhost:8000').replace(/\/$/, '')
const sessionStorageKey = 'ask-kisan-session-id'

export default function AskKisanApp() {
  const [question, setQuestion] = useState('')
  const [state, setState] = useState('idle')
  const [answer, setAnswer] = useState('')
  const [sources, setSources] = useState(null)
  const [error, setError] = useState('')

  async function submitQuestion(event) {
    event.preventDefault()
    const trimmedQuestion = question.trim()
    if (!trimmedQuestion) return

    setState('loading')
    setError('')
    try {
      const response = await fetch(`${apiBaseUrl}/query`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ question: trimmedQuestion, language: navigator.language?.split('-')[0] || 'en', session_id: sessionStorage.getItem(sessionStorageKey) }),
      })
      const payload = await response.json().catch(() => null)
      if (!response.ok || !payload?.answer) throw new Error(payload?.detail || 'Please check your connection and try again.')
      setAnswer(payload.answer)
      setSources(payload.sources)
      if (payload.session_id) sessionStorage.setItem(sessionStorageKey, payload.session_id)
      setState('success')
    } catch (requestError) {
      setState('error')
      setError(requestError.message || 'Please check your connection and try again.')
    }
  }

  const hasResult = state !== 'idle'
  return (
    <main className={`ask-page ${hasResult ? 'has-result' : ''}`}>
      <div className="hero-bleed" aria-hidden="true" />
      <section className="hero-frame">
        <Header />
        <div className="hero-content">
          <div className="hero-badge"><span aria-hidden="true">✦</span> Trusted agricultural guidance</div>
          <h1>What would you<br />like to grow?</h1>
          <p className="hero-support">Practical answers for every growing season.</p>
          <SearchBar question={question} onQuestionChange={setQuestion} onSubmit={submitQuestion} isLoading={state === 'loading'} />
          <p className="hero-hint">Include your crop and what you’re observing for a better answer.</p>
        </div>
        <a className="photo-credit" href="https://unsplash.com/photos/the-sun-is-setting-over-a-wheat-field-NzgDuBIzBNw" target="_blank" rel="noreferrer">Photo by N N / Unsplash</a>
      </section>
      <div className="answer-wrap"><ResultPanel state={state} answer={answer} sources={sources} error={error} /></div>
    </main>
  )
}
