require 'pry-byebug'
# Keeps track of game state
class Board
  @@num_player = 0

  def initialize
    @board_state = Array.new(12) { Array.new(4) { '-' } }.unshift(Array.new(4) { 'X' })
    @progress_indicators = Array.new(12) { Array.new(2) { '-' } }.unshift(%w[V O])
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
    store_code(Array.new(4) { rand(6) + 1 })
  end

  def attempt_break(gc)
    # #map is being used to change object_id
    update_board_state(gc.map(&:to_s))
    sc = store_code.map(&:to_i)

    gc.each_index do |i|
      next unless gc[i] == sc[i]

      sc[i] = 'V'
      gc[i] = nil
    end.compact!

    near_match(gc, sc)
    v_count = update_indicator_state(sc)
    draw_board
    [v_count, self.attempt_iterator -= 1]
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
    progress_indicators[attempt_iterator][0]
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
  attr_accessor :name
  attr_reader :role, :type
  def initialize(name, type)
    @name = name
    @score = 0
    @role = if Board.player == 0
      'breaker'
    else
      'maker'
    end
    @type = type
  end
end

# Runs the game
class Game
  attr_accessor :player1, :player2, :game

  def initialize(name1)
    @game = Board.new
    @player1 = Player.new(name1, 'user_character')
    @player2 = choose_players
  end

  def choose_players
    puts ' Will your nemesis be of flesh and blood? Y/n'
    prompt = "n" # gets.chomp
    if  prompt.match(/y/i)
      puts ' Codemaker, reveal your name/alias:'
      Player.new(gets.chomp, 'user_character')
      Board.add_player
    else
      name_cp = ['CH405', '470M', 'C1PH3R', 'D0C', '4C3', 'D00M'].sample
      puts " hahaa, so you want to take on a computational marvel like myself?!\n #{name_cp} hereby accepts your challenge!"
      Player.new(name_cp, 'non_user_character')
    end
  end

  def run_game
    game.generate_rand_code
    game.draw_board
    instructions
  end

  def instructions
    puts " You will have 12 turns to match the code.\n\n Type in 4 numbers ranging from 1 - 6.\n\n The number that appears underneath 'V' indicates that one of\n the characters is in the correct possition.\n\n The number that appears underneath 'O' indicate that the\n character is pressent in the code but does not sit in the correct possition.\n\n The same numbers can be placed more than once.\n\n Secret code example: 1121\n Code break example:  2416\n\n 'V' = 0 because no number is placed correctly.\n 'O' = 2 and not 4 because 1 only counts once like 2 only counts once"
    player = player1.role.match?(/breaker/) ? self.player1 : self.player2
    play_round(player)
  end

  def play_round(player)
    puts " Go ahead, #{player.name}, and guess the code:\n"

    win_stat = []
    retries = 2
    begin
      win_stat = game.attempt_break(gets.chomp.split('').map(&:to_i))
    rescue => exception
      if retries > 0
        puts " Beep Boop, erroneous input! Reiterate, please..."
        retry
      else
        puts " Beep Boop, erroneous input! Your persistent passing of inaccurate code is exasperating!\n\n Therefor I will reassign your name state to be: #{player.name = "Nincompoop"}\n\n Just write down 4 numbers between 0 and 7. \n Same numbers are allowed"
        retry
      end
    end
    check_win(player, win_stat)

  end

  def check_win(player, win_stat)
    if win_stat[0] > 3
      maker_win
    elsif win_stat[1] < -13
      breaker_win
    else
      play_round(player)
    end
  end

  def maker_win
    puts " You beat me?! I am not worth the blessing of the Omnissiah..\n"
  end

  def breaker_win
    puts " Opponent obliteration successful!\n"
  end
end

def setup_game
  puts 'Want to test your mettle in a game of Mastermind? Y/n'
  return unless gets.chomp.match?(/y/i)

  puts 'Please type in the name of he who breaks code:'
  name1 = gets.chomp
  puts mastermind = Game.new(name1)
  puts ' All hail the omnisia, for the flesh is weak!\n Press enter to begin'
  gets.chomp
  mastermind.run_game
  reset_game(name1)
end

def reset_game(name1)
  puts " Want to try again #{name1}? Y/n"
  return unless gets.chomp.match?(/y/i)
  mastermind = Game.new(name1)
  mastermind.run_game
  reset_game(name1)
end
