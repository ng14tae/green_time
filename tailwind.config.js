module.exports = {
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js'
  ],
  plugins: [require("daisyui")],
  daisyui: {
    themes: ["light",
      { mytheme: {
          "primary": "#1E90FF",   // 鮮やかなindigoブルー
          "secondary": "#FFECB3", // クリーム色
          "accent": "#FFD700",    //
          "neutral": "#FFA000", // ブラウン
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