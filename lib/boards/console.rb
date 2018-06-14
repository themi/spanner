module Boards
  class Console < Thor
    include Thor::Actions

    def initialize(*args)
      super
    end

    def self.source_root
      File.dirname(__FILE__)
    end

    desc "stats [--fetch | --no-fetch]", "fetch and display a summary of the onboarding stats"
    method_option :fetch, default: true, type: :boolean, desc: "default true, display prev fetch when false"
    def stats
      stats = Boards::Stats.new
      stats.fetch if options[:fetch]
      stats.display
    end

    private

      def set_member_object(requested_member_name=nil)
        if requested_member_name.nil?
          Trello::Member.find(Boards.config.default_member_name)
        else
          Trello::Member.find(requested_member_name)
        end
      end

      def set_board_object(member_object, board_id=nil)
        if board_id.nil?
          member_object.boards.first
        else
          Trello::Board.find(board_id)
        end
      end

      def all_labels(labels)
        labels.nil? || labels.empty? ? "new" : labels.map {|x| x.name}.join(', ')
      end

      def label_name(labels)
        labels.nil? || labels.empty? ? "new" : labels.first.name
      end


  end
end
