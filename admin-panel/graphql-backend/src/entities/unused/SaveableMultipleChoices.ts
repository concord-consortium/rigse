import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("index_saveable_multiple_choices_on_learner_id", ["learnerId"], {})
@Index(
  "index_saveable_multiple_choices_on_multiple_choice_id",
  ["multipleChoiceId"],
  {}
)
@Index("index_saveable_multiple_choices_on_offering_id", ["offeringId"], {})
@Entity("saveable_multiple_choices", { schema: "portal_development" })
export class SaveableMultipleChoices {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "learner_id", nullable: true })
  learnerId: number | null;

  @Column("int", { name: "multiple_choice_id", nullable: true })
  multipleChoiceId: number | null;

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

  @Column("varchar", { name: "uuid", nullable: true, length: 36 })
  uuid: string | null;
}
