// src/resolvers/UserResolver.ts
import {
  Resolver, Query, Mutation, Arg, Args,
  Field, ArgsType, ID, Authorized, InputType } from "type-graphql"
import { AdminProject } from "../entities/AdminProjects"
import {
  updateEntity, fuzzyFetch,
  PaginationAndFilter, fuzzyCount } from "../helpers/entityResolverHelpers"
import { listMeta } from "../helpers/listMeta"

@ArgsType()
class createAdminProject implements Partial<AdminProject>{
  @Field()
  name: string

  @Field()
  landingPageSlug: string

  @Field()
  projectCardDescription: string

  @Field()
  projectCardImageUrl: string

  @Field()
  landingPageContent: string

  @Field()
  public: boolean
}

@ArgsType()
class updateAdminProject extends createAdminProject{
  @Field(type => ID)
  id: number
}

@InputType()
class ProjectFilter implements Partial<AdminProject>{
  @Field(type => String)
  name?: string;
}

@ArgsType()
class ProjectSearch extends PaginationAndFilter {
  @Field(type => ProjectFilter)
  filter?: ProjectFilter
}

@Resolver()
export class AdminProjectResolver {
  @Authorized()
  @Query(() => [AdminProject])
  async allAdminProjects(@Args() searchParams:ProjectSearch) {
    return await fuzzyFetch<AdminProject>(AdminProject, 'adminProject', searchParams);
  }

  @Authorized()
  @Query(() => listMeta)
  async _allAdminProjectsMeta(@Args() searchParams:ProjectSearch){
    const count = await fuzzyCount<AdminProject>(AdminProject, 'adminProject', searchParams);
    return {count}
  }


  @Query(type => AdminProject)
  AdminProject(@Arg("id") id: string): Promise<AdminProject|undefined> {
    return AdminProject.findOne({
      where: { id },
      relations: ["users"]
    });
  }

  @Mutation(type => AdminProject)
  async deleteAdminProject(@Arg("id") id: string): Promise<AdminProject> {
    const project = await AdminProject.findOne({ where: { id } });
    if (!project) throw new Error("AdminProject not found!");
    await project.remove();
    return project;
  }

  @Mutation(type => AdminProject)
  async createAdminProject(
    @Args()
    params: createAdminProject) {
    return updateEntity<AdminProject>(AdminProject, params)
  }

  @Mutation(() => AdminProject)
  async updateAdminProject(
    @Args()
    params: updateAdminProject) {
    return updateEntity<AdminProject>(AdminProject, params)
  }
}
