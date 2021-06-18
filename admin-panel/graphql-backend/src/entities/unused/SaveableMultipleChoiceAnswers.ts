import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("m_c_id_and_position_index", ["multipleChoiceId", "position"], {})
@Entity("saveable_multiple_choice_answers", { schema: "portal_development" })
export class SaveableMultipleChoiceAnswers {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "multiple_choice_id", nullable: true })
  multipleChoiceId: number | null;

  @Column("int", { name: "position", nullable: true })
  position: number | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("varchar", { name: "uuid", nullable: true, length: 36 })
  uuid: string | null;

  @Column("tinyint", { name: "is_final", nullable: true, width: 1 })
  isFinal: boolean | null;

  @Column("text", { name: "feedback", nullable: true })
  feedback: string | null;

  @Column("tinyint", {
    name: "has_been_reviewed",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  hasBeenReviewed: boolean | null;

  @Column("int", { name: "score", nullable: true })
  score: number | null;
}
