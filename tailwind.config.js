module.exports = {
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js'
  ],
  plugins: [require("daisyui")],
  daisyui: {
    themes: ["light", "dark", "cupcake", "dracula",
      { mytheme: {
          "primary": "#1E90FF",   // デフォルトのボタン色
          "secondary": "#FF69B4", // サブ色
          "accent": "#FFD700",    // アクセント
          "neutral": "#3D4451",
          "base-100": "#FFFFFF",
          "info": "#2094f3",
          "success": "#009485",
          "warning": "#ff9900",
          "error": "#ff5724",
        } }
    ],
    base: true,
    styled: true,
    utils: true,
    prefix: "",
    logs: true,
    themeRoot: ":root",
  },
  theme: {
    container: {
      center: true,
      padding: '1rem',
    },
  },
  safelist: [
    {
      pattern: /alert-(success|error)/,
    }
  ],

}