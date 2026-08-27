/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,jsx}'],
  theme: {
    extend: {
      colors: { ink: '#17382b', forest: '#1e5a3d', moss: '#73a36c', canvas: '#f5f6f0' },
      boxShadow: { glass: '0 18px 60px rgba(23, 56, 43, 0.10)' },
    },
  },
  plugins: [],
}
