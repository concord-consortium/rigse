const pluralize = function (count: any, singular: any, plural?: any) {
  plural = plural || singular + "s";
  return count === 1 ? singular : plural;
};

export default pluralize;
