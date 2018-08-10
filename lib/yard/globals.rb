# frozen_string_literal: true
# @group Global Convenience Methods

# Shortcut for creating a YARD::CodeObjects::Proxy via a path
#
# @see YARD::CodeObjects::Proxy
# @see YARD::Registry.resolve
def P(namespace, name = nil, type = nil) # rubocop:disable Style/MethodName
  if name.nil?
    name = namespace
    namespace = nil
  end
  YARD::Registry.resolve(namespace, name, false, true, type)
end

# The global {YARD::Logger} instance
#
# @return [YARD::Logger] the global {YARD::Logger} instance
# @see YARD::Logger
def log
  YARD::Logger.instance
end


# Method that can be swapped in for `raise` calls that will drop into the
# `pry` debugger if Yard has been configured to do so (`--pry` CLI option).
# 
# Intended to replace `raise` calls in places where the error needs to be 
# addressed, allowing users to inspect values and move around the stack to 
# quickly and fully understand the problematic state.
# 
# After prying, calls `raise *args` as usual, so the behavior of the program is
# not altered. If prying is not enabled, just goes strait to `raise`.
# 
# @param [Array] args
#   The arguments to pass to `raise`.
# 
# @return [void]
#   Never returns.
# 
def debug_with_pry_then_raise *args
  if YARD::Config.pry?
    # Welcome! You'll want to step up a frame with the `up` command to get to
    # the error site.
    binding.pry
  end
  
  raise *args
end
