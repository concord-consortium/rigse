
import { Resolver, Query, Mutation, Arg, Args, ObjectType, Field,
         FieldResolver, Root, ArgsType, InputType, ID, Int } from "type-graphql"
import { AdminProjectUser } from "../entities/AdminProjectUsers"
import { listMeta } from "../helpers/listMeta"

@ArgsType()
class UpdateAdminProjectUserArgs implements Partial<AdminProjectUser>{
  @Field(type => ID)
  id: number;

  @Field(type => Boolean)
  isAdmin?: boolean=false;

  @Field(type => Boolean)
  isResearcher?: boolean=false;
}

@ArgsType()
class CreateAdminProjectUserArgs implements Partial<AdminProjectUser>{
  @Field(type => ID)
  userId: number;

  @Field(type => ID)
  projectId: number;

  @Field(type => Boolean)
  isAdmin?: boolean=false;

  @Field(type => Boolean)
  isResearcher?: boolean=false;
}

@ArgsType()
class PageSortQueryArgs {
  @Field(type => Int)
  page: number;

  @Field(type => Int)
  perPage: number;

  @Field()
  sortField: string;

  @Field()
  sortOrder: string;
}

@InputType()
class AdminProjectUserFilter {
  @Field(type => ID)
  userId?: string;
}

@ArgsType()
class AdminProjectUserQueryArgs extends PageSortQueryArgs {
  @Field(type => AdminProjectUserFilter)
  filter: AdminProjectUserFilter;
}

@Resolver(of => AdminProjectUser)
export class AdminProjectUserResolver {

  @Query(() => [AdminProjectUser])
  allAdminProjectUsers(
    @Args() {filter, page, perPage, sortField, sortOrder}:AdminProjectUserQueryArgs) {
    // FIXME: Including the project relation here is kind of inefficient
    // hopefully typeorm uses n+1 optimization, but it still means extra objects
    // are being loaded when all we care about might just be the id
    // ideally we could inject the ids into the response without loading the full relation
    // And even better we would look to see if just the id was requested and then
    // avoid the full request for the project. More generally this would mean
    // looking at the shape of the requested data to determine
    // how much of the tree we want to include in the result

    const relations = ["project"];
    let where = {}
    if(filter && filter.userId) {
      // It seems typeORM automatically converts the string userId to
      // the expected integer
      where = { userId: filter.userId }
    }

    return AdminProjectUser.find({where, relations})
  }

  @Query(() => listMeta)
  _allAdminProjectUsersMeta(
    @Args() {filter, page, perPage, sortField, sortOrder}:AdminProjectUserQueryArgs) {
      const where = filter
      const count = AdminProjectUser.count({where})
    return {count: count}
  }

  @Query(() => AdminProjectUser)
  AdminProjectUser(@Arg("id") id: string) {
    // Since this is a query for a single AdminProject it makes sense to include
    // the relations I'd think
    return AdminProjectUser.findOne({ where: { id }, relations: ["project"] });
  }


  // To keep the api simple we don't allow modification of the projectId or userId
  // a user will need to delete the item and make a new one

  // TODO only allow project admins to:
  //  - edit ProjectUsers that have a project they are an admin of
  @Mutation(() => AdminProjectUser)
  async updateAdminProjectUser(
      @Args() args: UpdateAdminProjectUserArgs) {
      const {id, ...params} = args;
      // NOTE: the relations: ["project"] is added so the returned projectUser
      // has a project field, otherwise typegraphql sends down a project: null
      // field. It does have a projectId: [id] field which is correct, but the
      // project: null is confusing
      // It'd be better if this field was not sent down if it was null or undefined
      // there might be a way to configure it that way.  If that is the case we
      // wouldn't need to include the project every time. For this model is probably
      // is a big problem, but this will probably be a pattern we need to establish
      const projectUser = await AdminProjectUser.findOne({ where: { id }, relations: ["project"] });
      if (!projectUser) throw new Error("ProjectUser not found!");
      Object.assign(projectUser, params);
      await projectUser.save();
      return projectUser;
  }

  @Mutation(() => AdminProjectUser)
  async createAdminProjectUser(
    @Args() args: CreateAdminProjectUserArgs) {
      const createdAt = new Date()
      const updatedAt = new Date()
      // const params = {userId: parseInt(userId), projectId: parseInt(projectId),
      const params = {...args, createdAt, updatedAt};
      const projectUser = AdminProjectUser.create(params);
      await projectUser.save();
      return projectUser;
  }

  @Mutation(() => AdminProjectUser)
  async deleteAdminProjectUser(@Arg("id") id: string) {
    const projectUser = await AdminProjectUser.findOne({ where: { id } });
    if (!projectUser) throw new Error("AdminProjectUser not found!");
    await projectUser.remove();
    return projectUser;
  }

}
