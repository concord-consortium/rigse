import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index(
  "index_saveable_sparks_measuring_resistance_on_learner_id",
  ["learnerId"],
  {}
)
@Index(
  "index_saveable_sparks_measuring_resistance_on_offering_id",
  ["offeringId"],
  {}
)
@Entity("saveable_sparks_measuring_resistance", {
  schema: "portal_development",
})
export class SaveableSparksMeasuringResistance {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "learner_id", nullable: true })
  learnerId: number | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("int", { name: "offering_id", nullable: true })
  offeringId: number | null;
}
