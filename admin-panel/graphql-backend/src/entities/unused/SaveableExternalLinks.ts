import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("svbl_xtrn_links_poly", ["embeddableId", "embeddableType"], {})
@Index("index_saveable_external_links_on_learner_id", ["learnerId"], {})
@Index("index_saveable_external_links_on_offering_id", ["offeringId"], {})
@Entity("saveable_external_links", { schema: "portal_development" })
export class SaveableExternalLinks {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "embeddable_id", nullable: true })
  embeddableId: number | null;

  @Column("varchar", { name: "embeddable_type", nullable: true, length: 255 })
  embeddableType: string | null;

  @Column("int", { name: "learner_id", nullable: true })
  learnerId: number | null;

  @Column("int", { name: "offering_id", nullable: true })
  offeringId: number | null;

  @Column("int", { name: "response_count", nullable: true })
  responseCount: number | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;
}
