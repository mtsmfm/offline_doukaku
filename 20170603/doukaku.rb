require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'

  gem 'activesupport', require: 'active_support/all'

  gem 'minitest', require: 'minitest/autorun'
  gem 'minitest-reporters'

  gem 'awesome_print'
  gem 'tapp'

  gem 'pry'
  gem 'pry-rescue', require: 'pry-rescue/minitest'
  gem 'pry-stack_explorer'
end

EMPTY = "."

class Omino
  attr_reader :array

  delegate :dig, to: :@array

  def initialize(array)
    @array = array
  end

  def each_with_index(&block)
    @array.each.with_index do |row, y|
      row.each.with_index do |col, x|
        block.call(col, x, y)
      end
    end
  end

  def inspect
    "\n" + @array.map do |row|
      row.map {|col| col == nil ? EMPTY : col }.join
    end.join("\n")
  end

  def rotate
    new_array = width.times.map do |x|
      height.times.map do |y|
        @array.dig(height - y - 1, x)
      end
    end

    Omino.new(new_array)
  end

  def flip
    new_array = height.times.map do |y|
      width.times.map do |x|
        @array.dig(y, width - x - 1)
      end
    end

    Omino.new(new_array)
  end

  def width
    @width ||= @array.map(&:length).max
  end

  def height
    @array.length
  end

  def ==(other)
    @array == other.array
  end

  def positions
    pos = []

    each_with_index do |col, x, y|
      pos << [x, y] if col
    end

    pos.sort
  end
end

def parse(input)
  array = input.split(/,|\n/).map do |row|
    row.chars.map do |c|
      case c
      when EMPTY; nil
      when /\d/; c.to_i
      else c
      end
    end
  end

  width = array.map(&:length).max
  array.map! {|row| row + Array.new(width - row.length) }

  Omino.new(array)
end

def ok?(board, omino, b_x, b_y)
  mapping = {}

  omino.each_with_index do |col, x, y|
    next unless col

    b = board.dig(b_y + y, b_x + x)

    return false unless b

    if mapping[col]
      return false unless (mapping[col] + b) == 7
    else
      mapping[col] = b
    end
  end

  true
end

def positions(input)
  board = parse(input)

  positions = []

  OMINOS.each do |omino|
    board.each_with_index do |_, x, y|
      positions << omino.positions.map {|_x, _y| [_x + x, _y + y] } if ok?(board, omino, x, y)
    end
  end

  positions
end

def solve(input)
  board = parse(input)

  OMINOS.each do |omino|
    board.each_with_index do |_, x, y|
      return "true" if ok?(board, omino, x, y)
    end
  end

  "false"
end

def rotate4(omino)
  3.times.inject([omino]) {|ary, _| ary + [ary.last.rotate] }
end

def flip(omino)
  [omino, omino.flip]
end

OMINOS = (<<EOS).split("\n\n").map(&method(:parse)).flat_map(&method(:rotate4)).flat_map(&method(:flip)).uniq(&:positions)
a
bcbc
a...

a
bcbc
.a

a
bcbc
..a

a
bcbc
...a

.a
bcbc
.a

.a
bcbc
..a

ba
.cbc
..a

ba
.cbc
.a

ba
.cb
..ac

ba
.cbc
...a

aba
..cbc
EOS

