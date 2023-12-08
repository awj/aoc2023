#!/usr/bin/env ruby

module Day7
  def self.parse(input)
    input.lines(chomp: true).map do |line|
      Hand.parse(line)
    end
  end

  # 247396610 too low
  def self.p1(input)
    hands = parse(input)

    hands.sort.each_with_index.map do |hand, rank|
      hand.bid * (rank + 1)
    end.sum
  end

  class Hand
    KIND_NAMES = {
      7 => "FIVE_OF_A_KIND",
      6 => "FOUR_OF_A_KIND",
      5 => "FULL_HOUSE",
      4 => "THREE_OF_A_KIND",
      3 => "TWO_PAIR",
      2 => "ONE_PAIR",
      1 => "HIGH_CARD",
    }

    # Define a mapping from the input card name to a numeric value such that
    # sorting by the numeric values reflects the strength of the cards.
    CARD_MAP = %w[2 3 4 5 6 7 8 9 T J Q K A].each_with_index.to_h

    attr_reader :cards, :bid, :kind, :table

    def self.parse(line)
      hand, bid = line.split(" ")

      cards = hand.chars.map do |char|
        CARD_MAP.fetch(char)
      end

      new(cards, bid.to_i, hand)
    end

    def initialize(cards, bid, hand_string)
      @cards = cards
      @bid = bid
      @hand_string = hand_string
      identify!
    end

    def to_s
      kind_name = KIND_NAMES[kind]
      "Hand<#{@hand_string}, #{bid}} (#{kind_name})>"
    end

    def inspect
      to_s
    end

    def <=>(other)
      return kind <=> other.kind if kind != other.kind

      cards <=> other.cards
    end

    private

    def identify!
      @table = cards.tally

      three_of_one = table.values.any? { |v| v == 3 }

      @kind = case table.size
              when 1 then FIVE_OF_A_KIND
              when 2 then three_of_one ? FULL_HOUSE : FOUR_OF_A_KIND
              when 3 then three_of_one ? THREE_OF_A_KIND : TWO_PAIR
              when 4 then ONE_PAIR
              when 5 then HIGH_CARD
              end
    end
  end
end
