# マインスイーパー
require './Board'
require './Cell'

class Minesweeper
  attr_accessor :board, :n
  def initialize
    start
  end

  private

    def start
      puts "Minesweeper"
      puts "▶start help"
      input = gets
      help if input == "\e[C\n" || input == "help\n"
      game_config
      board.puts_list
      try_game
    end

    def help
      puts(<<~EOS)
        start ▶help
        縦 横 (f):
        1 1 と入力すると(1,1)を開けます。
        フラグを立てるには f オプションをつけて下さい。
        例) 1 1 f
        ▶OK
      EOS
      input = gets
    end

    def game_config
      puts "7×7マス,爆弾3個 でよろしいですか？(▶yes　no)"
      yes_or_no = gets
      if yes_or_no == "yes\n" || yes_or_no == "\n"
        @n, bomb = 7, 3
      elsif yes_or_no == "no\n" || yes_or_no == "\e[C\n"
        @n, bomb = custom_info
      else
        puts "もう一度入力して下さい。"
        return game_config
      end
      @board = Board.new(n)
      board.create_board(bomb)
    end

    def try_game
      while board.continuing?
        print "縦 横 (f): "
        i,j,*flag = gets.split
        i,j = i.to_i,j.to_i
        if validate(i,j)
          puts "もう一度入力して下さい"
          return try_game
        end
        i -= 1
        j -= 1
        next board.flag(i,j) unless flag.empty?
        board.reveal(i,j)
      end
      ask_again
    end

    def ask_again
      puts "もう一度プレイしますか？(yes/no)"
      yes_or_no = gets
      if yes_or_no == "yes\n" || yes_or_no == "\n"
        start
      elsif yes_or_no == "no\n" || yes_or_no == "\e[C\n"
        puts "終了します"
        exit
      else
        return ask_again
      end
    end

    def validate(i,j)
      (not i) || (not j) || (i < 0 || i > n) || (j < 0 || j > n)
    end

    def custom_info
      puts "縦横何マスずつにしますか？"
      @n = gets.to_i
      puts "爆弾の個数は何個にしますか？"
      bomb = gets.to_i
      if n < 1 || bomb < 1 || n*n <= bomb
        puts "もう一度入力して下さい。"
        return custom_info
      end
      [n,bomb]
    end
end

Minesweeper.new
