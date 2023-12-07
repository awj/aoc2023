#!/usr/bin/env ruby

module Day4
  def self.parse(input)
    input.lines(chomp: true).map do |line|
      id, numbers = line.split(":")
      winning, numbers = numbers.split("|")
      winners = winning.split(" ").map(&:to_i)
      numbers = numbers.split(" ").map(&:to_i)

      Card.new(id, winners, numbers)
    end
  end

  def self.p1(input)
    parse(input).sum(&:score)
  end

  def self.p2(input)
    card_set = parse(input)

    totals = {}

    card_set.map do |card|
      totals.merge!(card.copy_tally(card_set)) do |key, old_val, new_val|
        old_val + new_val
      end
    end

    totals.values.sum
  end

  class Card
    attr_reader :id, :winners, :numbers

    def initialize(id, winners, numbers)
      @id = id
      @index = id.split(" ").last.to_i
      @winners = Set.new(winners)
      @numbers = Set.new(numbers)
    end

    def winning_numbers
      winners & numbers
    end

    def copy_tally(card_set)
      return @copy_tally if @copy_tally

      if score.zero?
        @copy_tally = { @index => 1 }
      else
        @copy_tally = copies(card_set).reduce({ @index => 1 }) do |tally, card|
          tally.merge(card.copy_tally(card_set)) do |key, old_val, new_val|
            old_val + new_val
          end
        end
      end
    end

    def copies(card_set)
      return [] if score.zero?

      winning_numbers.size.times.map do |offset|
        card_set[@index + offset]
      end
    end

    def score
      return 0 if winning_numbers.empty?

      1 * (2 ** (winning_numbers.size - 1))
    end
  end
end
