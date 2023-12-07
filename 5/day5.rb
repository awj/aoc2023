#!/usr/bin/env ruby

module Day5
  def self.parse(input)
    lines = input.lines(chomp: true)
    seeds = lines.shift

    seeds = seeds.split(":").last.strip.split(" ").map(&:to_i)

    tables = {}
    lookup_table = nil

    lines.each do |line|
      if line.match?(/^[0-9]/)
        destination, origin, range = line.split(" ").map(&:to_i)
        lookup_table << Mapping.new(destination: destination, origin: origin, range: range)
      elsif line.empty?
        lookup_table = nil
      else
        lookup_table = LookupTable.new(line)
        tables[lookup_table.from] = lookup_table
      end
    end

    tables[lookup_table.from] = lookup_table if lookup_table

    [seeds, tables]
  end

  def self.p1(input)
    seeds, tables = parse(input)

    location_numbers = seeds.map do |seed|
      lookup_name = "seed"
      lookup_number = seed

      loop do
        next_lookup = tables[lookup_name]
        lookup_number = next_lookup.destination_for(lookup_number)
        lookup_name = next_lookup.to
        break if lookup_name == "location"
      end

      lookup_number
    end

    location_numbers.min
  end

  # Walk through our "seed ranges" and progressively translate them into sets of
  # mapped ranges for the next round. `LookupTable#destination_ranges` can
  # return *multiple* ranges that cover the translated values according to the
  # lookup table's mappings, as well as the fragments of ranges that lie outside
  # those mappings.
  #
  # When we've translated the "location" ranges, return the smallest beginning
  # of a range.
  def self.p2(input)
    seeds, tables = parse(input)

    ranges = seeds.each_slice(2).map do |slice|
      start, finish = slice
      start..(start + finish - 1)
    end

    table = tables["seed"]

    loop do
      puts "#{table.to}: #{ranges}"
      ranges = ranges.map do |range|
        table.destination_ranges(range)
      end.flatten

      break if table.to == "location"

      table = tables[table.to]
    end

    ranges.map(&:begin).min
  end

  class LookupTable
    attr_reader :mappings, :from, :to

    def initialize(name, mappings: [])
      parts = name.split(" ").first.split("-")
      @name = name
      @from = parts.first
      @to = parts.last
      @mappings = mappings
    end

    def destination_for(value)
      mapping = mappings.find { |m| m.include?(value) }

      return value if mapping.nil?

      mapping.destination_for(value)
    end

    # Take a range of origin values and break it down into multiple ranges of
    # destination values.
    #
    # For any sequences of values that lie *outside* of the mappings, just
    # return the range that sequence covers.
    #
    # For sequences of values that lie *inside* the mappings, return the
    # post-mapping-translation ranges of those values.
    def destination_ranges(origin_range)
      mappings.sort_by!(&:origin)

      working_range = origin_range
      ranges = []

      mappings.each do |mapping|
        break if working_range.nil?

        next unless mapping.intersects?(working_range)

        start, during, finish = mapping.split(working_range)

        ranges << start if start
        ranges << during if during

        working_range = finish
      end

      ranges << working_range if working_range

      ranges
    end

    def <<(mapping)
      @mappings << mapping
    end
  end

  class Mapping
    attr_reader :origin, :destination, :range

    def initialize(destination:, origin:, range:)
      @origin = origin
      # Note triple dot range takes care of the fact that we count the starting
      # value as covered, but not the ending.
      #
      # e.g. an origin of 99 with a range of 2 covers 99 and 100, but not 101
      @origin_coverage = (origin...(origin + range))
      @destination = destination
      @destination_coverage = (destination...(destination + range))
      @range = range
    end

    def finish
      @origin_coverage.end
    end

    def include?(value)
      @origin_coverage.include?(value)
    end

    def intersects?(range)
      range.include?(@origin_coverage.begin) ||
        range.include?(@origin_coverage.end) ||
        @origin_coverage.include?(range.begin) ||
        @origin_coverage.include?(range.end)
    end

    # Break a range apart into "before", "during", and "after" segments. Return
    # those as an array (in that order). Return nil if one is not applicable.
    #
    # * before - the portion of the range before the defined mapping
    # * during - the *post-translation* portion of the range covered by the mapping
    # * after - the portion of the range that comes after the mapping
    def split(range)
      raise ArgumentError, "range #{range} does not intersect #{@origin_coverage}" unless intersects?(range)

      before = nil
      during = nil
      after = nil

      before = range.begin..(origin - 1) if range.begin < origin

      start_coverage = [range.begin, origin].max
      end_coverage = [range.end, finish-1].min

      raise "oops, #{range}, #{@origin_coverage}" if start_coverage > end_coverage

      during = map_range(start_coverage..end_coverage) if start_coverage < finish

      after = finish..range.end if range.end > finish

      [before, during, after]
    end

    def map_range(range)
      raise ArgumentError, "#{range} is not covered by #{@origin_coverage}" unless include?(range.begin) && include?(range.end)
      # raise ArgumentError, "empty range: #{range}" if range.size == 0

      start = range.begin
      finish = range.end

      destination_for(start)..destination_for(finish)
    end

    def destination_for(value)
      raise ArgumentError, "#{value} is not covered by #{@origin_coverage}" unless include?(value)

      destination + (value - origin)
    end
  end
end
