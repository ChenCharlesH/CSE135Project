# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

RENDERER =
  TREE_COUNT: 700
  LIGHT_COUNT: 200
  INTERVAL_Z: 400
  FOCUS: 100
  TREE_LUMINANCE:
    min: 3
    max: 15
  TREE_CHANGE_COUNT: 10
  TREE_CHANGE_DELTA: 0.5
  DELTA_THETA: Math.PI / 100
  init: ->
    @setParameters()
    @reconstructMethod()
    @createElements()
    @render()
    return
  setParameters: ->
    @$container = $('#jsi-forest-container')
    @width = @$container.width()
    @height = @$container.height()
    @context = $('<canvas />').attr(
      width: @width
      height: @height).appendTo(@$container).get(0).getContext('2d')
    @backgroundDark = @context.createLinearGradient(0, 0, 0, @height)
    @backgroundDark.addColorStop 0, 'hsl(220, 80%, 40%)'
    @backgroundDark.addColorStop 0.3, 'hsl(220, 80%, 10%)'
    @backgroundDark.addColorStop 0.4, 'hsl(220, 80%, 3%)'
    @backgroundDark.addColorStop 0.6, 'hsl(120, 30%, 3%)'
    @backgroundDark.addColorStop 1, 'hsl(120, 30%, 10%)'
    @backgroundLight = @context.createLinearGradient(0, 0, 0, @height)
    @backgroundLight.addColorStop 0, 'hsl(220, 80%, 60%)'
    @backgroundLight.addColorStop 0.4, 'hsl(220, 80%, 60%)'
    @backgroundLight.addColorStop 0.6, 'hsl(120, 50%, 60%)'
    @backgroundLight.addColorStop 1, 'hsl(120, 50%, 60%)'
    @theta = 0
    @trees = []
    @lights = []
    @treeIndex = 0
    @orderAsc = true
    @distance = Math.sqrt((@width / 2) ** 2 + (@height / 2) ** 2)
    @maxLuminaceCount = (@TREE_LUMINANCE.max - (@TREE_LUMINANCE.min)) * @TREE_CHANGE_COUNT / @TREE_CHANGE_DELTA
    return
  reconstructMethod: ->
    @render = @render.bind(this)
    return
  createElements: ->
    `var i`
    `var i`
    `var length`
    treeLight = TREE_CREATOR.create(@TREE_LUMINANCE.max)
    treeDarks = []
    centerX = @width / 2
    centerY = @height / 2
    x = @width * 1.6
    y = @height * 1.6
    maxZ = @INTERVAL_Z * @TREE_COUNT
    i = @TREE_LUMINANCE.min
    max = @TREE_LUMINANCE.max
    while i <= max
      treeDarks.push TREE_CREATOR.create(i)
      i += @TREE_CHANGE_DELTA
    i = 0
    length = @TREE_COUNT
    while i < length
      z = @INTERVAL_Z * (length - i)
      @trees.push new TREE(treeLight, treeDarks, centerX, centerY, x, y, z, maxZ, @FOCUS)
      @trees.push new TREE(treeLight, treeDarks, centerX, centerY, -x, y, z, maxZ, @FOCUS)
      if i > @TREE_COUNT / 2
        @trees.push new TREE(treeLight, treeDarks, centerX, centerY, x * 2, y, z + @INTERVAL_Z / 2, maxZ / 2, @FOCUS)
        @trees.push new TREE(treeLight, treeDarks, centerX, centerY, -x * 2, y, z + @INTERVAL_Z / 2, maxZ / 2, @FOCUS)
      i++
    i = 0
    length = @LIGHT_COUNT
    while i < length
      @lights.push new LIGHT(@width, @height, centerX, centerY, maxZ, @FOCUS)
      i++
    @shadow = SHADOW.init(@width, @height)
    return
  render: ->
    `var i`
    `var length`
    `var i`
    `var length`
    requestAnimationFrame @render
    @context.fillStyle = @backgroundDark
    @context.fillRect 0, 0, @width, @height
    i = 0
    length = @trees.length
    index = @treeIndex / @TREE_CHANGE_COUNT | 0
    while i < length
      @trees[i].render @context, false, index
      i++
    @shadow.render @context
    @context.save()
    @context.beginPath()
    i = 0
    length = @lights.length
    while i < length
      @lights[i].render @context
      i++
    @context.clip()
    @context.fillStyle = @backgroundLight
    @context.fillRect 0, 0, @width, @height
    i = 0
    length = @trees.length
    while i < length
      @trees[i].render @context, true
      i++
    @shadow.render @context
    @context.globalCompositeOperation = 'lighter'
    backgroundCover = @context.createRadialGradient(@width / 2, @height / 2, 0, @width / 2, @height / 2, @distance)
    hue = 180 + 90 * Math.sin(@theta)
    backgroundCover.addColorStop 0, 'hsl(' + hue + ', 80%, 10%)'
    backgroundCover.addColorStop 1, 'hsl(' + hue + ', 80%, 40%)'
    @context.fillStyle = backgroundCover
    @context.fillRect 0, 0, @width, @height
    @context.restore()
    @changeTreeIndex()
    @theta += @DELTA_THETA
    @hue %= Math.PI * 2
    return
  changeTreeIndex: ->
    if @orderAsc
      if ++@treeIndex == @maxLuminaceCount
        @treeIndex--
        @orderAsc = false
    else
      if --@treeIndex == 0
        @treeIndex++
        @orderAsc = true
    return
