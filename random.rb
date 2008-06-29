class IcfpRandomizer
  def initialize(random_seed)
    @seed = random_seed
    4.times do
      next_seed
    end
  end

  def random(n=nil)
    n ? next_random % n : next_random
  end 

  def next_seed
    @seed = @seed * 22695477 + 1
  end

  def next_random
    @x = (@seed / 65536) % 16384
    next_seed
    return @x
  end
end

if __FILE__ == $PROGRAM_NAME
  require "rubygems"
  require "spec"

  describe "The Icfp Randomizer" do

    it "should match the ICFP sequence for seed = 12345" do
      rand = IcfpRandomizer.new(12345)
      (0..9).map { |e| rand.random }.should == 
        [7193,2932,10386,5575,100,15976,430,9740,9449,1636]
    end

  end
end
  

