import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("index_learner_processing_events_on_learner_id", ["learnerId"], {})
@Index("index_learner_processing_events_on_url", ["url"], {})
@Entity("learner_processing_events", { schema: "portal_development" })
export class LearnerProcessingEvents {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "learner_id", nullable: true })
  learnerId: number | null;

  @Column("datetime", { name: "portal_end", nullable: true })
  portalEnd: Date | null;

  @Column("datetime", { name: "portal_start", nullable: true })
  portalStart: Date | null;

  @Column("datetime", { name: "lara_end", nullable: true })
  laraEnd: Date | null;

  @Column("datetime", { name: "lara_start", nullable: true })
  laraStart: Date | null;

  @Column("int", { name: "elapsed_seconds", nullable: true })
  elapsedSeconds: number | null;

  @Column("varchar", { name: "duration", nullable: true, length: 255 })
  duration: string | null;

  @Column("varchar", { name: "login", nullable: true, length: 255 })
  login: string | null;

  @Column("varchar", { name: "teacher", nullable: true, length: 255 })
  teacher: string | null;

  @Column("varchar", { name: "url", nullable: true, length: 255 })
  url: string | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("int", { name: "lara_duration", nullable: true })
  laraDuration: number | null;

  @Column("int", { name: "portal_duration", nullable: true })
  portalDuration: number | null;
}
