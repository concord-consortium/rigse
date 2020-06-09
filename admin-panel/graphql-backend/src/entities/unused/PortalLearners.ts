import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("index_portal_learners_on_sec_key", ["secureKey"], { unique: true })
@Index("index_portal_learners_on_bundle_logger_id", ["bundleLoggerId"], {})
@Index("index_portal_learners_on_console_logger_id", ["consoleLoggerId"], {})
@Index("index_portal_learners_on_offering_id", ["offeringId"], {})
@Index("index_portal_learners_on_student_id", ["studentId"], {})
@Entity("portal_learners", { schema: "portal_development" })
export class PortalLearners {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("varchar", { name: "uuid", nullable: true, length: 36 })
  uuid: string | null;

  @Column("int", { name: "student_id", nullable: true })
  studentId: number | null;

  @Column("int", { name: "offering_id", nullable: true })
  offeringId: number | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("int", { name: "bundle_logger_id", nullable: true })
  bundleLoggerId: number | null;

  @Column("int", { name: "console_logger_id", nullable: true })
  consoleLoggerId: number | null;

  @Column("varchar", {
    name: "secure_key",
    nullable: true,
    unique: true,
    length: 255,
  })
  secureKey: string | null;
}
