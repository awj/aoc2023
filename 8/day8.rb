#!/usr/bin/env ruby

require "set"

module Day8
  def self.parse(input)
    contents = input.lines(chomp: true)
    directions = contents.shift

    _blank = contents.shift

    mapping = {}

    contents.each do |node_line|
      name, dirs = node_line.split(" = ")

      dirs = dirs.gsub("(", "").gsub(")", "")

      left, right = dirs.split(", ")

      mapping[name] = [left, right]
    end

    [
      directions,
      mapping
    ]
  end

  def self.p1(input)
    directions, mapping = parse(input)

    count = 0
    current = "AAA"

    directions.chars.cycle do |dir|
      count += 1

      moves = mapping[current]

      current = dir == "L" ? moves.first : moves.last

      break if current == "ZZZ"
    end

    count
  end

  def self.p2(input)
    directions, mapping = parse(input)

    starting_points = mapping.keys.select { |k| k.end_with?("A") }

    navigators = starting_points.map do |location|
      Navigator.new(location, mapping)
    end

    cycles = []

    navigators.each do |navigator|
      count = 1

      directions.chars.cycle do |dir|
        navigator.step(dir, 0)

        if navigator.at_end?
          puts "#{navigator.start}: #{count}"
          cycles << count
          break
        end

        count += 1
      end
    end

    cycles.reduce(&:lcm)
  end

  class Navigator
    attr_reader :current, :mapping, :steps_to_satisfy, :start, :ends, :seen

    def initialize(start, mapping)
      @mapping = mapping
      @current = start
      @start = start
      @did_loop = false
      @steps_to_satisfy = 0
      @seen = Set.new
      @ends = Set.new
    end

    def at_end?
      current.end_with?("Z")
    end

    def looped?
      @did_loop
    end

    def step(dir, cycle_position)
      moves = mapping[current]

      @current = dir == "L" ? moves.first : moves.last

      unless @did_loop
        if @seen.include?([current, cycle_position])
          @did_loop = true
        else
          @seen << [current, cycle_position]
        end
      end

      @ends << current if at_end?

      @steps_to_satisfy += 1 unless at_end?
    end
  end
end
