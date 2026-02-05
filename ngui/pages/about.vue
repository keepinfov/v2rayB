<script lang="ts" setup>
const { t } = useI18n()
</script>

<template>
  <div class="about-container">
    <v-card class="pa-4 pa-sm-6 text-center about-card" color="surface-container">
      <v-avatar color="primary" size="80" class="mb-4">
        <span class="text-h4 font-weight-bold text-on-primary">{{ APP_SHORT }}</span>
      </v-avatar>

      <v-card-title class="text-h4 font-weight-bold">
        {{ APP_NAME }}
      </v-card-title>

      <v-card-subtitle class="mt-2">
        {{ t('about.description') }}
      </v-card-subtitle>

      <div class="d-flex flex-wrap justify-center ga-2 my-4">
        <v-chip color="primary" variant="tonal">
          <v-icon start size="small">mdi-tag</v-icon>
          v{{ system.version || '...' }}
        </v-chip>
        <v-chip
          v-if="system.updateAvailable"
          color="success"
          variant="tonal"
          :href="GITHUB_RELEASES"
          target="_blank"
        >
          <v-icon start size="small">mdi-update</v-icon>
          {{ system.latestVersion }} available
        </v-chip>
      </div>

      <v-divider class="my-4" />

      <div class="d-flex flex-wrap justify-center ga-2 mb-4">
        <v-btn
          :href="GITHUB_URL"
          target="_blank"
          variant="outlined"
          prepend-icon="mdi-star"
        >
          Star
        </v-btn>
        <v-btn
          :href="`${GITHUB_URL}/fork`"
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
          <li>{{ DEFAULT_PORTS.backend }}: {{ APP_NAME }} backend</li>
          <li>{{ DEFAULT_PORTS.socks5 }}: SOCKS5</li>
          <li>{{ DEFAULT_PORTS.http }}: HTTP</li>
          <li>{{ DEFAULT_PORTS.httpWithRules }}: HTTP with rules</li>
          <li>{{ DEFAULT_PORTS.tproxy }}: tproxy (transparent proxy)</li>
        </ul>
        <p>
          Issues: <a :href="GITHUB_ISSUES" target="_blank" class="text-primary">{{ GITHUB_REPO }}/issues</a>
        </p>
      </v-card-text>

      <v-divider class="my-4" />

      <v-btn
        :href="GITHUB_URL"
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

.about-card {
  width: 100%;
  max-width: 500px;
}

@media (max-width: 600px) {
  .about-container {
    padding: 16px;
    padding-top: 8px;
  }

  .about-card {
    max-width: 100%;
  }
}
</style>
