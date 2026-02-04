<script lang="ts" setup>
definePageMeta({ middleware: ['auth'] })

const { t } = useI18n()

const setting = ref<any>(null)
const loading = ref(true)
const error = ref<string | null>(null)
const remoteGFWListVersion = ref<string>('')

const loadSettings = async () => {
  try {
    const settingRes = await useV2Fetch<any>('setting').json()
    const remoteRes = await useV2Fetch<any>('remoteGFWListVersion').json()

    if (settingRes.data.value?.data) {
      system.value.gfwlist = settingRes.data.value.data.localGFWListVersion
      setting.value = settingRes.data.value.data.setting
    }
    if (remoteRes.data.value?.data?.remoteGFWListVersion) {
      remoteGFWListVersion.value = remoteRes.data.value.data.remoteGFWListVersion
    }
  } catch (e) {
    error.value = 'Failed to load settings'
  } finally {
    loading.value = false
  }
}

loadSettings()

const updateGFWList = async () => {
  const { data } = await useV2Fetch<any>('gfwList').put().json()
  if (data.value.code === 'SUCCESS') {
    system.value.gfwlist = data.value.data.localGFWListVersion
    useSnackbar(t('common.success'), 'success')
  }
}

const updateSetting = async () => {
  const { data } = await useV2Fetch<any>('setting').put(setting).json()
  if (data.value.code === 'SUCCESS') {
    useSnackbar(t('common.success'), 'success')
  }
}

const transparentOptions = [
  { value: 'close', title: t('setting.options.off') },
  { value: 'proxy', title: `${t('setting.options.on')}: ${t('setting.options.global')}` },
  { value: 'whitelist', title: `${t('setting.options.on')}: ${t('setting.options.whitelistCn')}` },
  { value: 'gfwlist', title: `${t('setting.options.on')}: ${t('setting.options.gfwlist')}` },
  { value: 'pac', title: `${t('setting.options.on')}: ${t('setting.options.sameAsPacMode')}` }
]

const transparentTypeOptions = [
  { value: 'redirect', title: 'redirect' },
  { value: 'tproxy', title: 'tproxy' },
  { value: 'system_proxy', title: 'system proxy' }
]

const pacModeOptions = [
  { value: 'whitelist', title: t('setting.options.whitelistCn') },
  { value: 'gfwlist', title: t('setting.options.gfwlist') },
  { value: 'routingA', title: 'RoutingA' }
]

const antipollutionOptions = [
  { value: 'closed', title: t('setting.options.closed') },
  { value: 'none', title: t('setting.options.antiDnsHijack') },
  { value: 'dnsforward', title: t('setting.options.forwardDnsRequest') },
  { value: 'doh', title: t('setting.options.doh') },
  { value: 'advanced', title: t('setting.options.advanced') }
]

const specialModeOptions = [
  { value: 'none', title: t('setting.options.closed') },
  { value: 'supervisor', title: 'supervisor' },
  { value: 'fakedns', title: 'fakedns' }
]

const tcpFastOpenOptions = [
  { value: 'default', title: t('setting.options.default') },
  { value: 'yes', title: t('setting.options.on') },
  { value: 'no', title: t('setting.options.off') }
]

const muxOptions = [
  { value: 'no', title: t('setting.options.off') },
  { value: 'yes', title: t('setting.options.on') }
]

const autoUpdateOptions = [
  { value: 'none', title: t('setting.options.off') },
  { value: 'auto_update', title: t('setting.options.updateGfwlistWhenStart') },
  { value: 'auto_update_at_intervals', title: t('setting.options.updateGfwlistAtIntervals') }
]

const subAutoUpdateOptions = [
  { value: 'none', title: t('setting.options.off') },
  { value: 'auto_update', title: t('setting.options.updateSubWhenStart') },
  { value: 'auto_update_at_intervals', title: t('setting.options.updateSubAtIntervals') }
]
</script>

