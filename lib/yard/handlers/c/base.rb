module YARD
  module Handlers
    module C
      class Base < Handlers::Base
        include YARD::Parser::C
        include HandlerMethods

        # @return [Boolean] whether the handler handles this statement
        def self.handles?(statement, processor)
          processor.globals.cruby_processed_files ||= {}
          processor.globals.cruby_ignored_files ||= {}

          return false if processor.globals.cruby_ignored_files[processor.file]
          processor.globals.cruby_processed_files[processor.file] = true

          if statement.respond_to? :declaration
            src = statement.declaration
          else
            src = statement.source
          end

          handlers.any? do |a_handler|
            statement_class >= statement.class &&
              case a_handler
              when String
                src == a_handler
              when Regexp
                src =~ a_handler
              end
          end
        end
        
        def self.statement_class(type = nil)
          type ? @statement_class = type : (@statement_class || Statement)
        end
        
        protected
        
        # @group Looking up Symbol and Var Values
        
        def symbols
          parser.globals.cruby_symbols ||= {}
        end
        
        def override_comments
          parser.globals.cruby_override_comments ||= []
        end
        
        def namespace_for_variable(var)
          namespaces[var] || P(remove_var_prefix(var))
        end

        def namespaces
          parser.globals.cruby_namespaces ||= {}
        end
        
        def processed_files
          parser.globals.cruby_processed_files ||= {}
        end

        def ignored_files
          parser.globals.cruby_ignored_files ||= {}
        end
                
        # @group Parsing an Inner Block
        
        def parse_block(opts = {})
          return if !statement.block || statement.block.empty?
          push_state(opts) do
            parser.process(statement.block)
          end
        end
        
        # @group Processing other files

        def process_file(file, object)
          log.debug "Processing embedded call to C source #{file}..."
          file = File.relative_path(statement.file, file)
          return if processed_files[file]
          ignored_files[file] = true
          begin
            parser.process(Parser::C::CParser.new(File.read(file)).parse)
          rescue Errno::ENOENT
            log.warn "Missing source file `#{file}' when parsing #{object}"
          end
        end

        # @endgroup
        
        private
        
        def remove_var_prefix(var)
          var.gsub(/^rb_[mc]|^[a-z_]+/, '')
        end
      end
    end
  end
end