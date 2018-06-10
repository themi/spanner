module Helpdesk
  class Storage
    attr_accessor :json_file

    def initialize(json_file)
      @json_file = json_file
    end

    def read
      check_cache_path
      filespec = File.join(Helpdesk.config.cache_folder, json_file)
      if File.exist?(filespec) && !file_expired?(filespec)
        File.read(filespec)
      else
        nil
      end
    end

    def save(json_data)
      check_cache_path
      filespec = File.join(Helpdesk.config.cache_folder, json_file)
      File.open(filespec, 'w+') { |file| file.write(json_data) }
    end

    private

      def file_expired?(filename)
        (File.mtime(filename) + Helpdesk.config.cache_expire_time) < Time.now
      end

      def check_cache_path
        FileUtils.mkdir_p(Helpdesk.config.cache_folder)
      end

  end
end
