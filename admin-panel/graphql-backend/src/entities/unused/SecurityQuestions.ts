import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("index_security_questions_on_user_id", ["userId"], {})
@Entity("security_questions", { schema: "portal_development" })
export class SecurityQuestions {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "user_id" })
  userId: number;

  @Column("varchar", { name: "question", length: 100 })
  question: string;

  @Column("varchar", { name: "answer", length: 100 })
  answer: string;
}
