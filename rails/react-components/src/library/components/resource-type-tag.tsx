import * as React from "react";
import css from "./resource-type-tag.scss";

// Map incoming search-side material_type values → display label + icon-class suffix.
// Keys match what the API returns on `resource.material_type`.
const MATERIAL_TYPE_MAP: Record<string, { label: string; iconKey: string }> = {
  "Interactive":   { label: "Simulation",  iconKey: "simulation" },
  "Assessment":    { label: "Assessment",  iconKey: "assessment" },
  "Activity":      { label: "Activity",    iconKey: "activity"   },
  "Investigation": { label: "Sequence",    iconKey: "sequence"   },
  "Collection":    { label: "Collection",  iconKey: "collection" }
};

interface Props {
  resource: { material_type: string };
}

export const ResourceTypeTag: React.FC<Props> = ({ resource }) => {
  const entry = MATERIAL_TYPE_MAP[resource.material_type];
  if (!entry) return null;
  return (
    <div className={css.resourceTypeTag} role="group" aria-label={`Resource type: ${entry.label}`}>
      <span className={`${css.icon} ${css[entry.iconKey]}`} aria-hidden="true" />
      <span className={css.label}>{entry.label}</span>
    </div>
  );
};
