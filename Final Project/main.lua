Class = require("class")
push = require("push")
require("Platform")

WINDOW_WIDTH, WINDOW_HEIGHT = love.window.getDesktopDimensions()

function love.load()
    love.window.setTitle('To The Heavens')

    push:setupScreen(WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {fullscreen = true})

    math.randomseed(os.time())

    player = {
        width = 40,
        height = 64,
        x = (WINDOW_WIDTH / 2) - (40 / 2),
        y = WINDOW_HEIGHT - 64,
        prevX = (WINDOW_WIDTH / 2) - (40 / 2),
        prevY = WINDOW_HEIGHT - 64,
        xVelocity = 0,
        yVelocity = 0,
        jumpSpeed = -900,
        gravity = -2000,
        speed = 250
    }

    states = {
        'menu',
        'game',
        'endlevel',
        'endgame'
    }

    state = 'menu'

    level = 1

    endLevelTimer = 4

    columnNum = 10
    rowNum = 9

    initLevel(level)
end

function initLevel(level)
    love.keyboard.keysPressed = {}

    if level%40 == 0 then
        columnNum = columnNum - 2
    end

    if level%20 == 0 then
        rowNum = rowNum - 2
    elseif level%10 == 0 then
        columnNum = columnNum - 1
    end

    platforms = {}
    setLayout(columnNum, rowNum)
end

function love.keypressed(key)
    love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
    if love.keyboard.keysPressed[key] then
        return true
    else
        return false
    end
end

function collides(x1, y1, width1, height1, x2, y2, width2, height2)
    return x1 < x2 + width2 and x2 < x1 + width1 and 
        y1 < y2 + height2 and y2 < y1 + height1
end

function love.update(dt)
    if state == 'menu' and (love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return')) then
        state = 'game'
    elseif state == 'game' then
        if love.keyboard.isDown('up') or love.keyboard.isDown('w') or love.keyboard.isDown('space') then
            if player.yVelocity == 0 then
                player.yVelocity = player.jumpSpeed
            end
        end

        if love.keyboard.isDown('left') or love.keyboard.isDown('a') then
            player.xVelocity = -player.speed
        elseif love.keyboard.isDown('right') or love.keyboard.isDown('d') then
            player.xVelocity = player.speed
        end

        if player.yVelocity ~= 0 then
            player.yVelocity = player.yVelocity - player.gravity * dt
            player.y = player.y + player.yVelocity * dt
        end

        if player.xVelocity ~= 0 then
            player.x = player.x + player.xVelocity * dt
            if not love.keyboard.isDown('left') and not love.keyboard.isDown('right') 
                and not love.keyboard.isDown('a') and not love.keyboard.isDown('d') then
                    player.xVelocity = 0
            end
        end

        if player.y + player.height > WINDOW_HEIGHT then
            player.yVelocity = 0
            player.y = WINDOW_HEIGHT - player.height
        elseif player.x < 0 then
            player.xVelocity = 0
            player.x = 0
        elseif player.x + player.width > WINDOW_WIDTH then
            player.xVelocity = 0
            player.x = WINDOW_WIDTH - player.width
        elseif player.y < 0 then
            player.y = WINDOW_HEIGHT - player.width
            player.yVelocity = 0
            level = level + 1
            state = 'endlevel'
        end

    elseif state == 'endlevel' then
        if level > 50 then
            state = 'endgame'
        end
        endLevelTimer = endLevelTimer - dt
        if endLevelTimer <= 1 then
            endLevelTimer = 4
            initLevel(level)
            state = 'game'
        end
    elseif state == 'endgame' then
        if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
            level = 1
            initLevel(1)
            state = 'game'
        end
    end

    resolveCollision()

    player.prevX = player.x
    player.prevY = player.y

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
    
    if love.keyboard.wasPressed('r') then
        love.load()
    end
end

function resolveCollision()
    local bottomTimer = 1/60
    for i = 1, #platforms do
        if player.x < platforms[i].x + platforms[i].width and player.x + player.width > platforms[i].x
        and player.y < platforms[i].y + platforms[i].height and player.y + player.height > platforms[i].y then
            if player.prevX < platforms[i].x + platforms[i].width and player.prevX + player.width > platforms[i].x then
                if player.y + player.height/2 < platforms[i].y + platforms[i].height/2 then
                    player.y = player.y - (player.y + player.height - platforms[i].y)
                    if love.keyboard.isDown('up') or love.keyboard.isDown('w') or love.keyboard.isDown('space') then
                        player.yVelocity = player.jumpSpeed
                    else
                        player.yVelocity = 200
                    end
                else
                    player.y = player.y + (platforms[i].y + platforms[i].height - player.y)
                    player.yVelocity = 2000
                    bottomTimer = bottomTimer - 1/60
                    if bottomTimer <= 0 then
                        player.yVelocity = 100
                    end
                end
            end
            
            if player.prevY < platforms[i].y + platforms[i].height and player.prevY + player.height > platforms[i].y then
                if player.x + player.width/2 < platforms[i].x + platforms[i].width/2 then
                    player.x = player.x - (player.x + player.width - platforms[i].x)
                else
                    player.x = player.x + (platforms[i].x + platforms[i].width - player.x)
                end
            end
        end
    end
end

function setLayout(columnNum, rowNum)
    yDistance = WINDOW_HEIGHT / (rowNum + 1)
    xMax = WINDOW_WIDTH / columnNum

    for x = 1, columnNum do
        for y = 1, rowNum do
            addPlatform(math.random((x - 1)*xMax, x*xMax), y*yDistance, 50, 10)
        end
    end
end

function addPlatform(x, y, width, height)
    table.insert(platforms, Platform(x, y, width, height))
end

function love.draw()
    if state == 'menu' then
        love.graphics.setBackgroundColor(0, 0, 0)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print('TO THE HEAVENS', WINDOW_WIDTH / 2 - 200, WINDOW_HEIGHT / 2 - 250, 0, 4, 4)
        love.graphics.print('Press Enter/Return to begin', WINDOW_WIDTH / 2 - 115, WINDOW_HEIGHT - 300, 0, 1.5, 1.5)
    elseif state == 'game' then
        love.graphics.setBackgroundColor(1, 1, 1)
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle('fill', player.x, player.y, player.width, player.height)

        for i = 1, #platforms do
            platforms[i]:render()
        end

        love.graphics.setColor(0, 0, 0)
        love.graphics.print('Level: '..level, 20, 20, 0, 2, 2)
    elseif state == 'endlevel' then
        love.graphics.setBackgroundColor(0, 0, 0)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print('YOU BEAT LEVEL '..level-1, WINDOW_WIDTH / 2 - 50, WINDOW_HEIGHT - 250)
        love.graphics.print('NEXT LEVEL BEGINS IN '..math.floor(endLevelTimer), WINDOW_WIDTH / 2 - 70, WINDOW_HEIGHT - 200)
    elseif state == 'endgame' then
        love.graphics.setBackgroundColor(0, 0, 0)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print('YOU BEAT "TO THE HEAVENS"!!!', WINDOW_WIDTH / 2 - 350, WINDOW_HEIGHT / 2 - 250, 0, 4, 4)
        love.graphics.print('Press Enter/Return to Play Again', WINDOW_WIDTH / 2 - 150, WINDOW_HEIGHT - 300, 0, 1.5, 1.5)
    end
end
