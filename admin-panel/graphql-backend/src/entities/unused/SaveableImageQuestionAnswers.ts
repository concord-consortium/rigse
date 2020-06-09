import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("i_q_id_and_position_index", ["imageQuestionId", "position"], {})
@Entity("saveable_image_question_answers", { schema: "portal_development" })
export class SaveableImageQuestionAnswers {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "image_question_id", nullable: true })
  imageQuestionId: number | null;

  @Column("int", { name: "bundle_content_id", nullable: true })
  bundleContentId: number | null;

  @Column("int", { name: "blob_id", nullable: true })
  blobId: number | null;

  @Column("int", { name: "position", nullable: true })
  position: number | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("mediumtext", { name: "note", nullable: true })
  note: string | null;

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
