------------------------------------------------------------------------------
--------- IMPORTS
------------------------------------------------------------------------------

import XMonad
import Data.Monoid
import System.Exit
import Graphics.X11.ExtraTypes.XF86
import XMonad.Hooks.DynamicLog
import XMonad.Layout.Spacing
import XMonad.Layout.NoBorders
import XMonad.Util.SpawnOnce
import XMonad.Layout.LayoutBuilder
import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import XMonad.Layout.Renamed (renamed, Rename(CutWordsLeft, Replace))
import XMonad.Layout.ThreeColumns

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

------------------------------------------------------------------------------
--------- CONFIGS
------------------------------------------------------------------------------

myModMask :: KeyMask
myModMask = mod4Mask -- action key

myTerminal :: String
myTerminal = "terminator"  -- terminal

myNormalBorderColor :: String
myNormalBorderColor  = "#213e3b" -- normal window border color

myFocusedBorderColor :: String
myFocusedBorderColor = "#d2e603" -- focused border color

myTitleColor :: String
myTitleColor = "#D2E603" -- color of window title

myTitleLength :: Int
myTitleLength = 80 -- truncate window title to this length

myCurrentWSColor :: String
myCurrentWSColor = "#D2E603" -- color of active workspace

myVisibleWSColor :: String
myVisibleWSColor = "#c185a7" -- color of inactive workspace

myUrgentWSColor :: String
myUrgentWSColor = "#cc0000" -- color of workspace with 'urgent' window

myCurrentWSLeft :: String
myCurrentWSLeft = "   " -- active workspace suffix

myCurrentWSRight :: String
myCurrentWSRight = "   " -- active workspace preffix

myVisibleWSLeft :: String
myVisibleWSLeft = "(" -- inactive workspace suffix

myVisibleWSRight :: String
myVisibleWSRight = ")" -- inactive workspace preffix

myUrgentWSLeft :: String
myUrgentWSLeft = "{" -- urgent workspace suffix

myUrgentWSRight :: String
myUrgentWSRight = "}" -- urgent workspace preffix

myBorderWidth :: Dimension
myBorderWidth   = 3 -- border width

myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True -- window foucs on hover

myClickJustFocuses :: Bool
myClickJustFocuses = False -- window foucs on click

scripts :: String
scripts = "/home/terra/Documents/scripts/" -- scripts location

myFont :: String
myFont = "xft:Ubuntu Mono:regular:size=9:antialias=true:hinting=true" -- fonts

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset -- window count in a workspace

--myWorkspaces    = ["\61705","\61563","\61441","\61684","\61635"]
myWorkspaces :: [String]
myWorkspaces = ["1","2","3","4","5"] -- workspace names


------------------------------------------------------------------------------
--------- KEY BINDINGS
------------------------------------------------------------------------------

myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $ [

      ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf) -- launch a terminal
    
    , ((0, xF86XK_MonBrightnessDown), spawn "") -- backlight keys
    , ((0, xF86XK_MonBrightnessUp), spawn "xbacklight -inc 25")

    , ((0, xF86XK_AudioMute), spawn "pactl set-sink-mute @DEFAULT_SINK@ toggle") -- volume keys
    , ((0, xF86XK_AudioLowerVolume), spawn "pactl set-sink-volume @DEFAULT_SINK@ -10%")
    , ((0, xF86XK_AudioRaiseVolume), spawn "pactl set-sink-volume @DEFAULT_SINK@ +10%")

    --, ((modm, xK_p), spawn "dmenu_run") -- launch dmenu
    ,((modm, xK_p), spawn "rofi -show run") -- launch rofi

    , ((modm .|. shiftMask, xK_p), spawn "gmrun") -- launch gmrun

    , ((modm .|. shiftMask, xK_c), kill)  -- close focused window

    , ((modm, xK_space ), sendMessage NextLayout) -- Rotate through the available layout algorithms

    , ((modm .|. shiftMask, xK_space), setLayout $ XMonad.layoutHook conf) --  Reset the layouts on the current workspace to default

    , ((modm, xK_n), refresh) -- Resize viewed windows to the correct size

    , ((modm, xK_Tab), windows W.focusDown) -- Move focus to the next window

    , ((modm, xK_j), windows W.focusDown) -- Move focus to the next window

    , ((modm, xK_k), windows W.focusUp  ) -- Move focus to the previous window

    , ((modm, xK_m), windows W.focusMaster  ) -- Move focus to the master window

    , ((modm, xK_Return), windows W.swapMaster) -- Swap the focused window and the master window

    , ((modm .|. shiftMask, xK_j), windows W.swapDown  ) -- Swap the focused window with the next window

    , ((modm .|. shiftMask, xK_k), windows W.swapUp    ) -- Swap the focused window with the previous window
    
    , ((modm, xK_h), sendMessage Shrink) -- Shrink the master area

    , ((modm, xK_l), sendMessage Expand) -- Expand the master area

    , ((modm, xK_t), withFocused $ windows . W.sink) -- Push window back into tiling

    , ((modm, xK_comma), sendMessage (IncMasterN 1)) -- Increment the number of windows in the master area

    , ((modm, xK_period), sendMessage (IncMasterN (-1))) -- Deincrement the number of windows in the master area

    -- , ((modm, xK_b), sendMessage ToggleStruts) -- Toggle the status bar gap. Use this binding with avoidStruts from Hooks.ManageDocks.

    , ((modm .|. shiftMask, xK_q), io (exitWith ExitSuccess)) -- Quit xmonad

    , ((modm              , xK_q), spawn "xmonad --recompile; xmonad --restart") -- Restart xmonad

    , ((modm .|. shiftMask, xK_slash), spawn ("echo \"" ++ help ++ "\" | xmessage -file -"))-- Run xmessage with a summary of the default keybindings (useful for beginners)
    ]
    ++

    [((m .|. modm, k), windows $ f i)  -- mod-[1..9], Switch to workspace N
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))  -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


