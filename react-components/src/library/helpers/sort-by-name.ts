const sortByName = function (a: any, b: any) {
  const aName = a.name.toUpperCase();
  const bName = b.name.toUpperCase();
  return (aName > bName ? 1 : (aName < bName ? -1 : 0));
};

export default sortByName;
