{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... } @ inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        formatter = pkgs.nixpkgs-fmt;
        devShells.default = pkgs.mkShell {
          # Required to build/install "mimemagic" Gem:
          # "Ensure you have either installed the shared-mime-info package for your distribution, or
          # obtain a version of freedesktop.org.xml and set FREEDESKTOP_MIME_TYPES_PATH to the location
          # of that file."
          FREEDESKTOP_MIME_TYPES_PATH = "${pkgs.shared-mime-info}/share/mime/packages/freedesktop.org.xml";

          DB_HOST = "127.0.0.1";
          DB_USER = "root";
          DB_PASSWORD = "xyzzy";
          DB_NAME = "portal";

          DISABLE_DATABASE_ENVIRONMENT_CHECK = "1";

          RAILS_ENV = "production";

          SOLR_HOST = "solr";
          SOLR_PORT = "8983";

          SITE_URL = "http://app.rigseprod.docker";
          SITE_NAME = "Test Portal";
          AUTHORING_SITE_URL = "https://authoring.staging.concord.org";
          THEME = "learn";
          HELP_EMAIL = "help@concord.org";
          ADMIN_EMAIL = "admin@concord.org";
          TOP_LEVEL_CONTAINER_NAME = "Sequence";
          SITE_KEY = "123456";
          RAILS_STDOUT_LOGGING = "true";
          GOOGLE_ANALYTICS_MEASUREMENT_ID = "G-G4ZNE5X0T6";

          packages = with pkgs; [
            ruby_2_7
            # Required to install "mysql2" Ruby Gem
            libmysqlclient
            # "! Unable to load application: ExecJS::RuntimeUnavailable: Could not find a JavaScript runtime. See https://github.com/rails/execjs for a list of available runtimes.
            # bundler: failed to load command: puma (/home/me/.local/share/gem/ruby/2.7.0/bin/puma)
            # ExecJS::RuntimeUnavailable: Could not find a JavaScript runtime. See https://github.com/rails/execjs for a list of available runtimes."
            nodejs
            # YUI Compressor (which the Ruby Gem 'yui-compressor' wraps, requires Java version >= 1.5 (see https://github.com/yui/yuicompressor#notes)
            # Otherwise the following error occurs:
            #  - https://github.com/yui/yuicompressor/issues/133#issue-27992028
            #  - https://github.com/sstephenson/ruby-yui-compressor/issues/38#issue-27992629
            adoptopenjdk-jre-bin

            mariadb-client # For poking around local database
            act # For test running GitHub Actions locally
          ];
        };
      }
    );
}
