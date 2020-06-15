function formatDate (dateString) {
  const d = new Date(dateString)
  const month = ('0' + (d.getMonth() + 1)).slice(-2)
  const day = ('0' + d.getDate()).slice(-2)
  const year = d.getFullYear()
  return month + '-' + day + '-' + year
}

export default formatDate
