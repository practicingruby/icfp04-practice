require "ant_interpreter"
puts "random seed: 12345\n\n"

ant = AntInterpreter.new("sample.ant", "sample.ant", "tiny.world")
#ant.watch << 11

10001.times do |i|
  #STDERR.puts i
  puts "After round #{i}..."
#=begin
  ant.map.traverse do |cell, pos|
    print "cell (#{pos[0]}, #{pos[1]}): "

    if cell.food > 0
      print "#{cell.food} food; "
    end

    if cell.rocky?
      print "rock"
    end

    if cell.black_anthill
      print "black hill; "
    end

    if cell.red_anthill
      print "red hill; "
    end

    if cell.red_markers.any? { |e| e }
      print "red marks: "
      (0..5).each do |mark|
        print mark if cell.red_markers[mark]
      end
      print "; "
    end

    if cell.black_markers.any? { |e| e }
      print "black marks: "
      (0..5).each do |mark|
         print mark if cell.black_markers[mark]
      end
      print "; "
    end

    if cell.ant?
      print "#{cell.ant.color} ant of id #{cell.ant.id}, "
      print "dir #{Map::DIRECTIONS.index(cell.ant.direction)}, "
      print "food #{cell.ant.has_food? ? 1 : 0}, "
      print "state #{cell.ant.state}, " 
      print "resting #{cell.ant.resting}"
    end

    puts
  end
#=end

  ant.next
  puts
end

