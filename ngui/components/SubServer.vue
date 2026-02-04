<script lang="ts" setup>
const { t } = useI18n()

const props = defineProps<{ data: any[], id: number }>()

const headers = [
  { title: 'ID', key: 'id', width: 80, align: 'center' as const },
  { title: t('server.name'), key: 'name', minWidth: 150 },
  { title: t('server.address'), key: 'address', minWidth: 200 },
  { title: t('server.protocol'), key: 'net', width: 120, align: 'center' as const },
  { title: t('server.latency'), key: 'pingLatency', width: 120, align: 'center' as const },
  { title: t('operations.name'), key: 'actions', sortable: false, width: 160, align: 'center' as const }
]

const selectRows = ref<any[]>([])
</script>

<template>
  <v-card color="surface-container" class="data-table-card">
    <v-toolbar color="transparent" density="comfortable" class="px-4">
      <v-toolbar-title class="text-h6">{{ t('common.servers') }}</v-toolbar-title>
      <v-spacer />
      <div class="d-flex ga-2">
        <OperateLatency :data="selectRows" type="ping" />
        <OperateLatency :data="selectRows" type="http" />
      </div>
    </v-toolbar>

    <v-divider />

    <v-data-table
      v-model="selectRows"
      :headers="headers"
      :items="props.data"
      item-value="id"
      show-select
      hover
      class="bg-transparent"
      density="comfortable"
    >
      <template #item.name="{ value }">
        <span class="font-weight-medium">{{ value }}</span>
      </template>

      <template #item.address="{ value }">
        <code class="text-body-2 text-on-surface-variant">{{ value }}</code>
      </template>

      <template #item.net="{ value }">
        <v-chip size="small" variant="tonal" color="secondary">
          {{ value }}
        </v-chip>
      </template>

      <template #item.pingLatency="{ value }">
        <v-chip v-if="value" size="small" :color="value < 200 ? 'success' : value < 500 ? 'warning' : 'error'" variant="tonal">
          {{ value }}ms
        </v-chip>
        <span v-else class="text-on-surface-variant">-</span>
      </template>

      <template #item.actions="{ item }">
        <div class="d-flex justify-center ga-1">
          <OperateConnect :data="item" :sub-i-d="props.id" />
          <OperateView :data="item" :sub-i-d="props.id" />
          <OperateShare :data="item" :sub-i-d="props.id" />
        </div>
      </template>
    </v-data-table>
  </v-card>
</template>

<style scoped>
.data-table-card :deep(.v-data-table__tr:hover) {
  background-color: rgb(var(--v-theme-surface-container-high)) !important;
}
</style>
