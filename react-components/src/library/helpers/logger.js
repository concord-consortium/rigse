import { v4 } from 'uuid'

const logManagerUrl = '//cc-log-manager.herokuapp.com/api/logs'
const sessionId = v4()

export const getDefaultData = () => {
  const currentUser = (window.Portal && window.Portal.currentUser) || { isAnonymous: true }
  return {
    application: 'rigse-log',
    session: sessionId,
    username: currentUser.isAnonymous ? 'anonymous' : `${currentUser.userId}@${window.location.host}`
  }
}

export const logEvent = function (data) {
  if (typeof (data) === 'string') {
    data = { event: data }
  }
  return postLogEvent(data)
}

export const postLogEvent = function (data) {
  const processedData = jQuery.extend(true, {}, getDefaultData(), { time: Date.now() }, data)
  jQuery.ajax({
    url: logManagerUrl,
    type: 'POST',
    crossDomain: true,
    data: JSON.stringify(processedData),
    contentType: 'application/json'
  })
  return processedData
}
