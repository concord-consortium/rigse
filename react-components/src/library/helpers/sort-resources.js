const sortResources = function (resources, sortMethod) {
  const sortedResources = sortMethod === 'Newest'
    ? resources.sort(sortByNewest)
    : sortMethod === 'Oldest'
      ? resources.sort(sortByOldest)
      : sortMethod === 'Less time required'
        ? resources.sort(sortByTimeRequiredAsc)
        : sortMethod === 'More time required'
          ? resources.sort(sortByTimeRequiredDesc)
          : resources.sort(sortByName)

  return sortedResources
}

const sortByName = function (a, b) {
  const aName = a.name.toUpperCase()
  const bName = b.name.toUpperCase()
  return ((aName > bName) - (bName > aName))
}

const sortByTimeRequiredAsc = function (a, b) {
  const materialTypes = ['Interactive', 'Activity', 'Investigation', 'Collection']
  return ((materialTypes.indexOf(a.material_type) > materialTypes.indexOf(b.material_type)) - (materialTypes.indexOf(b.material_type) > materialTypes.indexOf(a.material_type)))
}

const sortByTimeRequiredDesc = function (a, b) {
  const materialTypes = ['Collection', 'Investigation', 'Activity', 'Interactive']
  return ((materialTypes.indexOf(a.material_type) > materialTypes.indexOf(b.material_type)) - (materialTypes.indexOf(b.material_type) > materialTypes.indexOf(a.material_type)))
}

const sortByNewest = function (a, b) {
  return ((b.created_at > a.created_at) - (a.created_at > b.created_at))
}

const sortByOldest = function (a, b) {
  return ((a.created_at > b.created_at) - (b.created_at > a.created_at))
}

export default sortResources
