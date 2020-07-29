import { Column, Entity, Index, PrimaryGeneratedColumn, JoinColumn, ManyToOne } from "typeorm";
import { ObjectType, Field, ID } from "type-graphql";
import { User } from "./Users"
@Index("index_portal_students_on_user_id", ["userId"], {})
@Entity("portal_students", { schema: "portal_development" })
export class PortalStudent {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("varchar", { name: "uuid", nullable: true, length: 36 })
  uuid: string | null;

  @Column("int", { name: "user_id", nullable: true })
  userId: number | null;

  @Column("int", { name: "grade_level_id", nullable: true })
  gradeLevelId: number | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Field(() => User)
  // This doesn't specify the property on AdminProject for the reverse
  // reference (currently there isn't one)
  @ManyToOne(type => User)
  // We might be able to configure this so we don't need to provide a name
  // for every JoinColumn https://github.com/typeorm/typeorm/blob/master/docs/naming-strategy.md
  @JoinColumn({name: 'portal_permission_form_id'})
  user: User;

}
