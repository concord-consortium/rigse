import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("index_portal_nces06_districts_on_LEAID", ["leaid"], {})
@Index("index_portal_nces06_districts_on_NAME", ["name"], {})
@Index("index_portal_nces06_districts_on_STID", ["stid"], {})
@Entity("portal_nces06_districts", { schema: "portal_development" })
export class PortalNces06Districts {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("varchar", { name: "LEAID", nullable: true, length: 7 })
  leaid: string | null;

  @Column("varchar", { name: "FIPST", nullable: true, length: 2 })
  fipst: string | null;

  @Column("varchar", { name: "STID", nullable: true, length: 14 })
  stid: string | null;

  @Column("varchar", { name: "NAME", nullable: true, length: 60 })
  name: string | null;

  @Column("varchar", { name: "PHONE", nullable: true, length: 10 })
  phone: string | null;

  @Column("varchar", { name: "MSTREE", nullable: true, length: 30 })
  mstree: string | null;

  @Column("varchar", { name: "MCITY", nullable: true, length: 30 })
  mcity: string | null;

  @Column("varchar", { name: "MSTATE", nullable: true, length: 2 })
  mstate: string | null;

  @Column("varchar", { name: "MZIP", nullable: true, length: 5 })
  mzip: string | null;

  @Column("varchar", { name: "MZIP4", nullable: true, length: 4 })
  mzip4: string | null;

  @Column("varchar", { name: "LSTREE", nullable: true, length: 30 })
  lstree: string | null;

  @Column("varchar", { name: "LCITY", nullable: true, length: 30 })
  lcity: string | null;

  @Column("varchar", { name: "LSTATE", nullable: true, length: 2 })
  lstate: string | null;

  @Column("varchar", { name: "LZIP", nullable: true, length: 5 })
  lzip: string | null;

  @Column("varchar", { name: "LZIP4", nullable: true, length: 4 })
  lzip4: string | null;

  @Column("varchar", { name: "KIND", nullable: true, length: 1 })
  kind: string | null;

  @Column("varchar", { name: "UNION", nullable: true, length: 3 })
  union: string | null;

  @Column("varchar", { name: "CONUM", nullable: true, length: 5 })
  conum: string | null;

  @Column("varchar", { name: "CONAME", nullable: true, length: 30 })
  coname: string | null;

  @Column("varchar", { name: "CSA", nullable: true, length: 3 })
  csa: string | null;

  @Column("varchar", { name: "CBSA", nullable: true, length: 5 })
  cbsa: string | null;

  @Column("varchar", { name: "METMIC", nullable: true, length: 1 })
  metmic: string | null;

  @Column("varchar", { name: "MSC", nullable: true, length: 1 })
  msc: string | null;

  @Column("varchar", { name: "ULOCAL", nullable: true, length: 2 })
  ulocal: string | null;

  @Column("varchar", { name: "CDCODE", nullable: true, length: 4 })
  cdcode: string | null;

  @Column("float", { name: "LATCOD", nullable: true, precision: 12 })
  latcod: number | null;

  @Column("float", { name: "LONCOD", nullable: true, precision: 12 })
  loncod: number | null;

  @Column("varchar", { name: "BOUND", nullable: true, length: 1 })
  bound: string | null;

  @Column("varchar", { name: "GSLO", nullable: true, length: 2 })
  gslo: string | null;

  @Column("varchar", { name: "GSHI", nullable: true, length: 2 })
  gshi: string | null;

  @Column("varchar", { name: "AGCHRT", nullable: true, length: 1 })
  agchrt: string | null;

  @Column("int", { name: "SCH", nullable: true })
  sch: number | null;

  @Column("float", { name: "TEACH", nullable: true, precision: 12 })
  teach: number | null;

  @Column("int", { name: "UG", nullable: true })
  ug: number | null;

  @Column("int", { name: "PK12", nullable: true })
  pk12: number | null;

  @Column("int", { name: "MEMBER", nullable: true })
  member: number | null;

  @Column("int", { name: "MIGRNT", nullable: true })
  migrnt: number | null;

  @Column("int", { name: "SPECED", nullable: true })
  speced: number | null;

  @Column("int", { name: "ELL", nullable: true })
  ell: number | null;

  @Column("float", { name: "PKTCH", nullable: true, precision: 12 })
  pktch: number | null;

  @Column("float", { name: "KGTCH", nullable: true, precision: 12 })
  kgtch: number | null;

  @Column("float", { name: "ELMTCH", nullable: true, precision: 12 })
  elmtch: number | null;

  @Column("float", { name: "SECTCH", nullable: true, precision: 12 })
  sectch: number | null;

