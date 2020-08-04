import { Column, Entity, PrimaryGeneratedColumn, ManyToOne, OneToMany, JoinColumn, BaseEntity } from "typeorm";
import { ObjectType, Field, ID} from "type-graphql";
import { AdminProject } from "./AdminProjects"
import { PortalStudentPermissionForm } from "./PortalStudentPermissionForms"
@ObjectType()
@Entity("portal_permission_forms", { schema: "portal_development" })
export class PortalPermissionForm extends BaseEntity  {
  @Field(() => ID, {nullable: false})
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Field(() => String)
  @Column("varchar", { name: "name", nullable: true, length: 255 })
  name: string | null;

  @Field(() => String)
  @Column("varchar", { name: "url", nullable: true, length: 255 })
  url: string | null;

  @Column("timestamp", { name: "created_at" })
  createdAt: Date;

  @Column("timestamp", { name: "updated_at" })
  updatedAt: Date;

  @Field(() => AdminProject)
  // This doesn't specify the property on AdminProject for the reverse
  // reference (currently there isn't one)
  @ManyToOne(type => AdminProject)
  // We might be able to configure this so we don't need to provide a name
  // for every JoinColumn https://github.com/typeorm/typeorm/blob/master/docs/naming-strategy.md
  @JoinColumn({name: 'project_id'})
  project: AdminProject;

  @Field(() => [PortalStudentPermissionForm])
  @OneToMany(type => PortalStudentPermissionForm, (form: PortalStudentPermissionForm) => form.portalPermissionForm, {eager: true})
  portalStudentPermissionForms: PortalStudentPermissionForm[];


  @Field(() => ID)
  @Column("int", { name: "project_id", nullable: true })
  projectId: number
}
