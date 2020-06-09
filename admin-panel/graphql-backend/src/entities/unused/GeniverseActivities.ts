import { Column, Entity, PrimaryGeneratedColumn } from "typeorm";

@Entity("geniverse_activities", { schema: "portal_development" })
export class GeniverseActivities {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("mediumtext", { name: "initial_alleles", nullable: true })
  initialAlleles: string | null;

  @Column("varchar", { name: "base_channel_name", nullable: true, length: 255 })
  baseChannelName: string | null;

  @Column("int", { name: "max_users_in_room", nullable: true })
  maxUsersInRoom: number | null;

  @Column("tinyint", { name: "send_bred_dragons", nullable: true, width: 1 })
  sendBredDragons: boolean | null;

  @Column("datetime", { name: "created_at", nullable: true })
  createdAt: Date | null;

  @Column("datetime", { name: "updated_at", nullable: true })
  updatedAt: Date | null;

  @Column("varchar", { name: "title", nullable: true, length: 255 })
  title: string | null;

  @Column("varchar", { name: "hidden_genes", nullable: true, length: 255 })
  hiddenGenes: string | null;

  @Column("mediumtext", { name: "static_genes", nullable: true })
  staticGenes: string | null;

  @Column("tinyint", {
    name: "crossover_when_breeding",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  crossoverWhenBreeding: boolean | null;

  @Column("varchar", { name: "route", nullable: true, length: 255 })
  route: string | null;

  @Column("varchar", { name: "pageType", nullable: true, length: 255 })
  pageType: string | null;

  @Column("mediumtext", { name: "message", nullable: true })
  message: string | null;

  @Column("mediumtext", { name: "match_dragon_alleles", nullable: true })
  matchDragonAlleles: string | null;

  @Column("int", { name: "myCase_id", nullable: true })
  myCaseId: number | null;

  @Column("int", { name: "myCaseOrder", nullable: true })
  myCaseOrder: number | null;

  @Column("tinyint", {
    name: "is_argumentation_challenge",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  isArgumentationChallenge: boolean | null;

  @Column("int", { name: "threshold_three_stars", nullable: true })
  thresholdThreeStars: number | null;

  @Column("int", { name: "threshold_two_stars", nullable: true })
  thresholdTwoStars: number | null;

  @Column("tinyint", { name: "show_color_labels", nullable: true, width: 1 })
  showColorLabels: boolean | null;

  @Column("mediumtext", { name: "congratulations", nullable: true })
  congratulations: string | null;

  @Column("tinyint", {
    name: "show_tooltips",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  showTooltips: boolean | null;
}
