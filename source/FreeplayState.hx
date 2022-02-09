package;

#if sys
import smTools.SMFile;
// import sys.FileSystem;
// import sys.io.File;
#end
import flixel.util.FlxTimer;
import flixel.input.gamepad.FlxGamepad;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.addons.transition.FlxTransitionableState;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
#if windows
import Discord.DiscordClient;
#end

using StringTools;

class FreeplayState extends MusicBeatState // REWRITE FREEPLAY!?!?!? HELL YEA!!!!!
{
	var whiteshit:FlxSprite;

	var curSelected:Int = 0;

	var songArray:Array<String> = [
		"Too Seiso", "You Cant Kusa", "Triple Talent", "Circus", 'Ankimo', "Asacoco", "Sunshine", 'Caretaker', 'White Moon', "Koyochaos"
	];

	var boxgrp:FlxTypedSpriteGroup<FlxSprite>;

	var bg:FlxSprite;

	var cdman:Bool = true;

	var fuck:Int = 0;

	var songtext:FlxText;
	var prevsongtext:FlxText;

	override function create()
	{
		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Freeplay Menu", null);
		#end

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('MainMenuMusic'));
		}

		bg = new FlxSprite().loadGraphic(Paths.image('backgroundlool'));
		bg.screenCenter();
		bg.setGraphicSize(1280, 720);

		boxgrp = new FlxTypedSpriteGroup<FlxSprite>();

		if (FlxG.save.data.songArray.length != 0)
		{
			for (i in 0...songArray.length)
			{
				var songName = songArray[fuck];
				var songId = songName.replace(' ', '-').toLowerCase();

				if (FlxG.save.data.songArray.contains(songName))
				{
					FlxG.log.add(songArray[i] + ' found');

					var box:FlxSprite = new FlxSprite(fuck * 780, 0).loadGraphic(Paths.image('FreeBox'));
					boxgrp.add(box);

					var char:FlxSprite = new FlxSprite(fuck * 780, 0).loadGraphic(Paths.image('fpstuff/' + songId));
					if (songId == 'too-seiso' || songId == 'you-cant-kusa' || songId == 'triple-talent')
						char.setGraphicSize(620, 465);
					boxgrp.add(char);

					var daStatic:FlxSprite = new FlxSprite();
					daStatic.frames = Paths.getSparrowAtlas('daSTAT');
					daStatic.alpha = 0.2;
					daStatic.setGraphicSize(620, 465);
					daStatic.setPosition((fuck * 780) + 440, 211);
					daStatic.animation.addByPrefix('static', 'staticFLASH', 24, true);
					boxgrp.add(daStatic);
					daStatic.animation.play('static');

					fuck += 1;
				}
				else
				{
					songArray.remove(songName);
				}
			}
		}
		else
			songArray = ['lol'];

		whiteshit = new FlxSprite().makeGraphic(1280, 720, FlxColor.WHITE);
		whiteshit.alpha = 0;

		var songName = songArray[curSelected];

		songtext = new FlxText(0, FlxG.height - 80, songName, 25);
		songtext.setFormat("Sonic CD Menu Font Regular", 25, FlxColor.fromRGB(255, 255, 255));
		songtext.x = (FlxG.width / 2) - (25 / 2 * songName.length);

		FlxG.log.add('sexo: ' + (songtext.width / songName.length));

		prevsongtext = new FlxText(0, FlxG.height - 80, songName, 25);
		prevsongtext.x = (FlxG.width / 2) - (25 / 2 * songName.length);
		prevsongtext.setFormat("Sonic CD Menu Font Regular", 25, FlxColor.fromRGB(255, 255, 255));

		add(bg);
		add(songtext);
		add(prevsongtext);
		add(boxgrp);
		add(whiteshit);

		if (songArray[0] == 'lol')
		{
			remove(songtext);
			remove(prevsongtext);
		}

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var upP = FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A;
		var downP = FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D;
		var accepted = controls.ACCEPT;

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.DPAD_UP)
			{
				changeSelection(-1);
			}
			if (gamepad.justPressed.DPAD_DOWN)
			{
				changeSelection(1);
			}
		}

		if (cdman)
		{
			if (upP)
			{
				changeSelection(-1);
			}
			if (downP)
			{
				changeSelection(1);
			}
		}

		if (controls.BACK)
		{
			FlxG.switchState(new MainMenuState());
		}

		if (accepted && cdman && songArray[0] != 'lol')
		{
			cdman = false;

			var songId = songArray[curSelected].replace(' ', '-').toLowerCase();

			PlayState.SONG = Song.loadFromJson(songId + '-hard', songId);

			PlayState.isFreeplay = true;
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = 2;
			PlayState.storyWeek = 1;
			FlxTween.tween(whiteshit, {alpha: 1}, 0.4);
			FlxG.sound.play(Paths.sound('confirmMenu'));
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			PlayStateChangeables.nocheese = false;
			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState());
			});
		}
	}

	function changeSelection(change:Int = 0)
	{
		#if !switch
		// NGio.logEvent(songArray[curSelected]);
		#end

		var oldCurSelected = curSelected;

		curSelected += change;
		if (curSelected < 0)
			curSelected = songArray.length - 1;
		else if (curSelected > songArray.length - 1)
			curSelected = 0;

		var translationFactor = curSelected - oldCurSelected;

		cdman = false;
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		FlxTween.tween(boxgrp, {x: boxgrp.x - 780 * translationFactor}, 0.2, {
			ease: FlxEase.expoOut,
			onComplete: function(sus:FlxTween)
			{
				cdman = true;
			}
		});
		songtext.alpha = 0;

		var songName = songArray[curSelected];

		songtext.text = songName;
		FlxTween.tween(songtext, {alpha: 1, x: (FlxG.width / 2) - (25 / 2 * songName.length)}, 0.2, {ease: FlxEase.expoOut});
		FlxTween.tween(prevsongtext, {alpha: 0, x: (FlxG.width / 2) - (25 / 2 * songName.length)}, 0.2, {ease: FlxEase.expoOut});

		// NGio.logEvent(songArray[curSelected]);
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	#if sys
	public var sm:SMFile;
	public var path:String;
	#end
	public var songCharacter:String = "";

	public var diffs = [];

	#if sys
	public function new(song:String, week:Int, songCharacter:String, ?sm:SMFile = null, ?path:String = "")
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.sm = sm;
		this.path = path;
	}
	#else
	public function new(song:String, week:Int, songCharacter:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
	}
	#end
}
