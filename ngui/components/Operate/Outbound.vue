<script lang="ts" setup>
const { t } = useI18n()

const isVisible = ref(false)
const currentOutbound = ref('')
const setting = ref<{
  probeInterval: string
  probeURL: string
  type: string
}>()

const viewOutbound = async (outbound: string) => {
  isVisible.value = true
  currentOutbound.value = outbound
  const { data } = await useV2Fetch(`outbound?outbound=${outbound}`).json()
  setting.value = data.value.data.setting
}

const deleteOutbound = async (outbound: string) => {
  const { data } = await useV2Fetch('outbound').delete({ outbound }).json()
  proxies.value.outbounds = data.value.data.outbounds
  isVisible.value = false
}

const editOutbound = async (outbound: string) => {
  const { data } = await useV2Fetch('outbound').put({ outbound, setting: setting.value }).json()
  if (data.value.code === 'SUCCESS') {
    useSnackbar(t('common.success'), 'success')
  }
}
</script>

<template>
  <v-menu>
    <template #activator="{ props }">
      <v-btn v-bind="props" variant="tonal" size="small" color="primary">
        {{ proxies.currentOutbound.toUpperCase() }}
        <v-icon end>mdi-chevron-down</v-icon>
      </v-btn>
    </template>
    <v-list density="compact" bg-color="surface-container-high" rounded="lg">
      <v-list-item
        v-for="i in proxies.outbounds"
        :key="i"
        :title="i"
        @click="proxies.currentOutbound = i"
      >
        <template #append>
          <v-btn icon="mdi-cog" size="x-small" variant="text" @click.stop="viewOutbound(i)" />
        </template>
      </v-list-item>
    </v-list>
  </v-menu>

  <v-dialog v-model="isVisible" max-width="480">
    <v-card>
      <v-card-title>{{ currentOutbound }} - {{ $t('common.outboundSetting') }}</v-card-title>
      <v-card-text>
        <v-text-field
          v-for="(v, k) in setting"
          :key="k"
          v-model="setting![k]"
          :label="k.toString()"
          class="mb-2"
        />
      </v-card-text>
      <v-card-actions>
        <v-btn color="error" variant="text" @click="deleteOutbound(currentOutbound)">
          {{ $t('operations.delete') }}
        </v-btn>
        <v-spacer />
        <v-btn variant="text" @click="isVisible = false">
          {{ $t('operations.cancel') }}
        </v-btn>
        <v-btn color="primary" variant="tonal" @click="editOutbound(currentOutbound)">
          {{ $t('operations.confirm') }}
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>
