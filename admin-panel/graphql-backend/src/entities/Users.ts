import { Column, Entity, Index, PrimaryGeneratedColumn, BaseEntity, ManyToMany, JoinTable } from "typeorm";
import { ObjectType, Field, ID} from "type-graphql";
import { AdminProject } from "./AdminProjects";

@Index("index_users_on_confirmation_token", ["confirmationToken"], {
  unique: true,
})
@Index("index_users_on_login", ["login"], { unique: true })
@Index("index_users_on_id_and_type", ["id"], {})
@Entity("users", { schema: "portal_development" })
@ObjectType()
export class User extends BaseEntity {
  @Field(() => ID, {nullable: false})
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Field(() => String)
  @Column("varchar", {
    name: "login",
    nullable: true,
    unique: true,
    length: 40,
  })
  login: string;

  @Field(() => AdminProject)
  @ManyToMany(type => AdminProject, {cascade: true})
  @JoinTable({
      name: "admin_project_users", // table name for the junction table of this relation
      joinColumn: {
          name: "user_id",
          referencedColumnName: "id"
      },
      inverseJoinColumn: {
          name: "project_id",
          referencedColumnName: "id"
      }
  })
  projects: AdminProject[]

  @Field(() => String)
  @Column("varchar", { name: "first_name", nullable: true, length: 100 })
  firstName: string | null;

  @Field(() => String)
  @Column("varchar", { name: "last_name", nullable: true, length: 100 })
  lastName: string | null;

  @Field(() => String)
  @Column("varchar", { name: "email", length: 128 })
  email: string;

  @Field(() => String)
  @Column("varchar", { name: "encrypted_password", length: 128 })
  encryptedPassword: string;

  @Column("varchar", { name: "password_salt", length: 255 })
  passwordSalt: string;

  @Column("varchar", { name: "remember_token", nullable: true, length: 255 })
  rememberToken: string | null;

  @Column("varchar", {
    name: "confirmation_token",
    nullable: true,
    unique: true,
    length: 255,
  })
  confirmationToken: string | null;

  @Column("varchar", { name: "state", length: 255, default: () => "'passive'" })
  state: string;

  @Column("datetime", { name: "remember_created_at", nullable: true })
  rememberCreatedAt: Date | null;

  @Column("datetime", { name: "confirmed_at", nullable: true })
  confirmedAt: Date | null;

  @Column("datetime", { name: "deleted_at", nullable: true })
  deletedAt: Date | null;

  @Column("varchar", { name: "uuid", nullable: true, length: 36 })
  uuid: string | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("tinyint", {
    name: "default_user",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  defaultUser: boolean | null;

  @Column("tinyint", {
    name: "site_admin",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  siteAdmin: boolean | null;

  @Column("varchar", { name: "external_id", nullable: true, length: 255 })
  externalId: string | null;

  @Column("tinyint", {
    name: "require_password_reset",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  requirePasswordReset: boolean | null;

  @Column("tinyint", {
    name: "of_consenting_age",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  ofConsentingAge: boolean | null;

  @Column("tinyint", {
    name: "have_consent",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  haveConsent: boolean | null;

  @Column("tinyint", {
    name: "asked_age",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  askedAge: boolean | null;

  @Column("varchar", {
    name: "reset_password_token",
    nullable: true,
    length: 255,
  })
  resetPasswordToken: string | null;

  @Column("int", {
    name: "sign_in_count",
    nullable: true,
    default: () => "'0'",
  })
  signInCount: number | null;

  @Column("datetime", { name: "current_sign_in_at", nullable: true })
  currentSignInAt: Date | null;

  @Column("datetime", { name: "last_sign_in_at", nullable: true })
  lastSignInAt: Date | null;

  @Column("varchar", {
    name: "current_sign_in_ip",
    nullable: true,
    length: 255,
  })
  currentSignInIp: string | null;

  @Column("varchar", { name: "last_sign_in_ip", nullable: true, length: 255 })
  lastSignInIp: string | null;

  @Column("varchar", { name: "unconfirmed_email", nullable: true, length: 255 })
  unconfirmedEmail: string | null;

  @Column("datetime", { name: "confirmation_sent_at", nullable: true })
  confirmationSentAt: Date | null;

  @Column("tinyint", {
    name: "require_portal_user_type",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  requirePortalUserType: boolean | null;

  @Column("varchar", { name: "sign_up_path", nullable: true, length: 255 })
  signUpPath: string | null;

  @Column("tinyint", {
    name: "email_subscribed",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  emailSubscribed: boolean | null;
}
