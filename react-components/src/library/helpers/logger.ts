import { v4 } from 'uuid'

const sessionId = v4()

export const getDefaultData = () => {
  const currentUser = (window.Portal && window.Portal.currentUser) || { isAnonymous: true }
  return {
    application: 'rigse-log',
    session: sessionId,
    username: currentUser.isAnonymous ? 'anonymous' : `${currentUser.userId}@${window.location.host}`
  }
}

export const logEvent = function (data: any) {
  if (typeof (data) === 'string') {
    data = { event: data }
  }
  return postLogEvent(data)
}

export const postLogEvent = function (data: any) {
  const processedData = jQuery.extend(true, {}, getDefaultData(), { time: Date.now() }, data)
  jQuery.ajax({
    url: Portal.API_V1.getLogManagerUrl(),
    type: 'POST',
    crossDomain: true,
    data: JSON.stringify(processedData),
    contentType: 'application/json'
  })
  return processedData
}
