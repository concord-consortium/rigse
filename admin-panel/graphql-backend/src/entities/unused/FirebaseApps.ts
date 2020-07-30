import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("index_firebase_apps_on_name", ["name"], {})
@Entity("firebase_apps", { schema: "portal_development" })
export class FirebaseApps {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("varchar", { name: "name", nullable: true, length: 255 })
  name: string | null;

  @Column("varchar", { name: "client_email", nullable: true, length: 255 })
  clientEmail: string | null;

  @Column("text", { name: "private_key", nullable: true })
  privateKey: string | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;
}
