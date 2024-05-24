
// @function guessPortalDomain()
// Tries to use window.location to extract a portal host
// @returns string: eg: `https://learn.concord.org`
var guessPortalDomain = function () {
  return window.location.protocol +
    '//' + window.location.hostname +
    (window.location.port ? ':' + window.location.port : '')
}

// @function MakeTeacherEditionLinks(selector, domain)
// @param `selector`: dom selector, should look like `#teacher-edition-links a`
// @param `specDomain`: specify a host url eg: `https://learn.concord.org`
// if `specDomain` is omitted, we guess it from the window.location.
// This function decorates <a href=""/> style links and modifies the href value.
// It appends query params that let the runtime use login credentials specified
// by the `specDomain` portal.
export function MakeTeacherEditionLinks (selector, specDomain = null) {
  var updateAnchorTag = function (anchor) {
    var oldLink = anchor.getAttribute('href')
    var url = MakeTeacherEditionLink(oldLink, specDomain)
    anchor.setAttribute('href', url)
  }

  var links = document.querySelectorAll(selector)
  links.forEach(updateAnchorTag)
}

export function MakeTeacherEditionLink (linkURL, specDomain = null) {
  var defaultDomain = guessPortalDomain()
  var domain = specDomain || defaultDomain
  var url = new URL(linkURL)
  var searchParams = url.searchParams
  var domainUid = Portal.currentUser.userId
  searchParams.set('domain', domain)
  searchParams.set('domain_uid', domainUid)
  searchParams.set('mode', 'teacher-edition')
  searchParams.set('show_index', 'true')
  searchParams.set('logging', 'true')

  return url.toString()
}
