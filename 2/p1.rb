#!/usr/bin/env ruby

module Day2
  class Bag
    attr_reader :green, :red, :blue

    def initialize(vals = {})
      @green = vals.fetch("green", 0)
      @red = vals.fetch("red", 0)
      @blue = vals.fetch("blue", 0)
    end

    def can_play?(showing)
      green >= showing.green &&
        red >= showing.red &&
        blue >= showing.blue
    end
  end

  class Showing
    attr_reader :green, :red, :blue

    def initialize(vals)
      @green = vals.fetch("green", 0)
      @red = vals.fetch("red", 0)
      @blue = vals.fetch("blue", 0)
    end

    def |(other)
      Showing.new(
        "green" => [green, other.green].max,
        "red" => [red, other.red].max,
        "blue" => [blue, other.blue].max
      )
    end

    def power
      green * blue * red
    end
  end

  def self.p2(input)
    games = decode(input)

    games.values.sum do |showings|
      showings.reduce(&:|).power
    end
  end

  def self.p1(input)
    games = decode(input)
    comparison = Bag.new("green" => 13, "red" => 12, "blue" => 14)

    total = 0

    games.each do |game_id, showings|
      total += game_id if showings.all? { |showing| comparison.can_play?(showing) }
    end

    total
  end

  def self.decode(input)
    input.lines(chomp: true).reduce({}) do |result, line|
      result.merge(decode_line(line))
    end
  end

  def self.decode_line(line)
    game, moves = line.split(":")
    game_id = game.split(" ").last.to_i

    digested_moves = moves.split(";").map do |round|
      vals = round.split(", ").reduce({}) do |result, showing|
        count, color = showing.split(" ")
        result[color] = count.to_i
        result
      end

      Showing.new(vals)
    end

    {
      game_id => digested_moves
    }
  end
end
