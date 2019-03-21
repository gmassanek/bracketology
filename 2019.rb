require 'pp'
require 'csv'

RPIS = {}
CSV.foreach('rpis.csv', headers: true) do |row|
  RPIS[row["Team"]] = row["RPI"].to_f
end

ODDS = {
  [1, 16] => 135 / 136.0,
  [2, 15] => 128 / 136.0,
  [3, 14] => 115 / 136.0,
  [4, 13] => 108 / 136.0,
  [5, 12] => 89 / 136.0,
  [6, 11] => 84 / 136.0,
  [7, 10] => 85 / 136.0,
  [8, 9] => 69 / 136.0,
}

EAST_SEEDS = {
  1 => 'Duke',
  2 => 'Michigan State',
  3 => 'LSU',
  4 => 'Virginia Tech',
  5 => 'Mississippi State',
  6 => 'Maryland',
  7 => 'Louisville',
  8 => 'VCU',
  9 => 'UCF',
  10 => 'Minnesota',
  11 => 'Belmont',
  12 => 'Liberty',
  13 => 'Saint Louis',
  14 => 'Yale',
  15 => 'Bradley',
  16 => 'North Dakota State'
}

SOUTH_SEEDS = {
  1 => 'Virginia',
  2 => 'Tennessee',
  3 => 'Purdue',
  4 => 'Kansas State',
  5 => 'Wisconsin',
  6 => 'Villanova',
  7 => 'Cincinnati',
  8 => 'Ole Miss',
  9 => 'Oklahoma',
  10 => 'Iowa',
  11 => 'Saint Mary’s',
  12 => 'Oregon',
  13 => 'UC Irvine',
  14 => 'Old Dominion',
  15 => 'Colgate',
  16 => 'Gardner-Webb',
}

MIDWEST_SEEDS = {
  1 => 'North Carolina',
  2 => 'Kentucky',
  3 => 'Houston',
  4 => 'Kansas',
  5 => 'Auburn',
  6 => 'Iowa State',
  7 => 'Wofford',
  8 => 'Utah State',
  9 => 'Washington',
  10 => 'Seton Hall',
  11 => 'Ohio State',
  12 => 'New Mexico State',
  13 => 'Northeastern',
  14 => 'Georgia State',
  15 => 'Abilene Christian',
  16 => 'Iona',
}

WEST_SEEDS = {
  1 => 'Gonzaga',
  2 => 'Michigan',
  3 => 'Texas Tech',
  4 => 'Florida State',
  5 => 'Marquette',
  6 => 'Buffalo',
  7 => 'Nevada',
  8 => 'Syracuse',
  9 => 'Baylor',
  10 => 'Florida',
  11 => 'Arizona St',
  12 => 'Murray State',
  13 => 'Vermont',
  14 => 'Northern Kentucky',
  15 => 'Montana',
  16 => 'Fairleigh Dickinson',
}

ALL_CONFS = [EAST_SEEDS, WEST_SEEDS, SOUTH_SEEDS, MIDWEST_SEEDS]

class Team
  attr_reader :seed, :name, :rpi

  def initialize(seed, name)
    @seed = seed
    @name = name
    @rpi = RPIS[@name]
  end

  def to_s
    "#{@name} (#{@seed})"
  end
end

EAST = {}
WEST = {}
MIDWEST = {}
SOUTH = {}

EAST_SEEDS.each { |seed, name| EAST[seed] = Team.new(seed, name) }
WEST_SEEDS.each { |seed, name| WEST[seed] = Team.new(seed, name) }
MIDWEST_SEEDS.each { |seed, name| MIDWEST[seed] = Team.new(seed, name) }
SOUTH_SEEDS.each { |seed, name| SOUTH[seed] = Team.new(seed, name) }
ALL = [EAST, WEST, SOUTH, MIDWEST]

MATCHUPS = [
  [1, 16],
  [8, 9],
  [5, 12],
  [4, 13],
  [6, 11],
  [3, 14],
  [7, 10],
  [2, 15],
]

def probability(better, worse)
  worse / (better + worse).to_f
end

def pick_winner(team_1, team_2)
  favorite, underdog = [team_1, team_2].sort_by(&:seed)
  round1_odds = ODDS[[favorite.seed, underdog.seed]]
  better_probs = round1_odds || probability(favorite.seed - favorite.rpi, underdog.seed - underdog.rpi)
  #better_probs = probability(favorite.seed, underdog.seed)
  game_rand = rand()

  game_rand <= better_probs ? favorite : underdog
end

final_four = []
ALL.each do |conf|
  #### ROUND 1
  round2_teams = []
  MATCHUPS.each do |high_seed, low_seed|
    favorite = conf[high_seed]
    underdog = conf[low_seed]
    winner = pick_winner(favorite, underdog)
    round2_teams << winner
  end; nil
  pp round2_teams.map(&:to_s)

  #### ROUND 2
  round3_teams = []
  while round2_teams.length > 0 do
    players = round2_teams.shift(2)

    round3_teams << pick_winner(players.first, players.last)
  end
  pp round3_teams.map(&:to_s)

  #### ROUND 3
  round4_teams = []
  while round3_teams.length > 0 do
    players = round3_teams.shift(2)

    round4_teams << pick_winner(players.first, players.last)
  end
  pp round4_teams.map(&:to_s)

  #### ROUND 4
  round5_teams = []
  while round4_teams.length > 0 do
    players = round4_teams.shift(2)

    round5_teams << pick_winner(players.first, players.last)
  end
  pp round5_teams.map(&:to_s)

  final_four << round5_teams.first
  puts ""
end

puts "FINAL FOUR"
pp final_four.map(&:to_s)


puts ""
puts "FINALS"
puts game1_winner = pick_winner(final_four[0], final_four[1])
puts game2_winner = pick_winner(final_four[2], final_four[3])

puts ""
puts "WINNER"
puts champ = pick_winner(game1_winner, game2_winner)
