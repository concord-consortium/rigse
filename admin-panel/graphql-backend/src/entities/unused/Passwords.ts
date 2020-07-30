import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("index_passwords_on_user_id", ["userId"], {})
@Entity("passwords", { schema: "portal_development" })
export class Passwords {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "user_id", nullable: true })
  userId: number | null;

  @Column("varchar", { name: "reset_code", nullable: true, length: 255 })
  resetCode: string | null;

  @Column("datetime", { name: "expiration_date", nullable: true })
  expirationDate: Date | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;
}
