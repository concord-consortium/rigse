// src/resolvers/UserResolver.ts
import { Resolver, Query, Mutation, Arg, Args, ObjectType, Field, ArgsType, ID} from "type-graphql"
import { AdminProject } from "../entities/AdminProjects"
import { updateEntity } from "../helpers/entityResolverHelpers"

@ObjectType()
class adminProjectListMeta {
  @Field(() => Number)
  count: number
}

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
    params: createAdminProject) {
    return updateEntity<AdminProject>(AdminProject, params)
  }
}
