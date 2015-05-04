# always use the cucumber environment in cucumber tests
Spring::Commands::Rake.environment_matchers[/^cucumber($|:)/] = "cucumber"
module Spring
  module Commands
    class Cucumber
      def env(args)
        'cucumber'
      end
    end
  end
end
