# Summary
There are 5 types of external services supported by the Portal:
- runtime environments
- authoring environments
- teacher and student reports or dashboards
- researcher reports
- SSO clients

# Runtime Environments
A runtime environment is a site that handles students running a resource. In some cases the authoring environment and the runtime environment will be the same. The main way the Portal works with a runtime environment is through ExternalActivities. Additionally the Portal has Tools. An ExternalActivity can be associated with one Tool. The Tool provides a way for multiple ExternalActivities to have similar behavior.

Authors create these ExternalActivities (called Resources in the UI).

Teachers find ExternalActivities and assign them to their class. This assignment is called an Offering in the code. In LTI terminology this Offering is the same as a Resource Link.

## Launching
When a student views the class they can launch offerings. The way the launch happens depends on the properties of the ExternalActivity.

In all cases the launch sends the student's browser to the external runtime environment. It might be in a new tab or the same tab.  The portal takes the `ExternalActivities` properties and adds additional parameters to it in order to perform this launch.

If the `ExternalActivity#tool_id` value matches the ID of a tool with a source type of 'LARA', then the Portal will use a LARA specific launch. The added parameters can be seen here: https://github.com/concord-consortium/rigse/blob/d81d5a1da69253418abde7e0aa7baac4a1831a66/rails/app/controllers/portal/offerings_controller.rb#L62

Otherwise, the `ExternalActivity#url` is used. The added parameters can be seen here:
https://github.com/concord-consortium/rigse/blob/d81d5a1da69253418abde7e0aa7baac4a1831a66/rails/app/models/external_activity.rb#L162

## Publishing
The Authoring environment can publish its resources to the Portal. The publish creates or updates an ExternalActivity.

## Reporting
There are two ways reports can be associated with the ExternalActivity:
- directly referencing an ExternalReport
- having a Tool with a `source_type` that matches the `default_report_for_source_type` of an ExternalReport

More details on reports are below.

## Authorization
The runtime environment will likely need to use Portal APIs. It might need them to find out who the members of the class are. Or it might want the portal to generate a JWT the runtime can use with Firebase.

### Non LARA Runtime
For a non LARA launch the Portal generates a short-lived Portal JWT (via `SignedJwt::create_portal_token`) that includes the student's learner ID and user type as claims. This JWT is passed to the runtime as a URL parameter. The runtime can send this token back to the Portal in an Authorization header. If the runtime needs to access more APIs after the initial launch it can exchange this short-lived JWT for a longer-lived Portal JWT that can be renewed.

The JWT can be used with any Portal API endpoint — both the API Controller's `check_for_auth_token` and Devise's bearer token authentication recognize JWTs.

References (search for these strings)
- token generation: `SignedJwt::create_portal_token` (called from `external_activity.rb` and `create_collaboration.rb`)
- api controller auth check: `check_for_auth_token`

