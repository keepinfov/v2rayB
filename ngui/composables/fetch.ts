import { nanoid } from 'nanoid'
import { createFetch } from '@vueuse/core'

export const useV2Fetch = createFetch({
  baseUrl: `${system.value.api}/api/`,
  combination: 'overwrite',
  options: {
    beforeFetch({ options }) {
      if (user.value.token) {
        options.headers = {
          ...options.headers,
          Authorization: user.value.token,
          'X-V2raya-Request-Id': nanoid()
        }
      }

      return { options }
    },
    afterFetch({ data, response }) {
      if (data.code === 'FAIL') {
        const url = response.url || ''
        const isLatencyTest = url.includes('Latency')
        if (!isLatencyTest) {
          useSnackbar(data?.message, 'error')
        }
      }

      return { data }
    },
    onFetchError({ error, response }) {
      if (error) {
        const url = response?.url || ''
        const isLatencyTest = url.includes('Latency')
        if (!isLatencyTest) {
          useSnackbar(error?.message, 'error')
        }
      }

      return { error }
    }
  }
})
