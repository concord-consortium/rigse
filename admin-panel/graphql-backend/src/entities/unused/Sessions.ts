import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("index_sessions_on_session_id", ["sessionId"], {})
@Index("index_sessions_on_updated_at", ["updatedAt"], {})
@Entity("sessions", { schema: "portal_development" })
export class Sessions {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("varchar", { name: "session_id", length: 255 })
  sessionId: string;

  @Column("mediumtext", { name: "data", nullable: true })
  data: string | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;
}
