import { Column, Entity, PrimaryGeneratedColumn } from "typeorm";

@Entity("dataservice_console_contents", { schema: "portal_development" })
export class DataserviceConsoleContents {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "console_logger_id", nullable: true })
  consoleLoggerId: number | null;

  @Column("int", { name: "position", nullable: true })
  position: number | null;

  @Column("mediumtext", { name: "body", nullable: true })
  body: string | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;
}
