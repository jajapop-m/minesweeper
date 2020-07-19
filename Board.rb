class Board
  attr_accessor :n, :lists, :bomb_map, :bomb_count

  def initialize(n)
    @n = n
    @lists = Array.new(n){Array.new(n)}
    id = 0
    n.times do |i|
      n.times do |j|
        lists[i][j] = Cell.new(id)
        id += 1
      end
    end
  end

  def reveal(i,j,*flag)
    return flag(i,j) unless flag.empty?
    reveal_loop(i,j)
    check_game_status
  end

  def flag(i,j)
    lists[i][j].revealed = :flag
    check_game_status
  end

  def puts_list
    cur_stat_with_line_numbers = current_statuses
    cur_stat_with_line_numbers.each do |r|
      r.each {|a| print a.to_s.rjust([n.to_s.length, 2].max)}
      puts "\r"
    end
  end

  def create_board(bomb_count)
    bombs_set(bomb_count)
    numbers_set
  end

  def continuing?
    !game_over? && !game_clear?
  end

  private

    def reveal_loop(i,j)
      lists[i][j].revealed = true
      return if lists[i][j].status == :bomb
      return if (i < 0 || i > n-1 || j < 0 || j > n-1) || lists[i][j].status.to_s.match(/\d/)
      reveal_loop(i-1,j-1) if within_range?(i-1,j-1) && (not lists[i-1][j].revealed?)
      reveal_loop(i-1,j)   if within_range?(i-1,j)   && (not lists[i-1][j].revealed?)
      reveal_loop(i-1,j+1) if within_range?(i-1,j+1) && (not lists[i-1][j+1].revealed?)
      reveal_loop(i+1,j-1) if within_range?(i+1,j-1) && (not lists[i+1][j-1].revealed?)
      reveal_loop(i+1,j)   if within_range?(i+1,j)   && (not lists[i+1][j].revealed?)
      reveal_loop(i+1,j+1) if within_range?(i+1,j+1) && (not lists[i+1][j+1].revealed?)
      reveal_loop(i,j-1)   if within_range?(i,j-1)   && (not lists[i][j-1].revealed?)
      reveal_loop(i,j+1)   if within_range?(i,j+1)   && (not lists[i][j+1].revealed?)
    end

    def check_game_status
      return game_over  if game_over?
      return game_clear if game_clear?
      puts_list
    end

    def bombs_set(bomb_count)
      @bomb_count = bomb_count
      @bomb_map = Array.new(n*n,false)
      for c in 0...bomb_count
        bomb_map[c] = true
      end
      bomb_map.shuffle!
      bomb_map.each_with_index do |bool, idx|
        lists.flatten[idx].status = :bomb if bool
      end
    end

    def numbers_set
      bomb_map.each_slice(n).with_index do |line, i|
        line.each_with_index do |status, j|
          if status
            lists[i-1][j-1].status += 1 if (i != 0 && j != 0)     && lists[i-1][j-1].status != :bomb
            lists[i-1][j].status += 1   if i != 0                 && lists[i-1][j].status != :bomb
            lists[i-1][j+1].status += 1 if (i != 0 && j != n-1)   && lists[i-1][j+1].status != :bomb
            lists[i][j-1].status += 1   if j != 0                 && lists[i][j-1].status != :bomb
            lists[i][j+1].status += 1   if j != n-1               && lists[i][j+1].status != :bomb
            lists[i+1][j-1].status += 1 if (i != n-1 && j != 0)   && lists[i+1][j-1].status != :bomb
            lists[i+1][j].status += 1   if i != n-1               && lists[i+1][j].status != :bomb
            lists[i+1][j+1].status += 1 if (i != n-1 && j != n-1) && lists[i+1][j+1].status != :bomb
          end
        end
      end
      none_set
    end

    def none_set
      lists.flatten.each do |l|
        l.status = :safe if l.status == 0
      end
    end

    def game_over
      lists.flatten.each {|l| l.revealed = true if l.status == :bomb}
      puts_list
      puts "GAME OVER".center(n*([n.to_s.length,2].max)+n.to_s.length)
    end

    def game_over?
      lists.flatten.each do |l|
        return true if l.status == :bomb && l.revealed == true
      end
      false
    end

    def game_clear
      puts_list
      puts "CLEAR!!".center(n*([n.to_s.length,2].max)+n.to_s.length)
    end

    def game_clear?
      count = 0
      correct_flag = 0
      lists.flatten.each do |l|
        count += 1 if l.revealed?
        correct_flag += 1 if l.revealed == :flag && l.status == :bomb
      end
      count == n*n - bomb_count || correct_flag == bomb_count
    end

    def within_range?(i,j)
      i >= 0 && i < n && j >= 0 && j < n
    end

    def current_statuses
      cur_stat = []
      lists.flatten.each do |l|
        next cur_stat << "F" if l.revealed == :flag
        next cur_stat << "■" unless l.revealed?
        case s =  l.status
        when :safe
          cur_stat << "□"
        when :bomb
          cur_stat << "B"
        else
          cur_stat << s
        end
      end
      add_line_numbers(cur_stat)
    end

    def add_line_numbers(cur_stat)
      cur_stat.unshift([*1..n]).flatten!
      cur_stat_with_line_numbers = []
      cur_stat.each_slice(n).with_index do |r,i|
        next cur_stat_with_line_numbers[i] = r.unshift(" ") if i == 0
        cur_stat_with_line_numbers[i] = r.unshift(i)
      end
      cur_stat_with_line_numbers
    end
end
