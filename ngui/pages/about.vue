<script lang="ts" setup>
const { t } = useI18n()

let loading = $ref(true)
let version = $ref('Unknown')

const loadVersion = async () => {
  try {
    const { data } = await useV2Fetch<any>('version').json()
    if (data.value?.data?.version) {
      version = data.value.data.version
      system.value.version = version
    }
  } catch (e) {
    version = 'Unknown'
  } finally {
    loading = false
  }
}

loadVersion()
</script>

<template>
  <div class="about-container">
    <v-card class="pa-6 text-center" color="surface-container" max-width="500">
      <v-avatar color="primary" size="80" class="mb-4">
        <span class="text-h4 font-weight-bold text-on-primary">v2</span>
      </v-avatar>

      <v-card-title class="text-h4 font-weight-bold">
        v2rayB
      </v-card-title>

      <v-card-subtitle class="mt-2">
        {{ t('about.description') }}
      </v-card-subtitle>

      <div class="d-flex justify-center ga-2 my-4">
        <v-chip color="primary" variant="tonal">
          <v-icon start size="small">mdi-tag</v-icon>
          v{{ loading ? '...' : version }}
        </v-chip>
        <v-chip
          v-if="system.updateAvailable"
          color="success"
          variant="tonal"
          href="https://github.com/keepinfov/v2rayB/releases"
          target="_blank"
        >
          <v-icon start size="small">mdi-update</v-icon>
          {{ system.latestVersion }} available
        </v-chip>
      </div>

      <v-divider class="my-4" />

      <div class="d-flex justify-center ga-2 mb-4">
        <v-btn
          href="https://github.com/keepinfov/v2rayB"
          target="_blank"
          variant="outlined"
          prepend-icon="mdi-star"
        >
          Star
        </v-btn>
        <v-btn
          href="https://github.com/keepinfov/v2rayB/fork"
          target="_blank"
          variant="outlined"
          prepend-icon="mdi-source-fork"
        >
          Fork
        </v-btn>
      </div>

      <v-card-text class="text-body-2 text-on-surface-variant text-left">
        <p class="font-weight-medium mb-2">Default ports:</p>
        <ul class="mb-4">
          <li v-for="(port, i) in t('about.ports', [], { returnObjects: true })" :key="i">
            {{ port }}
          </li>
        </ul>
        <p>
          Issues: <a href="https://github.com/keepinfov/v2rayB/issues" target="_blank" class="text-primary">github.com/keepinfov/v2rayB/issues</a>
        </p>
      </v-card-text>

      <v-divider class="my-4" />

      <v-btn
        href="https://github.com/keepinfov/v2rayB"
        target="_blank"
        color="primary"
        variant="tonal"
        prepend-icon="mdi-github"
      >
        GitHub
      </v-btn>
    </v-card>
  </div>
</template>

<style scoped>
.about-container {
  display: flex;
  justify-content: center;
  align-items: flex-start;
  min-height: calc(100vh - 200px);
  padding-top: 24px;
}
</style>
