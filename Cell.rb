class Cell
  attr_accessor :id, :status, :revealed
  def initialize
    @status = 0
    @revealed = false
  end

  def revealed?
    revealed == true
  end
end
