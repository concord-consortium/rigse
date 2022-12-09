const sortResources = function (resources, sortMethod) {
  const sortedResources = sortMethod === 'Newest'
    ? resources.sort(sortByNewest)
    : sortMethod === 'Oldest'
      ? resources.sort(sortByOldest)
      : resources.sort(sortByName)

  return sortedResources
}

const sortByName = function (a, b) {
  const aName = a.name
  const bName = b.name
  if (aName === null || aName === '') {
    return 1
  }
  if (bName === null || bName === '') {
    return -1
  }
  return ((aName.toUpperCase() > bName.toUpperCase()) - (bName.toUpperCase() > aName.toUpperCase()))
}

/*

Keep these in case we eventually get the time required synced by Lara

const sortByTimeRequiredAsc = function (a, b) {
  const materialTypes = ['Interactive', 'Activity', 'Investigation', 'Collection']
  return ((materialTypes.indexOf(a.material_type) > materialTypes.indexOf(b.material_type)) - (materialTypes.indexOf(b.material_type) > materialTypes.indexOf(a.material_type)))
}

const sortByTimeRequiredDesc = function (a, b) {
  const materialTypes = ['Collection', 'Investigation', 'Activity', 'Interactive']
  return ((materialTypes.indexOf(a.material_type) > materialTypes.indexOf(b.material_type)) - (materialTypes.indexOf(b.material_type) > materialTypes.indexOf(a.material_type)))
}
*/

const sortByNewest = function (a, b) {
  return ((b.created_at > a.created_at) - (a.created_at > b.created_at))
}

const sortByOldest = function (a, b) {
  return ((a.created_at > b.created_at) - (b.created_at > a.created_at))
}

export default sortResources
