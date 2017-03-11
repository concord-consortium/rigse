There are at least two tricky login code paths.
One is when some site (like LARA) is using the Portal as a authentication provider.
The other is when the Portal is using another site as an auth provider.

And the most confusing is when these two are used together: a user logs into LARA with
the Portal provider and then chooses the schoology option at the portal.

One important part of this is how the redirecting happens.

In the "Portal as a auth provider" case, after the user logs in they need to be redirected back the appropriate page in the LARA.

In the most complex case the user is directed to the portal and then they log in at Schoology and then they need to be redirected back to LARA.

It seems currently the only option for logging into Schoology is using a monitored popup window. So in this case things might be a bit more simple, except that there is some session variable stuff going on.
