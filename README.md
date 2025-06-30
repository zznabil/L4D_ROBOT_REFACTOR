# L4D_ROBOT_REFACTOR
PAN XIAOHAI L4D ROBOT SOURCEMOD SOURCEPAWN PLUGIN REFACTOR WITH NEW FEATURES AND BEST PRACTICES

## Stuff

- The robot positioning seems to be generally higher than the player.

## TODO

- **Implement Zombie Detection:**
    - The robot currently does not detect any zombies (common or special infected).
    - Refer to `ScanEnemy` and `ScanCommon` functions in `l4d_robot - old original working.sp.txt` and `l4d_robot original PAN XIAOHAI.sp` for examples of how this was previously implemented using line-of-sight checks and distance calculations.
- **Implement Shooting Mechanics:**
    - The robot does not currently shoot at targets.
    - Refer to the `FireBullet` function (and related damage/weapon characteristic arrays) in the older `.sp.txt` files. This includes logic for bullet trajectory, hit detection (ray tracing), visual effects, and sound effects.
- **Implement Robot Reactions to Zombies:**
    - Once zombies are detected and shooting is possible, the robot needs to react appropriately (e.g., aiming, firing).
    - The main game loop (`OnGameFrame` calling a `Do` function in the old files) handled this logic, including target selection, aiming, and deciding when to shoot or reload.
- **Review Ray Tracing Implementation:**
    - Ensure ray tracing (`TR_TraceRayFilter` and custom filter functions) is correctly used for both line-of-sight in detection and for bullet hit registration in shooting, as demonstrated in the provided older script files.
- **Refine Robot Positioning:**
    - Address the observation that the robot positioning is currently too high.
    - The older scripts had logic for robot following and positioning relative to the player, which can be reviewed. The `l4d_robot - old original working.sp.txt` had more sophisticated multi-robot positioning.
