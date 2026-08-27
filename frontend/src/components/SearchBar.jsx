export default function SearchBar({ question, onQuestionChange, onSubmit, isLoading }) {
  const isEmpty = !question.trim()

  return (
    <form onSubmit={onSubmit} className="hero-search" aria-busy={isLoading}>
      <label className="sr-only" htmlFor="farmer-question">Ask a farming question</label>
      <svg className="hero-search-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" aria-hidden="true"><circle cx="11" cy="11" r="6.5" /><path d="m16 16 4 4" /></svg>
      <input id="farmer-question" className="hero-search-input" value={question} onChange={(event) => onQuestionChange(event.target.value)} placeholder="Ask about crops, pests, or schemes" maxLength={1000} disabled={isLoading} autoComplete="off" />
      <button type="submit" disabled={isEmpty || isLoading} className="hero-send-button" aria-label={isLoading ? 'Sending question' : 'Send question'}>
        {isLoading ? <span className="hero-loading-dot" aria-hidden="true" /> : <span className="text-xl leading-none" aria-hidden="true">↑</span>}
      </button>
    </form>
  )
}
