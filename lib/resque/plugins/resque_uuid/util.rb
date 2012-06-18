module Resque
  module Plugins
    module ResqueUUID

      module Util
        extend self

        # Ruby 1.9 introduces an inherit argument for Module#const_get and
        # #const_defined? and changes their default behavior.
        if Module.method(:const_get).arity == 1
          # Tries to find a constant with the name specified in the argument string:
          #
          #   "Module".constantize     # => Module
          #   "Test::Unit".constantize # => Test::Unit
          #
          # The name is assumed to be the one of a top-level constant, no matter whether
          # it starts with "::" or not. No lexical context is taken into account:
          #
          #   C = 'outside'
          #   module M
          #     C = 'inside'
          #     C               # => 'inside'
          #     "C".constantize # => 'outside', same as ::C
          #   end
          #
          # NameError is raised when the name is not in CamelCase or the constant is
          # unknown.
          def constantize(camel_cased_word)
            camel_cased_word = camel_cased_word.to_s

            if camel_cased_word.include?('-')
              camel_cased_word = classify(camel_cased_word)
            end

            names = camel_cased_word.split('::')
            names.shift if names.empty? || names.first.empty?

            constant = Object
            names.each do |name|
              constant = constant.const_defined?(name) ? constant.const_get(name) : constant.const_missing(name)
            end
            constant
          end
        else
          def constantize(camel_cased_word) #:nodoc:
            camel_cased_word = camel_cased_word.to_s

            if camel_cased_word.include?('-')
              camel_cased_word = classify(camel_cased_word)
            end

            names = camel_cased_word.split('::')
            names.shift if names.empty? || names.first.empty?

            constant = Object
            names.each do |name|
              constant = constant.const_defined?(name, false) ? constant.const_get(name) : constant.const_missing(name)
            end
            constant
          end
        end

      end

    end
  end
end
