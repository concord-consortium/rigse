import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("index_dataservice_bucket_loggers_on_learner_id", ["learnerId"], {})
@Index("index_dataservice_bucket_loggers_on_name", ["name"], {})
@Entity("dataservice_bucket_loggers", { schema: "portal_development" })
export class DataserviceBucketLoggers {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "learner_id", nullable: true })
  learnerId: number | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("varchar", { name: "name", nullable: true, length: 255 })
  name: string | null;
}
