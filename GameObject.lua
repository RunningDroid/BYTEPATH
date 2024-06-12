GameObject = Object:extend()

function GameObject:new(area, x, y, opts)
    local opts = opts or {}
    if opts then for k, v in pairs(opts) do self[k] = v end end

    self.area = area
    self.x, self.y = x, y
    self.id = UUID()
    self.creation_time = love.timer.getTime()
    self.timer = Timer()
    self.dead = false
    self.depth = 50

    self.previous_collisions = {}
    self.current_collisions = {}
end

function GameObject:update(dt)
    if self.timer then self.timer:update(dt) end
    if self.shape then 
        self.previous_collisions = table.copy(self.current_collisions) 
        self.current_collisions = {}
    end
end

function GameObject:draw()

end

function GameObject:destroy()
    self.timer:destroy()
    if self.shape then HC.remove(self.shape) end
    self.shape = nil
end

function GameObject:enter(tag)
    local shapes = {}
    for shape in pairs(HC.neighbors(self.shape)) do
        if shape.tag == tag then
            if self.shape:collidesWith(shape) then
                self.current_collisions[shape.id] = true
                if not self.previous_collisions[shape.id] then table.insert(shapes, shape) end
            end
        end
    end
    return shapes
end

function GameObject:enemyProjectileCollisions()
    for _, proj in ipairs(self:enter('Projectile')) do
        if proj.object then
			self:hit(proj.object.damage, proj.object.x, proj.object.y, proj.object.r)
			if self.hp <= 0 then
				current_room.player:onKill(self)
			end
			if proj.object.pierce > 0 then
				proj.object.pierce = proj.object.pierce - 1
				if proj.object.attack == "Explode" then
					proj.object.area:addGameObject("Explosion", proj.object.x, proj.object.y, {
						color = proj.object.color,
						attack = proj.object.attack,
						no_projectiles = proj.object.proj_spawned
					})
				end
            elseif current_room.player.bouncer and proj.object.bounce and proj.object.bounce > 0 then
                proj.object.bounce = proj.object.bounce - 1
                local x1, y1 = proj.object.shape:center()
                local x2, y2 = self.shape:center()
                local n = math.atan2(y2 - y1, x2 -x1)
                local nx, ny = math.cos(n), math.sin(n)
                local wall = n - math.pi/2
                local wx, wy = math.cos(wall), math.sin(wall)
                local vx, vy = math.cos(proj.object.r), math.sin(proj.object.r)
                local ux, uy = (vx * nx + vy * ny) * nx, (vx * nx + vy * ny) * ny
                local wx, wy = vx - ux, vy - uy
                local Vx, Vy = wx - ux, wy - uy
                proj.object.r = math.acos(Vx), math.asin(Vy)
            else
				proj.object:die()
			end
        end
        if self.dead then
			break
		end
    end
end
