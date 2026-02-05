import { createVuetify } from 'vuetify'
import { darkTheme } from '../theme/colors'

export default defineNuxtPlugin((app) => {
  const vuetify = createVuetify({
    theme: {
      defaultTheme: 'dark',
      themes: {
        dark: darkTheme
      }
    },
    defaults: {
      VBtn: {
        rounded: 'lg'
      },
      VCard: {
        rounded: 'lg'
      },
      VTextField: {
        variant: 'outlined',
        density: 'comfortable'
      },
      VSelect: {
        variant: 'outlined',
        density: 'comfortable'
      },
      VSwitch: {
        color: 'primary'
      },
      VDataTable: {
        hover: true
      },
      VDialog: {
        transition: 'dialog-transition'
      },
      VMenu: {
        transition: 'scale-transition'
      },
      VSnackbar: {
        timeout: 3000
      }
    }
  })
  app.vueApp.use(vuetify)
})
