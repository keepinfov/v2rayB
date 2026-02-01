<script lang="ts" setup>
import { useQRCode } from '@vueuse/integrations/useQRCode'

const { data, subID } = defineProps<{ data: any, subID?: number }>()
const { $index, row } = data

const isVisible = ref(false)
const qrcode = ref('')

const shareSubscription = async () => {
  const params = JSON.stringify({
    id: row.id,
    _type: row._type,
    sub: row._type === 'subscription' ? $index : subID! - 1
  })

  const { data } = await useV2Fetch(`sharingAddress?touch=${params}`).get().json()
  qrcode.value = useQRCode(data.value.data.sharingAddress).value
  isVisible.value = true
}
</script>

<template>
  <v-btn icon="mdi-share-variant" size="small" variant="text" @click="shareSubscription" />

  <v-dialog v-model="isVisible" max-width="300">
    <v-card class="text-center">
      <v-card-title>{{ row._type?.toUpperCase() }}</v-card-title>
      <v-card-text>
        <v-img :src="qrcode" width="200" class="mx-auto rounded-lg" />
      </v-card-text>
      <v-card-actions>
        <v-spacer />
        <v-btn variant="text" @click="isVisible = false">
          Close
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>
