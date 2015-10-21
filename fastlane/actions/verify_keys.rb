module Fastlane
  module Actions

    class VerifyKeysAction < Action
      def self.run(params)

        # Ensure no deploys with OSS keys
        require 'cocoapods-core'
        puts "Validating CocoaPods Keys"

        podfile = Pod::Podfile.from_file "Podfile"
        target = podfile.plugins["cocoapods-keys"]["target"] || ""
        podfile.plugins["cocoapods-keys"]["keys"].each do |key|
          puts " - #{key}"

            value = `bundle exec pod keys get #{key} #{target}`
            value = value.split("]").last.strip

          if value == "-" || value == ""
            message = "Did not pass validation for key #{key}." +
              "Run `bundle exec pod keys get #{key} #{target}` to see what it is."
              "It's likely this is running with OSS keys."
            raise message
          end
        end

      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Verifies all keys referenced from the Podfile, stored in the OS X Keychain, are non-empty."
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
