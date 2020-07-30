import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("index_access_grants_on_client_id", ["clientId"], {})
@Index("index_access_grants_on_learner_id", ["learnerId"], {})
@Index("index_access_grants_on_teacher_id", ["teacherId"], {})
@Index("index_access_grants_on_user_id", ["userId"], {})
@Entity("access_grants", { schema: "portal_development" })
export class AccessGrants {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("varchar", { name: "code", nullable: true, length: 255 })
  code: string | null;

  @Column("varchar", { name: "access_token", nullable: true, length: 255 })
  accessToken: string | null;

  @Column("varchar", { name: "refresh_token", nullable: true, length: 255 })
  refreshToken: string | null;

  @Column("datetime", { name: "access_token_expires_at", nullable: true })
  accessTokenExpiresAt: Date | null;

  @Column("int", { name: "user_id", nullable: true })
  userId: number | null;

  @Column("int", { name: "client_id", nullable: true })
  clientId: number | null;

  @Column("varchar", { name: "state", nullable: true, length: 255 })
  state: string | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("int", { name: "learner_id", nullable: true })
  learnerId: number | null;

  @Column("int", { name: "teacher_id", nullable: true })
  teacherId: number | null;
}
