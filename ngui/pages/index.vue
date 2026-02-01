<script lang="ts" setup>
definePageMeta({ middleware: ['auth', 'every-check'] })

const currentTab = ref('subscription')

const { data: { value: { data: { outbounds } } } } = await useV2Fetch<any>('outbounds').json()
const { data: { value: { data: { touch } } } } = await useV2Fetch<any>('touch').json()

proxies.value = {
  ...proxies.value,
  outbounds,
  subs: touch.subscriptions,
  servers: touch.servers
}

const tabs = computed(() => [
  { value: 'subscription', title: 'Subscriptions' },
  { value: 'server', title: 'Servers' },
  ...proxies.value.subs.map((s: any) => ({
    value: `sub-${s.id}`,
    title: s.remarks || s.host.toUpperCase(),
    sub: s
  }))
])
</script>

<template>
  <div>
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
  </div>
</template>
