<script lang="ts" setup>
const { data: row } = defineProps<{ data: any }>()

const input = ref('')
const isVisible = ref(false)

const remarkSubscription = async (remark: string) => {
  const { data } = await useV2Fetch('subscription').patch({
    subscription: {
      ...row,
      remarks: remark
    }
  }).json()

  proxies.value.subs = data.value.data.touch.subscriptions
  isVisible.value = false
}
</script>

<template>
  <v-btn icon="mdi-pencil" size="small" variant="text" @click="isVisible = true" />

  <v-dialog v-model="isVisible" max-width="400">
    <v-card>
      <v-card-title>{{ $t('configureSubscription.title') }}</v-card-title>
      <v-card-text>
        <v-text-field
          v-model="input"
          :label="$t('subscription.remarks')"
          autofocus
        />
      </v-card-text>
      <v-card-actions>
        <v-spacer />
        <v-btn variant="text" @click="isVisible = false">
          {{ $t('operations.cancel') }}
        </v-btn>
        <v-btn color="primary" variant="tonal" @click="remarkSubscription(input)">
          {{ $t('operations.confirm') }}
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>
