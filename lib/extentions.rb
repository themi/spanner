module Extentions
  module Colourize
    def black;        "\e[30m#{self}\e[0m" end
    def red;          "\e[31m#{self}\e[0m" end
    def green;        "\e[32m#{self}\e[0m" end
    def brown;        "\e[33m#{self}\e[0m" end
    def blue;         "\e[34m#{self}\e[0m" end
    def magenta;      "\e[35m#{self}\e[0m" end
    def cyan;         "\e[36m#{self}\e[0m" end
    def gray;         "\e[37m#{self}\e[0m" end

    def bblack;       "\e[40m#{self}\e[0m" end
    def bred;         "\e[41m#{self}\e[0m" end
    def bgreen;       "\e[42m#{self}\e[0m" end
    def bbrown;       "\e[43m#{self}\e[0m" end
    def bblue;        "\e[44m#{self}\e[0m" end
    def bmagenta;     "\e[45m#{self}\e[0m" end
    def bcyan;        "\e[46m#{self}\e[0m" end
    def bgray;        "\e[47m#{self}\e[0m" end

    def bold;         "\e[1m#{self}\e[22m" end
    def italic;       "\e[3m#{self}\e[23m" end
    def underline;    "\e[4m#{self}\e[24m" end
    def blink;        "\e[5m#{self}\e[25m" end
    def reverse_color;"\e[7m#{self}\e[27m" end
  end
end

String.class_eval do
  include Extentions::Colourize
end

def puts_response(response)
  puts response.to_h.to_s.brown
end

def puts_info(info)
  puts info.to_s.cyan
end

def puts_data(data)
  puts data.to_s.blue.bold
end
