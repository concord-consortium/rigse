// converts 'foo_bar_baz' to 'Foo bar baz'
const humanize = (snakeCasedWord: any) => {
  const [first, ...rest] = snakeCasedWord.replace(/_/g, " ").split("");
  return `${first.toUpperCase()}${rest.join("")}`;
};

export default humanize;
