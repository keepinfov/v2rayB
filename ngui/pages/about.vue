<script lang="ts" setup>
const { t } = useI18n()
const { data } = await useV2Fetch<any>('version').json()
const version = data.value?.data?.version || 'Unknown'
</script>

<template>
  <div class="d-flex justify-center">
    <v-card class="pa-6 text-center" color="surface-container" max-width="480">
      <v-avatar color="primary" size="80" class="mb-4">
        <span class="text-h4 font-weight-bold text-on-primary">v2</span>
      </v-avatar>

      <v-card-title class="text-h4 font-weight-bold">
        v2rayB
      </v-card-title>

      <v-card-subtitle>
        {{ t('about.description') }}
      </v-card-subtitle>

      <v-chip color="primary" variant="tonal" class="my-4">
        Version {{ version }}
      </v-chip>

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
        <p class="mb-4">{{ t('about.description') }}</p>
        <p class="font-weight-medium mb-2">Default ports:</p>
        <ul class="mb-4">
          <li v-for="(port, i) in t('about.ports', [], { returnObjects: true })" :key="i">
            {{ port }}
          </li>
        </ul>
        <p>
          Issues: <a :href="`https://${t('about.links.issues')}`" target="_blank">{{ t('about.links.issues') }}</a>
        </p>
        <p>
          Docs: <a :href="`https://${t('about.links.docs')}`" target="_blank">{{ t('about.links.docs') }}</a>
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
