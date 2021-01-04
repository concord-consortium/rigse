export const pack = (s) => {
  return s.split("\n").map(l => l.trim()).filter(l => l.length > 0).join("")
}
