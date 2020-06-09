// src/resolvers/UserResolver.ts


// import { Resolver, Query, Mutation, Arg, Args, ObjectType, Field, FieldResolver, Root, ID } from "type-graphql"
import {
  ArgsType, ID,
  Resolver, Query, Mutation, Arg,
  Args, ObjectType, Field, Authorized, AuthChecker
} from "type-graphql"

import { User } from "../entities/Users"
import { AdminProject } from "../entities/AdminProjects"
import { request } from "express"

@ArgsType()
class CreateUser implements Partial<User>{
  @Field()
  firstName: string

  @Field()
  lastName: string

  @Field()
  email: string

  @Field()
  login: string

  @Field( Type => [ID])
  projectsIds: string[]
}

@ArgsType()
class GenericPaginationAndFilter {
  // @Field()
  // filter: any

  @Field({defaultValue: 1})
  page: number

  @Field({defaultValue: 10})
  perPage: number

  @Field()
  sortField: string

  @Field()
  sortOrder: "ASC" | "DESC"
}


@ArgsType()
class UpdateUser extends CreateUser{
  @Field()
  id: number
}

@ObjectType()
class userListMeta {
  @Field(() => Number)
  count: number
}


@Resolver(of => User)
export class UserResolver {

  @Authorized()
  @Query(() => [User])
  allUsers(@Args() {page, perPage, sortField}:GenericPaginationAndFilter) {
    return User.find(
      {
        take: perPage,
        skip: (page - 1)  * perPage,
        relations: ["projects"],
      }
    )
  }

  @Authorized()
  @Query(() => userListMeta)
  _allUsersMeta(@Args() {page, perPage}:GenericPaginationAndFilter){
    return {count: User.count()}
  }

  @Authorized()
  @Query(() => User)
  User(@Arg("id") id: string) {
    return User.findOne({ where: { id }, relations: ["projects"]});
  }

  @Authorized()
  @Mutation(() => Boolean)
  async deleteUser(@Arg("id") id: string) {
    const user = await User.findOne({ where: { id } });
    if (!user) throw new Error("User not found!");
    await user.remove();
    return true;
  }

  @Authorized()
  @Mutation(() => User)
  async createUser(
    @Args()
    {firstName, lastName, email, projectsIds }: CreateUser)
    {
      const params = {firstName, lastName, email}
      const user = User.create(params);
      await user.save();
      return user;
  }

  @Authorized()
  @Mutation(() => User)
  async updateUser(
    @Args()
    {id, firstName, lastName, email, projectsIds }: UpdateUser)
    {
      const params = {firstName, lastName, email }
      const user = await User.findOne({ where: { id } });
      if (!user) throw new Error("User not found!");
      Object.assign(user, params);
      user.projects = await AdminProject.findByIds(projectsIds)
      await user.save();
      return user;
  }

}
