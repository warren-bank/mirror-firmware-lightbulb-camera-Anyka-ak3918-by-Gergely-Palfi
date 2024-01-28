# This is a modified version of
https://github.com/kuhnchris/IOT-ANYKA-PTZdaemon

# Available commands

The command names differ from the original to improve clarity, but this means the old web_ui is not compatible.

NOTE: some of the commands (set_ar, set_deg, set_speed...) are commented out because they are not so useful as the `init_ptz` call already sets them, if you need them just enable and recompile.

### PTZ commands
- `init_ptz` homes the camera and starts tracking the position in degrees
- `up` `down` `left` `right` relative motion for the web_ui
- `right_up` `right_down` `left_up` `left_down` relative diagonal motion commands for the web_ui
- `t2p [xdegrees] [ydegrees]` turn to position
### IR commands
- `init_ir`
- `get_ir_in_lev` get the input lever of the sensor
- `get_ir_thres` get the current setting for IR auto trigger (just a guess)
- `set_ir_thres [num]`
- `set_ir_cut [0|1]` control the IR shutter (used by web_ui)
- `set_ir_checkmode`
### Other commands
- `q` quit the daemon
- `ping` returns pong

## Build: 
There is no need for special compiler if using static executable. See the example on the main page to compile.

## PTZ?

**P**an **T**ilt **Z**oom - basically the camera controls.
