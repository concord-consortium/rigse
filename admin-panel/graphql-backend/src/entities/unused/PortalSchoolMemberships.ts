import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("member_type_id_index", ["memberType", "memberId"], {})
@Index(
  "school_memberships_long_idx",
  ["schoolId", "memberId", "memberType"],
  {}
)
@Entity("portal_school_memberships", { schema: "portal_development" })
export class PortalSchoolMemberships {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("varchar", { name: "uuid", nullable: true, length: 36 })
  uuid: string | null;

  @Column("varchar", { name: "name", nullable: true, length: 255 })
  name: string | null;

  @Column("mediumtext", { name: "description", nullable: true })
  description: string | null;

  @Column("datetime", { name: "start_time", nullable: true })
  startTime: Date | null;

  @Column("datetime", { name: "end_time", nullable: true })
  endTime: Date | null;

  @Column("int", { name: "member_id", nullable: true })
  memberId: number | null;

  @Column("varchar", { name: "member_type", nullable: true, length: 255 })
  memberType: string | null;

  @Column("int", { name: "school_id", nullable: true })
  schoolId: number | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;
}
