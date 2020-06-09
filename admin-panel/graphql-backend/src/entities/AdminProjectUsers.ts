import { Column, Entity, Index, PrimaryGeneratedColumn, BaseEntity, ManyToOne, JoinColumn } from "typeorm";
import { ObjectType, Field, ID } from "type-graphql";
import { AdminProject } from "./AdminProjects";

@Index("admin_proj_user_uniq_idx", ["projectId", "userId"], { unique: true })
@Index("index_admin_project_users_on_project_id", ["projectId"], {})
@Index("index_admin_project_users_on_user_id", ["userId"], {})

@ObjectType()
@Entity("admin_project_users", { schema: "portal_development" })
export class AdminProjectUser extends BaseEntity{
  @Field(() => ID)
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Field(() => ID)
  @Column("int", { name: "project_id", nullable: true })
  projectId: number | null;

  @Field(() => AdminProject)
  // This doesn't specify the property on AdminProject for the reverse
  // reference (currently there isn't one)
  @ManyToOne(type => AdminProject)
  // We might be able to configure this so we don't need to provide a name
  // for every JoinColumn https://github.com/typeorm/typeorm/blob/master/docs/naming-strategy.md
  @JoinColumn({name: 'project_id'})
  project: AdminProject;

  @Field(() => ID)
  @Column("int", { name: "user_id", nullable: true })
  userId: number | null;

  @Field(() => Boolean)
  @Column("tinyint", {
    name: "is_admin",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  isAdmin: boolean | null;

  @Field(() => Boolean)
  @Column("tinyint", {
    name: "is_researcher",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  isResearcher: boolean | null;
}
