#
# Turn off automatic escaping of html in filter output so we don't break Javascript json output in haml templates
#
# Example of option values
#
#  :javascript
#    #{JSON.generate(foo: "bar")}
#    escape_filter_interpolations = false: {"foo":"bar"}
#    escape_filter_interpolations = true: {&quot;foo&quot;:&quot;bar&quot;}
#
Haml::Template.options[:escape_filter_interpolations] = false
