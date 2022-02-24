// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration
module.exports = {
  content: [
    './js/**/*.js',
    '../lib/*_web.ex',
    '../lib/*_web/**/*.*ex'
  ],
  theme: {
    colors: {
      'white': '#ffffff',
      'gray': '#d3d6da',
      'green': '#6aaa64',
      'yellow': '#c9b458',
      'neutral': '#787c7e',
    },
    extend: {
      animation: {
        flip: 'flip 1s ease-in-out',
        pop: 'pop 0.1s',
      },
      keyframes: {
        flip: {
          '0%': { transform: 'rotateX(0)' },
          '50%': { transform: 'rotateX(-90deg)' },
          '100%': { transform: 'rotateX(0)' },
        },
        pop: {
          from: { transform: 'scale(0.8)', opacity: 0},
          '40%': { transform: 'scale(1.1)', opacity: 1},
        }
      }
    },
  },
  plugins: [
    require('@tailwindcss/forms')
  ]
}
