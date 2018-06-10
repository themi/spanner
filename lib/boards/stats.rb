module Boards
  class Stats
    attr_reader :milestones, :board

    def initialize
      me = Trello::Member.find(Boards.config.default_member_name)
      # @board = Trello::Board.find(config['trello_board_id'])
      @board = me.boards.first
      @milestones = [
        { caption: "New Client Apps", cards: [] },
        { caption: "Client App Onboarded", cards: [] },
        { caption: "Client App Off Loaded", cards: [] }
      ]
    end

    def fetch
      puts_data "Onboarding Stats..."
      board.cards.each do |card|
        puts_info "  " + card.name
        client_app_card = make_card_data(card)
        milestone = find_milestone_for(client_app_card)
        milestone[:cards] << client_app_card
      end
      save_stats({ id: board.id, name: board.name, milestones: milestones })
    end

    def display
      summary = json_to_object(read_stats)
      live, internal, on_hold, in_progress, deactivated = [], [], [], [], []
      summary.milestones.each do |milestone|
        live << milestone.cards.select { |c| c.status == "live"  }
        internal << milestone.cards.select { |c| c.status == "internal"  }
        on_hold << milestone.cards.select { |c| c.status == "on_hold"  }
        in_progress << milestone.cards.select { |c| c.status == "in_progress"  }
        deactivated << milestone.cards.select { |c| c.status == "deactivated"  }
      end
      puts_str_results ""
      puts_str_results "       Live: #{live.flatten.count}"
      puts_str_results "   Internal: #{internal.flatten.count}"
      puts_str_results "             -----"
      puts_str_results "      Total: #{live.flatten.count + internal.flatten.count}"
      puts_str_results "             ====="
      puts_str_results ""
      puts_str_results "    On Hold: #{on_hold.flatten.count}"
      puts_str_results "Deactivated: #{deactivated.flatten.count}"
      puts_str_results "In Progress: #{in_progress.flatten.count}"
      puts_str_results "             -----"
      puts_str_results "      Total: #{on_hold.flatten.count + deactivated.flatten.count + in_progress.flatten.count}"
      puts_str_results "             ====="
    end

    private
      def json_to_object(json_data)
        JSON.parse(json_data, object_class: OpenStruct)
      end

      def read_stats
        check_cache_path
        filespec = File.join(Boards.config.cache_folder, Boards.config.stats_filename)
        if File.exist?(filespec)
          File.read(filespec)
        else
          nil
        end
      end

      def check_cache_path
        FileUtils.mkdir_p(Boards.config.cache_folder)
      end

      def save_stats(board)
        check_cache_path
        filespec = File.join(Boards.config.cache_folder, Boards.config.stats_filename)
        File.open(filespec, 'w+') { |file| file.write(board.to_json) }
      end

      def find_milestone_for(client_app_card)
        milestone = milestones.select { |m| m[:caption] == client_app_card[:milestone] }.first
        milestone.nil? ? milestones.first : milestone
      end

      def make_card_data(card)
        {
          id: card.id,
          name: card.name,
          milestone_id: card.list_id,
          milestone: card.list.name,
          status: label_name(card.labels)
        }
      end

      def all_labels(labels)
        labels.nil? || labels.empty? ? "new" : labels.map {|x| x.name}.join(', ')
      end

      def label_name(labels)
        labels.nil? || labels.empty? ? "new" : labels.first.name
      end

  end
end
