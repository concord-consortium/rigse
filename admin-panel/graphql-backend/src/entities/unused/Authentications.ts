import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("index_authentications_on_user_id", ["userId"], {})
@Entity("authentications", { schema: "portal_development" })
export class Authentications {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "user_id", nullable: true })
  userId: number | null;

  @Column("varchar", { name: "provider", nullable: true, length: 255 })
  provider: string | null;

  @Column("varchar", { name: "uid", nullable: true, length: 255 })
  uid: string | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;
}
