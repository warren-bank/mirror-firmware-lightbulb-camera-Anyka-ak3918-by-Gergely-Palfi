# Original Repo
This code is a modified verison of [MuhammedKalkan's work](https://github.com/MuhammedKalkan/Anyka-Camera-Firmware)

The IR shutter and sensor have inverted logic on my camera, so that is the only difference.

The IR logic can be set in line #340
All I did was change DAY_LEVEL_HH to DAY_LEVEL_LL (triggers inverted logic in function `ak_misc_set_video_day_night` with the `switch (day_level)`)
