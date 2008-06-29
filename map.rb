require "cell"
require "pp"

class Map

  DIRECTIONS = [:east, :south_east, :south_west, :west, :north_west, :north_east]

  def self.parse(file)
    width, height, *data = File.read(file).split(/\n/)
    map = self.new(width.to_i,height.to_i)
    data.each_with_index do |row,y|
      row.delete(" ").split(//).each_with_index do |cell,x|
        case(cell)
        when "#"
          map[x,y].rocky = true
        when "+"
          map[x,y].red_anthill = true
          map[x,y].ant = Ant.new(:color => :red, :position => [x,y])
        when "-"
          map[x,y].black_anthill = true
          map[x,y].ant = Ant.new(:color => :black, :position => [x,y])
        when /\d/
          map[x,y].food = Integer(cell)
        end
      end
    end
    return map
  end
    
  def initialize(height, width)
    @height = height
    @width  = width
    @data = []
    height.times do
      row = []
      width.times { row << Cell.new }
      @data << row
    end
  end

  def [](*point)
    x,y = point.flatten
    @data[y][x]
  end

  def traverse
    @height.times do |y|
      @width.times do |x|
        yield(self[x,y],[x,y])
      end
    end
  end

  def find_ant(ant_id)
    Ant.find(ant_id).position
  end

  def kill_ant_at(position)
    if a = self[position].ant
      self[position].remove_ant
      Ant.kill(a.id)
    end
  end

  def adjacent_ants(pos,color)
    n = 0
    DIRECTIONS.each do |dir|
      cell = self[Map.adjacent_cell(pos,dir)]
      n += 1 if cell.ant? && cell.ant.color == color
    end
    return n
  end

  def surrounded_ant(pos)
    return unless ant = self[pos].ant

    if adjacent_ants(pos,ant.foe_color) >= 5
      kill_ant_at(pos)
      self[pos].food += 3 + (ant.has_food? ? 1 : 0)
    end
  end

  def update_surrounded_ants(pos)
    surrounded_ant(pos)
    DIRECTIONS.each do |dir|
      surrounded_ant(Map.adjacent_cell(pos,dir))
    end
  end

  def self.adjacent_cell(pos,dir)
    x,y = pos
    cache[[:adjacent_cell, pos, dir]] ||= case(dir)
    when :east 
      [x+1,y]
    when :south_east
      y % 2 == 0 ? [x,y+1] : [x+1, y+1]
    when :south_west
      y % 2 == 0 ? [x-1, y+1] : [x,y+1]
    when :west
      [x-1, y]
    when :north_west
        y % 2 == 0 ? [x-1,y-1] : [x,y-1]
    when :north_east
      y % 2 == 0 ? [x, y-1] : [x+1,y-1]
    end
  end

  def self.left_of(dir)
    DIRECTIONS[(DIRECTIONS.index(dir) + 5) % 6]
  end

  def self.right_of(dir)
    DIRECTIONS[(DIRECTIONS.index(dir) + 1) % 6]
  end

  def self.sensed_cell(pos, dir, sense_dir)
    @cache[[:sensed_cell, pos, dir, sense_dir]] ||= case(sense_dir)
    when :here
      pos
    when :ahead
      adjacent_cell(pos,dir)
    when :left_ahead
      adjacent_cell(pos,left_of(dir))
    when :right_ahead
      adjacent_cell(pos,right_of(dir))
    end
  end

  def self.cache
    @cache = {}
  end

  attr_reader :data

end

if __FILE__ == $PROGRAM_NAME
  require "rubygems"
  require "spec"
  require "pp"
  require "enumerator"

  describe "A map" do

    it "should take a width and height and generate a grid of cells" do
      width  = 3
      height = 2

      map = Map.new(height, width)
      map.data.length.should == height

      map.data.each do |r|
        r.length.should == width
        r.all? { |e| e.kind_of?(Cell) }.should == true
      end
    end

    { :east       => [3,2], :west       => [1,2], 
      :north_west => [1,1], :north_east => [2,1], 
      :south_east => [2,3], :south_west => [1,3] }.each do |dir, adj|
 
       it "should calculate adjacent cell for the #{dir} "+
          "direction when y is even" do
         Map.adjacent_cell([2,2], dir).should == adj
       end
    end

    { :east       => [4,3],  :west       => [2,3],
      :north_west => [3,2],  :north_east => [4,2],
      :south_east => [4,4],  :south_west => [3,4] }.each do |dir, adj|
      
      it "should calculate adjacent cell for the #{dir} "+
          "direction when y is odd" do
        Map.adjacent_cell([3,3], dir).should == adj      
      end
    end


    [:east, :north_east, :north_west, :west, 
     :south_west, :south_east, :east].each_cons(2) do |dir, left| 
      it "should calculate #{left} to be left of #{dir} " do 
        Map.left_of(dir).should == left
      end
    end


    [:east, :north_east, :north_west, :west, 
     :south_west, :south_east, :east].each_cons(2) do |right, dir| 
      it "should calculate #{right} to be right of #{dir} " do
        Map.right_of(dir).should == right
      end
    end
    
    it "should be able to sense a given cell" do
      Map.sensed_cell([3,3], :west, :here).should == [3,3]
    end

    it "should be able to sense the cell ahead of a given cell" do
      Map.sensed_cell([3,3], :west, :ahead).should == [2,3]
    end

    it "should be able to sense the cell left-ahead of a given cell" do
      Map.sensed_cell([3,3], :west, :left_ahead).should == [3,4]
    end

    it "should be able to sense to cell right-ahead of a given cell" do
      Map.sensed_cell([4,2], :west, :right_ahead).should == [3,1]
    end


  end

end
