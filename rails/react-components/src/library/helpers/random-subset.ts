import shuffleArray from "./shuffle-array";

const randomSubset = function (array: any) {
  const count = Math.round(Math.random() * array.length);
  const subset = array.slice(0, count);
  return shuffleArray(subset);
};

export default randomSubset;
