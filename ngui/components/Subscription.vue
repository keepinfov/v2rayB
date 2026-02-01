<script lang="ts" setup>
const { t } = useI18n()

const headers = [
  { title: 'ID', key: 'id', width: 70 },
  { title: t('subscription.host'), key: 'host' },
  { title: t('subscription.remarks'), key: 'remarks' },
  { title: t('subscription.timeLastUpdate'), key: 'status' },
  { title: t('subscription.numberServers'), key: 'servers.length', width: 100 },
  { title: t('operations.name'), key: 'actions', sortable: false, width: 200 }
]

const selectRows = ref<any[]>([])
const isUpdating = ref(false)

const updateSubscription = async (row: any) => {
  isUpdating.value = true
  const { data } = await useV2Fetch('subscription').put({ id: row.id, _type: row._type }).json()
  isUpdating.value = false

  if (data.value.code === 'SUCCESS') {
    useSnackbar(t('common.success'), 'success')
  }
}

const removeSubscription = async () => {
  const { data } = await useV2Fetch('touch').delete({
    touches: selectRows.value.map(x => ({ id: x.id, _type: x._type }))
  }).json()

  if (data.value.code === 'SUCCESS') {
    proxies.value.subs = data.value.data.touch.subscriptions
    selectRows.value = []
  }
}
</script>

<template>
  <v-card color="surface-container">
    <v-toolbar color="transparent" density="compact">
      <v-toolbar-title>Subscriptions</v-toolbar-title>
      <v-spacer />
      <OperateImport />
      <v-btn
        v-if="selectRows.length > 0"
        variant="tonal"
        color="error"
        class="ml-2"
        @click="removeSubscription"
      >
        <v-icon start>mdi-delete</v-icon>
        {{ t('operations.delete') }} ({{ selectRows.length }})
      </v-btn>
    </v-toolbar>

    <v-data-table
      v-model="selectRows"
      :headers="headers"
      :items="proxies.subs"
      item-value="id"
      show-select
      class="bg-transparent"
    >
      <template #item.servers.length="{ item }">
        <v-chip size="small" color="primary" variant="tonal">
          {{ item.servers?.length || 0 }}
        </v-chip>
      </template>

      <template #item.actions="{ item }">
        <div class="d-flex ga-1">
          <v-btn
            icon="mdi-refresh"
            size="small"
            variant="text"
            :loading="isUpdating"
            @click="updateSubscription(item)"
          />
          <OperateRemark :data="item" />
          <OperateShare :data="{ row: item }" />
        </div>
      </template>
    </v-data-table>
  </v-card>
</template>
