const shouldCancelSorting = (classes) => {
  return e => {
    // Only HTML elements with selected classes can be used to reorder offerings.
    const classList = e.target.classList
    for (const cl of classes) {
      if (classList.contains(cl)) {
        return false
      }
    }
    return true
  }
}

export default shouldCancelSorting
