require 'optparse'
begin
  require 'byebug'
rescue LoadError
end

class ArgsParser
  class ScriptOptions
    attr_accessor :cluster_name,
                  :autoscaling_group,
                  :services,
                  :task_definitions,
                  :launch_configuration

    def initialize
      self.services = []
      self.task_definitions = []
    end

    def define_options(parser)

      parser.banner = "Usage: ecs-deploy [options]"
      parser.separator ""
      parser.separator "Required options"

      parser.on('-cCLUSTER_NAME', '--cluster=CLUSTER_NAME', 'Cluster to deploy to')  do |cluster_name|
        self.cluster_name = cluster_name
      end

      parser.on('-sSERVICES_FILE', '--services=SERVICES_FILE', 'Path to yaml file containing valid service definition')  do |services_file|
        self.services = load_from_file(services_file)
      end

      parser.on('-dTASK_DEFINITIONS_FILE', '--task-definitions=TASK_DEFINITIONS_FILE', 'Path to yaml file containing valid task definitions')  do |task_definitions_file|
        self.task_definitions = load_from_file(task_definitions_file)
      end

      parser.on('-aAUTOSCALING_GROUP_FILE', '--autoscaling-group-file', 'Path to yaml file containing a valid autoscaling group definition') do |autoscaling_group_file|
        self.autoscaling_group = load_from_file(autoscaling_group_file)
      end

      parser.on('-lLAUNCH_CONFIGURATION_FILE', '--launch-configuration-file', 'Path to yaml file containing a valid launch configuration definition') do |launch_configuration_file|
        self.launch_configuration = load_from_file(launch_configuration_file)
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

    private
    def load_from_file(path)
      YAML.load_file(path)
    end
  end

  def parse(args)
    ap args
    @options = ScriptOptions.new
    @args = OptionParser.new do |parser|
      @options.define_options(parser)
      parser.parse!(args)
    end

    @options.validate!
    @options
  end
end
