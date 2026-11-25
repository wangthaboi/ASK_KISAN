/**
 * AskKisan Shared Client Script
 * Handles skeleton loader transitions, accessibility attributes, and dynamic metadata.
 */
document.addEventListener('DOMContentLoaded', () => {
  // Initialize dynamic copyright year
  const yearSpans = document.querySelectorAll('.current-year');
  const currentYear = new Date().getFullYear();
  yearSpans.forEach(el => {
    el.textContent = currentYear;
  });

  // Handle Skeleton Loader transition
  const skeletonContainer = document.querySelector('.skeleton-container');
  const pageContent = document.querySelector('.page-content');

  // Provide a clean, fluid transition from skeleton state to rendered document
  const revealContent = () => {
    if (skeletonContainer && pageContent) {
      skeletonContainer.classList.add('hidden');
      skeletonContainer.setAttribute('aria-busy', 'false');
      pageContent.classList.add('visible');
    }
  };

  // Check document readiness. If already loaded or ready, reveal after minimal frame to prevent visual flash
  if (document.readyState === 'complete') {
    setTimeout(revealContent, 100);
  } else {
    window.addEventListener('load', () => {
      setTimeout(revealContent, 100);
    });
    // Fallback timer to ensure content is visible even on slow network assets
    setTimeout(revealContent, 1500);
  }
});
