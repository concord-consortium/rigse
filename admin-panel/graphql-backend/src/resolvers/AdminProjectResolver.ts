// src/resolvers/UserResolver.ts

import {
  Resolver, Query, Mutation, Arg, ObjectType, Field,
  createParamDecorator
} from "type-graphql"
import { validate } from "class-validator"
import { AdminProject } from "../entities/AdminProjects"

@ObjectType()
class adminProjectListMeta {
  @Field(() => Number)
  count: number
}

interface MyContextType {
  fake: string
}


function UpdateTimeStamp() {
  return createParamDecorator<MyContextType>((resolver) => Date.now());
}

@Resolver()
export class AdminProjectResolver {

  @Query(() => [AdminProject])
  allAdminProjects() {
    return AdminProject.find({
      relations: ["users"]
    })
  }

  @Query(() => adminProjectListMeta)
  _allAdminProjectsMeta() {
    return {count: 2}
  }

  @Query(() => AdminProject)
  AdminProject(@Arg("id") id: string) {
    return AdminProject.findOne({
      where: { id },
      relations: ["users"]
    });
  }

  @Mutation(() => Boolean)
  async deleteAdminProject(@Arg("id") id: string) {
    const project = await AdminProject.findOne({ where: { id } });
    if (!project) throw new Error("AdminProject not found!");
    await project.remove();
    return true;
  }

  @Mutation(() => AdminProject)
  async createAdminProject(
    @Arg("name") name: string,
    @Arg("landingPageSlug") landingPageSlug: string,
    @Arg("public") isPublic: boolean=false,
    @Arg("projectCardDescription") projectCardDescription?: string,
    @Arg("projectCardImageUrl") projectCardImageUrl?: string,
    @Arg("landingPageContent") landingPageContent?: string
  ) {
    const createdAt = new Date()
    const updatedAt = new Date()
    const params = {
      name, landingPageSlug, projectCardDescription, projectCardImageUrl,
      public: isPublic, createdAt, updatedAt
    }
    const project = AdminProject.create(params);
    const errors = await validate(project)
    if (errors.length === 0) {
      await project.save();
      console.dir(project)
    } else {
      console.log(errors)
      console.dir(project)
      throw new Error("invalid project")
    }
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
    ) {
      const params = {
        name, landingPageSlug, projectCardDescription, projectCardImageUrl,
        public: isPublic
      }
      const project = await AdminProject.findOne({ where: { id } });
      if (!project) throw new Error("Project not found!");
      Object.assign(project, params);
      await project.save();
      return project;
  }
}
