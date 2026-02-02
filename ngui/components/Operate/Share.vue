<script lang="ts" setup>
import { useQRCode } from '@vueuse/integrations/useQRCode'

const { data: row, subID } = defineProps<{ data: any, subID?: number }>()
const { t } = useI18n()

const isVisible = ref(false)
const qrcode = ref('')

const shareItem = async () => {
  let subIndex: number
  if (row._type === 'subscription') {
    subIndex = proxies.value.subs.findIndex((s: any) => s.id === row.id)
  } else {
    subIndex = (subID ?? 0) - 1
  }

  const params = JSON.stringify({
    id: row.id,
    _type: row._type,
    sub: subIndex
  })

  const { data } = await useV2Fetch(`sharingAddress?touch=${params}`).get().json()
  qrcode.value = useQRCode(data.value.data.sharingAddress).value
  isVisible.value = true
}
</script>

<template>
  <v-btn icon="mdi-share-variant" size="small" variant="text" @click="shareItem" />

  <v-dialog v-model="isVisible" max-width="300">
    <v-card class="text-center">
      <v-card-title>{{ row._type?.toUpperCase() }}</v-card-title>
      <v-card-text>
        <v-img :src="qrcode" width="200" class="mx-auto rounded-lg" />
      </v-card-text>
      <v-card-actions>
        <v-spacer />
        <v-btn variant="text" @click="isVisible = false">
          {{ t('operations.close') }}
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>
