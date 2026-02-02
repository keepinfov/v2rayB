<script lang="ts" setup>
const { t } = useI18n()

const input = ref('')
const isVisible = ref(false)
const isImporting = ref(false)
const isBatch = ref(false)

const handleClickImportConfirm = async () => {
  isImporting.value = true
  const { data } = await useV2Fetch('import').post({ url: input.value }).json()
  isImporting.value = false

  if (data.value.code === 'SUCCESS') {
    proxies.value.subs = data.value.data.touch.subscriptions
    useSnackbar(t('common.success'), 'success')
    input.value = ''
    isVisible.value = false
  }
}

watch(isVisible, (visible) => {
  if (!visible) {
    input.value = ''
    isBatch.value = false
  }
})
</script>

<template>
  <v-btn variant="tonal" color="primary" @click="isVisible = true">
    <v-icon start>mdi-import</v-icon>
    {{ t('operations.import') }}
  </v-btn>

  <v-dialog v-model="isVisible" max-width="500">
    <v-card>
      <v-card-title>{{ $t('operations.import') }}</v-card-title>
      <v-card-text>
        <p class="text-body-2 mb-4">{{ $t('import.message') }}</p>
        <v-textarea
          v-if="isBatch"
          v-model="input"
          :label="$t('import.batchMessage')"
          rows="5"
          auto-grow
        />
        <v-text-field
          v-else
          v-model="input"
          label="URL"
          type="url"
          prepend-inner-icon="mdi-link"
        />
      </v-card-text>
      <v-card-actions>
        <v-btn variant="text" @click="isBatch = !isBatch">
          {{ isBatch ? t('operations.single') : $t('operations.inBatch') }}
        </v-btn>
        <v-spacer />
        <v-btn variant="text" @click="isVisible = false">
          {{ $t('operations.cancel') }}
        </v-btn>
        <v-btn color="primary" variant="tonal" :loading="isImporting" @click="handleClickImportConfirm">
          {{ $t('operations.confirm') }}
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>
