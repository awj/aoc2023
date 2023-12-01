# frozen_string_literal: true

module Day1
  def self.run(input)
    input.lines(chomp: true).map do |line|
      extract_calibration_value(line)
    end.sum
  end

  def self.extract_calibration_value(line)
    chars = line.chars

    first_digit = chars.find { |c| 48 <= c.ord && c.ord <= 57 }.to_i
    last_digit = chars.reverse.find { |c| 48 <= c.ord && c.ord <= 57 }.to_i

    10 * first_digit + last_digit
  end
end
