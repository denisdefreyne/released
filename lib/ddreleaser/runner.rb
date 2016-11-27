module DDReleaser
  class Runner
    def initialize(stages)
      @stages = stages
    end

    def run
      run_prechecks
      run_actual
    end

    private

    def run_prechecks
      puts '*** Running pre-checks…'
      puts
      @stages.each do |stage|
        puts "stage: #{stage.name}"

        stage.plugins.each do |plugin|
          next unless plugin.precheck?

          print "  step: #{plugin.inspect}… "

          res = plugin.precheck_safe

          if res.success?
            puts 'ok'
          else
            puts 'error'
            puts
            puts 'FAILURE!'
            puts '-----'
            puts res.reason
            puts '-----'
            puts 'Aborting!'
            exit 1
          end
        end
      end
      puts
    end

    def run_actual
      puts '*** Running…'
      puts
      @stages.each do |stage|
        puts "stage: #{stage.name}"

        stage.plugins.each do |plugin|
          print "  step: #{plugin.inspect}… "

          res = plugin.run

          if res.success?
            puts 'ok'
          else
            puts 'error'
            puts
            puts 'FAILURE!'
            puts '-----'
            puts res.reason
            puts '-----'
            puts 'Aborting!'
            exit 1
          end
        end
      end
      puts

      puts 'Finished! :)'
    end
  end
end
