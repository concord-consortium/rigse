import { Column, Entity, Index, PrimaryGeneratedColumn, ManyToOne, JoinColumn } from "typeorm";
import { ObjectType, Field, ID } from "type-graphql";
import { PortalPermissionForm } from "./PortalPermissionForms"
import { PortalStudent } from "./PortalStudents"

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

  @Field(() => PortalPermissionForm)
  // This doesn't specify the property on AdminProject for the reverse
  // reference (currently there isn't one)
  @ManyToOne(type => PortalPermissionForm)
  // We might be able to configure this so we don't need to provide a name
  // for every JoinColumn https://github.com/typeorm/typeorm/blob/master/docs/naming-strategy.md
  @JoinColumn({name: 'portal_permission_form_id'})
  permissionForm: PortalPermissionForm;

  @Field(() => PortalStudent)
  // This doesn't specify the property on AdminProject for the reverse
  // reference (currently there isn't one)
  @ManyToOne(type => PortalStudent)
  // We might be able to configure this so we don't need to provide a name
  // for every JoinColumn https://github.com/typeorm/typeorm/blob/master/docs/naming-strategy.md
  @JoinColumn({name: 'portal_student_id'})
  student: PortalStudent;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;
}
