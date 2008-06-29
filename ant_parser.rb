class AntParser

  REPLACEMENTS = {
    :leftahead      => :left_ahead,
    :rightahead     => :right_ahead,
    :friendwithfood => :friend_with_food,
    :foewithfood    => :foe_with_food,
    :foemarker      => :foe_marker,
    :foehome        => :foe_home
  }

  def self.parse(file)
    ant = AntParser.new
    File.read(file).map do |line|
      ant.parse_line(line)
    end
  end

  def parse_line(line)
    case(line)
    when /Sense.*Marker.*\d+/
      line =~ /(\w+)\s+(\w+)\s+(\d+)\s+(\d+)\s+.*(\d+)/
      [normalize($1), { :sense_dir => normalize($2),
                        :state     => Integer($3),
                        :fail      => Integer($4),
                        :condition => Integer($5) }]
    when /Sense/i
      line =~ /(\w+)\s+(\w+)\s+(\d+)\s+(\d+)\s+(\w+)/
      [normalize($1), { :sense_dir => normalize($2),
                        :state     => Integer($3),
                        :fail      => Integer($4),
                        :condition => normalize($5) } ]
    when /(un)*Mark/i
      line =~ /(\w+)\s+(\d+)\s+(\d+)/
      [normalize($1), { :marker => Integer($2),
                        :state  => Integer($3) } ]
    when /Move|PickUp/i
      line =~ /(\w+)\s+(\d+)\s+(\d+)/
      [normalize($1), { :state  => Integer($2),
                        :fail   => Integer($3) }]
    when /Drop/i
      line =~ /(\w+)\s+(\d+)/
      [normalize($1), { :state => Integer($2) }]
    when /Turn/i
      line =~ /(\w+)\s+(\w+)\s+(\d+)/
      [normalize($1), { :dir    => normalize($2),
                        :state  => Integer($3) }]
    when /Flip/i
      line =~ /(\w+)\s+(\d+)\s+(\d+)\s+(\d+)/
        [normalize($1), { :probability => Integer($2),
                          :state       => Integer($3),
                          :fail        => Integer($4) }]
    end

  end

  def normalize(string)
    s = string.gsub(" ","_").downcase.to_sym
    REPLACEMENTS[s] || s
  end

end

if __FILE__ == $PROGRAM_NAME
  require "rubygems"
  require "spec"

  describe "an ant parser" do

    before(:each) do
      @parser = AntParser.new
    end

    it "should parse sense instructions" do
      @parser.parse_line("Sense Ahead 1 3 Food").should == 
        [:sense, { :state     => 1, 
                   :fail      => 3, 
                   :condition => :food, 
                   :sense_dir => :ahead }]

    end

    it "should parse mark instructions" do
      @parser.parse_line("Mark 1 40").should ==
        [:mark, { :marker => 1, :state => 40 }]
    end

    it "should parse unmark instructions" do
      @parser.parse_line("Unmark 3 25").should ==
        [:unmark, { :marker => 3, :state => 25 } ]
    end

    it "should parse pickup instructions" do
      @parser.parse_line("Pickup 8 0").should ==
        [:pickup, { :state => 8, :fail => 0 }]
    end

    it "should parse drop instructions" do
      @parser.parse_line("Drop 5").should ==
        [:drop, { :state => 5 }] 
    end 
    
    it "should parse turn instructions" do
      @parser.parse_line("Turn Left 5").should ==
        [:turn, { :state => 5, :dir => :left }]
    end
    
    it "should process move instructions" do
      @parser.parse_line("Move 8 11") do
        [:move, { :state => 8, :fail => 11 }]
      end
    end

    it "should process flip instructions" do
      @parser.parse_line("Flip 3 12 13").should ==
        [:flip, { :probability => 3, 
                  :state       => 12, 
                  :fail        => 13 } ]
    end

  end
end
