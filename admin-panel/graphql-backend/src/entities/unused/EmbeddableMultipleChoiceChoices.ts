import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index(
  "index_embeddable_multiple_choice_choices_on_multiple_choice_id",
  ["multipleChoiceId"],
  {}
)
@Entity("embeddable_multiple_choice_choices", { schema: "portal_development" })
export class EmbeddableMultipleChoiceChoices {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("mediumtext", { name: "choice", nullable: true })
  choice: string | null;

  @Column("int", { name: "multiple_choice_id", nullable: true })
  multipleChoiceId: number | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("tinyint", { name: "is_correct", nullable: true, width: 1 })
  isCorrect: boolean | null;

  @Column("varchar", { name: "external_id", nullable: true, length: 255 })
  externalId: string | null;
}
