<script lang="ts" setup>
const { t } = useI18n()

const headers = [
  { title: 'ID', key: 'id', width: 80, align: 'center' as const },
  { title: t('subscription.host'), key: 'host', minWidth: 250 },
  { title: t('subscription.remarks'), key: 'remarks', minWidth: 150 },
  { title: t('subscription.timeLastUpdate'), key: 'status', width: 180 },
  { title: t('subscription.numberServers'), key: 'servers.length', width: 120, align: 'center' as const },
  { title: t('operations.name'), key: 'actions', sortable: false, width: 140, align: 'center' as const }
]

const selectRows = ref<any[]>([])
const isUpdating = ref(false)

const updateSubscription = async (row: any) => {
  isUpdating.value = true
  const { data } = await useV2Fetch('subscription').put({ id: row.id, _type: row._type }).json()
  isUpdating.value = false

  if (data.value.code === 'SUCCESS') {
    proxies.value.subs = data.value.data.touch.subscriptions
    useSnackbar(t('common.success'), 'success')
  }
}

const removeSubscription = async () => {
  if (selectRows.value.length === 0) return

  const { data } = await useV2Fetch('touch').delete({
    touches: selectRows.value.map(x => ({ id: x.id, _type: x._type }))
  }).json()

  if (data.value?.code === 'SUCCESS') {
    proxies.value.subs = data.value.data.touch.subscriptions || []
    selectRows.value = []
    useSnackbar(t('common.success'), 'success')
  }
}
</script>

<template>
  <v-card color="surface-container" class="data-table-card">
    <v-toolbar color="transparent" density="comfortable" class="px-4">
      <v-toolbar-title class="text-h6">{{ t('common.subscriptions') }}</v-toolbar-title>
      <v-spacer />
      <div class="d-flex ga-2">
        <OperateImport />
        <v-btn
          v-if="selectRows.length > 0"
          variant="tonal"
          color="error"
          @click="removeSubscription"
        >
          <v-icon start>mdi-delete</v-icon>
          {{ t('operations.delete') }} ({{ selectRows.length }})
        </v-btn>
      </div>
    </v-toolbar>

    <v-divider />

    <v-data-table
      v-model="selectRows"
      :headers="headers"
      :items="proxies.subs"
      item-value="id"
      show-select
      hover
      class="bg-transparent"
      density="comfortable"
    >
      <template #item.host="{ value }">
        <code class="text-body-2 text-on-surface-variant">{{ value }}</code>
      </template>

      <template #item.remarks="{ value }">
        <span class="font-weight-medium">{{ value || '-' }}</span>
      </template>

      <template #item.servers.length="{ item }">
        <v-chip size="small" color="primary" variant="tonal">
          {{ item.servers?.length || 0 }}
        </v-chip>
      </template>

      <template #item.actions="{ item }">
        <div class="d-flex justify-center ga-1">
          <v-btn
            icon="mdi-refresh"
            size="small"
            variant="text"
            :loading="isUpdating"
            @click="updateSubscription(item)"
          />
          <OperateRemark :data="item" />
          <OperateShare :data="item" />
        </div>
      </template>

      <template #no-data>
        <div class="text-center py-8 text-on-surface-variant">
          {{ t('welcome.messages.1') }}
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
