# Mega Man Labs

Framework for classic Mega Man games to build upon using [Godot Engine](https://godotengine.org).

![In-game screenshot](/.resources/screenshot-02.png)

## Features

- Classic Mega Man physics
- Mega Man and Proto Man as playable characters including optional
  - Sliding
  - Weapon charging
  - Double jumping
- Local multiplayer co-op (groundwork)
- Flexible stage sections system with camera screen transitions.
- Support for arbitrary base resolutions
  - Presets for regular (256 x 224) and wide-screen (384 x 240)
  - Dynamic in-game base resolution switching
  - Pixel-art upscaling filter for arbitrary
    (non-integer factor) target resolutions without visual artifacts
- Post-processing shaders
  - CRT-Easymode
  - CRT-Lottes
- Special weapons system
  - Quick switch method (MM10 style)
- UI, menus, and screens
  - Title screen
  - Stage-select screen
  - Game-over screen
  - Weapons sub-menu
  - Life/weapon energy bars
- Items and item drops
  - Life/weapon energy pellets
    - Optional non-pausing energy refills (MM11 style)
  - Extra lives
  - Energy tanks
- Checkpoints
- Optional modern lighting effects
  - Glow
- Modern gamepad support
- Touch screen controls and menu support
- Should work out of the box on various platforms
  - Desktop (Linux, Windows, MacOS), Android, iOS, HTML5
  - GLES2 support for low-end hardware, mobile, web, etc.
- Stage building features
  - Automatic conversion of ladder tiles (just draw them)
  - Automatic conversion of insta-kill hazard tiles (just draw them)
  - Doors (regular/boss)
  - Example gimmicks
    - Appearing blocks
    - Conveyor belts
    - Wall of death
  - Example enemies
    - Metall
    - Shield Attacker
    - Telly
  - Example robot master bosses
    - Thunder Man
  - Example stages
    - Test lab stage
    - Wide-screen rebuild of Heat Man's stage (MM2)

## Installation and Usage

To be able to take a look at, edit, test, and build this project, you need
**version 3.5** of the Godot Engine Editor, which you can download from the
[official website](https://godotengine.org/download/3.x). Just clone or download
this repository and import its `project.godot` file from within the Godot
editor project manager. Other versions might work, but it is recommended to
use the above-mentioned version of the Godot Engine.

## Contributing

In general, all kinds of contributions are appreciated, e.g., bug reports,
bug fixes, feature implementations like additional enemy types, etc.
As I am mostly focused on coding, I would be glad if there
are pixel-artists interested in creating original Mega Man artwork for this
project like stage tilesets, enemy designs, and so on.

For people with very little Godot experience interested in code contributions,
the following lists a few helpful related resources in no particular order:

- [Project Workflow Best Practices][Best Practices]
- [GDScript Style Guide][Style Guide]

## License

All code of this project is licensed under the MIT license
([LICENSE.txt](LICENSE.txt)).

Music used in this project is created by the
[Time Tangent Team](https://timetangentteam.bandcamp.com/releases) and
licensed under the [CC BY-NC-SA 3.0][CC BY-NC-SA 3.0] license.

[Thunder Man][Thunder Man Deviant Art] stage boss sprites are created by
[Boberatu][Boberatu Deviant Art] and licensed under the
[CC BY-NC 3.0][CC BY-NC 3.0] license.

Some touch screen [UI elements][X-Box Buttons] are created by
[Arks @Scissormarks][Arks] and licensed under the [CC BY 4.0][CC BY 4.0] license.

Mega Man and all related content is copyrighted by Capcom Co., Ltd.  
This project and its owner is not affiliated with Capcom in any way.

## Credits

### Assets

[Godot Virtual Joystick](https://github.com/MarcoFazioRandom/Virtual-Joystick-Godot)

### Resources

- Understanding pixel-art upscaling filters/shaders
  - [Pixel Art Filtering](https://jorenjoestar.github.io/post/pixel_art_filtering/)
  - [Manual texture filtering for pixelated games in WebGL](https://csantosbh.wordpress.com/2014/01/25/manual-texture-filtering-for-pixelated-games-in-webgl/)

[Boberatu Deviant Art]: https://www.deviantart.com/boberatu
[Thunder Man Deviant Art]: https://www.deviantart.com/boberatu/art/MPN-001-Thunder-man-313453472
[Arks]: https://twitter.com/ScissorMarks
[X-Box Buttons]: https://arks.itch.io/xbox-buttons
[CC BY-NC-SA 3.0]: https://creativecommons.org/licenses/by-nc-sa/3.0/
[CC BY-NC 3.0]: https://creativecommons.org/licenses/by-nc/3.0/
[CC BY 4.0]: https://creativecommons.org/licenses/by/4.0/
[Best Practices]: https://docs.godotengine.org/en/stable/getting_started/workflow/best_practices/index.html
[Style Guide]: https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/gdscript_styleguide.html