  @Column("float", { name: "UGTCH", nullable: true, precision: 12 })
  ugtch: number | null;

  @Column("float", { name: "TOTTCH", nullable: true, precision: 12 })
  tottch: number | null;

  @Column("float", { name: "AIDES", nullable: true, precision: 12 })
  aides: number | null;

  @Column("float", { name: "CORSUP", nullable: true, precision: 12 })
  corsup: number | null;

  @Column("float", { name: "ELMGUI", nullable: true, precision: 12 })
  elmgui: number | null;

  @Column("float", { name: "SECGUI", nullable: true, precision: 12 })
  secgui: number | null;

  @Column("float", { name: "TOTGUI", nullable: true, precision: 12 })
  totgui: number | null;

  @Column("float", { name: "LIBSPE", nullable: true, precision: 12 })
  libspe: number | null;

  @Column("float", { name: "LIBSUP", nullable: true, precision: 12 })
  libsup: number | null;

  @Column("float", { name: "LEAADM", nullable: true, precision: 12 })
  leaadm: number | null;

  @Column("float", { name: "LEASUP", nullable: true, precision: 12 })
  leasup: number | null;

  @Column("float", { name: "SCHADM", nullable: true, precision: 12 })
  schadm: number | null;

  @Column("float", { name: "SCHSUP", nullable: true, precision: 12 })
  schsup: number | null;

  @Column("float", { name: "STUSUP", nullable: true, precision: 12 })
  stusup: number | null;

  @Column("float", { name: "OTHSUP", nullable: true, precision: 12 })
  othsup: number | null;

  @Column("varchar", { name: "IGSLO", nullable: true, length: 1 })
  igslo: string | null;

  @Column("varchar", { name: "IGSHI", nullable: true, length: 1 })
  igshi: string | null;

  @Column("varchar", { name: "ISCH", nullable: true, length: 1 })
  isch: string | null;

  @Column("varchar", { name: "ITEACH", nullable: true, length: 1 })
  iteach: string | null;

  @Column("varchar", { name: "IUG", nullable: true, length: 1 })
  iug: string | null;

  @Column("varchar", { name: "IPK12", nullable: true, length: 1 })
  ipk12: string | null;

  @Column("varchar", { name: "IMEMB", nullable: true, length: 1 })
  imemb: string | null;

  @Column("varchar", { name: "IMIGRN", nullable: true, length: 1 })
  imigrn: string | null;

  @Column("varchar", { name: "ISPEC", nullable: true, length: 1 })
  ispec: string | null;

  @Column("varchar", { name: "IELL", nullable: true, length: 1 })
  iell: string | null;

  @Column("varchar", { name: "IPKTCH", nullable: true, length: 1 })
  ipktch: string | null;

  @Column("varchar", { name: "IKGTCH", nullable: true, length: 1 })
  ikgtch: string | null;

  @Column("varchar", { name: "IELTCH", nullable: true, length: 1 })
  ieltch: string | null;

  @Column("varchar", { name: "ISETCH", nullable: true, length: 1 })
  isetch: string | null;

  @Column("varchar", { name: "IUGTCH", nullable: true, length: 1 })
  iugtch: string | null;

  @Column("varchar", { name: "ITOTCH", nullable: true, length: 1 })
  itotch: string | null;

  @Column("varchar", { name: "IAIDES", nullable: true, length: 1 })
  iaides: string | null;

  @Column("varchar", { name: "ICOSUP", nullable: true, length: 1 })
  icosup: string | null;

  @Column("varchar", { name: "IELGUI", nullable: true, length: 1 })
  ielgui: string | null;

  @Column("varchar", { name: "ISEGUI", nullable: true, length: 1 })
  isegui: string | null;

  @Column("varchar", { name: "ITOGUI", nullable: true, length: 1 })
  itogui: string | null;

  @Column("varchar", { name: "ILISPE", nullable: true, length: 1 })
  ilispe: string | null;

  @Column("varchar", { name: "ILISUP", nullable: true, length: 1 })
  ilisup: string | null;

  @Column("varchar", { name: "ILEADM", nullable: true, length: 1 })
  ileadm: string | null;

  @Column("varchar", { name: "ILESUP", nullable: true, length: 1 })
  ilesup: string | null;

  @Column("varchar", { name: "ISCADM", nullable: true, length: 1 })
  iscadm: string | null;

  @Column("varchar", { name: "ISCSUP", nullable: true, length: 1 })
  iscsup: string | null;

  @Column("varchar", { name: "ISTSUP", nullable: true, length: 1 })
  istsup: string | null;

  @Column("varchar", { name: "IOTSUP", nullable: true, length: 1 })
  iotsup: string | null;
}
