<script lang="ts" setup>
import { parseURL } from 'ufo'

const { data: row, subID } = defineProps<{ data: any, subID: number }>()
const { t } = useI18n()

const isVisible = ref(false)
const serverInfo = ref<any>()

const viewServer = async () => {
  isVisible.value = true
  const params = JSON.stringify({
    id: row.id,
    _type: row._type,
    sub: subID! - 1
  })

  const { data } = await useV2Fetch(`sharingAddress?touch=${params}`).get().json()

  let info: any = parseURL(data.value.data.sharingAddress)

  info = {
    ...info,
    protocol: info.protocol.slice(0, -1),
    name: decodeURIComponent(info.hash).slice(1)
  }

  switch (info.protocol) {
    case 'ss': {
      const auth = atob(info.auth).split(':')
      const address = info.host.split(':')
      info = {
        ...info,
        host: address[0],
        port: address[1],
        method: auth[0],
        password: auth[1]
      }
      delete info.auth
      break
    }
    case 'trojan': {
      const address = info.host.split(':')
      info = {
        ...info,
        host: address[0],
        port: address[1],
        password: info.auth,
        name: decodeURIComponent(info.hash).slice(1)
      }
      delete info.auth
      break
    }
    case 'ssr': {
      const auth = atob(info.auth).split(':')
      const address = info.host.split(':')
      info = {
        ...info,
        host: address[0],
        port: address[1],
        method: auth[0],
        password: auth[1],
        protocol: info.protocol,
        obfs: info.obfs,
        name: decodeURIComponent(info.hash).slice(1)
      }
      delete info.auth
      break
    }
    case 'vless': {
      const auth = atob(info.auth).split(':')
      const address = info.host.split(':')
      info = {
        ...info,
        host: address[0],
        port: address[1],
        method: auth[0],
        password: auth[1],
        name: decodeURIComponent(info.hash).slice(1)
      }
      delete info.auth
      break
    }
    case 'vmess': {
      const parsed: any = JSON.parse(atob(info.host))
      info = {
        ...info,
        name: parsed.ps,
        ...parsed
      }
      delete info.host
      delete info.ps
      break
    }
    default:
      break
  }

  delete info.hash
  Object.keys(info).forEach((key) => {
    if (info[key] === '') delete info[key]
  })

  serverInfo.value = info
}
</script>

<template>
  <v-btn icon="mdi-information-outline" size="small" variant="text" @click="viewServer" />

  <v-dialog v-model="isVisible" max-width="500">
    <v-card>
      <v-card-title>{{ t('server.details') }}</v-card-title>
      <v-card-text>
        <v-text-field
          v-for="(v, k) in serverInfo"
          :key="k"
          :label="k.toString()"
          :model-value="v"
          readonly
          density="compact"
          class="mb-2"
        />
      </v-card-text>
      <v-card-actions>
        <v-spacer />
        <v-btn variant="text" @click="isVisible = false">
          {{ t('operations.close') }}
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>
