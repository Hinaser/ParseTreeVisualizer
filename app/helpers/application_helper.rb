module ApplicationHelper
  # Check if a particular namespace(module) of controller is the current one
  #
  # args - One or more module names to check
  #
  # Examples
  #
  #   # On Forest::TreeController
  #   current_controller?(:forest)           # => true
  #   current_controller?(:tree)        # => false
  #   current_controller?(:forest, :wood) # => true
  def current_namespace?(*args)
    args.any? { |v| v.to_s.downcase == controller.class.name.split('::')[0..-2].join('::').downcase }
  end

  # Check if a particular controller is the current one
  #
  # args - One or more controller names to check
  # *NOTE* controller is assumed to be without any parent modules
  #
  # Examples
  #
  #   # On TreeController
  #   current_controller?(:tree)           # => true
  #   current_controller?(:commits)        # => false
  #   current_controller?(:commits, :tree) # => true
  def current_controller?(*args)
    false if controller.class.name.include?('::')

    args.any? { |v| v.to_s.downcase == controller.controller_name }
  end

  # Check if a particular action is the current one
  #
  # args - One or more action names to check
  #
  # Examples
  #
  #   # On Projects#new
  #   current_action?(:new)           # => true
  #   current_action?(:create)        # => false
  #   current_action?(:new, :create)  # => true
  def current_action?(*args)
    args.any? { |v| v.to_s.downcase == action_name }
  end

  def body_data_page
    path = controller.controller_path.split('/')
    namespace = path.first if path.second

    [namespace, controller.controller_name, controller.action_name].compact.join(':')
  end

  def content_data_page
    path = controller.controller_path.split('/')
    namespace = path.first if path.second

    [namespace, controller.controller_name, controller.action_name].compact.join('-')
  end

end

