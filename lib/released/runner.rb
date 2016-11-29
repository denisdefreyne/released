module Released
  class Runner
    def initialize(stages)
      @stages = stages
    end

    def run
      assess_all
      try_achieve_all
    end

    private

    def assess_all
      puts '*** Assessing goals…'
      puts
      @stages.each do |stage|
        puts "#{format_stage stage.name}:"

        stage.goals.each do |goal|
          next unless goal.assessable?

          print "  #{goal}… "

          begin
            goal.assess
          rescue => e
            puts 'error'
            puts
            puts 'FAILURE!'
            puts '-----'
            puts e.message
            puts '-----'
            puts 'Aborting!'
            exit 1
          end

          puts 'ok'
        end
      end
      puts
    end

    def try_achieve_all
      puts '*** Achieving goals…'
      puts
      @stages.each do |stage|
        puts "#{format_stage stage.name}:"

        stage.goals.each do |goal|
          print "  #{goal}… "

          if goal.achieved?
            puts format_success_old('ok (already achieved)')
            next
          end

          begin
            goal.try_achieve
          rescue => e
            puts format_error('error')
            puts
            puts 'FAILURE!'
            puts '-----'
            puts e.message
            puts '-----'
            puts 'Aborting!'
            exit 1 # FIXME: eww
          end

          if goal.achieved?
            puts format_success_new('ok (newly achieved)')
            next
          end

          puts format_failure('failed')
          puts "    reason: #{goal.failure_reason}"
          exit 1 # FIXME: eww
        end
      end
      puts

      puts 'Finished! :)'
    end

    ORANGE       = "\e[38;5;208m"
    RED          = "\e[38;5;196m"
    DARK_GREEN   = "\e[38;5;28m"
    BRIGHT_GREEN = "\e[38;5;40m"
    BLUE         = "\e[38;5;27m"
    RESET        = "\e[0m"

    def format_header(s)
      s
    end

    def format_stage(s)
      BLUE + s + RESET
    end

    def format_success_old(s)
      DARK_GREEN + s + RESET
    end

    def format_success_new(s)
      BRIGHT_GREEN + s + RESET
    end

    def format_failure(s)
      ORANGE + s + RESET
    end

    def format_error(s)
      RED + s + RESET
    end
  end
end
