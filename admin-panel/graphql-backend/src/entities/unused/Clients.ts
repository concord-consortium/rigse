import { Column, Entity, PrimaryGeneratedColumn } from "typeorm";

@Entity("clients", { schema: "portal_development" })
export class Clients {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("varchar", { name: "name", nullable: true, length: 255 })
  name: string | null;

  @Column("varchar", { name: "app_id", nullable: true, length: 255 })
  appId: string | null;

  @Column("varchar", { name: "app_secret", nullable: true, length: 255 })
  appSecret: string | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("varchar", { name: "site_url", nullable: true, length: 255 })
  siteUrl: string | null;

  @Column("varchar", { name: "domain_matchers", nullable: true, length: 255 })
  domainMatchers: string | null;

  @Column("varchar", {
    name: "client_type",
    nullable: true,
    length: 255,
    default: () => "'confidential'",
  })
  clientType: string | null;

  @Column("text", { name: "redirect_uris", nullable: true })
  redirectUris: string | null;
}
