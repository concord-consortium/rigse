
import { Resolver, Query, Mutation, Arg, Args, ObjectType, Field,
  FieldResolver, Root, ArgsType, InputType, ID, Int } from "type-graphql"
import { PortalStudentPermissionForm } from "../entities/PortalStudentPermissionForms"
import { listMeta } from "../helpers/listMeta"

@ArgsType()
class UpdatePortalStudentPermissionFormArgs implements Partial<PortalStudentPermissionForm>{
  @Field(type => ID)
  id: number;

  @Field(type => Boolean)
  signed?: boolean=false;
}

@ArgsType()
class CreatePortalStudentPermissionFormArgs implements Partial<PortalStudentPermissionForm>{
  @Field(type => ID)
  portalStudentId: number;

  @Field(type => ID)
  portalPermissionFormId: number;

  @Field(type => Boolean)
  signed?: boolean=false;
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
class PortalStudentPermissionFormFilter {
  @Field(type => [ID])
  ids?: number[];

  @Field(type => ID)
  id?: string;

  @Field(type => ID)
  studentId?: string;

  @Field(type => ID)
  portalPermissionFormId?: string;
}

@ArgsType()
class PortalStudentPermissionFormQueryArgs extends PageSortQueryArgs {
  @Field(type => PortalStudentPermissionFormFilter)
  filter: PortalStudentPermissionFormFilter;
}

@Resolver(of => PortalStudentPermissionForm)
export class PortalStudentPermissionFormResolver {

  @Query(() => [PortalStudentPermissionForm])
  allPortalStudentPermissionForms(
    @Args() {filter, page, perPage, sortField, sortOrder}:PortalStudentPermissionFormQueryArgs) {
    let where = {}
    if(filter && filter.portalPermissionFormId) {
      // It seems typeORM automatically converts the string userId to
      // the expected integer
      where = { portalPermissionFormId: filter.portalPermissionFormId }
    }
    return PortalStudentPermissionForm.find({where})
  }

  @Query(() => listMeta)
  _allPortalStudentPermissionFormsMeta(
    @Args() {filter, page, perPage, sortField, sortOrder}:PortalStudentPermissionFormQueryArgs) {
    const where = filter
    const count = PortalStudentPermissionForm.count({where})
    return {count: count}
  }

  @Query(() => PortalStudentPermissionForm)
  PortalStudentPermissionForm(@Arg("id") id: string) {
    return PortalStudentPermissionForm.findOne({
      where: { id },
      relations: ["student"]
    });
  }

  // To keep the api simple we don't allow modification of the projectId or userId
  // a user will need to delete the item and make a new one

  // TODO only allow project admins to:
  //  - edit ProjectUsers that have a project they are an admin of
  @Mutation(() => PortalStudentPermissionForm)
  async updatePortalStudentPermissionForm(
  @Args() args: UpdatePortalStudentPermissionFormArgs) {
    const {id, ...params} = args;
    // NOTE: the relations: ["project"] is added so the returned projectUser
    // has a project field, otherwise typegraphql sends down a project: null
    // field. It does have a projectId: [id] field which is correct, but the
    // project: null is confusing
    // It'd be better if this field was not sent down if it was null or undefined
    // there might be a way to configure it that way.  If that is the case we
    // wouldn't need to include the project every time. For this model is probably
    // is a big problem, but this will probably be a pattern we need to establish
    const projectUser = await PortalStudentPermissionForm.findOne({ where: { id }});
    if (!projectUser) throw new Error("ProjectUser not found!");
    Object.assign(projectUser, params);
    await projectUser.save();
    return projectUser;
  }

  @Mutation(() => PortalStudentPermissionForm)
  async createPortalStudentPermissionForm(
  @Args() args: CreatePortalStudentPermissionFormArgs) {
    const createdAt = new Date()
    const updatedAt = new Date()
    // const params = {userId: parseInt(userId), projectId: parseInt(projectId),
    const params = {...args, createdAt, updatedAt};
    const projectUser = PortalStudentPermissionForm.create(params);
    await projectUser.save();
    return projectUser;
  }

  @Mutation(() => PortalStudentPermissionForm)
  async deletePortalStudentPermissionForm(@Arg("id") id: string) {
    const projectUser = await PortalStudentPermissionForm.findOne({ where: { id } });
    if (!projectUser) throw new Error("PortalStudentPermissionForm not found!");
    await projectUser.remove();
    return projectUser;
  }

}
