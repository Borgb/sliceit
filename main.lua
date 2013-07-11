display.setStatusBar( display.HiddenStatusBar )


local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0)

earthSize = 100


local earth = display.newImageRect( "earth.png", earthSize, earthSize)
physics.addBody( earth, "static", {isSensor = true} )
earth:setMask( earthMask )
earth.isHitTestMasked = true
earth.x = display.contentCenterX
earth.y = display.contentCenterY

local earthMask = graphics.newMask( "earthmask.png" )
local mask = graphics.newMask( "mask.png" )



---------------------------------------------------------------------------
-- 1pixel rect that will be the colliding object for slashing --
---------------------------------------------------------------------------
local touchrect = display.newRect(-1, -1, 1, 1)
physics.addBody( touchrect, {isSensor = true} )
touchrect.isBullet = true
touchrect:setFillColor(0, 0, 0, 0)

local touchEnd = 0


---------------------------------------------------------------------------
-- border edges so the rect can collide and reset when out of screen --
---------------------------------------------------------------------------

--The top edge
local borderTop = display.newRect( 0, -50, display.contentWidth, 10 )
physics.addBody( borderTop, "static", borderBody )
borderTop.name = "edge"
borderTop:setFillColor(255, 0, 0, 250)

--The bottom edge
local borderBottom = display.newRect( 0, display.contentHeight+50, display.contentWidth, 10 )
physics.addBody( borderBottom, "static",borderBody )
borderBottom.name = "edge"
borderBottom:setFillColor(0, 255, 0, 250)

--The left edge
local borderLeft = display.newRect( -50, 0, 10, display.contentHeight )
physics.addBody( borderLeft, "static", borderBody )
borderLeft.name = "edge"
borderLeft:setFillColor(0, 0, 255, 250)

--The right edge
local borderRight = display.newRect( display.contentWidth+50, 0, 10, display.contentHeight )
physics.addBody( borderRight, "static", borderBody )
borderRight.name = "edge"
borderRight:setFillColor(255, 0, 255, 250)


---------------------------------------------------------------------------
-- function for moving the rectangle and changeing gravity --
---------------------------------------------------------------------------

local function moveRect()

	touchrect.x = -100
	touchrect.y = -100

	physics.setGravity( 0, 0 )

	earth.x = display.contentCenterX
	earth.y = display.contentCenterY

	transition.to(earth, {time = 200, alpha = 1})

end


---------------------------------------------------------------------------
-- function and values for drawing slashing line --
---------------------------------------------------------------------------

local maxPoints = 5
local lineThickness = 7
local endPoints = {}

local function movePoint(event)

	touchrect.x = event.x
	touchrect.y = event.y

	        -- Insert a new point into the front of the array
        table.insert(endPoints, 1, {x = event.x, y = event.y, line= nil}) 
 
        -- Remove any excessed points
        if(#endPoints > maxPoints) then 
                table.remove(endPoints)
        end
 
        for i,v in ipairs(endPoints) do
                local line = display.newLine(v.x, v.y, event.x, event.y)
      		  line.width = lineThickness
                transition.to(line, { alpha = 0, width = 0, onComplete = function(event) line:removeSelf() end})                
        end
 
	if event.phase == "ended" then
		touchEnd = 1
		while(#endPoints > 0) do
			table.remove(endPoints)
		end

	elseif event.phase == "began" then
		touchEnd = 0
	end

end
Runtime:addEventListener("touch", movePoint)


---------------------------------------------------------------------------
-- switch image with 2 new ones with mask placed and rotated --
---------------------------------------------------------------------------

local function createSplit(maskXloc, maskYloc, angle1, angle2)

		earth.alpha = 0

		force1 = math.random(-15, -5)/2
		force2 = math.random(5, 15)/2

		local earth1 = display.newImageRect( "earth.png", earthSize, earthSize)
		earth1.x = earth.x
		earth1.y = earth.y
		earth1:setMask( mask )
		physics.addBody( earth1, {isSensor = true} )

		local earth2 = display.newImageRect( "earth.png", earthSize, earthSize)
		earth2.x = earth.x
		earth2.y = earth.y
		earth2:setMask( mask )
		physics.addBody( earth2, {isSensor = true} )

		earth.x = display.contentWidth + earth.contentWidth

		earth1.maskX = maskXloc
		earth1.maskY = maskYloc	
		earth1.maskRotation = angle1

		earth2.maskX = maskXloc
		earth2.maskY = maskYloc	
		earth2.maskRotation = angle2

		earth1:applyForce( force2, 0, earth1.x, earth1.y )
		earth2:applyForce( force1, 0, earth2.x, earth2.y )

		local function removeLine()
			earth1:removeSelf()
			earth2:removeSelf()
			moveRect()
		end

		transition.to(earth1, {time = 1500, alpha = 1, onComplete=removeLine} )
		transition.to(earth2, {time = 1500, alpha = 1} )

end


---------------------------------------------------------------------------
-- function for when slashing/colliding with the image  --
---------------------------------------------------------------------------

local xLine = {}
local yLine = {}

local function onCollision(event)

	if event.phase == "began" and event.object2.name ~= "edge" then

		xLine[1] = touchrect.x
		yLine[1] = touchrect.y

	elseif event.phase == "ended" and event.object2.name ~= "edge" and touchEnd ~= 1 then


		xLine[2] = touchrect.x
		yLine[2] = touchrect.y

		local midX = (xLine[1] + xLine[2])/2
		local midY = (yLine[1] + yLine[2])/2

		local maskXloc = midX - earth.x 
		local maskYloc = midY - earth.y

		local angle1 = 180 - math.deg( math.atan((xLine[1] - xLine[2])/(yLine[1] - yLine[2]) ))
		local angle2 = angle1 - 180

		timer.performWithDelay(20, function() createSplit(maskXloc, maskYloc, angle1, angle2) end, 1) 

	end

	if event.object2.name == "edge" then
		transition.to(earth, {time = 100, alpha = 0, onComplete=moveRect} )
	end


end
Runtime:addEventListener("collision", onCollision)
