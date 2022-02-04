package;

import flixel.FlxCamera;
#if cpp
import cpp.abi.Abi;
#end
import flixel.util.FlxTimer;
import flixel.input.gamepad.FlxGamepad;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.Lib;
import Options;
import Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;

using StringTools;

class OptionsMenu extends MusicBeatState
{
	public static var instance:OptionsMenu;

	var selector:FlxText;
	var curSelected:Int = 0;
	var cheat:Bool = false;
	var canselect:Bool = true;

	var options:Array<OptionCategory> = [
		new OptionCategory("Holo exe", [
			new JumpscareOption("Displays jumpscares in some songs (this affects the gameplay preformance by alot)"),
			new Vfx("Enables special visual effects (turning it off helps with memory and preformace)"),
			new SplashOption("Enables splattering blood on SICK! hits."),
			new CamMove("Makes the camera move to the notes you or your opponent presses."),
			new LowQuality('Removes parts of the stage in order to achieve smoother gameplay.')
		]),
		new OptionCategory("Gameplay", [
			new DFJKOption(controls),
			new DownscrollOption("Toggle making the notes scroll down rather than up."),
			new MiddlescrollOption("Sets the strumline to the middle of the screen and hides the opponent's."),
			new GhostTapOption("Toggle counting pressing a directional input when no arrow is there as a miss."),
			new Judgement("Customize your Hit Timings. (LEFT or RIGHT)"),
			#if desktop new FPSCapOption("Change your FPS Cap."),
			#end
			new ScrollSpeedOption("Change your scroll speed. (1 = Chart dependent)"),
			new AccuracyDOption("Change how accuracy is calculated. (Accurate = Simple, Complex = Milisecond Based)"),
			new ResetButtonOption("Toggle pressing R to gameover."),
			new InstantRespawn("Toggle if you instantly respawn after dying."),
			// new OffsetMenu("Get a note offset based off of your inputs!"),
			new CustomizeGameplay("Drag and drop gameplay modules to your prefered positions!")
		]),
		new OptionCategory("Appearance", [
			new EditorRes("Not showing the editor grid will greatly increase editor performance"),
			new DistractionsAndEffectsOption("Toggle stage distractions that can hinder your gameplay."),
			new CamZoomOption("Toggle the camera zoom in-game."),
			new StepManiaOption("Sets the colors of the arrows depending on quantization instead of direction."),
			new AccuracyOption("Display accuracy information on the info bar."),
			new SongPositionOption("Show the song's current position as a scrolling bar."),
			new NPSDisplayOption("Shows your current Notes Per Second on the info bar."),
			new RainbowFPSOption("Make the FPS Counter flicker through rainbow colors."),
			new CpuStrums("Toggle the CPU's strumline lighting up when it hits a note."),
		]),
		new OptionCategory("Misc", [
			new FPSOption("Toggle the FPS Counter"), new FlashingLightsOption("Toggle flashing lights that can cause epileptic seizures and strain."),
			new WatermarkOption("Enable and disable all watermarks from the engine."),
			new AntialiasingOption("Toggle antialiasing, improving graphics quality at a slight performance penalty."),
			new MissSoundsOption("Toggle miss sounds playing when you don't hit a note."), new ScoreScreen("Show the score screen after the end of a song"),
			new ShowInput("Display every single input on the score screen."),
			new Optimization("No characters or backgrounds. Just a usual rhythm game layout."),
			new GraphicLoading("On startup, cache every character. Significantly decrease load times. (HIGH MEMORY)"),
			new BotPlay("Showcase your charts and mods with autoplay."),
			#if debug
			new RealBot('The coolest botplay')]),
			#end
		new OptionCategory("Saves and Data", [
			#if desktop new ReplayOption("View saved song replays."),
			#end
			new ResetScoreOption("Reset your score on all songs and weeks. This is irreversible!"),
			new ResetSettings("Reset ALL your settings. This is irreversible!")
		])
	];

	public var acceptInput:Bool = true;

	private var currentDescription:String = "";
	private var grpControls:FlxTypedGroup<Alphabet>;

	public static var versionShit:FlxText;

	var currentSelectedCat:OptionCategory;
	var blackBorder:FlxSprite;

	override function create()
	{
		clean();
		instance = this;
		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menuBGBlue"));

		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = FlxG.save.data.antialiasing;
		add(menuBG);

		grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

		for (i in 0...options.length)
		{
			var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, options[i].getName(), true, false, true);
			controlLabel.isMenuItem = true;
			controlLabel.targetY = i;
			grpControls.add(controlLabel);
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
		}

		currentDescription = "none";

		versionShit = new FlxText(5, FlxG.height
			+ 40, 0,
			"Offset (Left, Right, Shift for slow): "
			+ HelperFunctions.truncateFloat(FlxG.save.data.offset, 2)
			+ " - Description - "
			+ currentDescription, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		blackBorder = new FlxSprite(-30, FlxG.height + 40).makeGraphic((Std.int(versionShit.width + 900)), Std.int(versionShit.height + 600), FlxColor.BLACK);
		blackBorder.alpha = 0.5;

		add(blackBorder);

		add(versionShit);

		FlxTween.tween(versionShit, {y: FlxG.height - 18}, 2, {ease: FlxEase.elasticInOut});
		FlxTween.tween(blackBorder, {y: FlxG.height - 18}, 2, {ease: FlxEase.elasticInOut});

		changeSelection();

		super.create();
	}

	var isCat:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (acceptInput)
		{
			if (controls.BACK && !isCat)
			{
				FlxG.switchState(new MainMenuState());
				trace("back to da menu");
			}
			else if (controls.BACK)
			{
				isCat = false;
				grpControls.clear();
				for (i in 0...options.length)
				{
					var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, options[i].getName(), true, false);
					controlLabel.isMenuItem = true;
					controlLabel.targetY = i;
					grpControls.add(controlLabel);
					// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
				}

				curSelected = 0;

				changeSelection(curSelected);
			}

