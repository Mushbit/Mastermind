require 'pry-byebug'
# Stores and updates game state
class Board
  @@num_player = 0

  attr_reader :xpert_mode

  def initialize(xpert_mode)
    @xpert_mode = xpert_mode
    @board_state = Array.new(12) { Array.new(@xpert_mode ? 5 : 4) { '-' } }.unshift(Array.new(@xpert_mode ? 5 : 4) { 'X' })
    @progress_indicators = Array.new(12) { Array.new(2) { '-' } }.unshift(%w[V O])
    @attempt_iterator = -1
    @@maker_code = false
  end

  def self.add_player
    @@num_player += 1
  end

  def self.remove_player
    @@num_player -= 1
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
    store_code(Array.new(@xpert_mode ? 5 : 4) { rand(@xpert_mode ? 8 : 6) + 1 })
  end

  def pass_maker_code(maker_code)
    store_code(maker_code)
    nil
  end

  def print_maker_code
    store_code.join('')
  end

  def attempt_break(breaker_code)
    # #map is being used to change object_id
    update_board_state(breaker_code.map(&:to_s))
    maker_code = store_code.map(&:to_i)

    breaker_code.each_index do |i|
      next unless breaker_code[i] == maker_code[i]

      maker_code[i] = 'V'
      breaker_code[i] = nil
    end.compact!

    near_match(breaker_code, maker_code)
    count_matching_chars = update_indicator_state(maker_code)
    draw_board
    [count_matching_chars, self.attempt_iterator -= 1]
  end

  def near_match(breaker_code, maker_code)
    maker_code.each_index do |i|
      if breaker_code.any?(maker_code[i])
        breaker_code.delete_at(breaker_code.index(maker_code[i]))
        maker_code[i] = 'O'
      end
    end
  end

  def update_board_state(breaker_code)
    board_state[attempt_iterator] = breaker_code
  end

  def update_indicator_state(maker_code)
    progress_indicators[attempt_iterator][0] = 0
    progress_indicators[attempt_iterator][1] = 0

    maker_code.tally.each do |k, v|
      progress_indicators[attempt_iterator][0] = v if k == 'V'
      progress_indicators[attempt_iterator][1] = v if k == 'O'
    end
    progress_indicators[attempt_iterator][0]
  end

  private

  attr_accessor :board_state, :progress_indicators, :attempt_iterator

  def store_code(code = 'No code generated')
    @@maker_code ||= code
    @@maker_code
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
    @role = Board.player.even? ? 'breaker' : 'maker'
    @type = type
  end
end

# Runs the game
class Game
  attr_accessor :player1, :player2, :game

  def initialize(name1, name2 = false)
    puts "\nFancy a challenge and want to try xpert mode? Y/n\n"
    @game = Board.new(gets.chomp.match?(/y/i))
    @player1 = Player.new(name1, 'player_character')
    Board.add_player
    @player2 = name2 ? Player.new(name2, 'player_character') : choose_players
  end

  def choose_players
    puts "\n Will your nemesis be of flesh and blood? Y/n\n"
    prompt = gets.chomp
    if  prompt.match(/y/i)
      puts "\n Codemaker, reveal your name/alias:"
      Player.new(gets.chomp, 'player_character')
    else
      name_npc = %w[CH405 470M C1PH3R D0C 4C3 D00M].sample
      puts "\n hahaa, so you want to take on a computational marvel like myself?!\n #{name_npc} hereby accepts your challenge!\n"
      npc = Player.new(name_npc, 'non_player_character')
      Board.remove_player
      npc
    end
  end

  def setup_game
    maker, breaker = player1.role > player2.role ? [player1, player2] : [player2, player1]
    game.draw_board
    case player2.type
    when 'non_player_character'
      game.generate_rand_code
      instructions
    when 'player_character'
      instructions
      puts "\n Pick the secret code #{maker.name}:\n"
      game.pass_maker_code(input_code(maker))
    else
      puts "\n Error. Player2 type does not correspond\n"
    end
    play_round(breaker)
  end

  def instructions
    puts "\n You will have 12 turns to match the code.\n\n Type in #{game.xpert_mode ? '5' : '4'} numbers ranging from 1 - #{game.xpert_mode ? '8' : '6'}.\n\n The number that appears underneath 'V' indicates that one of\n the characters is in the correct possition.\n\n The number that appears underneath 'O' indicate that the\n character is pressent in the code but does not sit in the correct possition.\n\n The same numbers can be placed more than once.\n\n Secret code example: #{game.xpert_mode ? '11215' : '1121'}\n Code break example:  #{game.xpert_mode ? '27168' : '2416'}\n\n 'V' = 0 because no number is placed correctly.\n 'O' = 2 and not 4 because 1 only counts once like 2 only counts once\n"
  end

  def play_round(breaker)
    puts "\n Go ahead, #{breaker.name}, and guess the code:\n"
    input_data = input_code(breaker)
    attempt_data = game.attempt_break(input_data)
    check_win(breaker, attempt_data)
  end

  def input_code(current_player)
    retries = 2
    begin
      input = game.xpert_mode ? gets.chomp.match(/^[1-8]{5}$/)[0] : gets.chomp.match(/^[1-6]{4}$/)[0]
      input.split('').map(&:to_i)
    rescue StandardError => e
      if retries > 0
        puts "\n Beep Boop, erroneous input! Reiterate, please...\n"
        retries -= 1
        retry
      else
        puts "\n Beep Boop, erroneous input! Your persistent passing of inaccurate code is exasperating!\n Therefor I will reassign the value of your name state. \n\n Just write down #{game.xpert_mode ? '5' : '4'} numbers between 1 and #{game.xpert_mode ? '8' : '6'}, #{current_player.name = 'Nincompoop'}. \n Same numbers are allowed\n"
        retry
      end
    end
  end

  def check_win(breaker, attempt_data)
    if attempt_data[0] > (game.xpert_mode ? 4 : 3)
      maker_win
    elsif attempt_data[1] < -12
      breaker_win
    else
      play_round(breaker)
    end
  end

  def maker_win
    puts "\n You beat me?! I am not worth the blessing of the Omnissiah..\n\n The secret code was: #{game.print_maker_code}\n"
  end

  def breaker_win
    puts "\n Gg!\n\n The secret code was: #{game.print_maker_code}\n"
  end
end

def run_game
  puts "\n Want to test your mettle in a game of Mastermind? Y/n\n"
  return unless gets.chomp.match?(/y/i)

  puts "\n Please type in the name of he who breaks code:\n"
  name1 = gets.chomp
  mastermind = Game.new(name1)

  name2 = mastermind.player2.name unless mastermind.player2.type == 'non_player_character'
  puts "\n Press enter to begin"
  gets.chomp
  mastermind.setup_game
  reset_game(name1, name2)
end

def reset_game(name1, name2 = false)
  puts ' Want to play again? Y/n'
  return unless gets.chomp.match?(/y/i)
  mastermind = Game.new(name1, name2)
  name2 = mastermind.player2.name unless mastermind.player2.type == 'non_player_character'
  puts "\n Press enter to begin"
  gets.chomp
  mastermind.setup_game
  reset_game(name1, name2)
end
