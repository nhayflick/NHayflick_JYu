class Square
  attr_reader :position,
              :has_bomb,
              :neighbors


  attr_accessor :viewstate, :adjacent_bombs

  def initialize(position, has_bomb)
    @position = position
    @has_bomb = has_bomb
    @viewstate = :*
    @adjacent_bombs = 0
    @neighbors = []
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

  def initialize(size = 9, bomb_count = 10)
    @size = size
    @bomb_count = bomb_count
    @board_array = Array.new(size) {Array.new(size)}
    add_squares(@board_array)
    plant_bombs(@bomb_count)
    build_square_data(@board_array)
  end

  def add_squares(board_array)
    board_array.each_with_index do |row, y|
      row.each_with_index do |square, x|
        board_array[y][x] = Square.new([x,y], false)
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
        planted_bombs += 1
      end
    end
  end

  def build_square_data(board_array)
    board_array.each do |row|
      row.each do |square|
        get_neighbors(square)
        get_adjacent_bombs(square)
      end
    end
  end

  def get_neighbors(square)
    row,col = square.position[0], square.position[1]

    neighbor_array = [[row - 1, col - 1],
                      [row - 1, col],
                      [row - 1, col + 1],
                      [row, col + 1],
                      [row + 1, col +1],
                      [row + 1, col],
                      [row + 1, col -1],
                      [row, col - 1]]

    neighbor_array.each do |neighbor_position|
      if get_square(neighbor_position).class == Square
        square.neighbors << get_square(neighbor_position)
      end
    end
  end

  def get_adjacent_bombs(square)
    square.neighbors.each do |neighbor|
      square.adjacent_bombs += 1 if neighbor.has_bomb?
    end
  end

  def get_square(position)
    board_array[position[1]][position[0]]
  end

  def play
    minesweeper = Board.new
    user = Player.new
    until false #update_board != :game_in_progress
      move_valid = false
      pos_valid = false
      until pos_valid == true && move_valid == true
        user_move = user.get_move
        pos_valid = position_valid?(user_move[0])
        move_valid = move_valid?(user_move[1])
      end
      get_square(user_move[0]).change_square(user_move[1])
    end
  end

  def update_board
    board_array.each_with_index do |row, y|
      row.each_with_index do |square, x|
        if square.viewstate == :revealed
          if square.has_bomb?
            puts "Bomb found. You lose."
            return :loser
          else
            if square.adjacent_bombs > 0

            end

          end
        elsif square.viewstate == :flagged
        else
        end


      end
    end
  end

  def position_valid?(position)
    position.none? {|coordinate| coordinate > @size || coordinate < 0} &&
    get_square(position).viewstate != :revealed
  end

  def move_valid?(action)
    [:toggle_flag, :reveal].include?(action.to_sym)
  end

end

class Player

  def get_move
    puts "Enter square location or action"
    puts "[x,y] reveal or [x,y] toggle_flag"
    input = gets.chomp.split(' ')
    move_position, move_type = input.first.to_a, input.last.to_sym
  end
end