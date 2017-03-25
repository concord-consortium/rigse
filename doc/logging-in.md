The portal has a pretty complex set of login options.
It can use other sites as authentication providers such as Schoology. It is also an
authentication provider for other sites such as LARA.

There are at least 5 possible places a user can enter their username and password:

1. By the default the header of pages has a login box, some pages change this.
2. During the registration process there is a custom login form that is shown the user at
the last step so they can login the first time more easily.
3. There is a stand alone login page at `/auth/login` that is used when there is an
authorization error. This page is also used when the portal is acting as the
authentication provider for another site (like LARA).
4. The geniverse extensions to the portal provide their own login form which submits the
username and password to the portal.
5. (Deprecated) There is an old standalone page at /users/sign_in that has not been
updated recently.

It supports redirecting a user to particular page after logging in. This is done with
the `after_sign_in_path=[path]` query parameter. Currently this is only supported by
`/auth/login` and the login form on the header.

If an anonymous user tries to access a restricted page they will be redirected to
`/auth/login?after_sign_in_path=[path]` this handles the case where a user is logged out
from inactivity and then tries to click a restricted link.

Perhaps the most complex redirect chain is when the portal is being used as an
authentication provider, and the user chooses to log into the portal with Schoology
(another authentication provider).  In this case the user is first directed to the portal
to login, then user clicks the 'login with schoology' button. The user is directed to
schoology to login, then after logging in, the user is first redirected back to the portal
then (after the portal verifies the schoology login info), the portal redirects the user
back to LARA.

Another complex redirect chain is when a logged out user tries to access a page they
don't have access to, and then logs in with Schoology.  In this case the user is first
redirected to /auth/login then they click the 'login with schoology' button. This takes
them to schoology, they login at schoology, they are redirected back the portal, and then
finally the portal redirects them back to the page they originally tried to access.

We are trying to avoid the use of session variables when keeping track of redirects. This
way users who have multiple tabs open are not surprised when they login and then
get redirected to some unexpected place. This can happen when a previous action stored
a redirect location in the session. The session is shared by all tabs of the browser.
Here is the status of this design goal:

- code that handles redirecting after an attempt to access a restricted page does not use
the session.  
- code that handles redirecting to an authentication client like LARA still
uses the session.

The login form on the header also supports a special mode when the portal has been
iframe'd into another site. This code is probably dead at this point because it was
created to support interactives that use portal authentication which are iframed in LARA.
These types of interactives would now be redirected to /auth/login not a page with the
login form in the header.
