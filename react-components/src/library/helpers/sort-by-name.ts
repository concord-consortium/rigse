var sortByName = function (a: any, b: any) {
  var aName = a.name.toUpperCase()
  var bName = b.name.toUpperCase()
  // @ts-expect-error TS(2362): The left-hand side of an arithmetic operation must... Remove this comment to see the full error message
  return ((aName > bName) - (bName > aName))
}

export default sortByName
