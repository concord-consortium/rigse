# SimpleAccessControl
#
# Acknowledgements: I give all credit to Ezra and Technoweenie for their two plugins which
# inspired the interface design and a lot of the code for this one.
#
# SimpleAccessControl is a streamlined, intuitive authorisation system. It derives heavily from
# acl_system2 and has made clear some problems which plagued the author when first using it. Some
# fixes to acl_system2's design:
#
#       * a normal Rails syntax:
#             access_rule 'admin', :only => :index
#             access_rule '(moderator || admin)', :only => :new
#       * error handling for helper methods (permit? bombs out with current_user == nil)
#       * one-line parser, easy to replace or alter
#       * proper before_filter usage, meaning access rules are parsed only when needed
#       * no overrideable default (which I found counter-intuitive in the end)
# 
# Also, it has two methods, access_control and permit?, for those moving from acl_system2.
#
# But, let me stress, everyone likes a slightly different system, so this one may not be
# your style. I find it synchronises very well with the interface of Acts as Authenticated (even
# though I have modified it so much that it's now called Authenticated Cookie).
#
module SimpleAccessControl

  def self.included(base)
    base.extend(ClassMethods)
    if base.respond_to?(:helper_method)
      base.send :helper_method, :restrict_to
      base.send :helper_method, :has_permission?
      base.send :helper_method, :permit?
    end
  end
  
  module ClassMethods

    # Support for acl_system2 migration
    def access_control(ruleset = {})
      ruleset.each do |actions, rule|
        case actions
        when :DEFAULT
          access_rule rule
        when Array, Symbol, String
          access_rule rule, :only => actions
        end
      end
    end

    # This is the core of the filtering system and it couldn't be simpler:
    #     access_rule '(admin || moderator)', :only => [:edit, :update]
    def access_rule(rule, filter_options = {})
      before_filter (filter_options||{}) { |c| c.send :permission_required, rule }
    end
  end
  
  protected

  # As in AAA you have login_required, here you have permission_required. Pass it a
  # rule and it will use SimpleAccessControl#has_permission? to evaluate against the
  # current user. Use SimpleAccessControl#has_permission? if you are not guarding an
  # action or whole controller. An empty or nil rule will always return true.
  #     permission_required('admin')
  def permission_required(rule = nil)
    if respond_to?(:logged_in?) && logged_in? && has_permission?(rule)
      send(:permission_granted) if respond_to?(:permission_granted)
      true
    else
      send(:permission_denied) if respond_to?(:permission_denied)
      false
    end
  end

  # For use in both controllers and views.
  #     has_permission?('role')
  #     has_permission?('admin', other_user)
  def has_permission?(rule, user = nil)
    user ||= (send(:current_user) if respond_to?(:current_user)) || nil
    access_controller.process(rule, user)
  end
  
  # For those of you converting from acl_system2
  def permit?(rule, context = {})
    has_permission?(rule, (context && context[:user] ? context[:user] : nil))
  end

  # A much shortened version of Ezra's acl_system2 version.
  #     restrict_to "admin | moderator" do
  #       link_to "foo"
  #     end
  def restrict_to(rule, user = nil)
    yield if block_given? && has_permission?(rule, user)
  end

  def access_controller #:nodoc:
    @access_controller ||= AccessControlHandler.new
  end

  # A dramatically simpler version than that found in acl_system2
  # It is SLOWER because it uses instance_eval to analyse the conditional, but it's DRY.
  class AccessControlHandler

    # Takes a string (which may be a complex conditional string or a single word as a string
    # or symbol) and checks if the user has those roles
    def process(string, user)
      return(check('', user)) if string.blank?
      if string =~ /^([^()\|&!]+)$/ then check($1, user) # it is simple enough to just pump through
      else instance_eval("!! (#{parse(string)})") # give it the going-over
      end
    end

    # Super-simple parsing, turning single or multiple & and | into && and ||. Wraps all the roles
    # in a check call to be evaluated.
    def parse(string)
      string.gsub(/(\|+|\&+)/) { $1[0,1]*2 }.gsub(/([^()|&! ]+)/) { "check('#{$1}', user)" }
    end

    # The heart of the system, all credit to Ezra for the original algorithm
    # Defaults to false if there is no user or that user does not have a roles association
    # Defaults to true if the role is blank
    def check(role, user)
      return(false) if user.blank? || !user.respond_to?(:roles)
      return(true) if role.blank?
      user.roles.map{ |r| r.title.downcase }.include? role.downcase
    end

  end

end