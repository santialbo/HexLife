
class HexLife
    radius: 15
    apotema: null
    nrows: 20
    ncols: 12
    cells: null
    dt: 200
    timeout: null
    canvas: null
    toroidal: true
    context: null
    bl: 2
    bh: 3
    sl: 3
    sh: 4

    constructor: ->
        @apotema = @radius*Math.cos(30*Math.PI/180)
        @refresh()

        @hooks()

        @createCells()
        @drawCells()

    refresh: ->
        @createCanvas()
        @resizeCanvas()
        @createDrawingContext()

    hooks: ->
        game = this
        @canvas.addEventListener "click", ((e) -> game.clickCanvasHandler game, e)

    start: ->
        @timeout = setInterval =>
            @update()
            @drawCells()
        , @dt

    pause: ->
        clearInterval @timeout

    update: ->
        cells2 = ((@cells[i][j] for j in [0..(@ncols - 1)]) for i in [0..(@nrows - 1)])
        for i in [0..(@nrows - 1)]
            for j in [0 ..(@ncols - 1)]
                n = @sumneighbours i, j
                if @cells[i][j]
                    cells2[i][j] = (n >= @sl and n <= @sh)
                else
                    cells2[i][j] = (n >= @bl and n <= @bh)
        @cells = cells2

    createCanvas: ->
        @canvas = document.getElementById 'canvas'

    clickCanvasHandler: (game, e) ->
        x = 0
        y = 0
        if (e.pageX || e.pageY) 
            x = e.pageX
            y = e.pageY
        else
            x = e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft 
            y = e.clientY + document.body.scrollTop + document.documentElement.scrollTop 
        x -= game.canvas.offsetLeft
        y -= game.canvas.offsetTop
        game.clickCanvas x, y
    
    clickCanvas: (x, y) ->
        maxdist = 1e6
        hi = 0
        hj = 0
        for i in [0..(@nrows - 1)]
            for j in [0 ..(@ncols - 1)]
                cy = @apotema*(i + 1) - @apotema
                cx = @radius + (2*@radius + @apotema)*j + (if i%2==1 then (@radius + @apotema*0.5) else 0) - (@radius + @apotema*0.5)
                dist = (Math.pow(cx - x, 2) + Math.pow(cy - y, 2))
                if dist < maxdist
                    hi = i
                    hj = j
                    maxdist = dist
        @cells[hi][hj] = not @cells[hi][hj]
        @drawCells()

    resizeCanvas: ->
        @canvas.width = (@radius*2 + @apotema)*@ncols - @apotema*0.5 + @radius
        @canvas.height = @apotema * (@nrows + 1)
        # crop image
        @canvas.width -= @radius*2
        @canvas.height -= @apotema*2

    createDrawingContext: ->
        @context = @canvas.getContext '2d'

    createCells: ->
        @cells = ((false for j in [0..(@ncols - 1)]) for i in [0..(@nrows - 1)])

    drawCells: ->
        for i in [0..(@nrows - 1)]
            for j in [0 ..(@ncols - 1)]
                if @cells[i][j]
                    @fillCell i, j, '#08C'
                else
                    @fillCell i, j, '#BEF'
        for i in [0..(@nrows - 1)]
            for j in [0 ..(@ncols - 1)]
                @drawCell i, j, '#FFF'

    fillCell: (i, j, c) ->
        @context.fillStyle = c
        cy = @apotema*(i + 1)
        cx = @radius + (2*@radius + @apotema)*j + (if i%2==1 then (@radius + @apotema*0.5) else 0)
        # crop image
        cx -= @radius + @apotema*0.5
        cy -= @apotema
        @context.beginPath()
        @context.moveTo (cx + @radius), cy
        for s in [1..6]
            @context.lineTo (cx + @radius*Math.cos(s*60*Math.PI/180)), (cy + @radius*Math.sin(s*60*Math.PI/180))
        @context.closePath()
        @context.fill()

    drawCell: (i, j, c) ->
        @context.strokeStyle = c
        @context.lineWidth = 3
        cy = @apotema*(i + 1)
        cx = @radius + (2*@radius + @apotema)*j + (if i%2==1 then (@radius + @apotema*0.5) else 0)
        # crop image
        cx -= @radius + @apotema*0.5
        cy -= @apotema
        @context.beginPath()
        @context.moveTo (cx + @radius), cy
        for s in [1..6]
            @context.lineTo (cx + @radius*Math.cos(s*60*Math.PI/180)), (cy + @radius*Math.sin(s*60*Math.PI/180))
        @context.closePath()
        @context.stroke()

    getneighbour: (i, j) ->
        if not @toroidal and (i < 0 or i >= @nrows or j < 0 or j >= @ncols)
            return false
        if i < 0
            i += @nrows
        else if i >= @nrows
            i -= @nrows
        if j < 0
            j += @ncols
        else if j >= @ncols
            j -= @ncols
        return @cells[i][j]

    sumneighbours: (i, j) ->
        sum = (@getneighbour i - 2, j) + (@getneighbour i + 2, j) + (@getneighbour i + 1, j) + (@getneighbour i - 1, j)
        if i%2 == 0
            sum += (@getneighbour i + 1, j - 1) + (@getneighbour i - 1, j - 1) 
        else
            sum += (@getneighbour i + 1, j + 1) + (@getneighbour i - 1, j + 1) 
        return sum

life = new HexLife()
$('#play').click (e) -> 
    life.start()
    $('#play').attr 'style', 'display: none;'
    $('#step').attr 'style', 'display: none;'
    $('#pause').attr 'style', ''
$('#pause').click (e) -> 
    life.pause()
    $('#pause').attr 'style', 'display: none;'
    $('#play').attr 'style', ''
    $('#step').attr 'style', ''
$('#step').click (e) -> 
    life.update()
    life.drawCells()
$('#toroidal').click (e) ->
    life.toroidal = $(this).is ':checked'
    console.log life.toroidal
$('#refresh').click (e) ->
    life.nrows = parseInt $('#nrows').val()
    life.ncols = parseInt $('#ncols').val()
    life.pause()
    life.refresh()
    life.createCells()
    life.drawCells()
$('#bl').blur (e) ->
    if not isNaN (parseInt $('#bl').val())
        life.bl = parseInt $('#bl').val()
    else
        parseInt $('#bl').val(life.bl)
$('#bh').blur (e) ->
    if not isNaN (parseInt $('#bh').val())
        life.bh = parseInt $('#bh').val()
    else
        parseInt $('#bh').val(life.bh)
$('#sl').blur (e) ->
    if not isNaN (parseInt $('#sl').val())
        life.sl = parseInt $('#sl').val()
    else
        parseInt $('#sl').val(life.sl)
$('#sh').blur (e) ->
    if not isNaN (parseInt $('#sh').val())
        life.sh = parseInt $('#sh').val()
    else
        parseInt $('#sh').val(life.sh)