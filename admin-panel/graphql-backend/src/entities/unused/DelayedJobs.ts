import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("delayed_jobs_priority", ["priority", "runAt"], {})
@Entity("delayed_jobs", { schema: "portal_development" })
export class DelayedJobs {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "priority", nullable: true, default: () => "'0'" })
  priority: number | null;

  @Column("int", { name: "attempts", nullable: true, default: () => "'0'" })
  attempts: number | null;

  @Column("longtext", { name: "handler", nullable: true })
  handler: string | null;

  @Column("mediumtext", { name: "last_error", nullable: true })
  lastError: string | null;

  @Column("datetime", { name: "run_at", nullable: true })
  runAt: Date | null;

  @Column("datetime", { name: "locked_at", nullable: true })
  lockedAt: Date | null;

  @Column("datetime", { name: "failed_at", nullable: true })
  failedAt: Date | null;

  @Column("varchar", { name: "locked_by", nullable: true, length: 255 })
  lockedBy: string | null;

  @Column("varchar", { name: "queue", nullable: true, length: 255 })
  queue: string | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;
}
