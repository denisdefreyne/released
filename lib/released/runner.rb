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

          res = goal.assess_safe

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

    def try_achieve_all
      puts '*** Achieving goals…'
      puts
      @stages.each do |stage|
        puts "#{format_stage stage.name}:"

        stage.goals.each do |goal|
          print "  #{goal}… "

          if goal.achieved?
            puts format_success('ok (already achieved)')
            next
          end

          res = goal.try_achieve
          if res.failure?
            puts format_error('error')
            puts
            puts 'FAILURE!'
            puts '-----'
            puts res.reason
            puts '-----'
            puts 'Aborting!'
            exit 1 # FIXME: eww
          end

          if goal.achieved?
            puts format_success('ok (newly achieved)')
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

    ORANGE = "\e[38;5;208m"
    RED    = "\e[38;5;196m"
    GREEN  = "\e[38;5;40m"
    BLUE  = "\e[38;5;27m"
    RESET  = "\e[0m"

    def format_header(s)
      s
    end

    def format_stage(s)
      BLUE + s + RESET
    end

    def format_success(s)
      GREEN + s + RESET
    end

    def format_failure(s)
      ORANGE + s + RESET
    end

    def format_error(s)
      RED + s + RESET
    end
  end
end
