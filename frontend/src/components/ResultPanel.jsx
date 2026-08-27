function AnswerText({ answer }) {
  return answer.split(/\n{2,}/).map((paragraph, index) => (
    <p key={`${paragraph}-${index}`} className="leading-7 text-ink/85">{paragraph}</p>
  ))
}

export default function ResultPanel({ state, answer, sources, error }) {
  if (state === 'idle') return null

  return (
    <section className="result-panel animate-rise" aria-live="polite" aria-atomic="true">
      {state === 'loading' && <div className="space-y-3" aria-label="Preparing a grounded response"><div className="h-3 w-28 animate-pulse rounded-full bg-forest/15" /><div className="h-4 w-full animate-pulse rounded-full bg-ink/10" /><div className="h-4 w-11/12 animate-pulse rounded-full bg-ink/10" /><div className="h-4 w-2/3 animate-pulse rounded-full bg-ink/10" /></div>}
      {state === 'error' && <div><p className="text-sm font-semibold text-forest">Couldn’t reach Ask Kisan</p><p className="mt-2 leading-7 text-ink/75">{error}</p></div>}
      {state === 'success' && (
        <div>
          <p className="mb-3 text-xs font-semibold uppercase tracking-[0.14em] text-forest">Ask Kisan</p>
          <div className="space-y-4"><AnswerText answer={answer} /></div>
          {sources?.length > 0 && <div className="mt-6 border-t border-forest/10 pt-4"><p className="text-xs font-medium text-ink/55">Grounded in Ask Kisan knowledge records</p><ul className="mt-2 flex flex-wrap gap-2" aria-label="Source references">{sources.map((source) => <li key={source} className="rounded-full bg-forest/8 px-3 py-1 text-xs font-medium text-forest">{source}</li>)}</ul></div>}
        </div>
      )}
    </section>
  )
}
