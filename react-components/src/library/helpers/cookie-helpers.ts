const setCookieName = (content) => {
  let cookieKey = ''
  for (let i = 0; i < content.length; i++) {
    cookieKey = Math.imul(31, cookieKey) + content.charCodeAt(i) | 0
  }
  const cookieName = `dismissed-alert${cookieKey.toString(16)}`
  return cookieName
}

const createCookie = (name, value, days) => {
  let expires = ''
  if (days) {
    const date = new Date()
    date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000))
    expires = '; expires=' + date.toGMTString()
  }
  document.cookie = encodeURIComponent(name) + '=' + encodeURIComponent(value) + expires + '; path=/'
}

const readCookie = (name) => {
  const nameEQ = encodeURIComponent(name) + '='
  const ca = document.cookie.split(';')
  for (let i = 0; i < ca.length; i++) {
    let c = ca[i]
    while (c.charAt(0) === ' ') {
      c = c.substring(1, c.length)
    }
    if (c.indexOf(nameEQ) === 0) {
      return decodeURIComponent(c.substring(nameEQ.length, c.length))
    }
  }
  return null
}

const eraseCookie = (name) => {
  createCookie(name, '', -1)
}

export default {
  setCookieName: setCookieName,
  createCookie: createCookie,
  readCookie: readCookie,
  eraseCookie: eraseCookie
}
