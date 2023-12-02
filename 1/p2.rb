module Day2
  # This took a *long* time to figure out. The lookahead `(?=)` is essential
  # here.
  #
  # In the input we can end up with something like 'eightwo' where both "eight"
  # and "two" are represented, but they "share" a character.
  #
  # Using a "normal" regex, capturing the "eight" from the string also *removes*
  # every single character of it from consideration. So in "eightwo" capturing
  # the "eight" leaves us with "wo", which doesn't match and thus doesn't
  # produce the correct output.
  #
  # Using lookahead anchored to *no* characters means we *do not* consume the
  # text input while matching. So the pattern (?=(input)) achieves *matching*
  # a regex while still considering trailing substrings of the regex.
  #
  # For our "eightwo" example, here's what the regex engine is doing:
  # * start at the beginning of the string
  # * we can match an "eight" after the beginning of the string, so do that.
  #   Because of the inner parens, capture that "eight" as output.
  # * due to lookahead, we *go back to the beginning of the string*, since we've
  #   already matched "eight", ignore it. Nothing else matches.
  # * because nothing matched in the previous step, advance a character and
  #   consider "ightwo"
  # * that does not match, so move ahead one (this happens for 'i', 'g', and
  #   'h')
  # * when we're at the "two", that matches as well, so capture it as output.
  DIGIT_REGEX = /(?=(one|two|three|four|five|six|seven|eight|nine|\d))/

  def self.run(input)
    input.lines(chomp: true).map do |line|
      extract_calibration_value(line)
    end.sum
  end

  def self.digit_from(match)
    case match
    when "one" then 1
    when "two" then 2
    when "three" then 3
    when "four" then 4
    when "five" then 5
    when "six" then 6
    when "seven" then 7
    when "eight" then 8
    when "nine" then 9
    else match.to_i
    end
  end

  def self.all_values(line)
    line.scan(DIGIT_REGEX).map(&:first).map { |match| digit_from(match) }
  end

  def self.extract_calibration_value(line)
    matching_values = all_values(line)

    (10 * matching_values.first) + matching_values.last
  end
end
