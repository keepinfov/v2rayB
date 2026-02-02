<script lang="ts" setup>
if (!user.value.exist) navigateTo('/signup')

const { t } = useI18n()

const username = ref('')
const password = ref('')
const loading = ref(false)

async function login() {
  loading.value = true
  const { data } = await useV2Fetch<any>('login').post({ username: username.value, password: password.value }).json()
  loading.value = false

  if (data.value.code !== 'SUCCESS') {
    useSnackbar(data.value.message, 'warning')
  } else {
    user.value.token = data.value.data.token
    useSnackbar(t('common.success'), 'success')
    navigateTo('/')
  }
}
</script>

<template>
  <div class="d-flex justify-center align-center auth-container">
    <v-card class="pa-6" max-width="400" width="100%" color="surface-container">
      <v-card-title class="text-h5 font-weight-bold text-center mb-4">
        v2rayB
      </v-card-title>

      <v-card-subtitle class="text-center mb-6">
        {{ t('login.title') }}
      </v-card-subtitle>

      <v-form @submit.prevent="login">
        <v-text-field
          v-model="username"
          :label="t('login.username')"
          prepend-inner-icon="mdi-account"
          autofocus
          class="mb-2"
        />

        <v-text-field
          v-model="password"
          :label="t('login.password')"
          type="password"
          prepend-inner-icon="mdi-lock"
          class="mb-4"
        />

        <v-btn
          type="submit"
          color="primary"
          block
          size="large"
          :loading="loading"
          :disabled="!username || !password"
        >
          {{ t('operations.login') }}
        </v-btn>
      </v-form>

      <v-alert type="info" variant="tonal" class="mt-6" density="compact">
        <p class="text-body-2 mb-2">
          Forgot password? Run <code>v2raya --reset-password</code> and restart.
        </p>
        <v-btn variant="text" size="small" color="primary" @click="user.exist = false">
          Already reset
        </v-btn>
      </v-alert>
    </v-card>
  </div>
</template>

<style scoped>
.auth-container {
  min-height: 80vh;
}
</style>
