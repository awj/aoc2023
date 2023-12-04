#!/usr/bin/env ruby

require "set"

module Day3
  # 439530 - too low
  # 708877 - too high
  def self.p1(input)
    grid = Grid.parse(input)

    unique_parts = Set.new

    all_parts = []

    grid.symbol_locations.each do |location|
      grid.parts_around(location).each do |part|
        unique_parts << part
        all_parts << part
      end
    end

    unique_parts.map(&:number).sum
  end

  def self.p2(input)
    grid = Grid.parse(input)

    grid.symbol_locations.map do |location|
      grid.gear_ratio(location)
    end.sum
  end

  class Grid
    attr_reader :squares, :symbol_locations

    def self.digit?(char)
      48 <= char.ord && char.ord <= 57
    end

    def self.parse(input)
      grid = new

      input.lines(chomp: true).each_with_index do |line, y|
        part_number = 0
        part_locations = []

        line.chars.each_with_index do |char, x|
          val = char.to_i
          if digit?(char)
            part_number = part_number * 10 + val
            part_locations << [x, y]
          else
            if part_number > 0
              part = Part.new(part_number, part_locations)
              part_locations.each do |location|
                grid.add(part, location)
              end

              part_number = 0
              part_locations = []
            end
          end

          if char != "." && !digit?(char)
            grid.add(GridSymbol.new(char), [x, y])
          end
        end

        if part_number > 0
          part = Part.new(part_number, part_locations)
          part_locations.each do |location|
            grid.add(part, location)
          end

          part_number = 0
          part_locations = []
        end
      end

      grid
    end

    def initialize()
      @squares = {}
      @symbol_locations = []
    end

    def [](location)
      @squares[location]
    end

    def parts_around(location)
      around(location).select do |element|
        element.is_a?(Part)
      end.uniq
    end

    def around(location)
      x, y = location

      results = []
      [-1, 0, 1].each do |dy|
        [-1, 0, 1].each do |dx|
          next if dx == 0 && dy == 0

          val = @squares[ [x + dx, y + dy] ]

          results << val if val
        end
      end

      results.uniq
    end

    def gear_ratio(location)
      square = self[location]

      return 0 unless square.is_a?(GridSymbol) && square.potential_gear?

      nearby = around(location)

      if nearby.size == 2
        nearby.map(&:number).reduce(:*)
      else
        0
      end
    end

    def add(item, location)
      squares[location] = item

      @symbol_locations << location if item.is_a?(GridSymbol)
    end
  end

  class Part
    attr_reader :number, :locations

    def initialize(number, locations)
      @number = number
      @locations = locations
    end

    def ==(other)
      other.class == Part && other.number == number && other.locations == locations
    end

    def eql?(other)
      self == other
    end

    def to_s
      "Part(#{number})"
    end

    def hash
      [number, locations].hash
    end

    alias inspect to_s
  end

  class GridSymbol
    attr_reader :symbol

    def initialize(symbol)
      @symbol = symbol
    end

    def ==(other)
      other.class == GridSymbol && other.symbol == symbol
    end

    def potential_gear?
      symbol == "*"
    end

    def to_s
      "Symbol(#{symbol})"
    end

    alias inspect to_s
  end
end
