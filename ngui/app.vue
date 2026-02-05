<script lang="ts" setup>
const snackbar = useSnackbarState()
</script>

<template>
  <v-app>
    <NuxtLayout>
      <NuxtPage />
    </NuxtLayout>

    <v-snackbar v-model="snackbar.show" :color="snackbar.color" :timeout="3000" location="bottom right">
      {{ snackbar.text }}
    </v-snackbar>
  </v-app>
</template>

<style>
html {
  overflow-y: auto;
}

.v-enter-active,
.v-leave-active,
.fade-transition-enter-active,
.fade-transition-leave-active,
.scale-transition-enter-active,
.scale-transition-leave-active,
.dialog-transition-enter-active,
.dialog-transition-leave-active,
.slide-y-transition-enter-active,
.slide-y-transition-leave-active {
  transition-duration: 150ms !important;
}
</style>
