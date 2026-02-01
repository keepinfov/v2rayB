<script lang="ts" setup>
const { data: row, subID } = defineProps<{ data: any, subID?: number }>()

const { t } = useI18n()

const connectServer = async () => {
  const { data } = await useV2Fetch('connection').post({
    sub: subID! - 1,
    id: row.id,
    _type: row._type,
    outbound: proxies.value.currentOutbound
  }).json()

  if (data.value.code === 'SUCCESS') {
    useSnackbar(t('common.success'), 'success')
  }
}
</script>

<template>
  <v-btn
    :icon="row.connected ? 'mdi-link-off' : 'mdi-link'"
    size="small"
    variant="text"
    :color="row.connected ? 'success' : undefined"
    @click="connectServer"
  />
</template>
