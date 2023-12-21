#!/usr/bin/env ruby

module Day9
  def self.parse(input)
    input.lines(chomp: true).map do |line|
      line.split.map(&:to_i)
    end
  end

  def self.p1(input)
    lines = parse(input)

    lines.map do |line|
      history = []

      until line.all?(&:zero?) do
        history.unshift(line.last)
        line = line.each_cons(2).map { |pair| pair[1] - pair[0] }
      end

      history.reduce(0, :+)
    end.sum
  end

  def self.p2(input)
    lines = parse(input)

    lines.map do |line|
      history = []

      until line.all?(&:zero?) do
        history.unshift(line.first)
        line = line.each_cons(2).map { |pair| pair[1] - pair[0] }
      end

      history.reduce(0) do |memo, obj|
        obj - memo
      end
    end.sum
  end
end
