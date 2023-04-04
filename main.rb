require 'pry-byebug'
# Keeps track of game state
class Board
  @@num_player = 0

  def initialize
    @board_state = Array.new(12) { Array.new(4) { '-' } }.unshift(Array.new(4) { 'X' })
    @progress_indicators = Array.new(12) { Array.new(2) { '-' } }.unshift(%w[V O])
    # is 1 because
    @attempt_iterator = -1
    @@secret_code = false
    generate_rand_code
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
    puts @@secret_code = code unless @@secret_code
    @@secret_code
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

end

# Runs the game
class Game
  attr_accessor :player1
  def initialize
    puts 'Please type in the name of the one who breaks code:'
    @player1 = Player.new(gets.chomp)
    choose_players
    @player2 = Player.new(gets.chomp)
    game = Board.new
    generate_rand_code
  end

  def choose_players
    puts 'Will your nemesis be of flesh and blood?'
    prompt = gets.chomp
    if  prompt.match(/y/i)
      puts 'Codemaker, reveal your name/alias:'
      Player.new(gets.chomp)
    else
      name_cp = ['CH405', '470M', 'C1PH3R', 'D0C', '4C3', 'D00M'].sample
      puts "hahaa, so you want to take me on?!\n #{name_cp} hereby accepts your challenge!"
      Player.new(name_cp)
    end
  end

  def guess_secret_code
    puts 'Go ahead and guess the code:'
    retries = 1
    begin
      game.attempt_break(gets.chomp.split('').map(&:to_i))
    rescue => exception
      if retries > 0
      puts "Beep Boop, erroneous input! Try again..."
      else
        puts "Beep Boop, erroneous input! Try again...again\n Just write down 4 numbers between 0 and 7 \n Duplicate numbers are allowed"
      end
      retry
    end

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
p game
game.attempt_break([1, 2, 3, 4])
game.attempt_break([1, 1, 3, 5])
p game
