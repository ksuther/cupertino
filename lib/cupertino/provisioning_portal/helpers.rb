# Monkey Patch Commander::UI to alias password to avoid conflicts
module Commander::UI
  alias :pw :password
end

class String
  include Term::ANSIColor
end

require 'yaml'

module Cupertino
  module ProvisioningPortal
    module Helpers
      def agent
        unless @agent
          @agent = Cupertino::ProvisioningPortal::Agent.new

          @agent.instance_eval do
            def username
              @username ||= ask "Username:"
            end

            def password
              @password ||= pw "Password:"
            end

            def team
              teams_by_name = {}
              page.form_with(:name => 'saveTeamSelection').radiobuttons.each do |radio|
                name = page.search("label[for=\"#{radio.dom_id}\"]").first.text.strip
                teams_by_name[name] = radio.value
              end

              name = choose "Select a team:", *teams_by_name.keys
              @team ||= teams_by_name[name]
            end
          end
        end

        @agent
      end

      def config
        unless @config
            @config = YAML.load_file(Cupertino::CONFIG)
        end
        
        @config
      end

      def save_config
        File.open(Cupertino::CONFIG, 'w') do |out|
          YAML.dump(config, out)
        end
      end
      
      def current_account
        current = config['current']
        config['accounts'][current] || current
      end

      def pluralize(n, singular, plural = nil)
        n.to_i == 1 ? "1 #{singular}" : "#{n} #{plural || singular + 's'}"
      end
      
      def try
        return unless block_given?

        begin
          yield
        rescue UnsuccessfulAuthenticationError
          say_error "Could not authenticate with Apple Developer Center. Check that your username & password are correct, and that your membership is valid and all pending Terms of Service & agreements are accepted. If this problem continues, try logging into https://developer.apple.com/membercenter/ from a browser to see what's going on." and abort
        end
      end
    end
  end
end
