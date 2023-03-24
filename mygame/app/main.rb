SOLUTION = 'RANARAMA'.freeze
FPS = 60

def check_solved?(args)
  args.state.puzzle_array.join == SOLUTION
end

def render_glyphs(args)
  args.state.puzzle_array.each_with_index do |glyph, index|
    path = "sprites/#{glyph}.png"
    x = 20 + (index * 101)
    y = 100
    args.outputs.sprites << { x: x, y: y, w: 81, h: 81, path: path }
  end
end

def render_selection(args)
  x1 = 20 + (args.state.selected_index * 101)
  x2 = 20 + ((args.state.selected_index + 1) * 101)
  args.outputs.primitives << { x:x1, y:100, w: 81, h: 81, r: 0, g: 0, b: 0, a: 50 }.solid!
  args.outputs.primitives << { x:x2, y:100, w: 81, h: 81, r: 0, g: 0, b: 0, a: 50 }.solid!
end

def fire_input?(args)
  args.inputs.keyboard.key_down.z ||
    args.inputs.keyboard.key_down.j ||
    args.inputs.keyboard.key_down.space ||
    args.inputs.controller_one.key_down.a
end

def handle_input(args)
  current_index = args.state.selected_index
  next_index = current_index
  if args.inputs.keyboard.key_down.left || args.inputs.controller_one.key_down.left
    next_index = current_index - 1
  elsif args.inputs.keyboard.key_down.right || args.inputs.controller_one.key_down.right
    next_index = current_index + 1
  end
  args.state.selected_index = next_index.clamp(0, 6)
end

def handle_swap(args)
  a = args.state.puzzle_array
  i = args.state.selected_index
  a[i], a[i+1] = a[i+1], a[i]
end

def initialize(args)
  $gtk.reset
  args.state.puzzle_array = SOLUTION.split('')
  3 + Random.new.rand(10).times do
    args.state.puzzle_array.shuffle!
  end
  args.state.selected_index = 3
  args.state.timer = 30 * FPS
end

def game_over_lose_tick(args)
  if fire_input?(args)
    args.state.scene = 'title'
    return
  end

  labels = []
  labels << { x: 40, y: 40, text: 'Failed' }
  args.outputs.labels << labels
end

def game_over_win_tick(args)
  if fire_input?(args)
    args.state.scene = 'title'
    return
  end

  labels = []
  labels << { x: 40, y: 40, text: 'Won' }
  args.outputs.labels << labels
end

def gameplay_tick(args)
  if check_solved?(args)
    args.state.scene = 'game_over_win'
    return
  end

  args.state.timer -= 1
  if args.state.timer == 0
    args.state.scene = 'game_over_lose'
    return
  end

  render_glyphs(args)
  render_selection(args)

  handle_input(args)
  handle_swap(args) if fire_input?(args)
end

def title_tick(args)
  if fire_input?(args)
    initialize(args)
    args.state.scene = 'gameplay'
    return
  end

  labels = []
  labels << { x: 40, y: 40, text: 'Prepare to enter ritual combat' }
  args.outputs.labels << labels
end

def tick args
  args.state.scene ||= 'title'
  send("#{args.state.scene}_tick", args)
end

$gtk.reset
