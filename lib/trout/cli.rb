require 'optparse'
require 'trout/managed_file'
require 'trout/version_list'

module Trout
  class CLI
    def self.run(arguments)
      new(arguments).run
    end

    attr_accessor :command, :option_parser, :arguments, :managed_files, :file_attributes

    def initialize(arguments)
      self.arguments       = arguments
      self.file_attributes = {}
      self.option_parser   = parse_options
      self.managed_files   = VersionList.new('.trout')
    end

    def run
      case command
      when 'checkout'
        file_attributes[:filename] = next_argument
        file_attributes[:git_url]  = next_argument
        file = ManagedFile.new(file_attributes)
        end_arguments
        file.checkout
        managed_files << file
      when 'update'
        file = managed_files[next_argument]
        end_arguments
        file.update
        managed_files << file
      when 'update-all'
        end_arguments
        managed_files.each do |file|
          file.update
          managed_files << file
        end
      when 'help', nil
        puts option_parser
        if arguments_left?
          puts
          usage_for(next_argument)
        end
      else
        unknown_command(command)
      end
    end

    private

    def parse_options
      option_parser = OptionParser.new do |parser|
        parser.banner =
          "trout helps you sync individual files from other git repositories.\n\n" +
          "Usage: trout [options] command arguments"

        parser.separator ""
        parser.separator "Options:"
        parser.separator ""

        parser.on("-s", "--source-root PATH", "Path to the file in the source repository") do |path|
          file_attributes[:source_root] = path
        end
        parser.on("-h", "--help", "View this help document")

        parser.separator ""
        parser.separator "Commands:"
        parser.separator ""
        parser.separator "  checkout   - start tracking a file from another repository"
        parser.separator "  help       - get usage details for a specific command"
        parser.separator "  update     - synchronize changes to a tracked file"
        parser.separator "  update-all - synchronize changes to all tracked file at once"
      end

      option_parser.parse!(arguments)

      if arguments_left?
        self.command = next_argument
      else
        self.command = 'help'
      end

      option_parser
    end

    def next_argument
      arguments.shift or invalid_arguments
    end

    def arguments_left?
      !arguments.empty?
    end

    def invalid_arguments
      puts "I don't understand the options you provided."
      puts %{Run "trout help #{command}" for usage information.}
      exit
    end

    def end_arguments
      invalid_arguments if arguments_left?
    end

    def usage_for(command)
      case command
      when 'checkout'
        puts "Usage: trout checkout filename git_url"
      when 'update'
        puts "Usage: trout update filename"
      else
        unknown_command(command)
      end
    end

    def unknown_command(command)
      puts %{I don't know how to "#{command}."}
      puts %{Run "trout help" for usage information.}
    end
  end
end
