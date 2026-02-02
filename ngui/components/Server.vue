<script lang="ts" setup>
const { t } = useI18n()

const headers = [
  { title: 'ID', key: 'id', width: 70 },
  { title: t('server.name'), key: 'name' },
  { title: t('server.address'), key: 'address' },
  { title: t('server.protocol'), key: 'net', width: 100 },
  { title: t('server.latency'), key: 'pingLatency', width: 100 },
  { title: t('operations.name'), key: 'actions', sortable: false, width: 180 }
]

let selectRows = $ref<any[]>([])
</script>

<template>
  <v-card color="surface-container">
    <v-toolbar color="transparent" density="compact">
      <v-toolbar-title>{{ t('common.servers') }}</v-toolbar-title>
      <v-spacer />
      <OperateLatency :data="selectRows" type="ping" />
      <OperateLatency :data="selectRows" type="http" />
    </v-toolbar>

    <v-data-table
      v-model="selectRows"
      :headers="headers"
      :items="proxies.servers"
      item-value="id"
      show-select
      class="bg-transparent"
    >
      <template #item.pingLatency="{ value }">
        <v-chip v-if="value" size="small" :color="value < 200 ? 'success' : value < 500 ? 'warning' : 'error'" variant="tonal">
          {{ value }}ms
        </v-chip>
        <span v-else class="text-on-surface-variant">-</span>
      </template>

      <template #item.actions="{ item }">
        <div class="d-flex ga-1">
          <OperateConnect :data="item" :sub-i-d="0" />
          <OperateView :data="item" :sub-i-d="0" />
          <OperateShare :data="item" :sub-i-d="0" />
        </div>
      </template>
    </v-data-table>
  </v-card>
</template>
