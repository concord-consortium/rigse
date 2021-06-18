import { Column, Entity, PrimaryGeneratedColumn } from "typeorm";

@Entity("saveable_interactive_states", { schema: "portal_development" })
export class SaveableInteractiveStates {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "interactive_id", nullable: true })
  interactiveId: number | null;

  @Column("int", { name: "position", nullable: true })
  position: number | null;

  @Column("longtext", { name: "state", nullable: true })
  state: string | null;

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

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;
}
