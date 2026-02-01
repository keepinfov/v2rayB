import vuetify, { transformAssetUrls } from 'vite-plugin-vuetify'
import { darkTheme } from './theme/colors'

export default defineNuxtConfig({
  ssr: false,
  modules: [
    '@vueuse/nuxt',
    '@unocss/nuxt',
    '@nuxtjs/i18n',
    (_options, nuxt) => {
      nuxt.hooks.hook('vite:extendConfig', (config) => {
        config.plugins!.push(vuetify({ autoImport: true }))
      })
    }
  ],
  vite: {
    vue: {
      template: {
        transformAssetUrls
      }
    }
  },
  i18n: {
    strategy: 'no_prefix',
    defaultLocale: 'en',
    bundle: {
      optimizeTranslationDirective: false,
      strictMessage: false
    },
    locales: [
      {
        code: 'en',
        language: 'en-US',
        file: 'en.yaml',
        name: 'English'
      }
    ]
  },
  unocss: {
    preflight: false
  },
  css: ['@mdi/font/css/materialdesignicons.css', 'vuetify/styles']
})
