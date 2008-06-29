class AntAlreadyPresentError < RuntimeError; end

class Cell

  attr_reader   :ant, :black_markers, :red_markers
  attr_accessor :food, :rocky, :black_anthill, :red_anthill

  def initialize
    @ant            = nil
    @black_markers  = []
    @red_markers    = []
    @food           = 0
  end

  def rocky?
    !!@rocky
  end

  def ant?
    !!@ant
  end

  def ant=(a)
    raise AntAlreadyPresentError if @ant
    @ant = a
  end

  def remove_ant
    @ant = nil
  end

  def red_anthill?
    !!@red_anthill
  end

  def black_anthill?
    !!@black_anthill
  end

  def matches(condition,color)
    return true if condition == :rock && rocky?
    case(condition)
    when :friend
      ant? && ant.color == color
    when :foe
      ant? && ant.color != color
    when :friend_with_food
      ant? && ant.color == color && ant.has_food?
    when :foe_with_food
      ant? && ant.color != color && ant.has_food?
    when :food
      food > 0
    when :rock
      false
    when Integer
      !! send("#{color}_markers")[condition]      
    when :foe_marker
      send("#{other_color(color)}_markers").any? { |e| e } 
    when :home
      !! send("#{color}_anthill")
    when :foe_home
      !! send("#{other_color(color)}_anthill")
    end
  end

  def other_color(col)
    {:black => :red, :red => :black}[col]
  end

end

if __FILE__ == $PROGRAM_NAME
  require "rubygems"
  require "spec"

  describe "A cell" do

    it "should be able to contain an ant" do
      cell = Cell.new
      ant  = mock("Ant")
      cell.ant = ant
      cell.ant.should == ant
    end

    it "should not set the ant if another is present" do
      cell = Cell.new
      ant1 = mock("Ant 1")
      ant2 = mock("Ant 2")
      cell.ant = ant1
      lambda { cell.ant = ant2 }.should raise_error(AntAlreadyPresentError)
      cell.remove_ant
      cell.ant = ant2
      cell.ant.should == ant2
    end

    it "should allow modifying food attribute" do
      cell = Cell.new
      cell.food = 10
      cell.food.should == 10
    end

    it "should have an array of red markers" do
      cell = Cell.new
      cell.red_markers.should == []
    end

    it "should have an array of black markers" do
      cell = Cell.new
      cell.black_markers.should == []
    end

    it "should have a boolean check for ant" do
      cell = Cell.new
      cell.should_not be_ant
      cell.ant = mock("Ant")
      cell.should be_ant
    end


  end 
end
