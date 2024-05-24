// converts 'foo_bar_baz' to 'Foo bar baz'
const humanize = (snakeCasedWord) => {
  const [first, ...rest] = snakeCasedWord.replace(/_/g, ' ').split('')
  return `${first.toUpperCase()}${rest.join('')}`
}

export default humanize
