CreditsModule = Object:extend()

function CreditsModule:new(console, y)
    self.console = console
    self.y = y

    self.console:addLine(0.02, '')
    self.console:addLine(0.04, '    game by $SSYGEN%')
    self.console:addLine(0.06, '    music by $AIRGLOW%')
    self.console:addLine(0.08, '    sound effects from $freesound.org% by')
    self.console:addLine(0.10, '        $fins jeckkech josepharaoh99 KorGround NSStudios TreasureSounds TheDweebMan%')
    self.console:addLine(0.12, '        $LittleRobotSoundFactory GameAudio NenadSimic DrMinky pyzaist CGEffex broumbroum%')
    self.console:addLine(0.14, '    fonts by')
    self.console:addLine(0.16, '        $Daniel Linssen Troy Mark Simonson%')
    self.console:addLine(0.18, '    made with $love2d.org% with help from')
    self.console:addLine(0.20, '        $slime bartbes CapsAdmin rxi RolandYonaba vrld pelevesque davisdude gvx bakpakin%')
    self.console:addLine(0.22, '    contributions from')
    self.console:addLine(0.24, '        $dulsi RobotLucca Runningdroid jn64%')
    self.console:addLine(0.26, '')

    self.y = y
    self.h = 6*self.console.font:getHeight()

    self.vertical_selection_index = 1
    self.horizontal_selection_index = 1
    self:setSelections()

    self.console.timer:after(0.20, function() self.active = true end)
end

