const sortResources = function (resources: any, sortMethod: any) {
  const sortedResources = sortMethod === "Newest"
    ? resources.sort(sortByNewest)
    : sortMethod === "Oldest"
      ? resources.sort(sortByOldest)
      : resources.sort(sortByName);

  return sortedResources;
};

const sortByName = function (a: any, b: any) {
  const aName = a.name;
  const bName = b.name;

  if (aName === null || aName === "") {
    return 1;
  }
  if (bName === null || bName === "") {
    return -1;
  }

  const aNameUpper = aName.toUpperCase();
  const bNameUpper = bName.toUpperCase();

  if (aNameUpper > bNameUpper) {
    return 1;
  } else if (aNameUpper < bNameUpper) {
    return -1;
  } else {
    return 0;
  }
};

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

const sortByNewest = function (a: any, b: any) {
  return ((b.created_at > a.created_at) ? 1 : (b.created_at < a.created_at) ? -1 : 0);
};

const sortByOldest = function (a: any, b: any) {
  return ((a.created_at > b.created_at) ? 1 : (a.created_at < b.created_at) ? -1 : 0);
};

export default sortResources;
