import { Column, Entity, PrimaryGeneratedColumn } from "typeorm";

@Entity("dataservice_console_loggers", { schema: "portal_development" })
export class DataserviceConsoleLoggers {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;
}
