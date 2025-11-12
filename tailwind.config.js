module.exports = {
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js'
  ],
  plugins: [require("daisyui")],
  daisyui: {
    themes: [
      { mytheme: {
          "primary": "#FB9E3A",   //オレンジ
          "secondary": "#FCEF91", // 黄色
          "accent": "#EA2F14",    // 赤
          "neutral": "#E6521F", // 赤茶
          "base-100": "#FFFFFF", // 白
          "info": "#00BFFF",    //オレンジみの強い濃いめの黄色
          "success": "#32CD99", //緑
          "warning": "#bae8e8", //水色
          "error": "#272343",  //濃いグレー
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
    extend: {
      fontFamily: {
        caprasimo: ["Caprasimo", 'cursive'],
        mplus: ['"M PLUS Rounded 1c"', 'sans-serif'],
      },
    },
  },
  safelist: [
    {
      pattern: /alert-(success|error)/,
    }
  ],

}