import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index(
  "index_portal_coll_mem_on_collaboration_id_and_student_id",
  ["collaborationId", "studentId"],
  {}
)
@Entity("portal_collaboration_memberships", { schema: "portal_development" })
export class PortalCollaborationMemberships {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "collaboration_id", nullable: true })
  collaborationId: number | null;

  @Column("int", { name: "student_id", nullable: true })
  studentId: number | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;
}
