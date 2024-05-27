let filterDiv: any = null

const shortenText = (text: any, length: any, breakOnSpace: any) => {
  let shortenedText = text
  length = (typeof length !== 'undefined') ? length : 350
  if (!text) {
    return ''
  } else {
    if (text.length > length) {
      if (breakOnSpace) {
        shortenedText = shortenedText.substring(0, text.lastIndexOf(' ', length)) + '…'
        shortenedText = shortenedText.replace(/[^\w\s]…/, '…') // trim any punctuation appearing immediately before ellipsis
        return shortenedText
      } else {
        return shortenedText.substring(0, length - 1) + '…'
      }
    } else {
      return text
    }
  }
}

const textOfHtml = (text: any) => {
  if (!filterDiv) {
    filterDiv = document.createElement('DIV')
  }

  filterDiv.innerHTML = text
  return filterDiv.innerText
}

const processResource = (resource: any) => {
  if (resource == null || resource._processed) {
    return
  }

  resource.filteredShortDescription = textOfHtml(resource.short_description)
  // Long description can be different based on the user type - teacher and non-teacher (student, anonymous).
  // Note that api also provides long_description and long_description_for_teacher if any UI component needs
  // to display both of them for given user (mostly likely teacher or admin).
  resource.longDescription = resource.long_description_for_current_user

  resource._processed = true
}

export default {
  textOfHtml: textOfHtml,
  processResource: processResource,
  shortenText: shortenText
}
