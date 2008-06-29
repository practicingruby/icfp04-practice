require "ant_parser"
require "map"
require "ant"
require "random"
require "pp"

class AntInterpreter

  def initialize(red_ant_brain,black_ant_brain,map)
    @red_ant_brain   = AntParser.parse(red_ant_brain)
    @black_ant_brain = AntParser.parse(black_ant_brain)
    @map             = Map.parse(map)
    @randomizer      = IcfpRandomizer.new(12345)
    @watch           = []
  end

  attr_reader :red_ant_brain, :black_ant_brain, :map
  attr_accessor :watch

  def brain(color)
    { :red => @red_ant_brain, :black => @black_ant_brain }[color]
  end

  def next
    Ant.all.keys.sort.each { |ant_id| step(ant_id) }
  end

  def step(ant_id)
    return unless ant = Ant.find(ant_id)
    pos = @map.find_ant(ant_id)
    if ant.resting > 0
      ant.resting -= 1
    else
      command, args = brain(ant.color)[ant.state] 
      res = send(command,args.merge(:ant => ant, :pos => pos))
      if args[:fail]
        res ? ant.state = args[:state] : ant.state = args[:fail]
      else
        ant.state = args[:state]
      end
    end
  if @watch.include? ant_id
    STDERR.puts [command, args, pos].inspect
  end
  rescue
    pp [ant_id, command, args]
    raise
  end

  def sense(options)
    cell_pos = Map.sensed_cell(options[:pos], 
                               options[:ant].direction,
                               options[:sense_dir])
    @map[cell_pos].matches(options[:condition], options[:ant].color)
  end

  def mark(options)
    @map[options[:pos]].
      send("#{options[:ant].color}_markers")[options[:marker]] = true
  end

  def unmark(options)
    @map[options[:pos]].
      send("#{options[:ant].color}_markers")[options[:marker]] = false
  end

  def pickup(options)
    cell = @map[options[:pos]]

    return false if options[:ant].has_food? || cell.food == 0

    cell.food -= 1
    options[:ant].take_food
  end

  def drop(options)
    if options[:ant].has_food?
      @map[options[:pos]].food += 1
      options[:ant].drop_food
    end
  end

  def turn(options)
    options[:ant].direction = 
      Map.send("#{options[:dir]}_of", options[:ant].direction)
  end

  def move(options)
    dest = Map.adjacent_cell(options[:pos], options[:ant].direction)
    return false if @map[dest].rocky? || @map[dest].ant?

    @map[options[:pos]].remove_ant 
    @map[dest].ant = options[:ant]
    options[:ant].resting = 14
    options[:ant].position = dest
    @map.update_surrounded_ants(dest)

    return true
  end

  def flip(options)
    @randomizer.random(options[:probability]).zero? 
  end

end
