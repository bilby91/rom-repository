require 'rom/repository/ext/relation'

require 'rom/repository/mapper_builder'
require 'rom/repository/loading_proxy'

module ROM
  class Repository < Gateway
    class Base # :trollface:
      def self.relations(*names)
        if names.any?
          attr_reader(*names)
          @relations = names
        else
          @relations
        end
      end

      def self.new(env, mapper_builder = MapperBuilder.new)
        super
      end

      def initialize(env, mapper_builder)
        self.class.relations.each do |name|
          proxy = LoadingProxy.new(
            env.relation(name), name: name, mapper_builder: mapper_builder
          )
          instance_variable_set("@#{name}", proxy)
        end
      end

      def combine(root, options)
        combine_opts = options.each_with_object({}) do |(type, relations), result|
          result[type] = relations.each_with_object({}) do |(key, relation), h|
            h[key] = relation.__send__(:for_combine)
          end
        end
        root.combine(combine_opts)
      end
    end
  end
end