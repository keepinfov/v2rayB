<script lang="ts" setup>
import { parseURL } from 'ufo'

definePageMeta({ middleware: ['auth'] })

const { t } = useI18n()
const message = $ref<string[]>([])
const logContainer = ref<HTMLElement | null>(null)
const connectionStatus = $ref<'connecting' | 'connected' | 'disconnected'>('connecting')

let socket: WebSocket | null = null
let reconnectTimer: ReturnType<typeof setTimeout> | null = null

const connect = () => {
  const parsed = parseURL(system.value.api)
  const protocol = parsed.protocol === 'https:' ? 'wss:' : 'ws:'
  const wsUrl = `${protocol}//${parsed.host}${parsed.pathname}/api/message?Authorization=${encodeURIComponent(user.value.token)}`

  socket = new WebSocket(wsUrl)

  socket.onopen = () => {
    connectionStatus = 'connected'
  }

  socket.onmessage = (msg) => {
    message.push(msg.data)
    nextTick(() => {
      if (logContainer.value) {
        logContainer.value.scrollTop = logContainer.value.scrollHeight
      }
    })
  }

  socket.onerror = () => {
    connectionStatus = 'disconnected'
  }

  socket.onclose = () => {
    connectionStatus = 'disconnected'
    reconnectTimer = setTimeout(() => {
      connectionStatus = 'connecting'
      connect()
    }, 3000)
  }
}

connect()

onUnmounted(() => {
  if (reconnectTimer) clearTimeout(reconnectTimer)
  if (socket) socket.close()
})

const clearLogs = () => {
  message.length = 0
}
</script>

<template>
  <v-card color="surface-container">
    <v-toolbar color="transparent" density="compact">
      <v-toolbar-title>{{ t('log.title') }}</v-toolbar-title>
      <v-spacer />
      <v-chip
        size="small"
        variant="tonal"
        :color="connectionStatus === 'connected' ? 'success' : connectionStatus === 'connecting' ? 'warning' : 'error'"
        class="mr-2"
      >
        {{ t(`log.${connectionStatus}`) }}
      </v-chip>
      <v-btn icon="mdi-delete" variant="text" @click="clearLogs" />
    </v-toolbar>

    <v-card-text
      ref="logContainer"
      class="bg-surface-container-lowest pa-4 font-mono text-body-2 overflow-auto log-content"
    >
      <template v-if="message.length === 0">
        <span class="text-on-surface-variant">{{ t('log.waiting') }}</span>
      </template>
      <template v-else>
        <div v-for="(line, i) in message" :key="i" class="mb-1">
          {{ line }}
        </div>
      </template>
    </v-card-text>
  </v-card>
</template>

<style scoped>
.log-content {
  height: calc(100vh - 200px);
  white-space: pre-wrap;
  word-break: break-all;
}
</style>
