import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("o_r_id_and_position_index", ["openResponseId", "position"], {})
@Entity("saveable_open_response_answers", { schema: "portal_development" })
export class SaveableOpenResponseAnswers {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "open_response_id", nullable: true })
  openResponseId: number | null;

  @Column("int", { name: "position", nullable: true })
  position: number | null;

  @Column("mediumtext", { name: "answer", nullable: true })
  answer: string | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

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
