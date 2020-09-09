const apiAlert = (err, message) => {
  message = message || 'Unable to call API!'
  if (err.message) {
    window.alert(`${message}\n${err.message}`)
  } else {
    window.alert(message)
  }
}

export default apiAlert
