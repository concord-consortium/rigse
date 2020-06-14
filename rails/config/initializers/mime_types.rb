# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register_alias "text/html", :iphone

Mime::Type.register "application/x-java-jnlp-file", :jnlp
Mime::Type.register "text/bundle", :bundle
Mime::Type.register "text/bundle", :config
Mime::Type.register "", :run_html
Mime::Type.register "", :run_resource_html
Mime::Type.register "", :run_sparks_html

# for blobs
Mime::Type.register "application/octet-stream", :blob