TEST_DATA = <<~EOS
/*0*/ test("44165,44516", "false");
/*1*/ test("26265,31436", "true");
/*2*/ test("46345,54215", "true");
/*3*/ test("62143,11152", "false");
/*4*/ test("4242,4314,1562", "false");
/*5*/ test("5612,3656,4523", "false");
/*6*/ test("5514,1311,5252", "false");
/*7*/ test("5262,4631,2644", "true");
/*8*/ test("6626,3324,2644", "false");
/*9*/ test("4645,6314,2564", "true");
/*10*/ test("54,65,23,21,14", "true");
/*11*/ test("5325,3641,1335", "true");
/*12*/ test("4163,2156,2553", "true");
/*13*/ test("3126,6543,4352", "false");
/*14*/ test("4464,5423,5216", "true");
/*15*/ test("3564,3634,5631", "false");
/*16*/ test("4363,3454,2126", "true");
/*17*/ test("25,25,33,12,52", "false");
/*18*/ test("1551,4542,3624", "true");
/*19*/ test("6623,4126,6331", "false");
/*20*/ test("2432,6215,1623", "true");
/*21*/ test("1151,6555,3616", "false");
/*22*/ test("2466,1242,4444", "false");
/*23*/ test("5646,1463,4244", "true");
/*24*/ test("1255,6413,4534", "true");
/*25*/ test("1325,2312,2425", "false");
/*26*/ test("2544,6413,4656", "true");
/*27*/ test("1656,4131,3235", "true");
/*28*/ test("6332,3631,4113", "false");
/*29*/ test("4525,2151,2336", "true");
/*30*/ test("1645,2356,4314", "true");
/*31*/ test("3334,6215,1553", "true");
/*32*/ test("2622,5251,5165", "false");
/*33*/ test("1111,5613,3451", "false");
/*34*/ test("6146,4512,6353", "true");
/*35*/ test("2455,3312,6461", "false");
/*36*/ test("1221,1325,1422", "false");
/*37*/ test("1562,2236,5212", "false");
/*38*/ test("6622,3324,5155", "true");
/*39*/ test("2352,4631,1236", "true");
/*40*/ test("4645,2252,6554", "false");
/*41*/ test("3542,6515,1231", "true");
/*42*/ test("12,61,56,45,23", "false");
/*43*/ test("4643,6522,3625", "false");
/*44*/ test("1151,1642,4512", "false");
/*45*/ test("5423,5146,2212", "false");
/*46*/ test("6224,3412,5653", "true");
/*47*/ test("3122,5423,6231", "true");
/*48*/ test("5421,2351,6513", "false");
/*49*/ test("5652,3542,3313", "true");
/*50*/ test("5524,3335,1146", "false");
/*51*/ test("5311,4126,6425", "true");
/*52*/ test("15,43,62,42,14", "true");
/*53*/ test("3631,3542,3265", "true");
/*54*/ test("1232,5364,6135", "true");
/*55*/ test("2441,4644,5433", "false");
/*56*/ test("2213,5621,3412", "true");
/*57*/ test("6644,1264,1235", "true");
/*58*/ test("5613,1423,6315", "true");
/*59*/ test("6552,1546,2141", "false");
/*60*/ test("5623,1461,5645", "true");
/*61*/ test("1442,1436,6362", "false");
/*62*/ test("3443,5145,4546", "false");
/*63*/ test("1244,1313,2316", "false");
/*64*/ test("2152,1463,2114", "true");
/*65*/ test("1211,6234,5561", "false");
/*66*/ test("4152,1252,3142", "false");
/*67*/ test("6645,1231,6122", "false");
/*68*/ test("353,241,121,536", "true");
/*69*/ test("224,444,651,234", "true");
/*70*/ test("643,214,244,343", "false");
/*71*/ test("624,542,214,333", "true");
/*72*/ test("441,426,536,656", "true");
/*73*/ test("564,642,513,364", "true");
/*74*/ test("422,136,414,416", "false");
/*75*/ test("463,356,113,662", "true");
/*76*/ test("464,515,435,462", "true");
/*77*/ test("531,145,364,525", "false");
/*78*/ test("623,564,153,633", "false");
/*79*/ test("335,462,531,424", "false");
/*80*/ test("131,111,535,436", "false");
/*81*/ test("435,414,423,365", "true");
/*82*/ test("144,512,332,346", "true");
/*83*/ test("342,246,342,634", "false");
/*84*/ test("246,566,431,415", "true");
/*85*/ test("444,554,234,621", "true");
/*86*/ test("313,624,165,652", "true");
/*87*/ test("563,262,545,315", "true");
/*88*/ test("213,264,154,264", "false");
/*89*/ test("364,434,246,113", "false");
/*90*/ test("411,656,325,225", "false");
/*91*/ test("624,234,115,443", "true");
/*92*/ test("252,214,635,154", "false");
/*93*/ test("146,213,525,164", "false");
/*94*/ test("456,423,112,352", "true");
/*95*/ test("253,156,111,355", "false");
/*96*/ test("252,161,562,365", "false");
/*97*/ test("136,553,544,524", "true");
/*98*/ test("414,351,161,525", "true");
/*99*/ test("261,442,111,531", "true");
/*100*/ test("323,664,454,133", "true");
/*101*/ test("213,415,225,165", "false");
/*102*/ test("363,162,165,533", "false");
/*103*/ test("346,441,315,241", "false");
/*104*/ test("121,312,155,164", "true");
/*105*/ test("123,311,452,365", "true");
/*106*/ test("361,145,212,431", "true");
/*107*/ test("451,264,412,513", "false");
/*108*/ test("311,456,263,226", "true");
/*109*/ test("343,442,624,635", "false");
/*110*/ test("534,644,234,251", "false");
/*111*/ test("515,346,462,435", "true");
/*112*/ test("445,126,165,636", "false");
/*113*/ test("343,355,126,353", "false");
/*114*/ test("623,533,256,144", "true");
/*115*/ test("125,341,566,416", "false");
/*116*/ test("354,434,621,411", "true");
/*117*/ test("356,435,253,114", "false");
/*118*/ test("141,265,533,514", "true");
/*119*/ test("613,426,142,535", "true");
/*120*/ test("366,322,413,325", "true");
/*121*/ test("331,542,343,545", "false");
/*122*/ test("261,512,563,123", "false");
/*123*/ test("242,132,656,164", "true");
/*124*/ test("133,545,441,665", "false");
/*125*/ test("111,151,621,545", "false");
/*126*/ test("132,154,234,653", "false");
/*127*/ test("114,455,635,511", "false");
/*128*/ test("14366,64254,66664,42611,41245", "false");
/*129*/ test("41114,53116,13122,66613,35111", "false");
/*130*/ test("22146,34244,16154,62531,51426", "true");
/*131*/ test("464316,136563,136326,535655,641161,252655", "true");
/*132*/ test("166255,615452,261224,533566,323335,556213", "false");
/*133*/ test("126665,245653,343553,254661,365415,361154", "false");
/*134*/ test("1512663,1525531,5456426,6336325,4324465,6512242,4112466", "true");
/*135*/ test("2236563,6644542,4425515,6641142,4214543,1156426,3225413", "false");
/*136*/ test("5545354,6566343,3525411,5356165,4625265,1535435,5522665", "false");
EOS

Minitest::Reporters.use!(Minitest::Reporters::ProgressReporter.new)

# docker-compose run --rm -w /app/YYYYmmdd bundle exec ruby doukaku.rb -n /#1$/
describe 'Doukaku' do
  def self.test_order; :sorted; end

  TEST_DATA.each_line do |test|
    number, input, expected = test.scan(/(\d+).*"(.*)", "(.*)"/)[0]

    it "##{number}" do
      assert_equal expected, solve(input)
    end
  end
end