<template>
  <div class="settings-container">
    <template v-if="loading">
      <div class="d-flex justify-center align-center py-16">
        <v-progress-circular indeterminate color="primary" size="48" />
      </div>
    </template>

    <template v-else-if="error">
      <v-alert type="error" class="mb-4">{{ error }}</v-alert>
    </template>

    <template v-else-if="setting">
    <v-row>
      <v-col cols="12" lg="6">
        <v-card class="mb-4" color="surface-container">
          <v-card-title class="d-flex align-center">
            <v-icon start>mdi-shield-check</v-icon>
            GFWList
          </v-card-title>
          <v-card-text>
            <div class="d-flex align-center justify-space-between flex-wrap ga-4">
              <div>
                <div class="text-body-2 text-on-surface-variant">{{ $t('common.latest') }}</div>
                <a
                  href="https://github.com/v2ray-a/dist-v2ray-rules-dat/releases"
                  target="_blank"
                  class="text-primary"
                >
                  {{ remoteGFWListVersion }}
                </a>
              </div>
              <div>
                <div class="text-body-2 text-on-surface-variant">{{ $t('common.local') }}</div>
                <div>{{ system.gfwlist }}</div>
              </div>
              <v-btn variant="tonal" color="primary" @click="updateGFWList">
                {{ $t('operations.update') }}
              </v-btn>
            </div>
          </v-card-text>
        </v-card>

        <v-card class="mb-4" color="surface-container">
          <v-card-title class="d-flex align-center">
            <v-icon start>mdi-web</v-icon>
            {{ $t('setting.transparentProxy') }}
          </v-card-title>
          <v-card-text>
            <v-select
              v-model="setting.transparent"
              :items="transparentOptions"
              item-title="title"
              item-value="value"
              :label="$t('setting.transparentProxy')"
              class="mb-4"
            />

            <div class="d-flex ga-4 mb-4 flex-wrap">
              <v-switch
                v-if="!system.lite"
                v-model="setting.ipforward"
                :label="$t('setting.ipForwardOn')"
                hide-details
              />
              <v-switch
                v-model="setting.portSharing"
                :label="$t('setting.portSharingOn')"
                hide-details
              />
            </div>

            <v-select
              v-if="setting.transparent !== 'close'"
              v-model="setting.transparentType"
              :items="transparentTypeOptions.filter(o => system.lite ? o.value === 'system_proxy' : true)"
              item-title="title"
              item-value="value"
              :label="$t('setting.transparentType')"
            />
          </v-card-text>
        </v-card>

        <v-card class="mb-4" color="surface-container">
          <v-card-title class="d-flex align-center">
            <v-icon start>mdi-routes</v-icon>
            {{ $t('setting.pacMode') }}
          </v-card-title>
          <v-card-text>
            <v-select
              v-model="setting.pacMode"
              :items="pacModeOptions"
              item-title="title"
              item-value="value"
              :label="$t('setting.pacMode')"
            />
          </v-card-text>
        </v-card>
      </v-col>

      <v-col cols="12" lg="6">
        <v-card class="mb-4" color="surface-container">
          <v-card-title class="d-flex align-center">
            <v-icon start>mdi-dns</v-icon>
            {{ $t('setting.preventDnsSpoofing') }}
          </v-card-title>
          <v-card-text>
            <v-select
              v-model="setting.antipollution"
              :items="antipollutionOptions"
              item-title="title"
              item-value="value"
              :label="$t('setting.preventDnsSpoofing')"
              class="mb-4"
            />

            <v-select
              v-if="setting.showSpecialMode"
              v-model="setting.specialMode"
              :items="specialModeOptions.filter(o => setting.antipollution === 'closed' ? o.value !== 'fakedns' : true)"
              item-title="title"
              item-value="value"
              :label="$t('setting.specialMode')"
            />
          </v-card-text>
        </v-card>

        <v-card class="mb-4" color="surface-container">
          <v-card-title class="d-flex align-center">
            <v-icon start>mdi-tune</v-icon>
            {{ $t('setting.network') }}
          </v-card-title>
          <v-card-text>
            <v-row>
              <v-col cols="12" sm="6">
                <v-select
                  v-model="setting.tcpFastOpen"
                  :items="tcpFastOpenOptions"
                  item-title="title"
                  item-value="value"
                  label="TCP Fast Open"
                />
              </v-col>
              <v-col cols="12" sm="6">
                <v-select
                  v-model="setting.muxOn"
                  :items="muxOptions"
                  item-title="title"
                  item-value="value"
                  :label="$t('setting.mux')"
                />
              </v-col>
            </v-row>

            <v-text-field
              v-if="setting.muxOn === 'yes'"
              v-model="setting.mux"
              :label="$t('setting.concurrency')"
              type="number"
              min="1"
              max="1024"
            />
          </v-card-text>
        </v-card>

        <v-card class="mb-4" color="surface-container">
          <v-card-title class="d-flex align-center">
            <v-icon start>mdi-update</v-icon>
            {{ $t('setting.autoUpdate') }}
          </v-card-title>
          <v-card-text>
            <v-select
              v-if="setting.pacMode === 'gfwlist' || setting.transparent === 'gfwlist'"
              v-model="setting.pacAutoUpdateMode"
              :items="autoUpdateOptions"
              item-title="title"
              item-value="value"
              :label="$t('setting.autoUpdateGfwlist')"
              class="mb-4"
            />

            <v-text-field
              v-if="setting.pacAutoUpdateMode === 'auto_update_at_intervals'"
              v-model="setting.pacAutoUpdateIntervalHour"
              :label="$t('setting.intervalHours')"
              type="number"
              min="1"
              class="mb-4"
            />

            <v-select
              v-model="setting.subscriptionAutoUpdateMode"
              :items="subAutoUpdateOptions"
              item-title="title"
              item-value="value"
              :label="$t('setting.autoUpdateSub')"
              class="mb-4"
            />

            <v-text-field
              v-if="setting.subscriptionAutoUpdateMode === 'auto_update_at_intervals'"
              v-model="setting.subscriptionAutoUpdateIntervalHour"
              :label="$t('setting.intervalHours')"
              type="number"
              min="1"
            />
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>

    <v-btn color="primary" size="large" block @click="updateSetting">
      {{ $t('operations.saveApply') }}
    </v-btn>
    </template>
  </div>
</template>

<style scoped>
.settings-container {
  max-width: 1200px;
  margin: 0 auto;
}
</style>
