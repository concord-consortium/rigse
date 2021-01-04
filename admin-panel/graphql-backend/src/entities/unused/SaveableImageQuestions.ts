import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index(
  "index_saveable_image_questions_on_image_question_id",
  ["imageQuestionId"],
  {}
)
@Index("index_saveable_image_questions_on_learner_id", ["learnerId"], {})
@Index("index_saveable_image_questions_on_offering_id", ["offeringId"], {})
@Entity("saveable_image_questions", { schema: "portal_development" })
export class SaveableImageQuestions {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "learner_id", nullable: true })
  learnerId: number | null;

  @Column("int", { name: "offering_id", nullable: true })
  offeringId: number | null;

  @Column("int", { name: "image_question_id", nullable: true })
  imageQuestionId: number | null;

  @Column("int", {
    name: "response_count",
    nullable: true,
    default: () => "'0'",
  })
  responseCount: number | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("varchar", { name: "uuid", nullable: true, length: 36 })
  uuid: string | null;
}
