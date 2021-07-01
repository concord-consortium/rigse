var sortByName = function (a, b) {
  console.log(a)
  console.log(b)
  var aName = a.name.toUpperCase()
  var bName = b.name.toUpperCase()
  return ((aName > bName) - (bName > aName))
}

export default sortByName
