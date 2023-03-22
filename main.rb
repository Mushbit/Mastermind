# Adds codebreaker behavior to Player
module MastermindCodeMaker
  def create_secret_code
    # randomly select chars
  end

  def give_feedback
    # correct number + placement
  end
end

# Adds codeMaker behavior to Player
module MastermindCodeBreaker
  def guess_secret_code
    # code
  end
end

# Keeps track of game state
class MastermindBoard
  attr_reader :num_of_players

  # @board_state = board_state # state
  @num_of_players = 0

  class << self
    def add_player
      self.num_of_players += 1
    end
  end

  class << self
    def board_state
      attr_accessor :board_state
    end
  end

  def draw_board
    # code
  end

  def give_feedback
    # magic here..
  end
end

# Player template
class Player
  def initialize(name)
    @name = name
    @score = 0
    @role = MastermindBoard.num_of_players == 1 ? 'codebreaker' : 'codemaker'
  end
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
