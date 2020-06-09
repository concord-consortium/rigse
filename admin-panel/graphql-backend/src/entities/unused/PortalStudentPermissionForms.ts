import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("p_s_p_form_id", ["portalPermissionFormId"], {})
@Index(
  "index_portal_student_permission_forms_on_portal_student_id",
  ["portalStudentId"],
  {}
)
@Entity("portal_student_permission_forms", { schema: "portal_development" })
export class PortalStudentPermissionForms {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("tinyint", { name: "signed", nullable: true, width: 1 })
  signed: boolean | null;

  @Column("int", { name: "portal_student_id", nullable: true })
  portalStudentId: number | null;

  @Column("int", { name: "portal_permission_form_id", nullable: true })
  portalPermissionFormId: number | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;
}
