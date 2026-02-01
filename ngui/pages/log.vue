<script lang="ts" setup>
import { parseURL } from 'ufo'

definePageMeta({ middleware: ['auth'] })

const message = $ref<string[]>([])
const logContainer = ref<HTMLElement | null>(null)

const parsed = parseURL(system.value.api)
const socket = new WebSocket(
  `ws://${parsed.host}${parsed.pathname}/api/message?Authorization=${encodeURIComponent(user.value.token)}`
)

socket.onmessage = (msg) => {
  message.push(msg.data)
  nextTick(() => {
    if (logContainer.value) {
      logContainer.value.scrollTop = logContainer.value.scrollHeight
    }
  })
}

onUnmounted(() => {
  socket.close()
})

const clearLogs = () => {
  message.length = 0
}
</script>

<template>
  <v-card color="surface-container">
    <v-toolbar color="transparent" density="compact">
      <v-toolbar-title>Logs</v-toolbar-title>
      <v-spacer />
      <v-btn icon="mdi-delete" variant="text" @click="clearLogs" />
    </v-toolbar>

    <v-card-text
      ref="logContainer"
      class="bg-surface-container-lowest pa-4 font-mono text-body-2 overflow-auto"
      style="height: calc(100vh - 200px); white-space: pre-wrap; word-break: break-all"
    >
      <template v-if="message.length === 0">
        <span class="text-on-surface-variant">Waiting for logs...</span>
      </template>
      <template v-else>
        <div v-for="(line, i) in message" :key="i" class="mb-1">
          {{ line }}
        </div>
      </template>
    </v-card-text>
  </v-card>
</template>
