import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index(
  "index_saveable_multiple_choice_rationale_choices_on_answer_id",
  ["answerId"],
  {}
)
@Index(
  "index_saveable_multiple_choice_rationale_choices_on_choice_id",
  ["choiceId"],
  {}
)
@Entity("saveable_multiple_choice_rationale_choices", {
  schema: "portal_development",
})
export class SaveableMultipleChoiceRationaleChoices {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "choice_id", nullable: true })
  choiceId: number | null;

  @Column("int", { name: "answer_id", nullable: true })
  answerId: number | null;

  @Column("varchar", { name: "rationale", nullable: true, length: 255 })
  rationale: string | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("varchar", { name: "uuid", nullable: true, length: 36 })
  uuid: string | null;
}
