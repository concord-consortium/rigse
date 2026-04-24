import { buildSelectedFilterChips } from "../../../src/library/helpers/selected-filter-chips";

describe("buildSelectedFilterChips", () => {
  it("returns an empty array when no filters are selected", () => {
    expect(
      buildSelectedFilterChips({
        subjectAreasSelected: [],
        gradeLevelsSelected: [],
        resourceTypesSelected: [],
        keyword: ""
      })
    ).toEqual([]);
  });

  it("produces one chip per selected subject, grade, and resource-type", () => {
    const chips = buildSelectedFilterChips({
      subjectAreasSelected: [{ key: "chemistry", title: "Chemistry" }],
      gradeLevelsSelected:  [{ key: "middle-school", title: "Middle School" }],
      resourceTypesSelected:[{ key: "simulation", title: "Simulation" }],
      keyword: ""
    });
    expect(chips.map(c => c.kind)).toEqual(["subject", "grade", "resourceType"]);
    expect(chips.map(c => c.label)).toEqual(["Chemistry", "Middle School", "Simulation"]);
  });

  it("produces a keyword chip wrapped in quotes when the keyword fits", () => {
    const chips = buildSelectedFilterChips({
      subjectAreasSelected: [], gradeLevelsSelected: [], resourceTypesSelected: [],
      keyword: "earthquakes"   // 11 chars → `"earthquakes"` = 13 chars total, under the 15 limit
    });
    expect(chips).toHaveLength(1);
    expect(chips[0]).toMatchObject({ kind: "keyword", label: `"earthquakes"` });
  });

  it("leaves a 13-char keyword untruncated (quotes + 13 chars = 15, equal to the limit)", () => {
    const chips = buildSelectedFilterChips({
      subjectAreasSelected: [], gradeLevelsSelected: [], resourceTypesSelected: [],
      keyword: "thirteenchars"   // 13 chars
    });
    expect(chips[0].label).toBe(`"thirteenchars"`);  // 15 chars total, no truncation
    expect(chips[0].label.length).toBe(15);
  });

  it("truncates a 14+ char keyword to 10 inner chars plus three-dot ellipsis inside quotes", () => {
    // Spec example from the mockup: "photosynth..." shown for "photosynthesis".
    const chips = buildSelectedFilterChips({
      subjectAreasSelected: [], gradeLevelsSelected: [], resourceTypesSelected: [],
      keyword: "photosynthesis"  // 14 chars
    });
    expect(chips[0].label).toBe(`"photosynth..."`);  // " + 10 chars + ... + " = 15 chars
    expect(chips[0].label.length).toBe(15);
  });
});
