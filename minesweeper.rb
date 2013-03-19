class Square
  attr_reader :position,
              :has_bomb

  attr_accessor :viewstate, :adjacent_bombs, :neighbors, :ever_opened

  def initialize(position, has_bomb)
    @position = position
    @has_bomb = has_bomb
    @viewstate = :*
    @adjacent_bombs = 0
    @neighbors = []
    @ever_opened = false
  end

  def place_bomb
    @has_bomb = true
  end

  def has_bomb?
    @has_bomb
  end

  def change_square(action)
    if action == :reveal
      @viewstate = :reveal
    else
      @viewstate = @viewstate == :flagged ? :* : :flagged
    end
  end

end

class Board
  attr_accessor :board_array

  def initialize(size = 9, bomb_count = 8)
    @size = size
    @bomb_count = bomb_count
    @board_array = Array.new(size) { Array.new(size) }
    # REV: (fyi) alternative: Array.new(size, Array.new(size))
    add_squares(@board_array)
    plant_bombs(@bomb_count)
    #build_square_data(@board_array)
  end

  def add_squares(board_array)
    board_array.each_with_index do |row, y|
      row.each_with_index do |square, x|
        board_array[y][x] = Square.new([x, y], false)
      end
    end
  end

  def plant_bombs(bomb_count)
    planted_bombs = 0
    until planted_bombs == bomb_count
      bomb_position = [rand(@size), rand(@size)]
      selected_square = get_square(bomb_position)
      if !selected_square.has_bomb?
        selected_square.place_bomb
        p "bomb planted #{selected_square.position}"
        planted_bombs += 1
      end
    end
  end

  #def build_square_data(board_array)
  #  board_array.each do |row|
  #    row.each do |square|
  #      get_neighbors(square)
  #      get_adjacent_bombs(square)
  #    end
  #  end
  #end

  def get_neighbors(square)
    square.neighbors = []
    row,col = square.position[0], square.position[1]

    # REV: I like this. It's a lot nicer to read than the double loop I had.
    neighbor_array = [[row - 1, col - 1],
                      [row - 1, col],
                      [row - 1, col + 1],
                      [row, col + 1],
                      [row + 1, col +1],
                      [row + 1, col],
                      [row + 1, col -1],
                      [row, col - 1]]

    neighbor_array.each do |neighbor_position|
      # if neighbor_position[0] >= 0 && neighbor_position[0] < @size && neighbor_position[1] >= 0 && neighbor_position[1] < @size
      # REV: Above line is a bit long and repetitive. Consider shortening it.
      # Here's what I came up with:
      if neighbor_position.all? { |x| x.between(0, size - 1) }
        square.neighbors << get_square(neighbor_position)
      end
    end
  end

  # REV: Consider renaming to "num_adjacent_bombs", since that's what it
  # returns.
  def get_adjacent_bombs(square)
    square.adjacent_bombs = 0
    square.neighbors.each do |neighbor|
      square.adjacent_bombs += 1 if neighbor.has_bomb?
    end
    square.adjacent_bombs
  end

  def get_square(position)
    board_array[position[1]][position[0]]
  end

  def play
    user = Player.new
    until win?(board_array)
      move_valid = false
      pos_valid = false
      until pos_valid == true && move_valid == true
        user_move = user.get_move
        pos_valid = position_valid?(user_move[0])
        move_valid = move_valid?(user_move[1])
      end
      square_selected = get_square(user_move[0])
      square_selected.change_square(user_move[1])
      if update(square_selected) == :loser
        return
      end
      print_board(board_array)
    end
    puts "You Win! puts #{@bomb_count}"
  end

  # REV: Considering decomposing this methods into helper methods?
  def update(square)
    get_neighbors(square)

    if square.ever_opened == false
      square.ever_opened = true
      if square.has_bomb?
        puts "Bomb found. You lose."
        return :loser
      elsif get_adjacent_bombs(square) == 0
        square.neighbors.each do |square|
          get_neighbors(square)
          get_adjacent_bombs(square)
          square.change_square(:reveal) unless square.viewstate == :flagged
          update(square)
        end
      end
    end
  end

  def win?(board_array)
    flagged_bombs = 0
    false_flags = 0

    board_array.each do |row|
      row.each do |square|
       flagged_bombs += 1 if square.has_bomb? && square.viewstate == :flagged
       false_flags += 1 if !square.has_bomb? && square.viewstate == :flagged
      end
    end
    # REV: Might be able to express the underlying logic better as:
    # if flagged_bombs == @bomb_count && false_flags == 0
    if flagged_bombs - false_flags == @bomb_count
      return true
    end

    return false
  end

  def position_valid?(position)
    # position.none? {|coordinate| coordinate > @size || coordinate < 0} &&
    # REV: Here's a shorter way to do the above line:
    position.all? { |coord| coord.between(0, @size) } &&
    get_square(position).viewstate != :revealed
  end

  def move_valid?(action)
    [:toggle_flag, :reveal].include?(action.to_sym)
  end

  # REV: Could shorten the lines here by using when/then.
  def print_board(board)
    board.each do |row|
      row.each do |square|
        print "|"
        case square.viewstate
        # REV: when/then example: when :* then print "*"
        when :*
          print "*"
        when :flagged
          print "F"
        when :reveal
          if square.has_bomb?
            print "BOOM, you're dead"
          else
            #get_neighbors(square)
            get_adjacent_bombs(square)
            if square.adjacent_bombs == 0
              print "_"
            else
              print square.adjacent_bombs
            end
          end
        end
      end
      print "| \n"
    end
  end

end

class Player
  def get_move
    puts "Enter square location or action"
    puts "x y reveal or x y toggle_flag"
    input = gets.chomp.split(' ')
    move_position, move_type = [input.first.to_i, input[1].to_i], input[2].to_sym
  end
end

minesweeper = Board.new
minesweeper.play