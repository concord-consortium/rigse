import { Column, Entity, PrimaryGeneratedColumn } from "typeorm";

@Entity("import_duplicate_users", { schema: "portal_development" })
export class ImportDuplicateUsers {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("varchar", { name: "login", nullable: true, length: 255 })
  login: string | null;

  @Column("varchar", { name: "email", nullable: true, length: 255 })
  email: string | null;

  @Column("int", { name: "duplicate_by", nullable: true })
  duplicateBy: number | null;

  @Column("mediumtext", { name: "data", nullable: true })
  data: string | null;

  @Column("int", { name: "user_id", nullable: true })
  userId: number | null;

  @Column("int", { name: "import_id", nullable: true })
  importId: number | null;
}
