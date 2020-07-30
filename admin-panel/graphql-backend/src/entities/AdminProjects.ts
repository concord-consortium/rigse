import {
  Column, Entity, Index, PrimaryGeneratedColumn,
  BaseEntity, ManyToMany, OneToMany, JoinTable
} from "typeorm";
import { ObjectType, Field, ID } from "type-graphql";
import { User } from "./Users"
import { PortalPermissionForm } from "./PortalPermissionForms"
@Index("index_admin_projects_on_landing_page_slug", ["landingPageSlug"], {
  unique: true,
})

@ObjectType()
@Entity("admin_projects", { schema: "portal_development" })
export class AdminProject extends BaseEntity {
  @Field(() => ID, {nullable: false})
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Field(() => String)
  @Column("varchar", { name: "name", nullable: false, length: 255 })
  name: string | null;

  @Column("timestamp", { name: "created_at", default: "CURRENT_TIMESTAMP"})
  createdAt: Date;

  @Column("timestamp", { name: "updated_at", default: "CURRENT_TIMESTAMP"})
  updatedAt: Date;

  @Field(() => String, {nullable: true})
  @Column("varchar", {
    name: "landing_page_slug",
    nullable: true,
    unique: true,
    length: 255,
  })
  landingPageSlug: string | null;

  @Field(() => String, {nullable: true, defaultValue: ""})
  @Column("mediumtext", { name: "landing_page_content", nullable: true })
  landingPageContent: string | null;

  @Field(() => String,{nullable: true})
  @Column("varchar", {
    name: "project_card_image_url",
    nullable: true,
    length: 255,
  })
  projectCardImageUrl: string | null;

  @Field(() => String,{nullable: true})
  @Column("varchar", {
    name: "project_card_description",
    nullable: true,
    length: 255,
  })
  projectCardDescription: string | null;

  @Field(() => Boolean, {nullable: true, defaultValue: false})
  @Column("tinyint", {
    name: "public",
    nullable: true,
    width: 1,
    default: 1,
  })
  public: boolean | null;

  @Field(() => User)
  @ManyToMany(type => User)
  @JoinTable({
      name: "admin_project_users", // table name for the junction table of this relation
      joinColumn: {
          name: "project_id",
          referencedColumnName: "id"
      },
      inverseJoinColumn: {
          name: "user_id",
          referencedColumnName: "id"
      }
  })
  users: User[]

  @OneToMany(type => PortalPermissionForm, permissionForm => permissionForm.project)
  permissionForms: PortalPermissionForm[];
}
