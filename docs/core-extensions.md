# Extensions to Existing Ruby Classes

These extensions are loaded early in the application startup and are
located here: config/initializers/00\_core\_extensions.rb

## Core Ruby Classes

### Hash

Hash is extended with a method: recursive\_symbolize\_keys which
Recursively converts the keys in a Hash to symbols.  
It also converts the keys in any Array elements which are Hashes to
symbols.

<span class="underline">Note</span>: This extension has been moved to
lib/app\_settings.rb since it was required there for loading the
settings  
file into APP\_CONFIG.

### Kernel

Kernel is extended with the method: suppress\_warnings

This enables selective supression of warnings from Ruby such as when
redefining  
the constant: REST\_AUTH\_SITE\_KEY when running spec tests

See:
http://mentalized.net/journal/2010/04/02/suppress\_warnings\_from\_ruby/

### String

String is extended with the methods: underscore\_module,
delete\_module(num=1)

### Object

Object is extended with the method: `display_name`

`Object#display_name` calls into `LocalNames.instance#local_name_for` in
`lib/local_names.rb`.  
The default behavior for `#display_name`, can be customized by editing
`config/local_names.yml`.

The return value for `#display_name` is determined by evaluating these
criterea:

1.  By default, the method returns a human readable version of an
    objects class name.
2.  Class Objects return a readable version of their own name.
3.  Strings return their value.
4.  If the object has redefeined “display\_name” that value is used.
5.  If there is an entry for the classname or string literal in
    `config/local_names.yml` its replacement value will be used.
    1.  The `default:` entry in `config/local_names.yml` is used by
        default.
    2.  A ‘theme-spefic’ value may be used instead by defining a section
        in the yaml with your themes name. 

Sample `config/local_names.yml`:

    <code>
    ---
    default:
      Portal::Clazz : Class
    smartgraphs:
      Portal::Clazz : Study Group
    </code>