			var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

			if (canselect)
			{
				if (gamepad != null)
				{
					if (gamepad.justPressed.DPAD_UP)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						changeSelection(-1);
					}
					if (gamepad.justPressed.DPAD_DOWN)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						changeSelection(1);
					}
				}

				if (FlxG.keys.justPressed.UP)
					changeSelection(-1);
				if (FlxG.keys.justPressed.DOWN)
					changeSelection(1);
			}

			if (isCat)
			{
				if (currentSelectedCat.getOptions()[curSelected].getAccept())
				{
					if (FlxG.keys.pressed.SHIFT)
					{
						if (FlxG.keys.pressed.RIGHT)
							currentSelectedCat.getOptions()[curSelected].right();
						if (FlxG.keys.pressed.LEFT)
							currentSelectedCat.getOptions()[curSelected].left();
					}
					else
					{
						if (FlxG.keys.justPressed.RIGHT)
							currentSelectedCat.getOptions()[curSelected].right();
						if (FlxG.keys.justPressed.LEFT)
							currentSelectedCat.getOptions()[curSelected].left();
					}
				}
				else
				{
					if (FlxG.keys.pressed.SHIFT)
					{
						if (FlxG.keys.justPressed.RIGHT)
							FlxG.save.data.offset += 0.1;
						else if (FlxG.keys.justPressed.LEFT)
							FlxG.save.data.offset -= 0.1;
					}
					else if (FlxG.keys.pressed.RIGHT)
						FlxG.save.data.offset += 0.1;
					else if (FlxG.keys.pressed.LEFT)
						FlxG.save.data.offset -= 0.1;

					versionShit.text = "Offset (Left, Right, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset, 2)
						+ " - Description - " + currentDescription;
				}
				if (currentSelectedCat.getOptions()[curSelected].getAccept())
					versionShit.text = currentSelectedCat.getOptions()[curSelected].getValue() + " - Description - " + currentDescription;
				else
					versionShit.text = "Offset (Left, Right, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset, 2)
						+ " - Description - " + currentDescription;
			}
			else
			{
				if (FlxG.keys.pressed.SHIFT)
				{
					if (FlxG.keys.justPressed.RIGHT)
						FlxG.save.data.offset += 0.1;
					else if (FlxG.keys.justPressed.LEFT)
						FlxG.save.data.offset -= 0.1;
				}
				else if (FlxG.keys.pressed.RIGHT)
					FlxG.save.data.offset += 0.1;
				else if (FlxG.keys.pressed.LEFT)
					FlxG.save.data.offset -= 0.1;

				versionShit.text = "Offset (Left, Right, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset, 2) + " - Description - "
					+ currentDescription;
			}

			if (controls.RESET)
				FlxG.save.data.offset = 0;

			if (controls.ACCEPT && canselect)
			{
				if (isCat)
				{
					if (currentSelectedCat.getOptions()[curSelected].press())
					{
						grpControls.members[curSelected].reType(currentSelectedCat.getOptions()[curSelected].getDisplay());
						trace(currentSelectedCat.getOptions()[curSelected].getDisplay());
						if (currentSelectedCat.getOptions()[curSelected].getDisplay().startsWith('BotPlay'))
						{
							var camera:FlxCamera;
							camera = new FlxCamera();
							FlxG.cameras.add(camera);
							canselect = false;
							FlxG.sound.music.stop();
							var nocheat:FlxSprite = new FlxSprite().loadGraphic(Paths.image('nocheating', 'exe'));
							nocheat.alpha = 0;
							nocheat.cameras = [camera];
							add(nocheat);
							new FlxTimer().start(2, function(ok:FlxTimer)
							{
								FlxTween.tween(nocheat, {alpha: 1}, 1, {
									onComplete: function(ok:FlxTween)
									{
										cheat = true;
										FlxG.save.data.fakebotplay = false;
									}
								});
							});
						}
					}
				}
				else
				{
					currentSelectedCat = options[curSelected];
					isCat = true;
					grpControls.clear();
					for (i in 0...currentSelectedCat.getOptions().length)
					{
						var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, currentSelectedCat.getOptions()[i].getDisplay(), true, false);
						controlLabel.isMenuItem = true;
						controlLabel.targetY = i;
						grpControls.add(controlLabel);
						// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
					}
					curSelected = 0;
				}

				changeSelection();
			}
			else if (!canselect && cheat && controls.ACCEPT)
			{
				FlxG.sound.music.play();
				FlxG.switchState(new OptionsMenu());
			}
		}
		FlxG.save.flush();
	}

	var isSettingControl:Bool = false;

	function changeSelection(change:Int = 0)
	{
		#if !switch
		// NGio.logEvent("Fresh");
		#end

		FlxG.sound.play(Paths.sound("scrollMenu"), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;

		if (isCat)
			currentDescription = currentSelectedCat.getOptions()[curSelected].getDescription();
		else
			currentDescription = "Please select a category";
		if (isCat)
		{
			if (currentSelectedCat.getOptions()[curSelected].getAccept())
				versionShit.text = currentSelectedCat.getOptions()[curSelected].getValue() + " - Description - " + currentDescription;
			else
				versionShit.text = "Offset (Left, Right, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset, 2) + " - Description - "
					+ currentDescription;
		}
		else
			versionShit.text = "Offset (Left, Right, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset, 2) + " - Description - "
				+ currentDescription;
		// selector.y = (70 * curSelected) + 30;

		var bullShit:Int = 0;

		for (item in grpControls.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}
