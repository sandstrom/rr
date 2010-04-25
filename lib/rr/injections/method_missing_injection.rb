module RR
  module Injections
    class MethodMissingInjection < Injection
      class << self
        def create(subject)
          instances[subject] ||= begin
            new(subject).bind
          end
        end

        def exists?(subject)
          instances.include?(subject)
        end
      end

      def initialize(subject)
        @subject = subject
        @placeholder_method_defined = false
      end

      def bind
        unless subject.respond_to?(original_method_alias_name)
          unless subject.respond_to?(:method_missing)
            @placeholder_method_defined = true
            subject_class.class_eval do
              def method_missing(method_name, *args, &block)
                super
              end
            end
          end
          subject_class.__send__(:alias_method, original_method_alias_name, :method_missing)
          bind_method
        end
        self
      end

      def reset
        if subject_has_method_defined?(original_method_alias_name)
          memoized_original_method_alias_name = original_method_alias_name
          placeholder_method_defined = @placeholder_method_defined
          subject_class.class_eval do
            remove_method :method_missing
            unless placeholder_method_defined
              alias_method :method_missing, memoized_original_method_alias_name
            end
            remove_method memoized_original_method_alias_name
          end
        end
      end

      def dispatch_method(method_name, args, block)
        MethodDispatches::MethodMissingDispatch.new(subject, method_name, args, block).call
      end

      protected
      def subject_class
        class << subject; self; end
      end

      def bind_method
        subject_class.class_eval((<<-METHOD), __FILE__, __LINE__ + 1)
        def method_missing(method_name, *args, &block)
          RR::Injections::MethodMissingInjection.create(self).dispatch_method(method_name, args, block)
        end
        METHOD
      end

      def original_method_alias_name
        MethodDispatches::MethodMissingDispatch.original_method_missing_alias_name
      end
    end
  end
end
