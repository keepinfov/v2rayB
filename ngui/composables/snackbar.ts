const snackbar = ref({
  show: false,
  text: '',
  color: 'success' as 'success' | 'error' | 'warning' | 'info'
})

export const useSnackbarState = () => snackbar

export const useSnackbar = (text: string, color: 'success' | 'error' | 'warning' | 'info' = 'success') => {
  snackbar.value = { show: true, text, color }
}
