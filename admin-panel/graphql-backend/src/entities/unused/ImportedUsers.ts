import { Column, Entity, PrimaryGeneratedColumn } from "typeorm";

@Entity("imported_users", { schema: "portal_development" })
export class ImportedUsers {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("varchar", { name: "user_url", nullable: true, length: 255 })
  userUrl: string | null;

  @Column("tinyint", { name: "is_verified", nullable: true, width: 1 })
  isVerified: boolean | null;

  @Column("int", { name: "user_id", nullable: true })
  userId: number | null;

  @Column("varchar", { name: "importing_domain", nullable: true, length: 255 })
  importingDomain: string | null;

  @Column("int", { name: "import_id", nullable: true })
  importId: number | null;
}
