# Animal Blast

Yet another match 3 blaster.

## Gameplay

Aim with the cursor, fire by clicking.

Connect three or more of the same to "pop" the animals,
saving them from their peril of falling into the river.
After popping,
if there are any animals that don't have a connection to the top of the screen,
they are also popped.

There are three default difficulties,
each changing the number of columns and variety of animals.

### Score

The game displays three stats:

1. The number of animals saved.
2. A score
	- For every shot, increases by `(n * (n + 1)) / 2`,
	where n is the number of animals saved in that shot.
3. The number of rows that have advanced from the top of the screen.

### Non-Continuous Mode

The game starts with five rows advancing onto the screen.
If you take a shot and it fails to pop any animals, you gain a strike.
On the third strike, a new row of animals advance onto the screen.

Additionally, if there are less than one and a half rows worth of animals left,
you're not currently in a state of warning, another row will advance.

### Continuous Mode

Rows will continuously roll onto screen.
There is no penalty for missing a shot.
While there are less than two and a half rows worth of animals left,
they will roll at a faster speed.

## Customization

There are some aspects of the game that can be customized.

### Palette

In the palette menu, accessed from the main screen,
you can change the tiles and animals used.

In order from left to right, the tiles represent:

- The "normal" tiles. These are where the animals are.
- The "lose" tiles. These are where the animals fall into on game over.
- The "defense" tiles. These are the bottom row, under the launcher.

There are eight animal options.

The top four are used in Easy,
the next two are added in Medium,
with the last two added in Hard.

### Game Difficulty

The custom difficulty grants access to the following properties:

- Balls per Row
	- Min 5, Max 15
	- The number of animals that make up a row, aka number of columns.
	- The size of the animals scales based on this.
- Number of Ball Types
	- Min 4, Max 8
	- The number of different animals from the palette to use.
- Continuous Roll Speed
	- Min 5
	- How fast (in pixels per second) to roll balls in continuous mode.
- Strikes until Next Roll
	- Min 1
	- The number of stikes needed to trigger a new row
	- At 1, rolls on every strike

## Licenses

Content in this repo is licensed under the [Mozilla Public License 2.0](LICENSE),
unless otherwise specified in [licenses.json](licenses.json).

Source Code available on [GitHub](https://github.com/icemoonmagic/animal-blast).
