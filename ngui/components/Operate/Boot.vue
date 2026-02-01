<script lang="ts" setup>
const bootV2rayA = async () => {
  const { data } = await useV2Fetch('v2ray').post().json()
  if (data.value.code === 'SUCCESS') {
    system.value.running = true
    system.value.connect = data.value.data.touch.connectedServer
  }
}
</script>

<template>
  <v-chip
    :color="system.running ? 'success' : 'surface-variant'"
    variant="tonal"
    size="small"
    @click="bootV2rayA"
  >
    <v-icon start size="small">
      {{ system.running ? 'mdi-check-circle' : 'mdi-circle-outline' }}
    </v-icon>
    {{ system.running ? $t('common.isRunning') : $t('common.notRunning') }}
  </v-chip>
</template>
