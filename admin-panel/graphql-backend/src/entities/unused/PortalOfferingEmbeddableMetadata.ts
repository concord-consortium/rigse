import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index(
  "index_portal_offering_metadata",
  ["offeringId", "embeddableId", "embeddableType"],
  { unique: true }
)
@Entity("portal_offering_embeddable_metadata", { schema: "portal_development" })
export class PortalOfferingEmbeddableMetadata {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "offering_id", nullable: true })
  offeringId: number | null;

  @Column("int", { name: "embeddable_id", nullable: true })
  embeddableId: number | null;

  @Column("varchar", { name: "embeddable_type", nullable: true, length: 255 })
  embeddableType: string | null;

  @Column("tinyint", {
    name: "enable_score",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  enableScore: boolean | null;

  @Column("int", { name: "max_score", nullable: true })
  maxScore: number | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("tinyint", {
    name: "enable_text_feedback",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  enableTextFeedback: boolean | null;
}
