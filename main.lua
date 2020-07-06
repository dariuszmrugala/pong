require 'config'

Class = require 'libraries/class'
push = require 'libraries/push'

require 'Ball'
require 'Paddle'


function love.load()
    
    love.graphics.setDefaultFilter('nearest', 'nearest')
    
    smallFont = love.graphics.newFont('font.ttf', 8)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    victoryFont = love.graphics.newFont('font.ttf', 24)
    
    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.ogg', 'static'),
        ['point_scored'] = love.audio.newSource('sounds/point_scored.ogg', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.ogg', 'static')
    }
    
    palyer1Score = 0
    palyer2Score = 0 
    
    winningPlayer = 0
    
    paddle1 = Paddle(5, 30, PADDLE_THICKNESS, PADDLE_HEIGHT)
    paddle2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 60 , PADDLE_THICKNESS ,PADDLE_HEIGHT)
    
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, BALL_SIZE , BALL_SIZE )
    
    math.randomseed(os.time())
    servingPlayer = math.random(2) == 1 and 1 or 2
    if servingPlayer == 1 then
        ball.dx = BALL_SPEED    
    else
        ball.dx = -BALL_SPEED
    end
    
    gameState = 'start'
    
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    })
    love.window.setTitle("Pong")
    
end

function love.resize(width, height)
    push:resize(width, height) 
end

function love.update(dt)
   
    if gameState == 'serve' then

    elseif gameState == 'play' then
        
        if ball:collides(paddle1) then
            -- deflect ball to the right
            ball.dx = -ball.dx * 1.03
            ball.x = paddle1.x + PADDLE_THICKNESS

            sounds['paddle_hit']:play()
            
            if ball.dy < 0 then
                ball.dy = -math.random(10,150)
            else
                ball.dy = math.random(10,150)
            end
        end
    
        if ball:collides(paddle2) then
            -- deflect ball to the left
            ball.dx = -ball.dx * 1.03
            ball.x = paddle2.x - BALL_SIZE

            sounds['paddle_hit']:play()
    
            if ball.dy < 0 then
                ball.dy = -math.random(10,150)
            else
                ball.dy = math.random(10,150)
            end
        end

        if ball.x <=0 then
            palyer2Score = palyer2Score + 1
            servingPlayer = 1
            sounds['point_scored']:play()
            ball:reset()
            ball.dx = BALL_SPEED
    
            if palyer2Score >= 3 then
                gameState = 'victory'
                winningPlayer = 2
            else
                gameState = 'serve'
            end
        end
    
        if ball.x >= VIRTUAL_WIDTH - BALL_SIZE then
            palyer1Score = palyer1Score + 1
            servingPlayer = 2

            sounds['point_scored']:play()
            ball:reset()
            ball.dx = -BALL_SPEED
            
            if palyer1Score >= 3 then
                gameState = 'victory'
                winningPlayer = 1
            else
                gameState = 'serve'
            end
        end

        if ball.y <= 0 then
            ball.dy = -ball.dy

            sounds['wall_hit']:play()
        end
    
        if ball.y >= VIRTUAL_HEIGHT - BALL_SIZE then
            ball.dy = -ball.dy

            sounds['wall_hit']:play()
        end

    end

    
    if love.keyboard.isDown('w') then
        paddle1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        paddle1.dy = PADDLE_SPEED
    else
        paddle1.dy = 0
    end
    
    if love.keyboard.isDown('up') then
        paddle2.dy = - PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        paddle2.dy = PADDLE_SPEED
    else
        paddle2.dy = 0
    end
    
    
    paddle1:update(dt)
    paddle2:update(dt)
    
    if gameState == 'play' then
        ball:update(dt)
    end

end

function love.keypressed(key)
    if key == 'escape' then 
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'victory' then
            gameState = 'start'
            palyer1Score = 0
            palyer2Score = 0
        elseif gameState == 'serve' then
            gameState = 'play'
        end
    end
end

function love.draw()
    push:apply('start')
    
    love.graphics.clear(40 / 255 , 42 / 255 , 52 / 255, 255 / 255)

    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf("Welcome to Pong!" , 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press Enter to Play!", 0 , 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf("Player " .. tostring(servingPlayer) .. "'s turn!", 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press Enter to Serve!", 0 , 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'victory' then
        love.graphics.setFont(victoryFont)
        love.graphics.printf("Player " .. tostring(winningPlayer) .. " wins!", 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press Enter to Serve!", 0 , 42, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then
    end
    
    ball:render()
    paddle1:render()
    paddle2:render()

    displayScore()
    
    if SHOW_FPS then
        displayFPS()
    end

    push:apply('end')
end

function displayFPS()
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.setFont(smallFont) 
    love.graphics.print('FPS: ' .. tostring( love.timer.getFPS() ), 0, 0)
    love.graphics.setColor(1,1,1,1)
end

function displayScore()
    love.graphics.setFont(scoreFont)
    love.graphics.print(palyer1Score, VIRTUAL_WIDTH / 2 - 50 , VIRTUAL_HEIGHT / 3)
    love.graphics.print(palyer2Score, VIRTUAL_WIDTH / 2 + 30 , VIRTUAL_HEIGHT / 3)
end