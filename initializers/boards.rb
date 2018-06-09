require 'trello'

Trello.configure do |trello|
  trello.developer_public_key = ENV["TRELLO_DEVELOPER_PUBLIC_KEY"]
  trello.member_token = ENV["TRELLO_MEMBER_TOKEN"]
end

Boards.configure do |c|
  c.default_member_name = ENV["TRELLO_MEMBER_NAME"]
  c.default_board_id = ENV["TRELLO_BOARD_ID"]
end