function CreditsModule:update(dt)
    if not self.active then return end

    if input:pressed('up') then
        self.vertical_selection_index = self.vertical_selection_index - 1
        if self.vertical_selection_index < 1 then
			self.vertical_selection_index = #self.selections
		end
        self.horizontal_selection_index = math.min(math.max(1, #self.selections[self.vertical_selection_index]), self.horizontal_selection_index)
    end

    if input:pressed('down') then
        self.vertical_selection_index = self.vertical_selection_index + 1
        if self.vertical_selection_index > #self.selections then
			self.vertical_selection_index = 1
		end
        self.horizontal_selection_index = math.min(math.max(1, #self.selections[self.vertical_selection_index]), self.horizontal_selection_index)
    end

    if input:pressed('left') then
        self.horizontal_selection_index = self.horizontal_selection_index - 1
        if self.horizontal_selection_index < 1 then
			self.horizontal_selection_index = #self.selections[self.vertical_selection_index]
		end
    end

    if input:pressed('right') then
        self.horizontal_selection_index = self.horizontal_selection_index + 1
        if self.horizontal_selection_index > #self.selections[self.vertical_selection_index] then
			self.horizontal_selection_index = 1
		end
    end

    if input:pressed('return') then
        local t = self.selections[self.vertical_selection_index][self.horizontal_selection_index]
        if t then love.system.openURL(t.link) end
    end

    if input:pressed('escape') then
        self.active = false
        self.console:addInputLine(0.02, '[;root,]arch~ ')
    end
end

function CreditsModule:draw()
    if not self.active then return end

    local font = self.console.font
    local selection = self.selections[self.vertical_selection_index][self.horizontal_selection_index]
    local x = selection.ox - 1
    local fontHeight = font:getHeight()
	local rowHeight = fontHeight + 2
    local y = (self.vertical_selection_index * rowHeight) + 5 -- there's a 5 pixel offset along the y axis somewhere
    if self.vertical_selection_index >= 6 and self.vertical_selection_index < 9 then
		y = y + rowHeight
	elseif self.vertical_selection_index >= 9 then
		y = y + (rowHeight * 2)
	end
    local width = selection.width + 2
    local r, g, b = unpack(boost_color)
    love.graphics.setColor(color255To1(r, g, b, 128))
    love.graphics.rectangle('fill', 8 + x, self.y + y, width, fontHeight)
    love.graphics.setColor(color255To1(255, 255, 255, 255))
end

function CreditsModule:setSelections()
    local font = self.console.font
    self.selections = {
        [1] = {{ox = font:getWidth('    game by '), width = font:getWidth('SSYGEN'), link = 'https://twitter.com/SSYGEN'}},
        [2] = {{ox = font:getWidth('    music by '), width = font:getWidth('AIRGLOW'), link = 'https://stratfordct.bandcamp.com/album/airglow-memory-bank'}},
        [3] = {{ox = font:getWidth('    sound effects from '), width = font:getWidth('freesound.org'), link = 'https://freesound.org/'}},
        [4] = {
            {ox = font:getWidth('        '), width = font:getWidth('fins'), link = 'https://freesound.org/people/fins/'},
            {ox = font:getWidth('        fins '), width = font:getWidth('jeckkech'), link = 'https://freesound.org/people/jeckkech/'},
            {ox = font:getWidth('        fins jeckkech '), width = font:getWidth('josepharaoh99'), link = 'https://freesound.org/people/josepharaoh99/'},
            {ox = font:getWidth('        fins jeckkech josepharaoh99 '), width = font:getWidth('KorGround'), link = 'https://freesound.org/people/KorGround/'},
            {ox = font:getWidth('        fins jeckkech josepharaoh99 KorGround '), width = font:getWidth('NSStudios'), link = 'https://freesound.org/people/nsstudios/'},
            {ox = font:getWidth('        fins jeckkech josepharaoh99 KorGround NSStudios '), width = font:getWidth('TreasureSounds'), link = 'https://freesound.org/people/TreasureSounds/'},
            {ox = font:getWidth('        fins jeckkech josepharaoh99 KorGround NSStudios TreasureSounds '), width = font:getWidth('TheDweebMan'), link = 'https://freesound.org/people/TheDweebMan/'},
        },
        [5] = {
            {ox = font:getWidth('        '), width = font:getWidth('LittleRobotSoundFactory'), link = 'https://freesound.org/people/LittleRobotSoundFactory/'},
            {ox = font:getWidth('        LittleRobotSoundFactory '), width = font:getWidth('GameAudio'), link = 'https://www.gameaudio101.com/'},
            {ox = font:getWidth('        LittleRobotSoundFactory GameAudio '), width = font:getWidth('NenadSimic'), link = 'https://freesound.org/people/NenadSimic/'},
            {ox = font:getWidth('        LittleRobotSoundFactory GameAudio NenadSimic '), width = font:getWidth('DrMinky'), link = 'https://freesound.org/people/DrMinky/'},
            {ox = font:getWidth('        LittleRobotSoundFactory GameAudio NenadSimic DrMinky '), width = font:getWidth('pyzaist'), link = 'https://freesound.org/people/pyzaist/'},
            {ox = font:getWidth('        LittleRobotSoundFactory GameAudio NenadSimic DrMinky pyzaist '), width = font:getWidth('CGEffex'), link = 'https://freesound.org/people/CGEffex/'},
            {ox = font:getWidth('        LittleRobotSoundFactory GameAudio NenadSimic DrMinky pyzaist CGEffex '), width = font:getWidth('broumbroum'), link = 'https://freesound.org/people/broumbroum/'},
        },
        [6] = {
            {ox = font:getWidth('        '), width = font:getWidth('Daniel Linssen'), link = 'https://twitter.com/managore'},
            {ox = font:getWidth('        Daniel Linssen '), width = font:getWidth('Troy'), link = 'http://www.pentacom.jp/pentacom/bitfontmaker2/gallery/?id=612'},
            {ox = font:getWidth('        Daniel Linssen Troy '), width = font:getWidth('Mark Simonson'), link = 'https://www.marksimonson.com/'},
        },
        [7] = {{ox = font:getWidth('    made with '), width = font:getWidth('love2d.org'), link = 'https://love2d.org/'}},
        [8] = {
            {ox = font:getWidth('        '), width = font:getWidth('slime'), link = 'https://twitter.com/slime73'},
            {ox = font:getWidth('        slime '), width = font:getWidth('bartbes'), link = 'https://twitter.com/bartbes'},
            {ox = font:getWidth('        slime bartbes '), width = font:getWidth('CapsAdmin'), link = 'https://steamcommunity.com/id/eliashogstvedt'},
            {ox = font:getWidth('        slime bartbes CapsAdmin '), width = font:getWidth('rxi'), link = 'https://github.com/rxi'},
            {ox = font:getWidth('        slime bartbes CapsAdmin rxi '), width = font:getWidth('RolandYonaba'), link = 'https://github.com/Yonaba'},
            {ox = font:getWidth('        slime bartbes CapsAdmin rxi RolandYonaba '), width = font:getWidth('vrld'), link = 'https://twitter.com/the_vrld'},
            {ox = font:getWidth('        slime bartbes CapsAdmin rxi RolandYonaba vrld '), width = font:getWidth('pelevesque'), link = 'https://github.com/pelevesque'},
            {ox = font:getWidth('        slime bartbes CapsAdmin rxi RolandYonaba vrld pelevesque '), width = font:getWidth('davisdude'), link = 'https://github.com/pelevesque'},
            {ox = font:getWidth('        slime bartbes CapsAdmin rxi RolandYonaba vrld pelevesque davisdude '), width = font:getWidth('gvx'), link = 'https://twitter.com/gvxdev'},
            {ox = font:getWidth('        slime bartbes CapsAdmin rxi RolandYonaba vrld pelevesque davisdude gvx '), width = font:getWidth('bakpakin'), link = 'http://bakpakin.com/'},
        },
        [9] = {
            {ox = font:getWidth('        '), width = font:getWidth('dulsi'), link = 'https://github.com/dulsi'},
            {ox = font:getWidth('        dulsi '), width = font:getWidth('RobotLucca'), link = 'https://steamcommunity.com/profiles/76561198039192925'},
            {ox = font:getWidth('        dulsi RobotLucca '), width = font:getWidth('Runningdroid'), link = 'https://github.com/RunningDroid'},
            {ox = font:getWidth('        dulsi RobotLucca Runningdroid '), width = font:getWidth('jn64'), link = 'https://github.com/jn64'},
        },
    }
end
