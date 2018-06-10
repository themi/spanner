module Boards
  class Console < Thor
    include Thor::Actions

    def initialize(*args)
      super
    end

    def self.source_root
      File.dirname(__FILE__)
    end

    desc "onboarding_stats [--member MEMBER_NAME] [--board BOARD_ID]", "List and Tally cards for the onboarding trello board"
    method_option :member_name, aliases: "-m", banner: "MEMBER_NAME", desc: "Trello member name"
    method_option :board_id, banner: "BOARD_ID", aliases: "-b", desc: "onboarding trello board id"
    def onboarding_stats
      member = set_member_object(options[:member_name])
      board = set_board_object(member, options[:board_id])
      puts member.username, board.id
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
