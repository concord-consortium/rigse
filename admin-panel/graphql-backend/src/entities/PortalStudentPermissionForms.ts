import { Column, Entity, Index, BaseEntity,
  PrimaryGeneratedColumn, ManyToOne, JoinColumn } from "typeorm";
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
@ObjectType()
export class PortalStudentPermissionForm extends BaseEntity {
  @Field(() => ID, {nullable: false})
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Field(() => Boolean)
  @Column("tinyint", { name: "signed", nullable: true, width: 1 })
  signed: boolean | null;

  @Field(() => ID)
  @Column("int", { name: "portal_student_id", nullable: true })
  portalStudentId: number | null;

  @Field(() => ID)
  @Column("int", { name: "portal_permission_form_id", nullable: true })
  portalPermissionFormId: number | null;

  @Field(() => PortalStudent)
  @ManyToOne(type => PortalStudent)
  @JoinColumn({name: 'portal_student_id'})
  student: PortalStudent;

  @Field(() => PortalPermissionForm)
  @ManyToOne(type => PortalPermissionForm)
  @JoinColumn({name: 'portal_permission_form_id'})
  portalPermissionForm: PortalPermissionForm;


  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;
}
