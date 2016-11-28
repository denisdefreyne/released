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
        puts "#{stage.name}:"

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
        puts "#{stage.name}:"

        stage.goals.each do |goal|
          print "  #{goal}… "

          if goal.achieved?
            puts 'ok (already achieved)'
            next
          end

          res = goal.try_achieve
          if res.failure?
            puts 'error'
            puts
            puts 'FAILURE!'
            puts '-----'
            puts res.reason
            puts '-----'
            puts 'Aborting!'
            exit 1 # FIXME: eww
          end

          if goal.achieved?
            puts 'ok (newly achieved)'
            next
          end

          puts 'failed'
          puts "    reason: #{goal.failure_reason}"
          exit 1 # FIXME: eww
        end
      end
      puts

      puts 'Finished! :)'
    end
  end
end
