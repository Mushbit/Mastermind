require 'pry-byebug'
# Keeps track of game state
class Board
  attr_reader :num_of_players

  @@num_player = 0

  def initialize
    @board_state = Array.new(12) { Array.new(4) { '-' } }.unshift(Array.new(4) { 'X' })
    @progress_indicators = Array.new(12) { Array.new(2) { '-' } }.unshift(%w[V O])
    # is 1 because
    @attempt_iterator = -1
    @@secret_code = false
  end

  def self.add_player
    @@num_player += 1
  end

  def self.player
    @@num_player
  end

  def draw_board
    puts "\n"
    puts create_board(@board_state, @progress_indicators).map(&:join)
    puts "\n"
  end

  def generate_rand_code
    store_code(4.times.map { rand(7) })
  end

  def attempt_break(guess)
    # #map is being used to change object_id
    update_board_state(guess.map(&:to_s))
    gc = guess
    sc = store_code.map(&:to_i)

    gc.each_index do |i|
      next unless gc[i] == sc[i]

      sc[i] = 'V'
      gc[i] = nil
    end.compact!

    near_match(gc, sc)
    update_indicator_state(sc)
    draw_board
  end

  def near_match(gc, sc)
    sc.each_index do |i|
      if gc.any?(sc[i])
        gc.delete_at(gc.index(sc[i]))
        sc[i] = 'O'
      end
    end
  end

  def update_board_state(gc)
    board_state[attempt_iterator] = gc
  end

  def update_indicator_state(sc)
    progress_indicators[attempt_iterator][0] = 0
    progress_indicators[attempt_iterator][1] = 0

    sc.tally.each do |k, v|
      progress_indicators[attempt_iterator][0] = v if k == 'V'
      progress_indicators[attempt_iterator][1] = v if k == 'O'
    end
    self.attempt_iterator -= 1

  end

  private

  attr_accessor :board_state, :progress_indicators, :attempt_iterator

  def store_code(code = "No code generated")
    @@secret_code = code unless @@secret_code
    @@secret_code # Perhaps change to class variable making @@secret_code false on initialize
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
    # Needs to pass an arrray
    game.attempt_break(guess)
  end
end

# Runs the game
class Game
  def initialize
    # codebreaker = Player.new(name)
    # codemaker = Player.new(name)
    # board = Board.new
    generate_rand_code
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

p max = Player.new('Max')
p game = Board.new
p game.generate_rand_code
p game
game.attempt_break([1, 2, 3, 4])
game.attempt_break([1, 1, 3, 5])
p game
