# Require the bundler gem and then call Bundler.require to load in all gems
# listed in Gemfile.
require 'bundler'
Bundler.require

# Setup DataMapper with a database URL. On Heroku, ENV['DATABASE_URL'] will be
# set, when working locally this line will fall back to using SQLite in the
# current directory.
DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite")

# This is the (limited) dictionary. In a real game you might want to have categories and clues.
DICTIONARY = ["London","New York","Cape Town","Beijing"]

# Define a simple DataMapper model.
class Game
  include DataMapper::Resource
  property :game_id, Serial, :key => true
  property :created_at, DateTime
  property :updated_at, DateTime
  property :word, String, :required => true
  property :display_word, String, :required => true
  property :letters_used, String, :default => ""
  property :guesses_remaining, Integer, :default => 10
  property :state, Integer, :default => 0
end

# Finalize the DataMapper models.
DataMapper.finalize

# Tell DataMapper to update the database according to the definitions above.
DataMapper.auto_upgrade!

get '/' do
  {:success => "welcome to hangman"}.to_json
end

get '/games' do
  content_type :json
  @games = Game.all(:order => :updated_at.desc)
  # generate how the string should be displayed on the client
  @games.to_json(:exclude => :word)
end

# CREATE: Route to create a new Game
post '/games/new' do
  content_type :json

  @game = Game.new()

  # get a random word from the dictionary
  word = DICTIONARY.sample.upcase

  @game.word = word
  @game.display_word = word.gsub(/[A-z]/, "_")

  if @game.save
    @game.to_json(:exclude => :word)
  else
    halt 500
  end
end

# READ: Route to show a specific Game based on its `id`
get '/games/:id' do
  content_type :json
  @game = Game.get(params[:id].to_i)

  if @game
    @game.to_json(:exclude => :word)
  else
    halt 404
  end
end

# guess a letter
post '/games/:id/guess' do
  content_type :json

  # the logic here goes:

  # - validate the input
  # - get the game using the id
  # - check if the letter has been used already, if so, return error
  # - check if the letter is in the word. if so, update display_word and add letter to letters_used. if not, decrement guesses and add to letters used
  # - terminate the game with a win/lose if applicable

  letter_to_check = params[:letter]

  if !letter_to_check
    halt 400, {:error => "Missing a letter"}.to_json
  end

  if letter_to_check.length > 1
    halt 400, {:error => "Not so fast – only one letter at a time"}.to_json
  end

  if !letter_to_check.match(/^[A-z]+$/)
    halt 400, {:error => "That's not in the alphabet"}.to_json
  end

  letter_to_check = letter_to_check.upcase

  @game = Game.get(params[:id].to_i)

  if params[:letter]

    letters_used = @game.letters_used.split(",").to_set

    if letters_used.include? letter_to_check
      # letter has been used already
      halt 400, {:error => "Letter already used"}.to_json
    else
      # letter is new

      letters_used << letter_to_check

      # add the letter to letters used
      if @game.letters_used.length == 0
        @game.letters_used = letter_to_check

      else
        @game.letters_used += ","
        @game.letters_used += letter_to_check
      end

      # check if it is contained in the word
      if @game.word.include? letter_to_check
        # letter is in the word, don't decrement letters_used

        # if they have guessed all the letters i.e. the set intersects exactly
        ## use a set intersection

        letters_in_word = @game.word.split("").to_set.delete(" ")

        puts "letters in word: #{letters_in_word}"

        if letters_in_word.subtract(letters_used).empty?
          # guessed the word, no need to loop through and add underscores
          @game.state = 1
          @game.display_word = @game.word
        else

          # assemble how the word is to be displayed, e.g. FOOTBALL as F__TB_LL
          display_word = ""
          @game.word.split("").each do |i|
            # don't replace whitespace with an underscore
            if (i == " ") || (letters_used.include? i)
              display_word += i
            else
              display_word += "_"
            end
          end
          @game.display_word = display_word

        end

      else
        @game.guesses_remaining -= 1

        # if gueses remaining == 0, game is over
        if @game.guesses_remaining == 0
          @game.state = 2
        end
      end

      if @game.save
        @game.to_json(:exclude => :word)
      else
        halt 500
      end

    end

  else
    halt 400, {:error => "Missing letter"}.to_json
  end

end
