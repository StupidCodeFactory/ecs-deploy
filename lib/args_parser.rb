require 'optparse'
require 'byebug'

class ArgsParser
  class ScriptOptions
    attr_accessor :cluster_name, :service_name

    def define_options(parser)
      parser.banner = "Usage: ecs-deploy [options]"
      parser.separator ""
      parser.separator "Required options"

      parser.on('-cCLUSTER_NAME', '--cluster=CLUSTER_NAME', 'Cluster to deploy to')  do |cluster_name|
        self.cluster_name = cluster_name
      end
      parser.on('-sSERVICE_NAME', '--service=SERVICE_NAME', 'Service to start')  do |cluster_name|
        self.service_name = service_name
      end

      parser.separator ""
      parser.separator "Global option"

      parser.on_tail('-h', '--help', 'Show this message') do
        parser.help
        exit 1
      end
    end

    def validate!
      raise ArgumentError.new("options --cluster CLUSTER_NAME is required") if cluster_name.nil?
    end
  end

  def parse(args)
    @options = ScriptOptions.new
    @args = OptionParser.new do |parser|
      @options.define_options(parser)
      parser.parse!(args)
    end

    @options.validate!
    @options
  end
end
