# Mega Man Labs

Implementation of the classic Mega Man in the [Godot Engine](https://godotengine.org).

![In-game screenshot](/.resources/screenshot-01.png)

## Purpose and Scope

Always wanting to try out game development, I aimlessly read about and fiddled
with current mainstream game engines. As a beginner and without a concrete
project, I felt overwhelmed and quit several times.

Finding out about Godot Engine at some point rekindled my interest in game
development. Its simplicity, coherence, permissive license, and being so
lightweight convinced me to try once more. From the philosophy of the engine
developers, helpful community resources, and the engine documentation I could
draw enough motivation and knowledge to work towards a clearly defined aim this
time around: Create a complete Mega Man (NES) stage.

Apart from being my favorite childhood video game, in my opinion, Mega Man
qualifies as a perfect game to reimplement for learning purpose as a beginner
in terms of complexity.

I put this on GitHub for anyone who might be interested in this stuff.
Be it for educational purpose, a Godot Engine test project to play around with,
an entry point for your own project, or something you might want to contribute
to in some way.

Depending on general interest, or lack thereof, my own motivation, and the
spare time I am able to spend, I might continue to expand this project beyond
the single stage.

I would like to mention that I do not intend for this project to become a
super easy to use Mega Man stage creator with a large amount of assets.
Because for this and more, there is already the awesome
[Mega Man Maker](https://megamanmaker.com/). However, I could imagine it to
become a kind of template or framework for Mega Man style games that offers
more flexibility but requires to accept a learning curve before being able to
create something playable.

## Installation and Usage

To be able to take a look at, edit, test, and build this project, you need
**version 3.2** of the Godot Engine Editor, which you can download from the
[official website](https://godotengine.org/download). Just clone or download
this repository and import its `project.godot` file from within the Godot
editor project manager. Other versions might work, but it is recommended to
use the currently used version of this project.

## Contributing

In general, all kinds of contributions are appreciated, e.g., bug reports,
bug fixes, feature implementations like additional enemy types, etc.
However, most valuable to me would be coding and program architecture advice
from more experienced programmers, since this is first and foremost a learning
project for myself. As I am mostly focused on coding, I would be glad if there
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

Mega Man and all related content is copyrighted by Capcom Co., Ltd.  
This project and its owner is not affiliated with Capcom in any way.

[Boberatu Deviant Art]: https://www.deviantart.com/boberatu
[Thunder Man Deviant Art]: https://www.deviantart.com/boberatu/art/MPN-001-Thunder-man-313453472
[CC BY-NC-SA 3.0]: https://creativecommons.org/licenses/by-nc-sa/3.0/
[CC BY-NC 3.0]: https://creativecommons.org/licenses/by-nc/3.0/
[Best Practices]: https://docs.godotengine.org/en/latest/getting_started/workflow/best_practices/index.html
[Style Guide]: https://docs.godotengine.org/en/latest/getting_started/scripting/gdscript/gdscript_styleguide.html
