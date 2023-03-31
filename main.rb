require 'pry-byebug'
# Keeps track of game state
class Board
  attr_reader :num_of_players

  @@num_player = 0

  def initialize
    # code
    @board_state = Array.new(12) { Array.new(4) { '-' } }.unshift(Array.new(4) { 'X' })
    @progress_indicators = Array.new(12) { Array.new(2) { '-' } }.unshift(%w[V O])
    generate_secret_code
  end

  def self.add_player
    @@num_player += 1
  end

  def self.player
    @@num_player
  end

  def draw_board
    puts create_board(@board_state, @progress_indicators).map(&:join)
  end

  def give_feedback
    # magic here..
  end

  def generate_secret_code
    store_secret_code(4.times.map { rand(4) })
  end

  def match_secret_code(guess) # <-------- working on this
    gc = guess
    sc = store_secret_code
    gc.each_index do |i|
      next unless gc[i] == sc[i]

      sc[i] = 'V'
      gc[i] = nil
    end.compact!

    sc.each_index do |i|
      if gc.any?(sc[i])
        sc[i] = 'O'
        gc[i] = nil
      end
    end
  end

  private

  attr_accessor :board_state, :progress_indicators

  def store_secret_code(code = 'No code generated')
    @secret_code = code unless @secret_code
    @secret_code
  end

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
    @role = if Board.player == 1
              'breaker'
            else
              'maker'
            end
    Board.add_player
  end

  def guess_secret_code(guess)
    game.match_secret_code(guess)
  end
end

# Runs the game
class Game
  def initialize
    # codebreaker = Player.new(name)
    # codemaker = Player.new(name)
    # board = Board.new
    generate_secret_code
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

# max = Player.new('Max')
game = Board.new
