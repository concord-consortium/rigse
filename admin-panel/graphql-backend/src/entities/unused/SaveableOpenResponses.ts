import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("index_saveable_open_responses_on_learner_id", ["learnerId"], {})
@Index("index_saveable_open_responses_on_offering_id", ["offeringId"], {})
@Index(
  "index_saveable_open_responses_on_open_response_id",
  ["openResponseId"],
  {}
)
@Entity("saveable_open_responses", { schema: "portal_development" })
export class SaveableOpenResponses {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "learner_id", nullable: true })
  learnerId: number | null;

  @Column("int", { name: "open_response_id", nullable: true })
  openResponseId: number | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("int", { name: "offering_id", nullable: true })
  offeringId: number | null;

  @Column("int", {
    name: "response_count",
    nullable: true,
    default: () => "'0'",
  })
  responseCount: number | null;
}
