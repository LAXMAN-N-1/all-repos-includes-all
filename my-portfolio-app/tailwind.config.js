/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/**/*.{js,jsx,ts,tsx}", // This line tells Tailwind to scan all JS, JSX, TS, TSX files in the src folder
  ],
  theme: {
    extend: {
      colors: {
        'peach-white': '#FFF9F5',
        'soft-gray-white': '#FAFAFA',
        'soft-red': '#FF6B6B',
        'coral': '#FF7F50',
        'blush-pink': '#FFD6E8',
        'mint': '#D2F8D2',
        'sky-blue': '#A3D5FF',
        'dark-gray': '#1F1F1F',
      },
      fontFamily: {
        inter: ['Inter', 'sans-serif'],
      },
    },
  },
  plugins: [],
}