module RR
  module DoubleDefinitions
    module Strategies
      module DoubleInjection
        # This class is Deprecated.
        # Calling instance_of will cause all instances of the passed in Class
        # to have the Double defined.
        #
        # The following example mocks all User's valid? method and return false.
        #   mock.instance_of(User).valid? {false}
        #
        # The following example mocks and proxies User#projects and returns the
        # first 3 projects.
        #   mock.instance_of(User).projects do |projects|
        #     projects[0..2]
        #   end        
        class InstanceOfClass < DoubleInjectionStrategy
          def initialize(*args)
            super

            if !double_definition_create.no_subject? && !double_definition_create.subject.is_a?(Class)
              raise ArgumentError, "instance_of only accepts class objects"
            end
          end

          protected
          def do_call
            DoubleDefinitions::DoubleInjections::NewInstanceOf.call(subject) do |subject|
              add_double_to_instance(subject, *args)
            end
          end
          
          def add_double_to_instance(instance, *args)
            double_injection = Injections::DoubleInjection.find_or_create(
              instance, method_name, (class << instance; self; end)
            )
            Double.new(double_injection, definition)
            #####
            if args.last.is_a?(ProcFromBlock)
              instance.__send__(:initialize, *args[0..(args.length-2)], &args.last)
            else
              instance.__send__(:initialize, *args)
            end
            instance
          end
        end
      end
    end
  end
end