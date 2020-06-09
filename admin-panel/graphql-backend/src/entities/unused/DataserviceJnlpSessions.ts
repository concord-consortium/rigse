import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("index_dataservice_jnlp_sessions_on_token", ["token"], {})
@Entity("dataservice_jnlp_sessions", { schema: "portal_development" })
export class DataserviceJnlpSessions {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("varchar", { name: "token", nullable: true, length: 255 })
  token: string | null;

  @Column("int", { name: "user_id", nullable: true })
  userId: number | null;

  @Column("int", { name: "access_count", nullable: true, default: () => "'0'" })
  accessCount: number | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;
}
