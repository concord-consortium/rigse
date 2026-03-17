# Add user_id Parameter to add_to_class API Endpoint

**Jira**: https://concord-consortium.atlassian.net/browse/RIGSE-338

**Status**: **Closed**

## Overview

Add `user_id` as an alternative parameter to the `POST /api/v1/students/add_to_class` endpoint, allowing callers like the report service task system to enroll students by their User record ID without first resolving it to a Portal::Student ID.

## Requirements

- The `add_to_class` endpoint must accept an optional `user_id` parameter as an alternative to `student_id`.
- When `user_id` is provided, the endpoint must look up the `Portal::Student` record associated with that user and proceed with the same enrollment logic.
- If both `student_id` and `user_id` are provided, `student_id` takes precedence and `user_id` is ignored.
- If neither `student_id` nor `user_id` is provided, the endpoint must return `"Missing student_id or user_id parameter"`.
- If `user_id` is provided but the user does not exist, the endpoint must return `"Invalid user_id: #{user_id}"`.
- If `user_id` is provided but the user has no associated `Portal::Student` record, the endpoint must return `"User #{user_id} is not a student"`.
- All existing authorization checks (`update_roster?` on the class, `show?` on the student) must apply identically regardless of whether `student_id` or `user_id` was used.
- Re-enrolling an already-enrolled student (via either parameter) must succeed silently.
- Existing callers using `student_id` must not be affected (backward compatible).

## Technical Notes

- **Endpoint**: `POST /api/v1/students/add_to_class` (routes.rb line 339)
- **Controller**: `API::V1::StudentsController#add_to_class` (students_controller.rb lines 183-207)
- **Student lookup**: Currently `Portal::Student.find_by_id(student_id)`. For `user_id`, would be `User.find_by_id(user_id)&.portal_student`.
- **Test file**: `spec/controllers/api/v1/students_controller_spec.rb` (lines 208-289 cover `add_to_class`)
- **Pundit policies**: `Portal::ClazzPolicy#update_roster?`, `Portal::StudentPolicy#show?`
- **OIDC auth**: Already works with this endpoint — no auth changes needed.
