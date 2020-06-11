// src/resolvers/UserResolver.ts
import { Resolver, Query, Mutation, Arg, ObjectType, Field } from "type-graphql"
import { AdminProject } from "../entities/AdminProjects"

@ObjectType()
class adminProjectListMeta {
  @Field(() => Number)
  count: number
}

@Resolver()
export class AdminProjectResolver {
  @Query(type => [AdminProject])
  allAdminProjects():  Promise<AdminProject[]> {
    return AdminProject.find({
      relations: ["users"]
    })
  }

  @Query(type => adminProjectListMeta)
  _allAdminProjectsMeta(): adminProjectListMeta{
    return {count: 2}
  }

  @Query(type => AdminProject)
  AdminProject(@Arg("id") id: string): Promise<AdminProject|undefined> {
    return AdminProject.findOne({
      where: { id },
      relations: ["users"]
    });
  }

  @Mutation(type => Boolean)
  async deleteAdminProject(@Arg("id") id: string): Promise<boolean> {
    const project = await AdminProject.findOne({ where: { id } });
    if (!project) throw new Error("AdminProject not found!");
    await project.remove();
    return true;
  }

  @Mutation(type => AdminProject)
  async createAdminProject(
    @Arg("name") name: string,
    @Arg("landingPageSlug") landingPageSlug: string,
    @Arg("public") isPublic: boolean=false,
    @Arg("projectCardDescription") projectCardDescription?: string,
    @Arg("projectCardImageUrl") projectCardImageUrl?: string
  ): Promise<AdminProject> {
    const createdAt = new Date()
    const updatedAt = new Date()
    const params = {
      name, landingPageSlug, projectCardDescription, projectCardImageUrl,
      public: isPublic, createdAt, updatedAt
    }
    const project = await AdminProject.create(params);
    return project;
  }

  @Mutation(() => AdminProject)
  async updateAdminProject(
      @Arg("id") id: string,
      @Arg("name") name: string,
      @Arg("landingPageSlug") landingPageSlug: string,
      @Arg("public", {nullable: true}) isPublic: boolean=false,
      @Arg("projectCardDescription", {nullable: true}) projectCardDescription?: string,
      @Arg("projectCardImageUrl", {nullable: true}) projectCardImageUrl?: string,
      @Arg("landingPageContent", {nullable: true}) landingPageContent?: string
    ): Promise<AdminProject> {
      const params = {
        name,
        landingPageSlug,
        landingPageContent,
        projectCardDescription,
        projectCardImageUrl,
        public: isPublic
      }
      const project = await AdminProject.findOne({ where: { id } });
      if (!project) throw new Error("Project not found!");
      Object.assign(project, params);
      await project.save();
      return project;
  }
}
