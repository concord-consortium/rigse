import { Column, Entity, Index } from "typeorm";

@Index("index_roles_users_on_role_id_and_user_id", ["roleId", "userId"], {})
@Index("index_roles_users_on_user_id_and_role_id", ["userId", "roleId"], {})
@Entity("roles_users", { schema: "portal_development" })
export class RolesUsers {
  @Column("int", { name: "role_id", nullable: true })
  roleId: number | null;

  @Column("int", { name: "user_id", nullable: true })
  userId: number | null;
}
