import { Column, Entity, PrimaryGeneratedColumn } from "typeorm";

@Entity("imports", { schema: "portal_development" })
export class Imports {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "job_id", nullable: true })
  jobId: number | null;

  @Column("datetime", { name: "job_finished_at", nullable: true })
  jobFinishedAt: Date | null;

  @Column("int", { name: "import_type", nullable: true })
  importType: number | null;

  @Column("int", { name: "progress", nullable: true })
  progress: number | null;

  @Column("int", { name: "total_imports", nullable: true })
  totalImports: number | null;

  @Column("int", { name: "user_id", nullable: true })
  userId: number | null;

  @Column("longtext", { name: "upload_data", nullable: true })
  uploadData: string | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("longtext", { name: "import_data", nullable: true })
  importData: string | null;
}
