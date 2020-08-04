import { Column, Entity, Index, PrimaryGeneratedColumn, JoinColumn, ManyToOne, BaseEntity} from "typeorm";
import { ObjectType, Field, ID } from "type-graphql";
import { User } from "./Users"
@Index("index_portal_students_on_user_id", ["userId"], {})
@Entity("portal_students", { schema: "portal_development" })

@ObjectType()
export class PortalStudent extends BaseEntity {
  @Field(() => ID, {nullable: false})
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Field(() => ID)
  @Column("int", { name: "user_id", nullable: true })
  userId: number | null;

  @Field(() => User)
  @ManyToOne(type => User)
  @JoinColumn({name: "user_id"})
  user?: User

  @Field(() => ID)
  @Column("int", { name: "grade_level_id", nullable: true })
  gradeLevelId: number | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Field(() => String)
  get name(): string {
    if(this.user) {
      return `${this.user.firstName} ${this.user.lastName}`
    }
    return "error"
  }
}