Example [implementation in CLUE](https://github.com/concord-consortium/collaborative-learning/blob/14d066421c6f6a55102bb9d1a9d849491928316e/src/lib/auth.ts#L310)

### OAuth2 Authorization
The Portal supports OAuth2 authorization for SPAs and other external services that need to authenticate users. This is used by report SPAs (like portal-report) when they are opened standalone (not launched from the Portal with a token), and by other Portal-integrated SPAs like the token-service and glossary authoring.

The Portal supports two OAuth2 grant types, determined by the Client's `client_type`:
- **Implicit grant** (`response_type=token`) for PUBLIC clients (SPAs)
- **Authorization code grant** (`response_type=code`) for CONFIDENTIAL clients (server-side apps like LARA)

#### Implicit grant flow (SPAs)

1. The SPA redirects the user's browser to `/auth/concord_id/authorize` with parameters: `client_id`, `redirect_uri`, `response_type=token`, and `state`.
2. If the user is already logged into the Portal, the Portal immediately redirects back. If not, the Portal shows a login page (displaying the Client's `name`), and after login completes the redirect.
3. The Portal validates the `redirect_uri` against the Client's registered `redirect_uris` (exact match), creates an AccessGrant with the Client, and redirects back to the SPA with the access token in the URL **fragment**: `#access_token=...&token_type=bearer&expires_in=604800&state=...`
4. The SPA extracts the token from the fragment and can use it to call Portal APIs. The token can also be exchanged for a Portal JWT.

There is no user consent screen — authorization is automatic once the user is logged in. The `state` parameter is passed through unchanged and can be used by the SPA to restore its original context after the redirect.

#### SPA OAuth2 initialization pattern

Several of our SPAs support being launched with OAuth2 initialization parameters instead of (or in addition to) a direct token. When the SPA detects these parameters, it:

1. Saves the current URL query string to `sessionStorage` with a random key
2. Redirects to `{auth-domain}/auth/oauth_authorize` with `client_id`, `redirect_uri` (origin + pathname only, no query string), `response_type=token`, and the random key as `state`
3. When the Portal redirects back with the access token in the URL fragment, the SPA extracts it and uses `state` to retrieve the original query string from `sessionStorage`, restoring the URL via `history.replaceState`

This pattern is used by portal-report, collaborative-learning (CLUE), and Activity Player. The key URL parameters are:

| Parameter | portal-report / Activity Player | CLUE | Purpose |
|---|---|---|---|
| Auth domain | `auth-domain` | `authDomain` | Portal URL for OAuth2 authorization |
| Resource link | (derived from `offering` URL) | `resourceLinkId` | Portal offering ID, used when requesting JWTs |

The naming difference is purely conventional — portal-report uses kebab-case, CLUE uses camelCase. Both use the same underlying OAuth2 implicit grant flow and the same Portal endpoint.

CLUE also has a `convertURLToOAuth2()` function that rewrites the URL after an initial token-based launch: it removes the `token` parameter and adds `authDomain` + `resourceLinkId`. This way if the user reloads the page, the OAuth2 flow re-authenticates instead of trying to reuse the expired launch token.

For the Portal to support direct OAuth2 launches (instead of the current short-lived JWT approach), it would need to generate launch URLs with `auth-domain`/`authDomain` pointing to itself and include the other context parameters the SPA needs (class, offering, etc.), without a `token` parameter. The SPA would then handle authentication via the OAuth2 redirect flow on first load.

#### Authorization code flow (server-side apps)

1. The app redirects the user to `/auth/concord_id/authorize` with `response_type=code` and the same other parameters.
2. After login, the Portal redirects back with a `code` in the query string.
3. The app exchanges the code for an access token server-to-server via `POST /oauth/token` with `client_id`, `client_secret`, and `code`. The response includes `access_token`, `refresh_token`, and `expires_in`.

References (search for these strings)
- authorize endpoint: `oauth_authorize` (in `auth_controller.rb`)
- validation: `validate_oauth_authorize` (in `access_grant.rb`)
- redirect building: `implicit_flow_redirect_uri_for`, `auth_code_redirect_uri_for` (in `access_grant.rb`)
- token exchange: `access_token` action (in `auth_controller.rb`)

### LARA Runtime
For a LARA launch, OAuth2 is used. The portal sends a `domain` and `domain_uid` parameter to LARA. LARA checks if there is a user currently signed in with an auth client for this domain and this uid. If not then LARA redirects the user back to the Portal to get signed in. And then the user is returned back to LARA with an AccessGrant token. The URL parameters are preserved throughout this process. In this case the AccessGrant has a client, so LARA can use this token with any API.

The LARA runtime javascript code does not use this token. Instead it makes requests to the LARA server and the LARA server then makes a request to the Portal.

# Authoring environments
The only authoring environment the portal currently has is LARA. However other environments should almost work. The main integration point for these environments is the `ExternalActivity#author_url`. If this is set then the Portal will open this URL when an author clicks the edit button or link associated with the external activity.

## Publishing
Authoring environments can also 'publish' resources to the portal. Currently LARA is the only system doing this. LARA uses 2 methods of publishing.

### LARA Runtime
For the LARA built in runtime it uses the portal publish api. This not only includes information for setting up the ExternalActivity, but also includes the reportable structure of the resource. The Portal takes this structure and creates or updates a set of models to save the structure.

### LARA Activity Player Runtime
For the Activity Player runtime, LARA uses the more basic ExternalActivity api. In this case it simply creates or updates the external activity.  This is the same api that should be used by non LARA systems that want to manage ExternalActivities to make it easier for authors.

## AuthoringSite model
Additionally there is an AuthoringSite model, which is how a convenience 'create XYZ' button can be added to `/authoring` page.

# Teacher and Student Reports or Dashboards
As described above ExternalReports are used to provide reports and dashboards for ExternalActivities. The ExternalReport model is also used for Researcher reports.

The ExternalReport has a Client which indicates what domain the report is hosted on, so the portal can validate its requests.

## Types
An ExternalReport has 2 types for teachers:
- offering
- class

It can also be marked as "allowed for students"

The other types of ExternalReports are described in the Researcher section

### Offering Report
An offering report is associated with an assignment in the Portal. In places where teachers see the assignment they also see a button to run this report.

The report has to be associated with the assigned ExternalActivity either directly or indirectly through the source_type.

### Class Report
A class report is for classes. In places where teachers see classes they will see a button to run this report.

The report has to be associated directly with the ExternalActivity. The indirect use of `source_type` is not supported for Class reports.

When a class has one or more assignments with a Class Report, then the report button is shown at the class level of the UI.

### Student Report
If the report is allowed for students, and the report is an offering report, then the student will see a report button next to the assignment.

When the student report is launched, the user id of the current user is passed as a `studentId` to the report. This is in addition to the other parameters below. Reference: https://github.com/concord-consortium/rigse/blob/d81d5a1da69253418abde7e0aa7baac4a1831a66/rails/app/models/external_report.rb#L39
Also the learner (student, offering) is added to the access grant of the token.

## Launching
The offering_controller provides the following actions for reports:
- report
- external_report

The Portal adds several parameters onto the URL provided by the ExternalReport. They can be seen here: https://github.com/concord-consortium/rigse/blob/d81d5a1da69253418abde7e0aa7baac4a1831a66/rails/app/models/external_report.rb#L68

## Authorization
When a report is launched from the Portal, the Portal creates an AccessGrant with the ExternalReport's Client and passes the token to the report as a URL parameter. The report can use this token to call back to the Portal. Since the token has a client, it can be used with any Portal API.

When an ExternalReport is set up in the Portal a Client is needed and must have the correct settings. Our teacher reports are normally SPAs, so the Client should have a type of `public`, and it should specify the domain of the SPA.

If the SPA report also supports OAuth2 (so it can be run without being launched from the Portal with a token), then the Client's `redirect_uris` must also be specified. See the OAuth2 Authorization section under Runtime Environments above for details on the OAuth2 flow.

Additionally if the user is a teacher then the teacher object is added to the access grant.  If the user is a student then the learner object (student, offering) is added to the access grant. These additions to the grant are used when the report requests a JWT. The issued JWT then includes claims based on the teacher or learner. References:
- https://github.com/concord-consortium/rigse/blob/d81d5a1da69253418abde7e0aa7baac4a1831a66/rails/app/controllers/api/v1/jwt_controller.rb#L59
- https://github.com/concord-consortium/rigse/blob/d81d5a1da69253418abde7e0aa7baac4a1831a66/rails/app/controllers/api/v1/jwt_controller.rb#L89

# Researcher Reports

**TODO**

# SSO clients

**TODO**

# From a Modeling Point of View

## Tool
In the portal there is a `tools` model. This model has a `tool_id` (url), `source_type`, `remote_duplicate_url`, and `name`. An ExternalActivity can be associated with a single Tool.

The source_type of the ExternalActivity#tool is used to find an ExternalReport configured with a default_report_for_source_type.

In the user researcher report filer page, only ExternalActivites that have a Tool with a `source_type` of "LARA" are shown in the "runnables" list.

When the (currently defunct) move student feature is used, the portal sends the `tool_id` (url) of the ExternalActivities in the original class and new class of the student, to the ExternalReports#move_students_api_url

The `tool_id` is used when an external activity is created using the `api/v1/external_activity` api.

When ActivityRuntimeAPI is used to publish a new activity or sequence a new Tool is created if the `source_type` is passed in. In this case the Tool has no `tool_id`. This feature is mainly for developer convenience.

## ExternalReport
Has a `default_report_for_source_type`. When an ExternalActivity has a tool with this `source_type` is assigned to a class, then report buttons for this assignment will automatically be added.

ExternalActivities can also have one or more ExternalReports directly associated with them. This makes it possible for an author or admin to set up a special report or dashboard for a specific resource.

## ExternalActivity
Authors and admins can duplicate ExternalActivities. If the ExternalActivity has an `author_url` value and it's Tool has a `remote_duplicate_url` value, then the special `duplicate_on_remote` function is called. This sends a http request to `#{Tool.remote_duplicate_url}`. It expects the remote authoring system to copy the resource and then return the same kind of data that would normally be sent when an author "publishes" the resource to the Portal. Then the Portal does this publishing internally using the `ActivityRuntimeAPI`. This internal publishing happens as an 'update' operation not a 'create' operation. This is because the ExternalActivity already exists.

When data_helpers.rb generates JSON from the activity it includes `lara_activity_or_sequence` which is based on whether the activity has a tool with a `source_type` of "LARA". This is used to determine which links are shown to the user.

## Client
Clients are used for authentication. When the Portal creates an AccessGrant to provide a token to an external service (e.g., report launches, OAuth flows), the AccessGrant has an associated Client. The Client is used to verify requests with the token. If the client specifies `domain_matchers` then only requests from those domains are accepted. Note: student assignment launches use Portal JWTs instead of AccessGrants (see the Non LARA Runtime section above), so Clients are not involved in that flow.

When the Client is used for OAuth2, it must also specify `redirect_uris` — the exact URLs the Portal is allowed to redirect to after authorization. The Client's `client_type` (public or confidential) determines which OAuth2 grant type is used. See the OAuth2 Authorization section under Runtime Environments above for the full flow.

## Seeding the Database
To make it easier for developers, when the database is seeded a few of the resources above are automatically created.

An ExternalReport is created for the portal-report. And a Client is created that this ExternalReport uses.

# Ways to Improve

## Eliminate the source_type

### default_report
The use of `source_type` to connect ExternalActivities to default reports is not needed. Instead a `default_report` can be added to the Tool model. This will have the same behavior and simplify the modeling.

### remove filtering of runnables in user researcher report
Currently the runnables are filtered by `source_type` in the user researcher report page. This is not really useful, and seems like it could just be removed. If we need filtering like this, we could add Tool filtering.

### duplicate activity support
Currently a `source_type` of LARA means the portal uses the `remote_duplicate` action in LARA when an ExternalActivity is duplicated. It is convenient for authors so they can duplicate resources in the portal without needing to set up the ExternalActivity for the resource (description, grade_levels, ...). Instead of using this check on a `source_type` of LARA, this should be made generic so non-LARA authoring systems can provide support for duplicating from the Portal.

There are a couple options for making this more generic:
- a new field on the Tool model could provide a URL for this remote duplication. The JSON payload sent to it could include enough info that this would be a static URL like `authoring.cocnord.org/remote_duplicate` This would require changes in both the Portal and LARA in how this remote_duplicate is handled.
- a new `duplicate_url` field could be added on ExternalActivity model and publishing systems can set this when they add activities. This way the url can include the id like it currently does `/activities/1234/remote_duplicate`. This requires changes in the Portal and LARA, but the LARA changes are pretty minimal.

## Merge Tool and Client models
In LTI our Tool and Client models are basically considered the Tool. This seems to make sense but it would involve some differences from our current approach.  It might not be the best option for us.

Reports and SSO Clients also use the current Client model. So we would need to make Tools for all of these. And this in turn means that an author manually adding an ExternalActivity would see a larger list of Tools in the selection menu. Since manually making ExternalActivities is only done by Admins, this approach seems OK.

## Associate all ExternalActivities with a Tool
If the Tool and Client models are merged then this would come for free as long as the ExternalActivity has a Tool. Otherwise it would be useful for Tools to be connected to a Client.

There are several reasons to associate all ExternalActivities with a Tool:

- **Default reports:** If a `default_report` is added to the Tool model (see "Eliminate the source_type" above), then all ExternalActivities with that Tool would automatically get the report. This only works if every ExternalActivity has a Tool.
- **LTI alignment:** In LTI, the Tool is the central concept that ties together the platform registration and launch context. Ensuring every ExternalActivity has a Tool moves closer to this model.
- **Client for token generation:** ~~A client on the Tool could be used by the Portal when generating tokens during the ExternalActivity launch, increasing security and allowing these tokens to be used with any Portal API.~~ This motivation has been addressed differently — student assignment launches now use Portal JWTs instead of AccessGrants, and JWTs work with all APIs without requiring a Client.

If we take this approach it means we'll need to make Tools for all external activities which make connections back to the Portal. Currently this list probably is:
- CLUE
- tt.concord.org

## Improve Move students between classes
Currently the move student between classes is defunct. We broke it when adding the report-service way of storing the student work. And additionally it had problems when LARA interactives or plugins stored data in their own databases (usually FiresStore or Firebase realtime database).

It was initially implemented by adding a url to the ExternalReport model. If Tools and Clients were merged, then each ExternalReport would have a Tool. And the Tool could have a move_students_url. Additionally, when an interactive or plugins work with Firestore or Firebase they currently require Clients. So if Clients and Tools were merged then this same Tool#move_students_url field would be available. So then when moving a student all registered Tools could be notified and they'd have a chance to update their storage.

An even better solution (if possible), is to change how all of these systems store student data so a student can be moved without needing to change these systems. The reason this is tricky is that the systems need to grant access to teachers to see their students work. This is done by associating the student work with a class identifier. And then the teacher is given a JWT that includes this identifier in the claims, so then the external system can know the teacher can be granted access to all data associated with this identifier. The only way around this is for the JWT to include the student identifiers of every student in the class. This makes the JWT big and means that a new one needs to be issued each time a student is added.

I'd think this 'moving student' issue is something that LTI needs to address too. So if we were partners with them again it would be a good thing to raise.
