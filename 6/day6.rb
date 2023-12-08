#!/usr/bin/env ruby

module Day6
  def self.parse(input)
    times, distances = input.lines(chomp: true)

    times = times.split(":").last.split(" ").map(&:to_i)
    distances = distances.split(":").last.split(" ").map(&:to_i)

    times.zip(distances)
  end

  def self.parse_p2(input)
    time, distance = input.lines(chomp: true)

    time = time.split(":").last.gsub(" ", "").to_i
    distance = distance.split(":").last.gsub(" ", "").to_i

    [[time, distance]]
  end

  def self.p2(input)
    pairs = parse_p2(input)

    pairs.map do |pair|
      fastest_solutions(pair)
    end.reduce(:*)
  end

  def self.p1(input)
    pairs = parse(input)

    pairs.map do |pair|
      possible_solutions(pair).size
    end.reduce(:*)
  end

  def self.possible_solutions(problem)
    time, max_distance = problem

    time.times.map do |charge_time|
      (time - charge_time) * charge_time
    end.select { |distance| distance > max_distance }
  end

  # The distance is a parabolic curve with respect to "charge time"
  #
  # Using:
  #   d = distance
  #   t = total time
  #   x = charge time
  #
  # We can plug in the "current max distance" then solve for the roots of the
  # parabolic equation to find the exact amount of charge time required to pass
  # the distance.
  #
  # distance = (total time - charge time) * charge time
  # d = (t - x) * x
  # d = tx - x^2
  # d = -x^2 + tx
  # -d = x^2 - tx
  # 0 = x^2 - tx + d
  #
  # We're now in the form of ax^2 + bx + c, so we can use standard parabolic
  # roots to find the times where we cross over.
  def self.real_fastest_solutions(problem)
    time, distance = problem

    start, finish = roots(time.to_f, distance.to_f)

    first_winner = start.ceil
    last_winner = finish.floor

    last_winner - first_winner + 1
  end

  def self.roots(time, max_distance)
    negative = (time - Math.sqrt((-time * -time) - (4 * 1 * max_distance))) / 2
    positive = (time + Math.sqrt((-time * -time) - (4 * 1 * max_distance))) / 2

    [negative, positive]
  end

  # Because the distance travelled is a direct function of "charge time", we
  # know that the possible charge times form a simple distribution curve. So
  # there's a point on the curve where we cross from "not a winning distance" to
  # "a winning distance", and a point where we go from "a winning distance" back
  # to "not a winning distance". Every point *between* those two will be a
  # winner, and every point outside of them is not.
  #
  # So we can use a binary search on "winning, not winning" to get us very close
  # to these crossovers, then iterate towards identifying them. Once we *have*
  # the values where we cross over, simple subtraction gives us the number of
  # winning charge times.
  def self.fastest_solutions(problem)
    time, max_distance = problem

    first_winner = find_threshold(time, max_distance, :beginning)

    last_winner = find_threshold(time, max_distance, :end)

    # We have to add 1 because subtraction is giving us the number of winners
    # *between* first and last, but not including the *first* one in the count.
    last_winner - first_winner + 1
  end

  # Starting from the midpoint between 0 and total_time, head in `direction`
  # until we find the first/last possible winning value.
  def self.find_threshold(total_time, max_distance, direction)
    sign = direction == :beginning ? -1 : +1

    pivot = total_time / 2
    increment = pivot / 2

    # Do a binary search of the possible numbers between 0 and total time until
    # we're down to incrementing by 1. If our charge time is a winner, go
    # towards `direction` by half and check that time. Otherwise go away from
    # `direction` by half.
    while increment > 1
      winner = ((total_time - pivot) * pivot) > max_distance

      puts "#{pivot}: #{winner}, #{increment}"

      pivot += winner ? (increment * sign) : -(increment * sign)

      increment /= 2
    end

    # Now that we've found a number that's *close* to the point where charging
    # starts to work, walk towards the threshold we're seeking by 1 from there
    # until we find the first number that fails to beat the score.
    pivot += 1 * sign while ((total_time - (pivot + sign)) * (pivot + sign)) > max_distance

    pivot
  end

  # Avoid an intermediate array by using `Enumerable#count`. We still have to
  # enumerate and check every number between 0 and the total time.
  #
  # In practice, this helped only slightly.
  def self.faster_solutions(problem)
    time, max_distance = problem

    time.times.count do |charge_time|
      ((time - charge_time) * charge_time) > max_distance
    end
  end
end
