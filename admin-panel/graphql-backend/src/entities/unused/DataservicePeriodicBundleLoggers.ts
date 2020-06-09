import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("learner_index", ["learnerId"], {})
@Entity("dataservice_periodic_bundle_loggers", { schema: "portal_development" })
export class DataservicePeriodicBundleLoggers {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "learner_id", nullable: true })
  learnerId: number | null;

  @Column("mediumtext", { name: "imports", nullable: true })
  imports: string | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;
}
