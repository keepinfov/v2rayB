<script lang="ts" setup>
definePageMeta({ middleware: ['auth', 'every-check'] })

const { t } = useI18n()
const currentTab = ref('subscription')
let loading = $ref(true)
let error = $ref<string | null>(null)

const loadData = async () => {
  try {
    const outboundsRes = await useV2Fetch<any>('outbounds').json()
    const touchRes = await useV2Fetch<any>('touch').json()

    if (outboundsRes.data.value?.data?.outbounds) {
      proxies.value.outbounds = outboundsRes.data.value.data.outbounds
    }
    if (touchRes.data.value?.data?.touch) {
      proxies.value.subs = touchRes.data.value.data.touch.subscriptions || []
      proxies.value.servers = touchRes.data.value.data.touch.servers || []
    }
  } catch (e) {
    error = 'Failed to load data'
  } finally {
    loading = false
  }
}

loadData()

const tabs = computed(() => [
  { value: 'subscription', title: t('common.subscriptions') },
  { value: 'server', title: t('common.servers') },
  ...proxies.value.subs.map((s: any) => ({
    value: `sub-${s.id}`,
    title: s.remarks || s.host?.toUpperCase() || 'Unknown',
    sub: s
  }))
])
</script>

<template>
  <div>
    <template v-if="loading">
      <div class="d-flex justify-center align-center py-16">
        <v-progress-circular indeterminate color="primary" size="48" />
      </div>
    </template>

    <template v-else-if="error">
      <v-alert type="error" class="mb-4">{{ error }}</v-alert>
    </template>

    <template v-else>
      <v-tabs v-model="currentTab" color="primary" class="mb-6" show-arrows>
        <v-tab v-for="tab in tabs" :key="tab.value" :value="tab.value">
          {{ tab.title }}
        </v-tab>
      </v-tabs>

      <v-window v-model="currentTab">
        <v-window-item value="subscription">
          <Subscription />
        </v-window-item>

        <v-window-item value="server">
          <Server />
        </v-window-item>

        <v-window-item v-for="s in proxies.subs" :key="`sub-${s.id}`" :value="`sub-${s.id}`">
          <SubServer :id="s.id" :data="s.servers" />
        </v-window-item>
      </v-window>
    </template>
  </div>
</template>
