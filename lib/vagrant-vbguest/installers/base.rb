module VagrantVbguest
  module Installers
    class Error < Vagrant::Errors::VagrantError
      error_namespace "vagrant.plugins.vbguest.errors.installer"
    end

    # This is the base class all installers must inherit from
    # It defines the basic structure of an Installer and should
    # never be used directly
    class Base

      # Tests whether this installer class is applicable to the
      # current environment. Usually, testing for a specific OS.
      # Subclasses must override this method and return `true` if
      # they wish to handle.
      #
      # This method will be called only when an Installer detection
      # is run. It is ignored, when passing an Installer class 
      # directly as an config (`installer`) option.
      # 
      # @param [Vagrant::VM]
      # @return [Boolean]
      def self.match?(vm)
        false
      end
      
      attr_reader :vm

      def initialize(vm)
        @vm = vm
      end      

      # The absolute file path of the GuestAdditions iso file should
      # be uploaded into the guest.
      # Subclasses must override this method!
      # 
      # @return [String] 
      def tmp_path
      end

      # The mountpoint path
      # Subclasses shall override this method, if they need to mount the uploaded file!
      # 
      # @retunn [String] 
      def mount_point
      end

      # Handles the installation process.
      # All necessary steps for an installation must be defined here.
      # This includes uploading the iso into the box, mounting,
      # installing and cleaning up.
      # Subclasses must override this method!
      # 
      # @param [String] iso_file The path to the local GuestAdditions iso file
      # @param [Hash] opts Optional options Hash wich meight get passed to {Vagrant::Communication::SSH#execute} and firends
      # @yield [type, data] Takes a Block like {Vagrant::Communication::Base#execute} for realtime output of the command being executed
      # @yieldparam [String] type Type of the output, `:stdout`, `:stderr`, etc.
      # @yieldparam [String] data Data for the given output.
      def install(iso_file, opts=nil, &block)
      end

      # A helper method to handle the GuestAdditions iso file upload
      def upload(file)
        vm.ui.info(I18n.t("vagrant.plugins.vbguest.start_copy_iso", :from => file, :to => tmp_path))
        vm.channel.upload(file, tmp_path)
      end

      # A helper method to delete the uploaded GuestAdditions iso file 
      # from the guest
      def cleanup
        vm.channel.execute("rm #{tmp_path}") do |type, data|
          vm.ui.error(data.chomp, :prefix => false)
        end
      end

    end
  end
end