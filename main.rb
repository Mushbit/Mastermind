require 'pry-byebug'
# Adds codebreaker behavior to Player
module MastermindCodeMaker
  def generate_secret_code
    4.times.map { rand(10) }
  end

  def give_feedback
    # correct number + placement
  end
end

# Adds codeMaker behavior to Player
module MastermindCodeBreaker
  def guess_secret_code(guess)
    MastermindBoard.match_secret_code(guess) # <------- i left off here!!!
  end
end

# Keeps track of game state
class MastermindBoard
  attr_reader :num_of_players

  def initialize
    # code
    @board_state = Array.new(12) { Array.new(4) { '-' } }.unshift(Array.new(4) { 'X' })
    @code_break_indicators = Array.new(12) { Array.new(2) { '-' } }.unshift(%w[V O])
    @num_of_players = 0
  end

  def add_player
    self.num_of_players += 1
  end

  def draw_board
    # code
    board = create_board(@board_state, @code_break_indicators)
    p board
    puts board.map(&:join)
  end

  def give_feedback
    # magic here..
  end

  private

  attr_accessor :board_state, :code_break_indicators
  attr_writer :num_of_players

  def create_board(state, indicators)
    side_bar = []
    (1..13).each do |i|
      case i
      when (1..9) then side_bar.unshift("#{i}  ")
      when (10..12) then side_bar.unshift("#{i} ")
      when 13 then side_bar.unshift('   ')
      end
    end
    (0..12).map { |i| [side_bar[i], state[i], ' ', indicators[i]] }
  end
end

# Player template
class Player
  def initialize(name)
    @name = name
    @score = 0
    @role = MastermindBoard.num_of_players == 1 ? 'codebreaker' : 'codemaker'
    MastermindBoard.add_player
  end

  include MastermindCodeBreaker
end

# Runs the game
class Game
  def initialize
    # codebreaker = Player.new(name)
    # codemaker = Player.new(name)
    # board = MastermindBoard.new
  end

  def instructions
    # instruction magic...
  end

  def play_round
    # player round type of code..
  end

  def error_handling
    # yep...
  end
end
