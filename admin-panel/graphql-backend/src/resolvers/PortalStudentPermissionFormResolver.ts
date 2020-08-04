
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


  @Mutation(() => PortalStudentPermissionForm)
  async updatePortalStudentPermissionForm(
  @Args() args: UpdatePortalStudentPermissionFormArgs) {
    const {id, ...params} = args;
    const studentPermissionForm = await PortalStudentPermissionForm.findOne({ where: { id }});
    if (!studentPermissionForm) throw new Error("ProjectUser not found!");
    Object.assign(studentPermissionForm, params);
    await studentPermissionForm.save();
    return studentPermissionForm;
  }

  @Mutation(() => PortalStudentPermissionForm)
  async createPortalStudentPermissionForm(
  @Args() args: CreatePortalStudentPermissionFormArgs) {
    const createdAt = new Date()
    const updatedAt = new Date()
    const params = {...args, createdAt, updatedAt};
    const studentPermissionForm = PortalStudentPermissionForm.create(params);
    await studentPermissionForm.save();
    return studentPermissionForm;
  }

  @Mutation(() => PortalStudentPermissionForm)
  async deletePortalStudentPermissionForm(@Arg("id") id: string) {
    const studentPermissionForm = await PortalStudentPermissionForm.findOne({ where: { id } });
    // For reasons I don't understand, we need to send a complete object back
    // GraphQL was failing when we sent back a studentPermissionForm without an id...
    const deletedProxy = Object.assign({}, studentPermissionForm)
    if (!studentPermissionForm) throw new Error("PortalStudentPermissionForm not found!");
    await studentPermissionForm.remove();
    return deletedProxy;
  }

}