------------------------------------------------------------------------------
--------- MOUSE BINDINGS
------------------------------------------------------------------------------

myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $    
    [
    	((modm, button1), (\w -> focus w >> mouseMoveWindow w >> windows W.shiftMaster)) -- mod-button1, Set the window to floating mode and move by dragging

    	, ((modm, button2), (\w -> focus w >> windows W.shiftMaster)) -- mod-button2, Raise the window to the top of the stack

    	, ((modm, button3), (\w -> focus w >> mouseResizeWindow w >> windows W.shiftMaster)) -- mod-button3, Set the window to floating mode and resize by dragging.
    ]


------------------------------------------------------------------------------
--------- LAYOUTS
------------------------------------------------------------------------------

myLayout = spacing 8 $ tiled ||| Mirror tiled ||| threeCol ||| noBorders Full
  where
     
     tiled   = Tall nmaster delta ratio -- default tiling algorithm partitions the screen into two panes

     nmaster = 1 -- The default number of windows in the master pane

     ratio   = 1/2 -- Default proportion of screen occupied by master pane

     delta   = 3/100 -- Percent of screen to increment by when resizing panes

     threeCol   = renamed [Replace "threeCol"] $ limitWindows 3  $ ThreeCol 1 (3/100) (1/2)

------------------------------------------------------------------------------
--------- WINDOW RULES
------------------------------------------------------------------------------

myManageHook = composeAll [ 
    	className =? "MPlayer"        --> doFloat
    	, className =? "Gimp"           --> doFloat
    	, resource  =? "desktop_window" --> doIgnore
    	, resource  =? "kdesktop"       --> doIgnore 
    ]


------------------------------------------------------------------------------
--------- EVENTS
------------------------------------------------------------------------------

myEventHook = mempty

myLogHook = return ()

myStartupHook = do  -- run on startup
	spawnOnce "nitrogen --restore &"  -- restore last wallpaper 
	spawnOnce "picom --experimental-backend &"

------------------------------------------------------------------------------
--------- STATUS BAR      
------------------------------------------------------------------------------

myBar = "xmobar" -- status bar

myPP = xmobarPP {
	ppTitle = xmobarColor myTitleColor "" . shorten myTitleLength,
	ppCurrent = xmobarColor myCurrentWSColor "" . wrap myCurrentWSLeft myCurrentWSRight,
	ppVisible = xmobarColor myVisibleWSColor "" . wrap myVisibleWSLeft myVisibleWSRight,
	ppUrgent = xmobarColor myUrgentWSColor "" . wrap myUrgentWSLeft myUrgentWSRight
}

toggleStrutsKey XConfig {XMonad.modMask = modMask} = (modMask, xK_b) -- Key binding to toggle the gap for the bar.


------------------------------------------------------------------------------
--------- RUN XMONAD
------------------------------------------------------------------------------

main = xmonad =<< statusBar myBar myPP toggleStrutsKey defaults

defaults = def {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = myLayout,
        manageHook         = myManageHook,
        handleEventHook    = myEventHook,
        logHook            = myLogHook,
        startupHook        = myStartupHook
    }


------------------------------------------------------------------------------
--------- HELP
------------------------------------------------------------------------------

help :: String
help = unlines ["The default modifier key is 'widows'. Default keybindings:",
    "",
    "-- launching and killing programs",
    "mod-Shift-Enter  Launch terminator",
    "mod-p            Launch dmenu",
    "mod-Shift-p      Launch gmrun",
    "mod-Shift-c      Close/kill the focused window",
    "mod-Space        Rotate through the available layout algorithms",
    "mod-Shift-Space  Reset the layouts on the current workSpace to default",
    "mod-n            Resize/refresh viewed windows to the correct size",
    "",
    "-- move focus up or down the window stack",
    "mod-Tab        Move focus to the next window",
    "mod-Shift-Tab  Move focus to the previous window",
    "mod-j          Move focus to the next window",
    "mod-k          Move focus to the previous window",
    "mod-m          Move focus to the master window",
    "",
    "-- modifying the window order",
    "mod-Return   Swap the focused window and the master window",
    "mod-Shift-j  Swap the focused window with the next window",
    "mod-Shift-k  Swap the focused window with the previous window",
    "",
    "-- resizing the master/slave ratio",
    "mod-h  Shrink the master area",
    "mod-l  Expand the master area",
    "",
    "-- floating layer support",
    "mod-t  Push window back into tiling; unfloat and re-tile it",
    "",
    "-- increase or decrease number of windows in the master area",
    "mod-comma  (mod-,)   Increment the number of windows in the master area",
    "mod-period (mod-.)   Deincrement the number of windows in the master area",
    "",
    "-- quit, or restart",
    "mod-Shift-q  Quit xmonad",
    "mod-q        Restart xmonad",
    "mod-[1..9]   Switch to workSpace N",
    "",
    "-- Workspaces & screens",
    "mod-Shift-[1..9]   Move client to workspace N",
    "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
    "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
    "",
    "-- Mouse bindings: default actions bound to mouse events",
    "mod-button1  Set the window to floating mode and move by dragging",
    "mod-button2  Raise the window to the top of the stack",
    "mod-button3  Set the window to floating mode and resize by dragging"]
