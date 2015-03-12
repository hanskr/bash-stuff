-- Load Extensions
local application = require "mjolnir.application"
local window = require "mjolnir.window"
local hotkey = require "mjolnir.hotkey"
local keycodes = require "mjolnir.keycodes"
local fnutils = require "mjolnir.fnutils"
local alert = require "mjolnir.alert"
local screen = require "mjolnir.screen"
-- User packages
local grid = require "mjolnir.bg.grid"
local appfinder = require "mjolnir.cmsj.appfinder"
local sw = require "mjolnir._asm.watcher.screen"

local definitions = nil
local hyper = nil

local gridset = function(frame)
	return function()
		local win = window.focusedwindow()
		if win then
			grid.set(win, frame, win:screen())
		else
			alert.show("No focused window.")
		end
	end
end

local hotkeys = {}

function createHotkeys()
  for key, fun in pairs(definitions) do
    hotkey.bind(hyper, key, fun)
  end
end

function applyPlace(win, place)
  local scrs = screen:allscreens()
  local scr = scrs[place[1]]
  grid.set(win, place[2], scr)
end

function applyLayout(layout1, layout2)
  return function()
    local screens = screen:allscreens()
    local layout = nil
    if # screens == 1 then layout = layout1 else layout = layout2 end
    for appName, place in pairs(layout) do
      local app = appfinder.app_from_name(appName)
      if app then
        for i, win in ipairs(app:allwindows()) do
          if i <= # place then
            applyPlace(win, place[i])
          else
            applyPlace(win, place[1])
          end
        end
      end
    end
  end
end

function init()
  createHotkeys()
  layoutApplier:start()
  alert.show("Mjolnir, at your service.")
end

-- Actual config =================================

hyper = {"cmd", "alt", "shift"}
-- Set grid size.
grid.GRIDWIDTH  = 2
grid.GRIDHEIGHT = 2
grid.MARGINX = 0
grid.MARGINY = 0
local gw = grid.GRIDWIDTH
local gh = grid.GRIDHEIGHT

local goleft = {x = 0, y = 0, w = gw/2, h = gh}
local goright = {x = gw/2, y = 0, w = gw/2, h = gh}
local goup = {x = 0, y = 0, w = gw, h = gh/2}
local godown = {x = 0, y = gh/2, w = gw, h = gh/2}
local gobig = {x = 0, y = 0, w = gw, h = gh}

local layout1 = {
  iTerm = {{1, gobig}},
  HipChat = {{1, gobig}},
  ["IntelliJ IDEA"] = {{1, gobig}},
  ["Microsoft Outlook"] = {{1, gobig}},
  Spotify = {{1, gobig}},
  ["Google Chrome"] = {{1, gobig}}
}

local layout2 = {
  iTerm = {{2, gobig}},
  HipChat = {{1, gobig}},
  ["IntelliJ IDEA"] = {{2, gobig}},
  ["Microsoft Outlook"] = {{1, gobig}},
  Spotify = {{1, gobig}},
  ["Google Chrome"] = {{2, gobig},{1, gobig}}
}

definitions = {
  f = grid.maximize_window,
  left = gridset(goleft),
  right = gridset(goright),
  up = gridset(goup),
  down = gridset(godown),

  z = applyLayout(layout1, layout2),

  x = grid.pushwindow_nextscreen,
  r = mjolnir.reload
}

layoutApplier = sw.new(applyLayout(layout1, layout2))
init()