TREE_CREATOR =
  WIDTH: 120
  HEIGHT: 200
  TRUNK_RATE: 0.8
  BRANCH_RADIAN: Math.PI / 6
  BRANCH_RATE: 0.55
  BRANCH_LEVEL: 8
  COLOR: 'hsl(120, 80%, %luminance%)'
  create: (luminance) ->
    @setParameters luminance
    @drawTree @WIDTH / 2, @HEIGHT, Math.PI / 2, @HEIGHT / 4, 3, 0
    {
      canvas: @canvas
      x: -@WIDTH / 2
      y: -@HEIGHT
    }
  setParameters: (luminance) ->
    @canvas = $('<canvas />').attr(
      width: @WIDTH
      height: @HEIGHT).get(0)
    @context = @canvas.getContext('2d')
    @context.strokeStyle = @COLOR.replace('%luminance', luminance)
    return
  drawTree: (x, y, radian, length, width, level) ->
    if level > @BRANCH_LEVEL
      return
    sin = length * Math.sin(radian)
    cos = length * Math.cos(radian)
    @drawTree x + cos * @TRUNK_RATE, y - (sin * @TRUNK_RATE), radian, length * @TRUNK_RATE, width * @TRUNK_RATE, level + 1
    i = -1
    while i <= 1
      @drawTree x + cos * @BRANCH_RATE, y - (sin * @BRANCH_RATE), radian + @BRANCH_RADIAN * i, length * @BRANCH_RATE, width * @BRANCH_RATE, level + 1
      i += 2
    @context.lineWidth = width
    @context.beginPath()
    @context.moveTo x, y
    @context.lineTo x + length * Math.cos(radian), y - (length * Math.sin(radian))
    @context.stroke()
    return

TREE = (treeLight, treeDarks, centerX, centerY, x, y, z, maxZ, focus) ->
  @treeLight = treeLight
  @treeDarks = treeDarks
  @centerX = centerX
  @centerY = centerY
  @x = x
  @y = y
  @z = z
  @maxZ = maxZ
  @focus = focus
  return

TREE.prototype =
  MAGNIFICATION: 10
  render: (context, isLight, index) ->
    tree = if isLight then @treeLight else @treeDarks[index]
    rate = @focus / (@focus + @z)
    x = @centerX + @x * rate
    y = @centerY + @y * rate
    rate *= @MAGNIFICATION
    context.save()
    context.translate x, y
    context.scale rate, rate
    context.drawImage tree.canvas, tree.x, tree.y
    context.restore()
    if --@z < 0
      @z = @maxZ
    return

LIGHT = (width, height, centerX, centerY, maxZ, focus) ->
  @width = width
  @height = height
  @centerX = centerX
  @centerY = centerY
  @maxZ = maxZ
  @focus = focus
  @init()
  return

LIGHT.prototype =
  VELOCITY_RANGE:
    min: -3
    max: 3
  MAX_RADIUS: 12
  init: ->
    @x = @getRandomValue(
      min: -@width * 2
      max: @width * 2)
    @y = @getRandomValue(
      min: -@height
      max: @height)
    @z = @getRandomValue(
      min: 0
      max: @maxZ)
    @vx = @getRandomValue(@VELOCITY_RANGE)
    @vy = @getRandomValue(@VELOCITY_RANGE)
    @rate = 1
    return
  getRandomValue: (range) ->
    range.min + (range.max - (range.min)) * Math.random()
  render: (context) ->
    rate = @focus / (@focus + @z)
    x = @centerX + @x * rate
    y = @centerY - (@y * rate)
    context.moveTo x, y
    context.arc x, y, @MAX_RADIUS * rate * @rate, 0, Math.PI * 2, false
    if --@z < -@focus or x < 0 or x > @width or y < 0 or y > @height
      @init()
      @rate = 0
    @x += @vx * rate
    @y += @vy * rate
    if @rate >= 1
      return
    @rate += 0.01
    return
SHADOW =
  SHAKE_INTERVAL: Math.PI / 120
  COLOR: 'rgba(0, 0, 0, 0.3)'
  init: (width, height) ->
    @width = width
    @height = height
    @theta = 0
    this
  render: (context) ->
    context.save()
    context.fillStyle = @COLOR
    context.translate @width / 2, @height
    context.scale 0.6, 1.2
    context.rotate Math.PI / 60 * Math.sin(@theta)
    context.beginPath()
    context.arc 0, -108, 8, 0, Math.PI * 2, false
    context.fill()
    context.beginPath()
    context.moveTo 5, -100
    context.bezierCurveTo 40, -100, 40, -70, 30, -40
    context.lineTo 25, -40
    context.lineTo 25, 5
    context.lineTo 5, 5
    context.lineTo 5, -40
    context.lineTo -5, -40
    context.lineTo -5, 5
    context.lineTo -25, 5
    context.lineTo -25, -40
    context.lineTo -30, -40
    context.bezierCurveTo -40, -70, -40, -100, -5, -100
    context.fill()
    context.restore()
    @theta += @SHAKE_INTERVAL
    @theta %= Math.PI * 2
    return
$ ->
  RENDERER.init()
  return
