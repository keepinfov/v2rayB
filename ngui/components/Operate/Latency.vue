<script lang="ts" setup>
const { data: row, type } = defineProps<{ data: any[], type: 'ping' | 'http' }>()

const loading = ref(false)

const testServer = async () => {
  if (!row || row.length === 0) return

  loading.value = true
  const alias = `${type}Latency`

  const { data } = await useV2Fetch(`${alias}?whiches=${JSON.stringify(row)}`).get().json()

  for (const i of data.value.data.whiches) {
    proxies.value.subs[i.sub].servers[i.id - 1][alias] = i[alias]
  }
  loading.value = false
}
</script>

<template>
  <v-btn
    variant="tonal"
    size="small"
    :loading="loading"
    :disabled="!row || row.length === 0"
    class="mr-2"
    @click="testServer"
  >
    <v-icon start>{{ type === 'ping' ? 'mdi-speedometer' : 'mdi-web' }}</v-icon>
    {{ type.toUpperCase() }}
  </v-btn>
</template>
