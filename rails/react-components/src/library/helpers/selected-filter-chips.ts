export type SelectedFilterChip =
  | { kind: "subject";      key: string; label: string }
  | { kind: "grade";        key: string; label: string }
  | { kind: "resourceType"; key: string; label: string }
  | { kind: "keyword";      key: "keyword"; label: string };

interface BuildArgs {
  subjectAreasSelected:  { key: string; title: string }[];
  gradeLevelsSelected:   { key: string; title: string }[];
  resourceTypesSelected: { key: string; title: string }[];
  keyword: string;
}

// Max total chip label length, including the two surrounding quotes and, when truncated,
// the three-dot ellipsis.
const MAX_CHIP_DISPLAY = 15;
const ELLIPSIS = "...";
const QUOTE_CHARS = 2;
const TRUNCATED_INNER_LEN = MAX_CHIP_DISPLAY - QUOTE_CHARS - ELLIPSIS.length;  // = 10

export function buildSelectedFilterChips (s: BuildArgs): SelectedFilterChip[] {
  const chips: SelectedFilterChip[] = [];
  s.subjectAreasSelected.forEach(sa =>
    chips.push({ kind: "subject", key: sa.key, label: sa.title }));
  s.gradeLevelsSelected.forEach(gl =>
    chips.push({ kind: "grade", key: gl.key, label: gl.title }));
  s.resourceTypesSelected.forEach(rt =>
    chips.push({ kind: "resourceType", key: rt.key, label: rt.title }));
  const kw = s.keyword.trim();
  if (kw.length > 0) {
    const untruncated = `"${kw}"`;
    const label = untruncated.length <= MAX_CHIP_DISPLAY
      ? untruncated
      : `"${kw.slice(0, TRUNCATED_INNER_LEN)}${ELLIPSIS}"`;
    chips.push({ kind: "keyword", key: "keyword", label });
  }
  return chips;
}
