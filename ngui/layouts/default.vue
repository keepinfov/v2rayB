<script lang="ts" setup>
const { t } = useI18n()
const route = useRoute()

const navItems = [
  { to: '/', icon: 'mdi-home', title: t('common.dashboard') },
  { to: '/setting', icon: 'mdi-cog', title: t('common.setting') },
  { to: '/log', icon: 'mdi-text-box-outline', title: t('common.log') },
  { to: '/about', icon: 'mdi-information-outline', title: t('common.about') }
]
</script>

<template>
  <v-layout>
    <v-app-bar color="surface-container" elevation="0" density="comfortable">
      <template #prepend>
        <v-app-bar-nav-icon class="d-lg-none" />
      </template>

      <v-app-bar-title>
        <NuxtLink to="/" class="text-decoration-none text-on-surface font-weight-bold">
          {{ APP_NAME }}
        </NuxtLink>
        <v-chip
          v-if="system.updateAvailable"
          size="x-small"
          color="success"
          variant="flat"
          class="ml-2"
          :href="GITHUB_RELEASES"
          target="_blank"
        >
          {{ system.latestVersion }}
        </v-chip>
      </v-app-bar-title>

      <template #append>
        <div class="d-flex align-center ga-2">
          <OperateBoot />
          <OperateOutbound />
        </div>
      </template>
    </v-app-bar>

    <v-navigation-rail color="surface-container" permanent class="d-none d-lg-flex nav-rail">
      <template #prepend>
        <v-avatar color="primary" size="40" class="my-4">
          <span class="text-h6 font-weight-bold text-on-primary">{{ APP_SHORT }}</span>
        </v-avatar>
      </template>

      <v-list density="compact" nav class="px-2">
        <v-list-item
          v-for="item in navItems"
          :key="item.to"
          :to="item.to"
          :prepend-icon="item.icon"
          :title="item.title"
          :active="route.path === item.to"
          rounded="lg"
          color="primary"
          class="mb-1"
        />
      </v-list>
    </v-navigation-rail>

    <v-main class="bg-background">
      <v-container fluid class="main-container pa-4 pa-md-6 pa-lg-8">
        <slot />
      </v-container>
    </v-main>
  </v-layout>

  <v-bottom-navigation color="surface-container" class="d-lg-none" grow>
    <v-btn v-for="item in navItems" :key="item.to" :to="item.to" :value="item.to">
      <v-icon>{{ item.icon }}</v-icon>
      <span class="text-caption">{{ item.title }}</span>
    </v-btn>
  </v-bottom-navigation>
</template>

<style scoped>
.nav-rail {
  border-right: 1px solid rgb(var(--v-theme-outline-variant));
  margin-top: 48px;
  height: calc(100vh - 48px);
}

.main-container {
  max-width: 1400px;
  margin-left: auto;
  margin-right: auto;
}

@media (min-width: 1280px) {
  .main-container {
    padding-top: 32px !important;
  }
}
</style>
