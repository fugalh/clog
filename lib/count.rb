# simple example filter that just does the equivalent of 'wc -l'

class CountFilter
  attr_reader :name
  def initialize
    @count = 0
    @name = 'Count'
  end
  def filter(line)
    @count += 1
    false # because we return false, the fallback will still be in effect
  end
  def to_s
    @count.to_s
  end
end
