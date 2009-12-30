Bump the version in rites.xml before building and updating an installer on a server.

Select an /investigations/<nnn>.jnlp url to test and then use as the template.

Make sure it runs normally before continuing.

Then set the parameter JNLP_URLS in jnlps.conf to this value.

If you want to test the installer on a local instance of investigations 
installation_jnlp might look like this:

  JNLP_URLS="http://localhost:3000/investigations/107.jnlp"

Otherwise if you are building an Installer for a server make sure JNLP_URLS
references a valid url on the server hosting the Investigations instance.

Remove the older cached jar files:

  rm -r jars
  ../../scripts/cache-jars.sh

Run BitRock Installer:

  /Applications/BitRock\ InstallBuilder\ Enterprise\ 6.1.3/bin/Builder.app/Contents/MacOS/installbuilder.sh build rites.xml osx

Open and run the installer it created with a command like this::

  open ../../installers/RITES-2009xx.x-osx-installer.dmg

Now try opening the same url you used for the installation_jnlp setting with the parameters
that instead run with the Installer:

  http://localhost:3000/investigations/107.jnlp?use_installer=1

