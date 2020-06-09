import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("index_portal_teacher_full_status_on_offering_id", ["offeringId"], {})
@Index("index_portal_teacher_full_status_on_teacher_id", ["teacherId"], {})
@Entity("portal_teacher_full_status", { schema: "portal_development" })
export class PortalTeacherFullStatus {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "offering_id", nullable: true })
  offeringId: number | null;

  @Column("int", { name: "teacher_id", nullable: true })
  teacherId: number | null;

  @Column("tinyint", { name: "offering_collapsed", nullable: true, width: 1 })
  offeringCollapsed: boolean | null;
}
