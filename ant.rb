class Ant

  def initialize(options={})
    @id        = Ant.next_id
    @color     = options[:color]
    @state     = options[:state] || 0
    @resting   = options[:resting] || 0
    @direction = options[:direction] || :east
    @position  = options[:position]
    self.class.all[@id] = self
  end

  def self.next_id
    @id ||= -1
    @id += 1
  end

  def self.all
    @ants ||= {}
  end

  def self.find(id)
    all[id]
  end

  def self.kill(id)
    all[id] = nil
  end

  def self.exist?(ant_id)
    !!all[ant_id]
  end

  def has_food?
    !!@food
  end

  def take_food
    @food = true
  end

  def drop_food
    @food = false
  end

  def foe_color
    { :black => :red, :red => :black }[color]
  end

  attr_reader :id, :color
  attr_accessor :state, :resting, :direction, :position

end

if __FILE__ == $PROGRAM_NAME 

  require "rubygems"
  require "spec"

  describe "An ant" do

    it "should have a color" do
      @ant = Ant.new(:color => :black)
      @ant.color.should == :black
    end

    it "should have a state" do
      @ant = Ant.new(:state => 0)
      @ant.state.should == 0
    end

    it "should have a resting attribute" do
      @ant = Ant.new(:resting => 10)
      @ant.resting.should == 10
    end

    it "should have a direction" do
      @ant = Ant.new(:direction => :west)
      @ant.direction.should == :west
    end

    it "should be able to set its attributes" do
      @ant = Ant.new
      @ant.state     = 100
      @ant.resting   = 10
      @ant.direction = :west

      [@ant.state, @ant.resting, @ant.direction].should == [100,10,:west]
    end

    it "should know whether it has food" do
      @ant = Ant.new
      @ant.has_food?.should == false
      @ant.take_food
      @ant.has_food?.should == true
      @ant.drop_food
      @ant.has_food?.should == false
    end

 end

end
