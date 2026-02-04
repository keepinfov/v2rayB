<script lang="ts" setup>
import { parseURL } from 'ufo'

definePageMeta({ middleware: ['auth'] })

const { t } = useI18n()
const message = $ref<string[]>([])
const logContainer = ref<HTMLElement | null>(null)
const connectionStatus = $ref<'connecting' | 'connected' | 'disconnected'>('connecting')
const autoScroll = $ref(true)

let socket: WebSocket | null = null
let reconnectTimer: ReturnType<typeof setTimeout> | null = null

const connect = () => {
  const parsed = parseURL(system.value.api)
  const protocol = parsed.protocol === 'https:' ? 'wss:' : 'ws:'
  const wsUrl = `${protocol}//${parsed.host}/api/message?Authorization=${encodeURIComponent(user.value.token)}`

  socket = new WebSocket(wsUrl)

  socket.onopen = () => {
    connectionStatus = 'connected'
  }

  socket.onmessage = (msg) => {
    message.push(msg.data)
    if (autoScroll) {
      nextTick(() => {
        if (logContainer.value) {
          logContainer.value.scrollTop = logContainer.value.scrollHeight
        }
      })
    }
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

const getLogClass = (line: string) => {
  if (line.includes('error') || line.includes('Error') || line.includes('ERROR'))
    return 'log-error'
  if (line.includes('warn') || line.includes('Warn') || line.includes('WARN'))
    return 'log-warn'
  if (line.includes('info') || line.includes('Info') || line.includes('INFO'))
    return 'log-info'
  return ''
}
</script>

<template>
  <v-card color="surface-container" class="log-card">
    <v-toolbar color="transparent" density="comfortable" class="px-4">
      <v-toolbar-title class="text-h6">{{ t('log.title') }}</v-toolbar-title>
      <v-spacer />

      <v-chip
        size="small"
        variant="tonal"
        :color="connectionStatus === 'connected' ? 'success' : connectionStatus === 'connecting' ? 'warning' : 'error'"
        class="mr-4"
      >
        <v-icon start size="small">
          {{ connectionStatus === 'connected' ? 'mdi-check-circle' : connectionStatus === 'connecting' ? 'mdi-loading mdi-spin' : 'mdi-alert-circle' }}
        </v-icon>
        {{ t(`log.${connectionStatus}`) }}
      </v-chip>

      <v-btn-group variant="text" density="comfortable">
        <v-btn
          :icon="autoScroll ? 'mdi-arrow-collapse-down' : 'mdi-arrow-collapse-up'"
          :color="autoScroll ? 'primary' : undefined"
          @click="autoScroll = !autoScroll"
        />
        <v-btn icon="mdi-delete" @click="clearLogs" />
      </v-btn-group>
    </v-toolbar>

    <v-divider />

    <div
      ref="logContainer"
      class="log-content bg-surface-container-lowest pa-4 overflow-auto"
    >
      <template v-if="message.length === 0">
        <div class="text-center py-8 text-on-surface-variant">
          <v-icon size="48" class="mb-4">mdi-text-box-outline</v-icon>
          <div>{{ t('log.waiting') }}</div>
        </div>
      </template>
      <template v-else>
        <div
          v-for="(line, i) in message"
          :key="i"
          class="log-line font-mono text-body-2"
          :class="getLogClass(line)"
        >
          {{ line }}
        </div>
      </template>
    </div>

    <v-divider />

    <v-card-actions class="px-4 py-2">
      <span class="text-body-2 text-on-surface-variant">
        {{ message.length }} {{ message.length === 1 ? 'line' : 'lines' }}
      </span>
    </v-card-actions>
  </v-card>
</template>

<style scoped>
.log-card {
  display: flex;
  flex-direction: column;
  height: calc(100vh - 140px);
  min-height: 400px;
}

.log-content {
  flex: 1;
  overflow-y: auto;
  overflow-x: hidden;
}

.log-line {
  padding: 2px 0;
  white-space: pre-wrap;
  word-break: break-all;
  line-height: 1.5;
}

.log-line:hover {
  background-color: rgb(var(--v-theme-surface-container));
}

.log-error {
  color: rgb(var(--v-theme-error));
}

.log-warn {
  color: rgb(var(--v-theme-warning));
}

.log-info {
  color: rgb(var(--v-theme-info));
}

@media (min-width: 1280px) {
  .log-card {
    height: calc(100vh - 160px);
  }

  .log-line {
    font-size: 14px;
  }
}
</style>
