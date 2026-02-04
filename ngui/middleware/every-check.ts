export default defineNuxtRouteMiddleware(async() => {
  const nuxtApp = useNuxtApp()
  const { t } = nuxtApp.$i18n

  const { data } = await useV2Fetch<any>('version').json()

  if (data.value?.code === 'SUCCESS') {
    system.value.docker = data.value.data.dockerMode
    system.value.version = data.value.data.version
    system.value.lite = data.value.data.lite

    if (data.value.data.foundNew && data.value.data.remoteVersion) {
      system.value.latestVersion = data.value.data.remoteVersion
      system.value.updateAvailable = true
    } else {
      system.value.updateAvailable = false
    }

    let message = t(system.value.docker ? 'welcome.docker' : 'welcome.default', {
      version: system.value.version
    })
    let color: 'success' | 'info' = 'info'

    if (data.value.data.foundNew) {
      message = `${message}. ${t('welcome.newVersion', {
        version: data.value.data.remoteVersion
      })}`
      color = 'success'
    }

    useSnackbar(message, color)

    if (data.value.data.serviceValid === false)
      useSnackbar(t('version.v2rayInvalid'), 'error')
    else if (!data.value.data.v5)
      useSnackbar(t('version.v2rayNotV5'), 'error')
  }
})
