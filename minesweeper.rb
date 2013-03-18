class Square
  attr_reader :location,
              :has_bomb,
              :up,
              :down,
              :left,
              :right,
              :up_left,
              :up_right,
              :down_left,
              :down_right

  attr_accessor :viewstate

  def initialize(position, has_bomb)
    @position = position
    @has_bomb = has_bomb
    @viewstate = :*
  end

  def place_bomb
    :has_bomb = true
  end

  def has_bomb?
    @has_bomb
  end

end

class Board
  attr_accessor :board_array

  def initialize(size = 9, bomb_count = 10)
    @size = size
    @bomb_count = bomb_count
    @board_array = Array.new(size) {Array.new(size)}
    add_squares(@board_array)
    plant_bombs(@board_array, @bombs)
    play
  end

  def add_squares(board_array)
    board_array.each_with_index do |row, y|
      row.each_with_index do |square, x|
        Square.new([x,y], false)
      end
    end
  end

  def plant_bombs(bomb_count)
    planted_bombs = 0
    until planted_bombs == bomb_count
      bomb_position = [rand(@size), rand(@size)]
      selected_square = board_array[bomb_position[0]][bomb_position[1]]
      if !selected_square.has_bomb?
        selected_square.place_bomb
        planted_bombs += 1
      end
    end
  end

  def play
    minesweeper = Board.new
  end

end