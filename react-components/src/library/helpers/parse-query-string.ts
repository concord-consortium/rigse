// from https://stackoverflow.com/questions/979975/
const parseQueryString = function (queryString?: any) {
  if (queryString == null) {
    queryString = window.location.search.replace(/^\?/, '')
  }
  let vars = queryString.split('&')
  let params: any = {}
  for (let i = 0; i < vars.length; i++) {
    let pair = vars[i].split('=')
    // If first entry with this name
    if (typeof params[pair[0]] === 'undefined') {
      params[pair[0]] = decodeURIComponent(pair[1])
      // If second entry with this name
    } else if (typeof params[pair[0]] === 'string') {
      let arr = [params[pair[0]], decodeURIComponent(pair[1])]
      params[pair[0]] = arr
      // If third or later entry with this name
    } else {
      params[pair[0]].push(decodeURIComponent(pair[1]))
    }
  }
  return params
}

export default parseQueryString
