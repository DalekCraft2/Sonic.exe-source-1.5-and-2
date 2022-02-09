package; // If you reading this, i am putting random comments on my code cus i feel lonely.

import Replay.Ana;
import Replay.Analysis;
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.FlxGraphic;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.EnumTools;
import haxe.Exception;
import haxe.Json;
import lime.app.Application;
import lime.graphics.Image;
import lime.media.AudioContext;
import lime.media.AudioManager;
import lime.utils.Assets;
import openfl.Lib;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.filters.ShaderFilter;
import openfl.geom.Matrix;
import openfl.ui.KeyLocation;
import openfl.ui.Keyboard;
import openfl.utils.AssetLibrary;
import openfl.utils.AssetManifest;
import openfl.utils.AssetType;
import openfl.media.Sound;
#if sys
import smTools.SMFile;
#end

using StringTools;

#if cpp
import webm.WebmPlayer;
#end
#if cpp
import Discord.DiscordClient;
#end
#if cpp
import Sys;
import sys.FileSystem;
import sys.io.File;
#end

class PlayState extends MusicBeatState
{
	public static var instance:PlayState = null;

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var isFreeplay:Bool = false;
	public static var isList:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var weekSong:Int = 0;
	public static var weekScore:Int = 0;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;

	var spinArray:Array<Int>;

	public static var songPosBG:FlxSprite;

	public var visibleCombos:Array<FlxSprite> = [];

	public static var songPosBar:FlxBar;

	public static var rep:Replay;
	public static var loadRep:Bool = false;
	public static var inResults:Bool = false;

	public static var noteBools:Array<Bool> = [false, false, false, false, false];

	var halloweenLevel:Bool = false;

	var songLength:Float = 0;
	var kadeEngineWatermark:FlxText;

	#if cpp
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	private var vocals:FlxSound;

	public static var isSM:Bool = false;
	#if sys
	public static var sm:SMFile;
	public static var pathToSm:String;
	#end

	public var originalX:Float;

	public static var dad:Character;
	public static var gf:Character;
	public static var boyfriend:Boyfriend;

	public var notes:FlxTypedGroup<Note>;

	private var unspawnNotes:Array<Note> = [];

	public var strumLine:FlxSprite;

	private var curSection:Int = 0;
	var camLocked:Bool = true;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	public static var strumLineNotes:FlxTypedGroup<FlxSprite> = null;
	public static var playerStrums:FlxTypedGroup<FlxSprite> = null;
	public static var playerSplashes:FlxTypedGroup<FlxSprite> = null;
	public static var cpuStrums:FlxTypedGroup<FlxSprite> = null;

	private var camZooming:Bool = false;

	private static var curSong:String = "";

	private var gfSpeed:Int = 1;

	public var health:Float = 1; // making public because sethealth doesnt work without it

	private var combo:Int = 0;

	public static var misses:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var campaignSicks:Int = 0;
	public static var campaignGoods:Int = 0;
	public static var campaignBads:Int = 0;
	public static var campaignShits:Int = 0;

	public var accuracy:Float = 0.00;

	private var accuracyDefault:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalNotesHitDefault:Float = 0;
	private var totalPlayed:Int = 0;
	private var ss:Bool = false;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;
	private var songPositionBar:Float = 0;

	private var generatedMusic:Bool = false;

	private var shakeCam:Bool = false;
	private var shakeCam2:Bool = false;

	private var startingSong:Bool = false;

	public var iconP1:HealthIcon; // making these public again because i may be stupid
	public var iconP2:HealthIcon; // what could go wrong?
	public var camHUD:FlxCamera;
	public var camHUD2:FlxCamera; // jumpscares, ect..
	public var camSustains:FlxCamera;
	public var camNotes:FlxCamera;

	private var camGame:FlxCamera;

	public var cannotDie = false;

	public static var offsetTesting:Bool = false;

	public var isSMFile:Bool = false;

	var notesHitArray:Array<Date> = [];
	var currentFrames:Int = 0;

	var canDodge:Bool = false;
	var dodging:Bool = false;

	var preloaded:Bool = false;

	var daSection:Int = 1;
	var daJumpscare:FlxSprite = new FlxSprite(0, 0);
	var daP3Static:FlxSprite = new FlxSprite(0, 0);
	var daNoteStatic:FlxSprite = new FlxSprite(0, 0);

	var idleToBeat:Bool = true; // change if bf and dad would idle to the beat of the song
	var idleBeat:Int = 2; // how frequently bf and dad would play their idle animation(1 - every beat, 2 - every 2 beats and so on)

	public var dialogue:Array<String> = ['dad:blah blah blah', 'bf:coolswag'];

	var lowQuality:Bool = FlxG.save.data.lq;

	var songName:FlxText;
	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var funpillarts1ANIM:FlxSprite;
	var funpillarts2ANIM:FlxSprite;
	var funboppers1ANIM:FlxSprite;
	var funboppers2ANIM:FlxSprite;

	var p3staticbg:FlxSprite;

	var wall:FlxSprite;

	var balling:FlxSprite = new FlxSprite(0, 0);

	var porker:FlxSprite;
	var thechamber:FlxSprite;
	var floor:FlxSprite;
	var fleetwaybgshit:FlxSprite;
	var emeraldbeam:FlxSprite;
	var emeraldbeamyellow:FlxSprite;
	var pebles:FlxSprite;
	var hands:FlxSprite;
	var eyeflower:FlxSprite;
	var leftSpeaker:FlxSprite;
	var rightSpeaker:FlxSprite;
	var discoBall:FlxSprite;
	var blackFuck:FlxSprite;
	var startCircle:FlxSprite;
	var startText:FlxSprite;
	var cooltext:String = '';
	var isRing:Bool = SONG.isRing;
	var deezNuts:Array<Int> = [4, 5];
	var ballsinyojaws:Int = 0;
	var floaty:Float = 0;
	var tailscircle:String = '';
	var ezTrail:FlxTrail;
	var bgspec:FlxSprite;
	var noteLink:Bool = true;
	var heatlhDrop:Float = 0;
	var camX:Int = 0;
	var camY:Int = 0;
	var bfcamX:Int = 0;
	var bfcamY:Int = 0;
	var cameramove:Bool = FlxG.save.data.cammove;
	var vgblack:FlxSprite;
	var tentas:FlxSprite;
	var fakertransform:FlxSprite = new FlxSprite(100 - 10000, 100 - 10000);
	var popup:Bool = true;

	var fc:Bool = true;

	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;

	public var songScore:Int = 0;

	var songScoreDef:Int = 0;
	var scoreTxt:FlxText;
	var replayTxt:FlxText;
	var ringCounter:FlxSprite;
	var counterNum:FlxText;
	var cNum:Int = 0;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	public static var daPixelZoom:Float = 6;

	public static var theFunne:Bool = true;

	var funneEffect:FlxSprite;
	var inCutscene:Bool = false;
	var usedTimeTravel:Bool = false;

	public static var repPresses:Int = 0;
	public static var repReleases:Int = 0;

	public static var timeCurrently:Float = 0;
	public static var timeCurrentlyR:Float = 0;

	// Will fire once to prevent debug spam messages and broken animations
	private var triggeredAlready:Bool = false;

	// Will decide if she's even allowed to headbang at all depending on the song
	private var allowedToHeadbang:Bool = false;

	// Per song additive offset
	public static var songOffset:Float = 0;

	// BotPlay text
	private var botPlayState:FlxText;
	// Replay shit
	private var saveNotes:Array<Dynamic> = [];
	private var saveJudge:Array<String> = [];
	private var replayAna:Analysis = new Analysis(); // replay analysis

	public static var highestCombo:Int = 0;

	private var executeModchart = false;

	// Animation common suffixes
	private var dataSuffix:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
	private var dataColor:Array<String> = ['purple', 'blue', 'green', 'red'];

	private var dataSuffix5k:Array<String> = ['LEFT', 'DOWN', 'SPACE', 'UP', 'RIGHT'];
	private var dataColor5k:Array<String> = ['purple', 'blue', 'gold', 'green', 'red'];

	public static var startTime = 0.0;

	// API stuff

	public function addObject(object:FlxBasic)
	{
		add(object);
	}

	public function removeObject(object:FlxBasic)
	{
		remove(object);
	}

	override public function create()
	{
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();

		FlxG.sound.cache(Paths.inst(songLowercase));
		FlxG.sound.cache(Paths.voices(songLowercase));

		if (isRing)
			ballsinyojaws = 1;

		if (curSong != songLowercase)
		{
			Main.dumpCache(); // Honestly it's just preloading so idrc.

			// PRELOADING STUFFS
			if (songLowercase == 'too-seiso' && FlxG.save.data.jumpscares)
			{
				daJumpscare.frames = Paths.getSparrowAtlas('sonicJUMPSCARE', 'exe');
				daJumpscare.animation.addByPrefix('jump', 'sonicSPOOK', 24, false);
				add(daJumpscare);
				daJumpscare.animation.play('jump');

				daNoteStatic.frames = Paths.getSparrowAtlas('hitStatic', 'exe');
				daNoteStatic.animation.addByPrefix('static', 'staticANIMATION', 24, false);
				daNoteStatic.animation.play('static');

				remove(daNoteStatic);
			}
			else if (songLowercase == 'parent')
			{
				add(fakertransform);
				fakertransform.frames = Paths.getSparrowAtlas('Faker_Transformation', 'exe');
				fakertransform.animation.addByPrefix('1', 'TransformationRIGHT');
				fakertransform.animation.addByPrefix('2', 'TransformationLEFT');
				fakertransform.animation.addByPrefix('3', 'TransformationUP');
				fakertransform.animation.addByPrefix('4', 'TransformationDOWN');
				fakertransform.animation.play('1', true);
				fakertransform.animation.play('2', true);
				fakertransform.animation.play('3', true);
				fakertransform.animation.play('4', true);
				fakertransform.alpha = 0;
				remove(fakertransform);
			}
			else if (songLowercase == 'you-cant-kusa')
			{
				daNoteStatic.frames = Paths.getSparrowAtlas('hitStatic', 'exe');
				daNoteStatic.animation.addByPrefix('static', 'staticANIMATION', 24, false);
				daNoteStatic.animation.play('static');

				remove(daNoteStatic);

				dad = new Character(100, 100, 'sonic.exe alt');
				add(dad);
				remove(dad);
			}
			else if (songLowercase == 'triple-talent')
			{
				daP3Static.frames = Paths.getSparrowAtlas('Phase3Static', 'exe');
				daP3Static.animation.addByPrefix('P3Static', 'Phase3Static', 24, false);
				add(daP3Static);
				daP3Static.animation.play('P3Static');
				remove(daP3Static);

				daNoteStatic.frames = Paths.getSparrowAtlas('hitStatic', 'exe');
				daNoteStatic.animation.addByPrefix('static', 'staticANIMATION', 24, false);
				daNoteStatic.animation.play('static');

				remove(daNoteStatic);

				/*p3staticbg.frames = Paths.getSparrowAtlas('Phase3Static', 'exe');
					p3staticbg.animation.addByPrefix('P3Static', 'Phase3Static', 24, true);
					add(p3staticbg);
					p3staticbg.animation.play('P3Static');
					p3staticbg.screenCenter();
					p3staticbg.scale.x = 4;
					p3staticbg.scale.y = 4;
					p3staticbg.visible = false;
					p3staticbg.cameras = [camHUD2];
					remove(p3staticbg); */

				dad = new Character(61.15, -94.75, 'beast');
				add(dad);
				remove(dad);

				dad = new Character(61.15, -94.75, 'knucks');
				add(dad);
				remove(dad);

				dad = new Character(61.15, -94.75, 'eggdickface');
				add(dad);
				remove(dad);

				dad = new Character(61.15, -94.75, 'tails');
				add(dad);
				remove(dad);

				boyfriend = new Boyfriend(466.1, 685.6 - 300, 'bf-perspective-flipped');
				add(boyfriend);
				remove(boyfriend);

				boyfriend = new Boyfriend(466.1, 685.6 - 300, 'bf-perspective');
				add(boyfriend);
				remove(boyfriend);
			}
			else if (songLowercase == 'sunshine')
			{
				var bfdeathshit:FlxSprite = new FlxSprite(); // Yo what if i just preload the game over :)
				bfdeathshit.frames = Paths.getSparrowAtlas('3DGOpng');
				bfdeathshit.setGraphicSize(720, 720);
				bfdeathshit.animation.addByPrefix('firstdeath', 'DeathAnim', 24, false);
				bfdeathshit.screenCenter();
				bfdeathshit.animation.play('firstdeath');
				add(bfdeathshit);
				bfdeathshit.animation.finishCallback = function(b:String)
				{
					remove(bfdeathshit);
				}
				dad = new Character(100, 100, 'TDollAlt');
				add(dad);
				remove(dad);
			}
			else if (songLowercase == 'koyochaos')
			{
				FlxG.bitmap.add(Paths.image('characters/fleetway1', 'shared'));
				FlxG.bitmap.add(Paths.image('characters/fleetway2', 'shared'));
				FlxG.bitmap.add(Paths.image('characters/fleetway3', 'shared'));
				FlxG.bitmap.add(Paths.image('Warning', 'exe'));
				FlxG.bitmap.add(Paths.image('spacebar_icon', 'exe'));

				var dad1:Character = new Character(0, 0, 'fleetway-extras');
				dad1.alpha = 0.01;
				add(dad1);
				remove(dad1);

				var dad2:Character = new Character(0, 0, 'fleetway-extras2');
				dad2.alpha = 0.01;
				add(dad2);
				remove(dad2);

				var dad3:Character = new Character(0, 0, 'fleetway-extras3');
				dad3.alpha = 0.01;
				add(dad3);
				remove(dad3);

				boyfriend = new Boyfriend(2040.55 - 200, 685.6 - 130, 'bf-super');
				add(boyfriend);
				remove(boyfriend);

				var poo4:FlxSprite = new FlxSprite();
				add(poo4);
				poo4.frames = Paths.getSparrowAtlas('Warning', 'exe');
				poo4.animation.addByPrefix('a', 'Warning Flash', 24, false);
				poo4.animation.play('a', true);
				poo4.alpha = 0.01;
				remove(poo4);

				var poo1:FlxSprite = new FlxSprite();
				add(poo1);
				poo1.frames = Paths.getSparrowAtlas('spacebar_icon', 'exe');
				poo1.animation.addByPrefix('a', 'spacebar', 24, false);
				poo1.animation.play('a', true);
				poo1.alpha = 0.01;
				remove(poo1);

				preloaded = true;
			}
			FlxG.sound.playMusic(Paths.inst(songLowercase), 0, false);
			// LOL
		}
		else
			preloaded = true;

		if (PlayStateChangeables.nocheese)
		{
			cooltext = SONG.song;
		}
		else
		{
			cooltext = '???';
		}

		SONG.noteStyle = ChartingState.defaultnoteStyle;

		blackFuck = new FlxSprite().makeGraphic(1280, 720, FlxColor.BLACK);

		startCircle = new FlxSprite();
		startText = new FlxSprite();

		spinArray = [
			272, 276, 336, 340, 400, 404, 464, 468, 528, 532, 592, 596, 656, 660, 720, 724, 784, 788, 848, 852, 912, 916, 976, 980, 1040, 1044, 1104, 1108,
			1424, 1428, 1488, 1492, 1552, 1556, 1616, 1620
		];

		FlxG.mouse.visible = false;
		instance = this;

		if (FlxG.save.data.fpsCap > 290)
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(800);

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		sicks = 0;
		bads = 0;
		shits = 0;
		goods = 0;

		misses = 0;

		highestCombo = 0;
		repPresses = 0;
		repReleases = 0;
		inResults = false;

		PlayStateChangeables.useDownscroll = FlxG.save.data.downscroll;
		PlayStateChangeables.safeFrames = FlxG.save.data.frames;
		PlayStateChangeables.scrollSpeed = FlxG.save.data.scrollSpeed;
		PlayStateChangeables.botPlay = FlxG.save.data.botplay;
		PlayStateChangeables.Optimize = FlxG.save.data.optimize;
		PlayStateChangeables.zoom = FlxG.save.data.zoom;

		// pre lowercasing the song name (create)
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();

		removedVideo = false;

		#if cpp
		executeModchart = FileSystem.exists(Paths.lua(songLowercase + "/modchart"));
		if (isSM)
			executeModchart = FileSystem.exists(pathToSm + "/modchart.lua");
		if (executeModchart)
			PlayStateChangeables.Optimize = false;
		#end
		#if !cpp
		executeModchart = false; // FORCE disable for non cpp targets
		#end

		trace('Mod chart: ' + executeModchart + " - " + Paths.lua(songLowercase + "/modchart"));

		#if windows
		// Making difficulty text for Discord Rich Presence.
		storyDifficultyText = CoolUtil.difficultyFromInt(storyDifficulty);

		iconRPC = SONG.player2;

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: Week " + storyWeek;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;

		curStage = "";

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camHUD2 = new FlxCamera();
		camHUD2.bgColor.alpha = 0;
		camSustains = new FlxCamera();
		camSustains.bgColor.alpha = 0;
		camNotes = new FlxCamera();
		camNotes.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camSustains);
		FlxG.cameras.add(camNotes);
		FlxG.cameras.add(camHUD2);

		camHUD.zoom = PlayStateChangeables.zoom;

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial', 'tutorial');

		var curDifficulty = '';

		switch (storyDifficulty)
		{
			case 1:
				curDifficulty = '-easy';
			case 3:
				curDifficulty = '-hard';
		}

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		if (SONG.eventObjects == null)
		{
			SONG.eventObjects = [new Song.Event("Init BPM", 0, SONG.bpm, "BPM Change")];
		}

		TimingStruct.clearTimings();

		var convertedStuff:Array<Song.Event> = [];

		var currentIndex = 0;
		for (i in SONG.eventObjects)
		{
			var name = Reflect.field(i, "name");
			var type = Reflect.field(i, "type");
			var pos = Reflect.field(i, "position");
			var value = Reflect.field(i, "value");

			if (i.type == "BPM Change")
			{
				var beat:Float = i.position;

				var endBeat:Float = Math.POSITIVE_INFINITY;

				TimingStruct.addTiming(beat, i.value, endBeat, 0); // offset in this case = start time since we don't have a offset

				if (currentIndex != 0)
				{
					var data = TimingStruct.AllTimings[currentIndex - 1];
					data.endBeat = beat;
					data.length = (data.endBeat - data.startBeat) / (data.bpm / 60);
					TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length;
				}

				currentIndex++;
			}
			convertedStuff.push(new Song.Event(name, pos, value, type));
		}

		SONG.eventObjects = convertedStuff;

		trace('INFORMATION ABOUT WHAT U PLAYIN WIT:\nFRAMES: ' + PlayStateChangeables.safeFrames + '\nZONE: ' + Conductor.safeZoneOffset + '\nTS: '
			+ Conductor.timeScale + '\nBotPlay : ' + PlayStateChangeables.botPlay);

		// defaults if no stage was found in chart
		var stageCheck:String = 'stage';

		if (SONG.stage == null)
		{
			// TODO
		}
		else
		{
			stageCheck = SONG.stage;
		}

		if (!PlayStateChangeables.Optimize)
		{
			switch (stageCheck)
			{
				// SONG 1 STAGE
				case 'sonicStage':
					{
						defaultCamZoom = 1.0;
						curStage = 'SONICstage';

						var sSKY:FlxSprite = new FlxSprite(-222, -64 + 150).loadGraphic(Paths.image('PolishedP1/SKY'));
						sSKY.antialiasing = FlxG.save.data.antialiasing;
						sSKY.scrollFactor.set(1, 1);
						sSKY.active = false;
						add(sSKY);

						var hills:FlxSprite = new FlxSprite(-264, -156 + 150).loadGraphic(Paths.image('PolishedP1/HILLS'));
						hills.antialiasing = FlxG.save.data.antialiasing;
						hills.scrollFactor.set(1.1, 1);
						hills.active = false;
						if (!lowQuality)
							add(hills);

						var bg2:FlxSprite = new FlxSprite(-345, -289 + 170).loadGraphic(Paths.image('PolishedP1/trees'));
						bg2.updateHitbox();
						bg2.antialiasing = FlxG.save.data.antialiasing;
						bg2.scrollFactor.set(1.2, 1);
						bg2.active = false;
						if (!lowQuality)
							add(bg2);

						var bg:FlxSprite = new FlxSprite(-297, -246 + 150).loadGraphic(Paths.image('PolishedP1/FLOOR1'));
						bg.antialiasing = FlxG.save.data.antialiasing;
						bg.scrollFactor.set(1.3, 1);
						bg.active = false;
						add(bg);

						var eggman:FlxSprite = new FlxSprite(-218, -219 + 150).loadGraphic(Paths.image('PolishedP1/mikoTree'));
						eggman.updateHitbox();
						eggman.antialiasing = FlxG.save.data.antialiasing;
						eggman.scrollFactor.set(1.32, 1);
						eggman.active = false;

						add(eggman);

						var tail:FlxSprite = new FlxSprite(-199 - 150, -259 + 150).loadGraphic(Paths.image('PolishedP1/TAIL'));
						tail.updateHitbox();
						tail.antialiasing = FlxG.save.data.antialiasing;
						tail.scrollFactor.set(1.34, 1);
						tail.active = false;

						add(tail);

						var knuckle:FlxSprite = new FlxSprite(185 + 100, -350 + 150).loadGraphic(Paths.image('PolishedP1/matsuri'));
						knuckle.updateHitbox();
						knuckle.antialiasing = FlxG.save.data.antialiasing;
						knuckle.scrollFactor.set(1.36, 1);
						knuckle.active = false;

						add(knuckle);

						var sticklol:FlxSprite = new FlxSprite(-100, 50);
						sticklol.frames = Paths.getSparrowAtlas('PolishedP1/TailsSpikeAnimated');
						sticklol.animation.addByPrefix('a', 'Tails Spike Animated', 4, true);
						sticklol.setGraphicSize(Std.int(sticklol.width * 1.2));
						sticklol.updateHitbox();
						sticklol.antialiasing = FlxG.save.data.antialiasing;
						sticklol.scrollFactor.set(1.37, 1);

						add(sticklol);

						if (!lowQuality)
							sticklol.animation.play('a', true);
					}
				case 'LordXStage': // epic
					{
						defaultCamZoom = 0.8;
						curStage = 'LordXStage';

						var sky:FlxSprite = new FlxSprite(-1900, -1006).loadGraphic(Paths.image('LordXStage/sky'));
						sky.setGraphicSize(Std.int(sky.width * .5));
						sky.antialiasing = FlxG.save.data.antialiasing;
						sky.scrollFactor.set(1, 1);
						sky.active = false;
						add(sky);

						var hills1:FlxSprite = new FlxSprite(-1440, -806 + 200).loadGraphic(Paths.image('LordXStage/hills1'));
						hills1.setGraphicSize(Std.int(hills1.width * .5));
						hills1.scale.x = 0.6;
						hills1.antialiasing = FlxG.save.data.antialiasing;
						hills1.scrollFactor.set(1.1, 1);
						hills1.active = false;
						add(hills1);

						var floor:FlxSprite = new FlxSprite(-1400, -496).loadGraphic(Paths.image('LordXStage/floor'));
						floor.setGraphicSize(Std.int(floor.width * .5));
						floor.antialiasing = FlxG.save.data.antialiasing;
						floor.scrollFactor.set(1.5, 1);
						floor.scale.x = 1;
						floor.active = false;
						add(floor);

						eyeflower = new FlxSprite(100 - 500, 100);
						eyeflower.frames = Paths.getSparrowAtlas('LordXStage/WeirdAssFlower_Assets', 'exe');
						eyeflower.animation.addByPrefix('animatedeye', 'flower', 30, true);
						eyeflower.setGraphicSize(Std.int(eyeflower.width * 0.8));
						eyeflower.antialiasing = FlxG.save.data.antialiasing;
						eyeflower.scrollFactor.set(1.5, 1);
						add(eyeflower);

						hands = new FlxSprite(100 - 300, -400 + 25);
						hands.frames = Paths.getSparrowAtlas('LordXStage/NotKnuckles_Assets', 'exe');
						hands.animation.addByPrefix('handss', 'Notknuckles', 30, true);
						hands.setGraphicSize(Std.int(hands.width * .5));
						hands.antialiasing = FlxG.save.data.antialiasing;
						hands.scrollFactor.set(1.5, 1);
						add(hands);

						var smallflower:FlxSprite = new FlxSprite(-1500, -506).loadGraphic(Paths.image('LordXStage/smallflower'));
						smallflower.setGraphicSize(Std.int(smallflower.width * .6));
						smallflower.antialiasing = FlxG.save.data.antialiasing;
						smallflower.scrollFactor.set(1.5, 1);
						smallflower.active = false;
						add(smallflower);

						var bFsmallflower:FlxSprite = new FlxSprite(-1500 + 300, -506 - 50).loadGraphic(Paths.image('LordXStage/smallflower'));
						bFsmallflower.setGraphicSize(Std.int(bFsmallflower.width * .6));
						bFsmallflower.antialiasing = FlxG.save.data.antialiasing;
						bFsmallflower.scrollFactor.set(1.5, 1);
						bFsmallflower.active = false;
						bFsmallflower.flipX = true;
						add(bFsmallflower);

						var smallflowe2:FlxSprite = new FlxSprite(-1500, -506).loadGraphic(Paths.image('LordXStage/smallflowe2'));
						smallflowe2.setGraphicSize(Std.int(smallflower.width * .6));
						smallflowe2.antialiasing = FlxG.save.data.antialiasing;
						smallflowe2.scrollFactor.set(1.5, 1);
						smallflowe2.active = false;
						add(smallflowe2);

						var tree:FlxSprite = new FlxSprite(-1900 + 650 - 100, -1006 + 350).loadGraphic(Paths.image('LordXStage/tree'));
						tree.setGraphicSize(Std.int(tree.width * .7));
						tree.antialiasing = FlxG.save.data.antialiasing;
						tree.scrollFactor.set(1.5, 1);
						tree.active = false;
						add(tree);

						if (FlxG.save.data.distractions && !lowQuality)
						{ // My brain is constantly expanding
							hands.animation.play('handss', true);
							eyeflower.animation.play('animatedeye', true);
						}
					}
				// SECRET SONG STAGE!!! Real B)

				case 'sonicfunStage':
					{
						defaultCamZoom = 0.9;
						curStage = 'sonicFUNSTAGE';

						var funsky:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('FunInfiniteStage/sonicFUNsky'));
						funsky.setGraphicSize(Std.int(funsky.width * 0.9));
						funsky.antialiasing = FlxG.save.data.antialiasing;
						funsky.scrollFactor.set(0.3, 0.3);
						funsky.active = false;
						add(funsky);

						var funbush:FlxSprite = new FlxSprite(-42, 171).loadGraphic(Paths.image('FunInfiniteStage/Bush2'));
						funbush.antialiasing = FlxG.save.data.antialiasing;
						funbush.scrollFactor.set(0.3, 0.3);
						funbush.active = false;
						add(funbush);

						funpillarts2ANIM = new FlxSprite(182, -100); // Zekuta why...
						funpillarts2ANIM.frames = Paths.getSparrowAtlas('FunInfiniteStage/Majin Boppers Back', 'exe');
						funpillarts2ANIM.animation.addByPrefix('bumpypillar', 'MajinBop2', 24);
						// funpillarts2ANIM.setGraphicSize(Std.int(funpillarts2ANIM.width * 0.7));
						funpillarts2ANIM.antialiasing = FlxG.save.data.antialiasing;
						funpillarts2ANIM.scrollFactor.set(0.6, 0.6);
						add(funpillarts2ANIM);

						var funbush2:FlxSprite = new FlxSprite(132, 354).loadGraphic(Paths.image('FunInfiniteStage/Bush 1'));
						funbush2.antialiasing = FlxG.save.data.antialiasing;
						funbush2.scrollFactor.set(0.3, 0.3);
						funbush2.active = false;
						add(funbush2);

						funpillarts1ANIM = new FlxSprite(-169, -167);
						funpillarts1ANIM.frames = Paths.getSparrowAtlas('FunInfiniteStage/Majin Boppers Front', 'exe');
						funpillarts1ANIM.animation.addByPrefix('bumpypillar', 'MajinBop1', 24);
						// funpillarts1ANIM.setGraphicSize(Std.int(funpillarts1ANIM.width * 0.7));
						funpillarts1ANIM.antialiasing = FlxG.save.data.antialiasing;
						funpillarts1ANIM.scrollFactor.set(0.6, 0.6);
						add(funpillarts1ANIM);

						var funfloor:FlxSprite = new FlxSprite(-340, 660).loadGraphic(Paths.image('FunInfiniteStage/floor BG'));
						funfloor.antialiasing = FlxG.save.data.antialiasing;
						funfloor.scrollFactor.set(0.5, 0.5);
						funfloor.active = false;
						add(funfloor);

						funboppers1ANIM = new FlxSprite(1126, 903);
						funboppers1ANIM.frames = Paths.getSparrowAtlas('FunInfiniteStage/majin FG1', 'exe');
						funboppers1ANIM.animation.addByPrefix('bumpypillar', 'majin front bopper1', 24);
						funboppers1ANIM.antialiasing = FlxG.save.data.antialiasing;
						funboppers1ANIM.scrollFactor.set(0.8, 0.8);

						funboppers2ANIM = new FlxSprite(-293, 871);
						funboppers2ANIM.frames = Paths.getSparrowAtlas('FunInfiniteStage/majin FG2', 'exe');
						funboppers2ANIM.animation.addByPrefix('bumpypillar', 'majin front bopper2', 24);
						funboppers2ANIM.antialiasing = FlxG.save.data.antialiasing;
						funboppers2ANIM.scrollFactor.set(0.8, 0.8);
					}

				case 'sunkStage':
					{
						defaultCamZoom = 0.9;
						curStage = 'sunkStage';

						var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('SunkBG', 'exe'));
						bg.setGraphicSize(Std.int(bg.width * 0.8));
						bg.antialiasing = FlxG.save.data.antialiasing;
						bg.scrollFactor.set(.91, .91);
						bg.x -= 670;
						bg.y -= 260;
						bg.active = false;
						add(bg);
					}
				case 'TDStage':
					{
						defaultCamZoom = 0.9;
						curStage = 'TDStage';

						bgspec = new FlxSprite().loadGraphic(Paths.image('TailsBG', 'exe'));
						bgspec.setGraphicSize(Std.int(bgspec.width * 1.2));
						bgspec.antialiasing = FlxG.save.data.antialiasing;
						bgspec.scrollFactor.set(.91, .91);
						bgspec.x -= 370;
						bgspec.y -= 130;
						bgspec.active = false;
						add(bgspec);
					}

				case 'sanicStage':
					{
						defaultCamZoom = 0.9;
						curStage = 'sanicStage';

						var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('sanicbg', 'exe'));
						bg.setGraphicSize(Std.int(bg.width * 1.2));
						bg.antialiasing = FlxG.save.data.antialiasing;
						bg.scrollFactor.set(.91, .91);
						bg.x -= 370;
						bg.y -= 130;
						bg.active = false;
						add(bg);
					}

				case 'sonicexeStage': // i fixed the bgs and shit!!! - razencro part 1
					{
						defaultCamZoom = .9;
						curStage = 'SONICexestage';

						var sSKY:FlxSprite = new FlxSprite(-414, -440.8).loadGraphic(Paths.image('SonicP2/sky'));
						sSKY.antialiasing = FlxG.save.data.antialiasing;
						sSKY.scrollFactor.set(1, 1);
						sSKY.active = false;
						sSKY.scale.x = 1.4;
						sSKY.scale.y = 1.4;
						add(sSKY);

						var trees:FlxSprite = new FlxSprite(-290.55, -298.3).loadGraphic(Paths.image('SonicP2/backtrees'));
						trees.antialiasing = FlxG.save.data.antialiasing;
						trees.scrollFactor.set(1.1, 1);
						trees.active = false;
						trees.scale.x = 1.2;
						trees.scale.y = 1.2;
						add(trees);

						var bg2:FlxSprite = new FlxSprite(-306, -334.65).loadGraphic(Paths.image('SonicP2/trees'));
						bg2.updateHitbox();
						bg2.antialiasing = FlxG.save.data.antialiasing;
						bg2.scrollFactor.set(1.2, 1);
						bg2.active = false;
						bg2.scale.x = 1.2;
						bg2.scale.y = 1.2;
						add(bg2);

						var bg:FlxSprite = new FlxSprite(-309.95, -240.2).loadGraphic(Paths.image('SonicP2/ground'));
						bg.antialiasing = FlxG.save.data.antialiasing;
						bg.scrollFactor.set(1.3, 1);
						bg.active = false;
						bg.scale.x = 1.2;
						bg.scale.y = 1.2;
						add(bg);

						bgspec = new FlxSprite(-428.5 + 50 + 700, -449.35 + 25 + 392 + 105 + 50).loadGraphic(Paths.image("SonicP2/GreenHill"));
						bgspec.antialiasing = false;
						bgspec.scrollFactor.set(1, 1);
						bgspec.active = false;
						bgspec.visible = false;
						bgspec.scale.x = 8;
						bgspec.scale.y = 8;
						add(bgspec);
					}
				case 'trioStage': // i fixed the bgs and shit!!! - razencro part 1
					{
						defaultCamZoom = .9;
						curStage = 'TrioStage';

						var sSKY:FlxSprite = new FlxSprite(-621.1, -395.65).loadGraphic(Paths.image('Phase3/Glitch'));
						sSKY.antialiasing = FlxG.save.data.antialiasing;
						sSKY.scrollFactor.set(0.9, 1);
						sSKY.active = false;
						sSKY.scale.x = 1.2;
						sSKY.scale.y = 1.2;
						add(sSKY);

						p3staticbg = new FlxSprite(0, 0);
						p3staticbg.frames = Paths.getSparrowAtlas('NewTitleMenuBG', 'exe');
						p3staticbg.animation.addByPrefix('P3Static', 'TitleMenuSSBG', 24, true);
						p3staticbg.animation.play('P3Static');
						p3staticbg.screenCenter();
						p3staticbg.scale.x = 4.5;
						p3staticbg.scale.y = 4.5;
						p3staticbg.visible = false;
						add(p3staticbg);

						var trees:FlxSprite = new FlxSprite(-607.35, -401.55).loadGraphic(Paths.image('Phase3/Trees'));
						trees.antialiasing = FlxG.save.data.antialiasing;
						trees.scrollFactor.set(0.95, 1);
						trees.active = false;
						trees.scale.x = 1.2;
						trees.scale.y = 1.2;
						add(trees);

						var bg2:FlxSprite = new FlxSprite(-623.5, -410.4).loadGraphic(Paths.image('Phase3/Trees2'));
						bg2.updateHitbox();
						bg2.antialiasing = FlxG.save.data.antialiasing;
						bg2.scrollFactor.set(1, 1);
						bg2.active = false;
						bg2.scale.x = 1.2;
						bg2.scale.y = 1.2;
						add(bg2);

						var bg:FlxSprite = new FlxSprite(-630.4, -266).loadGraphic(Paths.image('Phase3/Grass'));
						bg.antialiasing = FlxG.save.data.antialiasing;
						bg.scrollFactor.set(1.1, 1);
						bg.active = false;
						bg.scale.x = 1.2;
						bg.scale.y = 1.2;
						add(bg);

						bgspec = new FlxSprite(-428.5 + 50, -449.35 + 25).makeGraphic(2199, 1203, FlxColor.BLACK);
						bgspec.antialiasing = FlxG.save.data.antialiasing;
						bgspec.scrollFactor.set(1, 1);
						bgspec.active = false;
						bgspec.visible = false;

						bgspec.scale.x = 1.2;
						bgspec.scale.y = 1.2;
						add(bgspec);
					}
				case 'fakerStage': // i fixed the bgs and shit!!! - razencro part 1
					{
						defaultCamZoom = .95;
						curStage = 'FAKERSTAGE';

						var sky:FlxSprite = new FlxSprite(-631.8, -493.15).loadGraphic(Paths.image('fakerBG/sky'));
						sky.antialiasing = FlxG.save.data.antialiasing;
						sky.scrollFactor.set(1, 1);
						sky.active = false;
						sky.scale.x = .9;
						sky.scale.y = .9;
						add(sky);

						var mountains:FlxSprite = new FlxSprite(-631.8, -475.5).loadGraphic(Paths.image('fakerBG/mountains'));
						mountains.antialiasing = FlxG.save.data.antialiasing;
						mountains.scrollFactor.set(1.1, 1);
						mountains.active = false;
						mountains.scale.x = .9;
						mountains.scale.y = .9;
						add(mountains);

						var grass:FlxSprite = new FlxSprite(-631.8, -475.5).loadGraphic(Paths.image('fakerBG/grass'));
						grass.antialiasing = FlxG.save.data.antialiasing;
						grass.scrollFactor.set(1.2, 1);
						grass.active = false;
						grass.scale.x = .9;
						grass.scale.y = .9;
						add(grass);

						var tree2:FlxSprite = new FlxSprite(-631.8, -475.5).loadGraphic(Paths.image('fakerBG/tree2'));
						tree2.antialiasing = FlxG.save.data.antialiasing;
						tree2.scrollFactor.set(1.225, 1);
						tree2.active = false;
						tree2.scale.x = .9;
						tree2.scale.y = .9;
						add(tree2);

						var pillar2:FlxSprite = new FlxSprite(-631.8, -459.55).loadGraphic(Paths.image('fakerBG/pillar2'));
						pillar2.antialiasing = FlxG.save.data.antialiasing;
						pillar2.scrollFactor.set(1.25, 1);
						pillar2.active = false;
						pillar2.scale.x = .9;
						pillar2.scale.y = .9;
						add(pillar2);

						var plant:FlxSprite = new FlxSprite(-631.8, -493.15).loadGraphic(Paths.image('fakerBG/plant'));
						plant.antialiasing = FlxG.save.data.antialiasing;
						plant.scrollFactor.set(1.25, 1);
						plant.active = false;
						plant.scale.x = .9;
						plant.scale.y = .9;
						add(plant);

						var tree1:FlxSprite = new FlxSprite(-631.8, -493.15).loadGraphic(Paths.image('fakerBG/tree1'));
						tree1.antialiasing = FlxG.save.data.antialiasing;
						tree1.scrollFactor.set(1.25, 1);
						tree1.active = false;
						tree1.scale.x = .9;
						tree1.scale.y = .9;
						add(tree1);

						var pillar1:FlxSprite = new FlxSprite(-631.8, -493.15).loadGraphic(Paths.image('fakerBG/pillar1'));
						pillar1.antialiasing = FlxG.save.data.antialiasing;
						pillar1.scrollFactor.set(1.25, 1);
						pillar1.active = false;
						pillar1.scale.x = .9;
						pillar1.scale.y = .9;
						add(pillar1);

						var flower1:FlxSprite = new FlxSprite(-631.8, -493.15).loadGraphic(Paths.image('fakerBG/flower1'));
						flower1.antialiasing = FlxG.save.data.antialiasing;
						flower1.scrollFactor.set(1.25, 1);
						flower1.active = false;
						flower1.scale.x = .9;
						flower1.scale.y = .9;
						add(flower1);

						var flower2:FlxSprite = new FlxSprite(-631.8, -493.15).loadGraphic(Paths.image('fakerBG/flower2'));
						flower2.antialiasing = FlxG.save.data.antialiasing;
						flower2.scrollFactor.set(1.25, 1);
						flower2.active = false;
						flower2.scale.x = .9;
						flower2.scale.y = .9;
						add(flower2);
					}

				case 'exeStage': // if this doesn't work i swear i will beat krillin to death /j
					{
						curStage = 'EXEStage';
						defaultCamZoom = 0.9;

						var sSKY:FlxSprite = new FlxSprite(-414, -240.8).loadGraphic(Paths.image('exeBg/sky'));
						sSKY.antialiasing = FlxG.save.data.antialiasing;
						sSKY.scrollFactor.set(1, 1);
						sSKY.active = false;
						sSKY.scale.x = 1.2;
						sSKY.scale.y = 1.2;
						add(sSKY);

						var trees:FlxSprite = new FlxSprite(-290.55, -298.3).loadGraphic(Paths.image('exeBg/backtrees'));
						trees.antialiasing = FlxG.save.data.antialiasing;
						trees.scrollFactor.set(1.1, 1);
						trees.active = false;
						trees.scale.x = 1.2;
						trees.scale.y = 1.2;
						add(trees);

						var bg2:FlxSprite = new FlxSprite(-306, -334.65).loadGraphic(Paths.image('exeBg/trees'));
						bg2.updateHitbox();
						bg2.antialiasing = FlxG.save.data.antialiasing;
						bg2.scrollFactor.set(1.2, 1);
						bg2.active = false;
						bg2.scale.x = 1.2;
						bg2.scale.y = 1.2;
						add(bg2);

						var bg:FlxSprite = new FlxSprite(-309.95, -240.2).loadGraphic(Paths.image('exeBg/ground'));
						bg.antialiasing = FlxG.save.data.antialiasing;
						bg.scrollFactor.set(1.3, 1);
						bg.active = false;
						bg.scale.x = 1.2;
						bg.scale.y = 1.2;
						add(bg);

						var treething:FlxSprite = new FlxSprite(-409.95, -340.2);
						treething.frames = Paths.getSparrowAtlas('exeBg/ExeAnimatedBG_Assets');
						treething.animation.addByPrefix('a', 'ExeBGAnim', 24, true);
						treething.antialiasing = FlxG.save.data.antialiasing;
						treething.scrollFactor.set(1, 1);
						add(treething);

						var tails:FlxSprite = new FlxSprite(700, 500).loadGraphic(Paths.image('exeBg/TailsCorpse'));
						tails.antialiasing = FlxG.save.data.antialiasing;
						tails.scrollFactor.set(1, 1);
						add(tails);

						if (FlxG.save.data.distractions)
						{
							treething.animation.play('a', true);
						}
					}
				case 'chamber': // fleetway my beloved
					{
						defaultCamZoom = .7;
						curStage = 'chamber';

						wall = new FlxSprite(-2379.05, -1211.1);
						wall.frames = Paths.getSparrowAtlas('Chamber/Wall');
						wall.animation.addByPrefix('a', 'Wall instance 1');
						wall.animation.play('a');
						wall.antialiasing = FlxG.save.data.antialiasing;
						wall.scrollFactor.set(1.1, 1.1);
						add(wall);

						floor = new FlxSprite(-2349, 921.25);
						floor.antialiasing = FlxG.save.data.antialiasing;
						add(floor);
						floor.frames = Paths.getSparrowAtlas('Chamber/Floor');
						floor.animation.addByPrefix('a', 'floor blue');
						floor.animation.addByPrefix('b', 'floor yellow');
						floor.animation.play('b', true);
						floor.animation.play('a', true); // whenever song starts make sure this is playing
						floor.scrollFactor.set(1.1, 1);
						floor.antialiasing = FlxG.save.data.antialiasing;

						fleetwaybgshit = new FlxSprite(-2629.05, -1344.05);
						add(fleetwaybgshit);
						fleetwaybgshit.frames = Paths.getSparrowAtlas('Chamber/FleetwayBGshit');
						fleetwaybgshit.animation.addByPrefix('a', 'BGblue');
						fleetwaybgshit.animation.addByPrefix('b', 'BGyellow');
						fleetwaybgshit.animation.play('b', true);
						fleetwaybgshit.animation.play('a', true);
						fleetwaybgshit.antialiasing = FlxG.save.data.antialiasing;
						fleetwaybgshit.scrollFactor.set(1.1, 1);

						emeraldbeam = new FlxSprite(0, -1376.95 - 200);
						emeraldbeam.antialiasing = FlxG.save.data.antialiasing;
						emeraldbeam.frames = Paths.getSparrowAtlas('Chamber/Emerald Beam');
						emeraldbeam.animation.addByPrefix('a', 'Emerald Beam', 24, true);
						emeraldbeam.animation.play('a');
						emeraldbeam.scrollFactor.set(1.1, 1);
						emeraldbeam.visible = true; // this starts true, then when sonic falls in and screen goes white, this turns into flase
						add(emeraldbeam);

						emeraldbeamyellow = new FlxSprite(-300, -1376.95 - 200);
						emeraldbeamyellow.antialiasing = FlxG.save.data.antialiasing;
						emeraldbeamyellow.frames = Paths.getSparrowAtlas('Chamber/Emerald Beam Charged');
						emeraldbeamyellow.animation.addByPrefix('a', 'Emerald Beam Charged', 24, true);
						emeraldbeamyellow.animation.play('a');
						emeraldbeamyellow.scrollFactor.set(1.1, 1);
						emeraldbeamyellow.visible = false; // this starts off on false and whenever emeraldbeam dissapears, this turns true so its visible once song starts
						add(emeraldbeamyellow);

						var emeralds:FlxSprite = new FlxSprite(326.6, -191.75);
						emeralds.antialiasing = FlxG.save.data.antialiasing;
						emeralds.frames = Paths.getSparrowAtlas('Chamber/Emeralds', 'exe');
						emeralds.animation.addByPrefix('a', 'TheEmeralds', 24, true);
						emeralds.animation.play('a');
						emeralds.scrollFactor.set(1.1, 1);
						emeralds.antialiasing = FlxG.save.data.antialiasing;
						add(emeralds);

						thechamber = new FlxSprite(-225.05, 463.9);
						thechamber.frames = Paths.getSparrowAtlas('Chamber/The Chamber');
						thechamber.animation.addByPrefix('a', 'Chamber Sonic Fall', 24, false);
						thechamber.scrollFactor.set(1.1, 1);
						thechamber.antialiasing = FlxG.save.data.antialiasing;

						pebles = new FlxSprite(-562.15 + 100, 1043.3);
						add(pebles);
						pebles.frames = Paths.getSparrowAtlas('Chamber/pebles');
						pebles.animation.addByPrefix('a', 'pebles instance 1');
						pebles.animation.addByPrefix('b', 'pebles instance 2');
						pebles.animation.play('b', true);
						pebles.animation.play('a',
							true); // during cutscene this is gonna play first and then whenever the yellow beam appears, make it play "a"
						pebles.scrollFactor.set(1.1, 1);
						pebles.antialiasing = FlxG.save.data.antialiasing;

						porker = new FlxSprite(2880.15, -762.8);
						porker.frames = Paths.getSparrowAtlas('Chamber/Porker Lewis');
						porker.animation.addByPrefix('porkerbop', 'Porker FG');

						porker.scrollFactor.set(1.4, 1);
						porker.antialiasing = FlxG.save.data.antialiasing;
					}
				case 'stage':
					{
						defaultCamZoom = 0.9;
						curStage = 'stage';
						var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
						bg.antialiasing = FlxG.save.data.antialiasing;
						bg.scrollFactor.set(0.9, 0.9);
						bg.active = false;
						add(bg);

						var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
						stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
						stageFront.updateHitbox();
						stageFront.antialiasing = FlxG.save.data.antialiasing;
						stageFront.scrollFactor.set(0.9, 0.9);
						stageFront.active = false;
						add(stageFront);

						var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
						stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
						stageCurtains.updateHitbox();
						stageCurtains.antialiasing = FlxG.save.data.antialiasing;
						stageCurtains.scrollFactor.set(1.3, 1.3);
						stageCurtains.active = false;

						add(stageCurtains);
					}
				default:
					{
						defaultCamZoom = 0.9;
						curStage = 'stage';
						var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
						bg.antialiasing = FlxG.save.data.antialiasing;
						bg.scrollFactor.set(0.9, 0.9);
						bg.active = false;
						add(bg);

						var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
						stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
						stageFront.updateHitbox();
						stageFront.antialiasing = FlxG.save.data.antialiasing;
						stageFront.scrollFactor.set(0.9, 0.9);
						stageFront.active = false;
						add(stageFront);

						var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
						stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
						stageCurtains.updateHitbox();
						stageCurtains.antialiasing = FlxG.save.data.antialiasing;
						stageCurtains.scrollFactor.set(1.3, 1.3);
						stageCurtains.active = false;

						add(stageCurtains);
					}
			}
		}
		// defaults if no gf was found in chart
		var gfCheck:String = 'gf';

		if (SONG.gfVersion == null)
		{
			switch (storyWeek)
			{
				case 6:
					gfCheck = 'gf-pixel';
			}
		}
		else
		{
			gfCheck = SONG.gfVersion;
		}

		var curGf:String = '';
		switch (gfCheck)
		{
			case 'gf-pixel':
				curGf = 'gf-pixel';
			case 'gf-exe':
				curGf = 'gf-exe';
			default:
				curGf = 'gf';
		}

		gf = new Character(400, 130, curGf);
		if (curStage == 'SONICstage' || curStage == 'SONICexestage') // i fixed the bgs and shit!!! - razencro part 2
		{
			gf.scrollFactor.set(1.37, 1);
		}
		else if (curStage == 'FAKERSTAGE')
		{
			gf.scrollFactor.set(1.24, 1);
		}
		else
		{
			gf.scrollFactor.set(0.95, 0.95);
		}

		dad = new Character(100, 100, SONG.player2);

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}
			case 'suisei':
				dad.x -= 130;
				dad.y += -50;
			case 'coco':
				dad.setGraphicSize(Std.int(dad.width * 0.2));
				dad.x -= 1840;
				dad.y += 80;
				dad.y -= 1500;
			case 'tails':
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'sonic.exe alt':
				camPos.set(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);
			case 'mio':
				dad.x -= 200;
				dad.y -= 150;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
		}

		boyfriend = new Boyfriend(770, 450, SONG.player1);

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'SONICstage':
				boyfriend.y += 25;
				dad.y += 200;
				dad.x += 200;
				dad.scale.x = 1.1;
				dad.scale.y = 1.1;
				dad.scrollFactor.set(1.37, 1);
				boyfriend.scrollFactor.set(1.37, 1);
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y - 100);
			case 'FAKERSTAGE':
				gf.x += 200;
				gf.y += 100;
				dad.scrollFactor.set(1.25, 1);
				boyfriend.scrollFactor.set(1.25, 1);
				boyfriend.x = 318.95 + 500;
				boyfriend.y = 494.2 - 150;
				dad.y += 14.3;
				dad.x += 59.85;

				gf.y -= 150;
			case 'SONICexestage': // i fixed the bgs and shit!!! - razencro part 3

				dad.y -= 125;

				boyfriend.x = 1036 - 100;
				boyfriend.y = 300;

				dad.scrollFactor.set(1.37, 1);
				boyfriend.scrollFactor.set(1.37, 1);

				gf.x = 635.5 - 50 - 100;
				gf.y = 265.1 - 250;

				camPos.set(boyfriend.getGraphicMidpoint().x, boyfriend.getGraphicMidpoint().y);

			case 'sonicFUNSTAGE':
				boyfriend.y += 334;
				boyfriend.x += 80;
				dad.y += 470;
				gf.y += 300;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y - 200);

			case 'LordXStage':
				dad.y += 190 - 50;
				dad.x = -113 - 50;
				boyfriend.y += 150 - 25;
				boyfriend.x += 50;
				boyfriend.scale.x = 1.2;
				boyfriend.scale.y = 1.2;
				dad.scrollFactor.set(1.53, 1);
				boyfriend.scrollFactor.set(1.53, 1);
				camPos.set(dad.getGraphicMidpoint().x + 200, dad.getGraphicMidpoint().y);
			case 'sunkStage':
				boyfriend.x -= 100;
				dad.x = -100;
				dad.y = 250;
				dad.scale.x = 1;
				dad.scale.y = 1;
			case 'TDStage':
				dad.y += 230;
				dad.x -= 250;
			case 'sanicStage':
				dad.y -= 560;
				dad.x -= 1000;
			case 'EXEStage':
				boyfriend.x += 300;
				boyfriend.y += 100;
				gf.x += 430;
				gf.y += 170;
			case 'TrioStage':
				dad.scrollFactor.set(1.1, 1);
				boyfriend.scrollFactor.set(1.1, 1);

				boyfriend.x = 466.1;
				boyfriend.y = 373.4;

				dad.x = -43.65;
				dad.y = 274.05 + 24;
				camPos.set(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);
			case 'chamber':
				boyfriend.x = 2040.55;
				boyfriend.y = 685.6;

				dad.x = 61.15;
				dad.y = -94.75;

				dad.scrollFactor.set(1.1, 1);
				boyfriend.scrollFactor.set(1.1, 1);
		}

		if (!PlayStateChangeables.Optimize)
		{
			FlxG.log.add('uhh so the cur stage is ' + curStage);

			if (curStage == 'SONICstage' || curStage == 'SONICexestage' || curStage == 'FAKERSTAGE' || curStage == 'EXEStage')
				add(gf);

			add(dad);
			add(boyfriend);

			switch (curStage) // This for layering lmao
			{
				case 'sonicFUNSTAGE':
					add(funboppers1ANIM);
					add(funboppers2ANIM);
				case 'chamber':
					add(thechamber);
					add(porker);
			}
		}

		if (loadRep)
		{
			FlxG.watch.addQuick('rep rpesses', repPresses);
			FlxG.watch.addQuick('rep releases', repReleases);
			// FlxG.watch.addQuick('Queued',inputsQueued);

			PlayStateChangeables.useDownscroll = rep.replay.isDownscroll;
			PlayStateChangeables.safeFrames = rep.replay.sf;
			PlayStateChangeables.botPlay = true;
		}

		trace('uh ' + PlayStateChangeables.safeFrames);

		trace("SF CALC: " + Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		if (PlayStateChangeables.useDownscroll)
			strumLine.y = FlxG.height - 165;

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		playerSplashes = new FlxTypedGroup<FlxSprite>();
		add(playerSplashes);
		cpuStrums = new FlxTypedGroup<FlxSprite>();

		// startCountdown();

		if (SONG.song == null)
			trace('song is null???');
		else
			trace('song looks gucci');

		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();

		generateSong(songLowercase);

		for (i in unspawnNotes)
		{
			var dunceNote:Note = i;
			notes.add(dunceNote);
			if (executeModchart)
			{
				if (!dunceNote.isSustainNote)
					dunceNote.cameras = [camNotes];
				else
					dunceNote.cameras = [camSustains];
			}
			else
			{
				dunceNote.cameras = [camHUD];
			}
		}

		if (startTime != 0)
		{
			var toBeRemoved = [];
			for (i in 0...notes.members.length)
			{
				var dunceNote:Note = notes.members[i];

				if (dunceNote.strumTime - startTime <= 0)
					toBeRemoved.push(dunceNote);
				else
				{
					if (PlayStateChangeables.useDownscroll)
					{
						if (dunceNote.mustPress)
							dunceNote.y = (playerStrums.members[Math.floor(Math.abs(dunceNote.noteData))].y
								+
								0.45 * (startTime - dunceNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2))
								- dunceNote.noteYOff;
						else
							dunceNote.y = (strumLineNotes.members[Math.floor(Math.abs(dunceNote.noteData))].y
								+
								0.45 * (startTime - dunceNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2))
								- dunceNote.noteYOff;
					}
					else
					{
						if (dunceNote.mustPress)
							dunceNote.y = (playerStrums.members[Math.floor(Math.abs(dunceNote.noteData))].y
								- 0.45 * (startTime - dunceNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2))
								+ dunceNote.noteYOff;
						else
							dunceNote.y = (strumLineNotes.members[Math.floor(Math.abs(dunceNote.noteData))].y
								- 0.45 * (startTime - dunceNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2))
								+ dunceNote.noteYOff;
					}
				}
			}

			for (i in toBeRemoved)
				notes.members.remove(i);
		}

		trace('generated');

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		if (songLowercase == 'too-seiso')
		{
			FlxG.camera.follow(camFollow, LOCKON, 0.05 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
		}
		else if (songLowercase == 'circus')
		{
			FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
		}
		else if (songLowercase == 'ankimo')
		{
			FlxG.camera.follow(camFollow, LOCKON, 0.08 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
		}
		else if (songLowercase == 'asacoco')
		{
			FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
		}
		else if (songLowercase == 'parent')
		{
			fakertransform.setPosition(dad.getGraphicMidpoint().x - 400, dad.getGraphicMidpoint().y - 400);
			FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
		}
		else if (songLowercase == 'koyochaos')
		{
			FlxG.camera.follow(camFollow, LOCKON, 0.06 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
		}
		else if (songLowercase == 'sunshine')
		{
			if (FlxG.save.data.vfx)
			{
				var vcr:VCRDistortionShader;
				vcr = new VCRDistortionShader();

				var daStatic:FlxSprite = new FlxSprite(0, 0);

				daStatic.frames = Paths.getSparrowAtlas('daSTAT');

				daStatic.setGraphicSize(FlxG.width, FlxG.height);

				daStatic.alpha = 0.05;

				daStatic.screenCenter();

				daStatic.cameras = [camHUD];

				daStatic.animation.addByPrefix('static', 'staticFLASH', 24, true);

				add(daStatic);

				daStatic.animation.play('static');

				camGame.setFilters([new ShaderFilter(vcr)]);

				camHUD.setFilters([new ShaderFilter(vcr)]);
			}

			FlxG.camera.follow(camFollow, LOCKON, 0.06 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
		}
		else if (songLowercase  == 'you-cant-kusa')
		{
			FlxG.camera.follow(camFollow, LOCKON, 0.06 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
		}
		else if (songLowercase == 'triple-talent')
		{
			FlxG.camera.follow(camFollow, LOCKON, 0.12 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
		}
		else if (songLowercase == 'white-moon')
		{
			vgblack = new FlxSprite().loadGraphic(Paths.image('black_vignette', 'exe'));
			tentas = new FlxSprite().loadGraphic(Paths.image('tentacles_black', 'exe'));
			tentas.alpha = 0;
			vgblack.alpha = 0;
			vgblack.cameras = [camHUD];
			tentas.cameras = [camHUD];
			add(vgblack);
			add(tentas);
			health = 2;
			FlxG.camera.follow(camFollow, LOCKON, 0.09 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
		}
		else if (songLowercase == 'too-fest')
		{
			camFollow.y = dad.getMidpoint().y + 700;
			camFollow.x = dad.getMidpoint().x + 700;
			FlxG.camera.follow(camFollow, LOCKON, 0.05 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
		}
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		if (FlxG.save.data.songPosition) // I dont wanna talk about this code :(
		{
			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('healthBar'));
			if (PlayStateChangeables.useDownscroll)
				songPosBG.y = FlxG.height * 0.9 + 45;
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);

			songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, songLength);
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
			add(songPosBar);

			var songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - (SONG.song.length * 5), songPosBG.y, 0, SONG.song, 16);
			if (PlayStateChangeables.useDownscroll)
				songName.y -= 3;
			songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songName.scrollFactor.set();
			add(songName);
			songName.cameras = [camHUD];
		}

		notes = new FlxTypedGroup<Note>();
		add(notes);

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		if (PlayStateChangeables.useDownscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		switch (dad.curCharacter)
		{
			case 'TDoll':
				healthBar.createFilledBar(FlxColor.fromRGB(255, 165, 0), FlxColor.fromRGB(49, 176, 209));
			case 'suisei', 'sonic.exe', 'mio', 'coco':
				healthBar.createFilledBar(FlxColor.fromRGB(0, 19, 102), FlxColor.fromRGB(49, 176, 209));
			case 'sonicfun', 'exe', 'sanic':
				healthBar.createFilledBar(FlxColor.fromRGB(60, 0, 138), FlxColor.fromRGB(49, 176, 209)); // FlxColor.fromRGB(60, 0, 138)
			case 'tails':
				healthBar.createFilledBar(FlxColor.fromRGB(108, 108, 108), FlxColor.fromRGB(49, 176, 209));
			case 'fleetway':
				healthBar.createFilledBar(FlxColor.fromRGB(255, 255, 0), FlxColor.fromRGB(49, 176, 209));
			default:
				healthBar.createFilledBar(0xFFFF0000, FlxColor.fromRGB(49, 176, 209));
		}

		// healthBar
		add(healthBar);

		// Add Kade Engine watermark
		kadeEngineWatermark = new FlxText(4, healthBarBG.y
			+ 50, 0,
			SONG.song
			+ " - "
			+ CoolUtil.difficultyFromInt(storyDifficulty)
			+ (Main.watermarks ? " | KE " + MainMenuState.kadeEngineVer : ""), 16);
		kadeEngineWatermark.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		kadeEngineWatermark.scrollFactor.set();
		add(kadeEngineWatermark);

		if (PlayStateChangeables.useDownscroll)
			kadeEngineWatermark.y = FlxG.height * 0.9 + 45;

		scoreTxt = new FlxText(FlxG.width / 2 - 235, healthBarBG.y + 50, 0, "", 20);

		scoreTxt.screenCenter(X);

		originalX = scoreTxt.x;

		scoreTxt.scrollFactor.set();

		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		add(scoreTxt);

		replayTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0, "REPLAY",
			20);
		replayTxt.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		replayTxt.borderSize = 4;
		replayTxt.borderQuality = 2;
		replayTxt.scrollFactor.set();
		if (loadRep)
		{
			add(replayTxt);
		}
		// Literally copy-paste of the above, fu
		botPlayState = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0,
			"BOTPLAY", 20);
		botPlayState.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botPlayState.scrollFactor.set();
		botPlayState.borderSize = 4;
		botPlayState.borderQuality = 2;
		if (PlayStateChangeables.botPlay && !loadRep)
			add(botPlayState);

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		if (isRing)
		{
			if (FlxG.save.data.downscroll)
			{
				ringCounter = new FlxSprite(1133, 30).loadGraphic(Paths.image('Counter', 'exe'));
				add(ringCounter);
				ringCounter.cameras = [camHUD];

				counterNum = new FlxText(1207, 36, 0, '0', 10, false);
				counterNum.setFormat('EurostileTBla', 60, FlxColor.fromRGB(255, 204, 51), FlxTextBorderStyle.OUTLINE, FlxColor.fromRGB(204, 102, 0));
				counterNum.setBorderStyle(OUTLINE, FlxColor.fromRGB(204, 102, 0), 3, 1);
				add(counterNum);
				counterNum.cameras = [camHUD];
			}
			else
			{
				ringCounter = new FlxSprite(1133, 610).loadGraphic(Paths.image('Counter', 'exe'));
				add(ringCounter);
				ringCounter.cameras = [camHUD];

				counterNum = new FlxText(1207, 606, 0, '0', 10, false);
				counterNum.setFormat('EurostileTBla', 60, FlxColor.fromRGB(255, 204, 51), FlxTextBorderStyle.OUTLINE, FlxColor.fromRGB(204, 102, 0));
				counterNum.setBorderStyle(OUTLINE, FlxColor.fromRGB(204, 102, 0), 3, 1);
				add(counterNum);
				counterNum.cameras = [camHUD];
			}
		}

		strumLineNotes.cameras = [camHUD];
		playerSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		doof.cameras = [camHUD];
		if (FlxG.save.data.songPosition)
		{
			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
		}
		kadeEngineWatermark.cameras = [camHUD];
		if (loadRep)
			replayTxt.cameras = [camHUD];
		startCircle.cameras = [camHUD2];
		startText.cameras = [camHUD2];
		blackFuck.cameras = [camHUD2];

		startingSong = true;

		trace('starting');

		switch (StringTools.replace(curSong, " ", "-").toLowerCase())
		{
			case 'too-seiso':
				startSong();
				startCountdown();
				add(blackFuck);
				startCircle.loadGraphic(Paths.image('StartScreens/CircleTooSlow', 'exe'));
				startCircle.x += 777;
				add(startCircle);
				startText.loadGraphic(Paths.image('StartScreens/TextTooSlow', 'exe'));
				startText.x -= 1200;
				add(startText);

				new FlxTimer().start(0.6, function(tmr:FlxTimer)
				{
					FlxTween.tween(startCircle, {x: 0}, 0.5);
					FlxTween.tween(startText, {x: 0}, 0.5);
				});

				new FlxTimer().start(1.9, function(tmr:FlxTimer)
				{
					FlxTween.tween(startCircle, {alpha: 0}, 1);
					FlxTween.tween(startText, {alpha: 0}, 1);
					FlxTween.tween(blackFuck, {alpha: 0}, 1);
				});
			case 'you-cant-kusa':
				startSong();
				startCountdown();
				add(blackFuck);
				startCircle.loadGraphic(Paths.image('StartScreens/CircleYouCantRun', 'exe'));
				startCircle.x += 777;
				add(startCircle);
				startText.loadGraphic(Paths.image('StartScreens/TextYouCantRun', 'exe'));
				startText.x -= 1200;
				add(startText);

				new FlxTimer().start(0.6, function(tmr:FlxTimer)
				{
					FlxTween.tween(startCircle, {x: 0}, 0.5);
					FlxTween.tween(startText, {x: 0}, 0.5);
				});

				new FlxTimer().start(1.9, function(tmr:FlxTimer)
				{
					FlxTween.tween(startCircle, {alpha: 0}, 1);
					FlxTween.tween(startText, {alpha: 0}, 1);
					FlxTween.tween(blackFuck, {alpha: 0}, 1);
				});
			case 'triple-talent':
				startCountdown();
				add(blackFuck);
				startCircle.loadGraphic(Paths.image('StartScreens/CircleTripleTrouble', 'exe'));
				startCircle.x += 777;
				add(startCircle);
				startText.loadGraphic(Paths.image('StartScreens/TextTripleTrouble', 'exe'));
				startText.x -= 1200;
				add(startText);

				new FlxTimer().start(0.6, function(tmr:FlxTimer)
				{
					FlxTween.tween(startCircle, {x: 0}, 0.5);
					FlxTween.tween(startText, {x: 0}, 0.5);
				});

				new FlxTimer().start(1.9, function(tmr:FlxTimer)
				{
					FlxTween.tween(startCircle, {alpha: 0}, 1);
					FlxTween.tween(startText, {alpha: 0}, 1);
					FlxTween.tween(blackFuck, {alpha: 0}, 1);
				});
			case 'circus':
				add(blackFuck);
				startCircle.loadGraphic(Paths.image('StartScreens/CircleMajin', 'exe'));
				startCircle.x += 777;
				add(startCircle);
				startText.loadGraphic(Paths.image('StartScreens/TextMajin', 'exe'));
				startText.x -= 1200;
				add(startText);
				new FlxTimer().start(0.6, function(tmr:FlxTimer)
				{
					FlxTween.tween(startCircle, {x: 0}, 0.5);
					FlxTween.tween(startText, {x: 0}, 0.5);
				});

				new FlxTimer().start(1.9, function(tmr:FlxTimer)
				{
					FlxTween.tween(startCircle, {alpha: 0}, 1);
					FlxTween.tween(startText, {alpha: 0}, 1);
					FlxTween.tween(blackFuck, {alpha: 0}, 1);
				});
				startCountdown();
			case 'ankimo':
				startSong();
				startCountdown();
				add(blackFuck);
				startCircle.loadGraphic(Paths.image('StartScreens/CircleCycles', 'exe'));
				startCircle.x += 777;
				add(startCircle);
				startText.loadGraphic(Paths.image('StartScreens/TextCycles', 'exe'));
				startText.x -= 1200;
				add(startText);
				new FlxTimer().start(0.6, function(tmr:FlxTimer)
				{
					FlxTween.tween(startCircle, {x: 0}, 0.5);
					FlxTween.tween(startText, {x: 0}, 0.5);
				});

				new FlxTimer().start(1.9, function(tmr:FlxTimer)
				{
					FlxTween.tween(startCircle, {alpha: 0}, 1);
					FlxTween.tween(startText, {alpha: 0}, 1);
					FlxTween.tween(blackFuck, {alpha: 0}, 1);
				});
				startCountdown();
			case 'asacoco':
				add(blackFuck);
				startCircle.loadGraphic(Paths.image('StartScreens/Coco', 'exe'));
				startCircle.scale.x = 0;
				startCircle.x += 50;
				add(startCircle);
				new FlxTimer().start(0.6, function(tmr:FlxTimer)
				{
					FlxTween.tween(startCircle.scale, {x: 1}, 0.2, {ease: FlxEase.elasticOut});
					FlxG.sound.play(Paths.sound('flatBONK', 'exe'));
				});

				new FlxTimer().start(1.9, function(tmr:FlxTimer)
				{
					FlxTween.tween(blackFuck, {alpha: 0}, 1);
					FlxTween.tween(startCircle, {alpha: 0}, 1);
				});
				startCountdown();
			case 'sunshine':
				canPause = false;
				bgspec.visible = false;
				kadeEngineWatermark.visible = false;
				healthBarBG.visible = false;
				healthBar.visible = false;
				botPlayState.visible = false;
				iconP1.visible = false;
				iconP2.visible = false;
				scoreTxt.visible = false;
				gf.visible = true;
				boyfriend.alpha = 1;
				bgspec.visible = true;
				kadeEngineWatermark.visible = true;
				botPlayState.visible = true;
				healthBarBG.visible = true;
				healthBar.visible = true;
				iconP1.visible = true;
				iconP2.visible = true;
				scoreTxt.visible = true;
				generateStaticArrows(0, false);
				generateStaticArrows(1, false);
				var startthingy:FlxSprite = new FlxSprite();

				startthingy.frames = Paths.getSparrowAtlas('TdollStart', 'exe');
				startthingy.animation.addByPrefix('sus', 'Start', 24, false);
				startthingy.cameras = [camHUD2];
				add(startthingy);
				startthingy.screenCenter();
				var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image('ready', 'exe'));
				var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image('set', 'exe'));
				var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image('go', 'exe'));

				ready.scale.x = 0.5; // i despise all coding.
				set.scale.x = 0.5;
				go.scale.x = 0.7;
				ready.scale.y = 0.5;
				set.scale.y = 0.5;
				go.scale.y = 0.7;
				ready.screenCenter();
				set.screenCenter();
				go.screenCenter();
				ready.cameras = [camHUD];
				set.cameras = [camHUD];
				go.cameras = [camHUD];
				var amongus:Int = 0;

				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					startthingy.animation.play('sus', true);
				});

				startthingy.animation.finishCallback = function(pog:String)
				{
					new FlxTimer().start(Conductor.crochet / 3000, function(tmr:FlxTimer)
					{
						switch (amongus)
						{
							case 0:
								startCountdown();
								add(ready);
								FlxTween.tween(ready.scale, {x: .9, y: .9}, Conductor.crochet / 500);
								FlxG.sound.play(Paths.sound('ready', 'exe'));
							case 1:
								ready.visible = false;
								add(set);
								FlxTween.tween(set.scale, {x: .9, y: .9}, Conductor.crochet / 500);
								FlxG.sound.play(Paths.sound('set', 'exe'));
							case 2:
								set.visible = false;
								add(go);
								FlxTween.tween(go.scale, {x: 1.1, y: 1.1}, Conductor.crochet / 500);
								FlxG.sound.play(Paths.sound('go', 'exe'));
							case 3:
								go.visible = false;
								canPause = true;
						}
						amongus += 1;
						if (amongus < 5)
							tmr.reset(Conductor.crochet / 700);
					});
				}
			case 'parent':
				startCountdown();
				add(blackFuck);
				startCircle.loadGraphic(Paths.image('StartScreens/CircleFaker', 'exe'));
				startCircle.x += 777;
				add(startCircle);
				startText.loadGraphic(Paths.image('StartScreens/TextFaker', 'exe'));
				startText.x -= 1200;
				add(startText);
				new FlxTimer().start(0.6, function(tmr:FlxTimer)
				{
					FlxTween.tween(startCircle, {x: 0}, 0.5);
					FlxTween.tween(startText, {x: 0}, 0.5);
				});

				new FlxTimer().start(1.9, function(tmr:FlxTimer)
				{
					FlxTween.tween(startCircle, {alpha: 0}, 1);
					FlxTween.tween(startText, {alpha: 0}, 1);
					FlxTween.tween(blackFuck, {alpha: 0}, 1);
				});
				startCountdown();
			case 'koyochaos':
				FlxG.camera.zoom = defaultCamZoom;
				camHUD.visible = false;
				dad.visible = false;
				dad.setPosition(600, 400);
				camFollow.setPosition(900, 700);
				FlxG.camera.focusOn(camFollow.getPosition());
				new FlxTimer().start(0.5, function(lol:FlxTimer)
				{
					if (preloaded)
					{
						new FlxTimer().start(1, function(lol:FlxTimer)
						{
							FlxTween.tween(FlxG.camera, {zoom: 1.5}, 3, {ease: FlxEase.cubeOut});
							FlxG.sound.play(Paths.sound('robot', 'exe'));
							FlxG.camera.flash(FlxColor.RED, 0.2);
						});
						new FlxTimer().start(2, function(lol:FlxTimer)
						{
							FlxG.sound.play(Paths.sound('sonic', 'exe'));
							thechamber.animation.play('a');
						});
						new FlxTimer().start(6, function(lol:FlxTimer)
						{
							startCountdown();
							FlxG.sound.play(Paths.sound('beam', 'exe'));
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.2, {ease: FlxEase.cubeOut});
							FlxG.camera.shake(0.02, 0.2);
							FlxG.camera.flash(FlxColor.WHITE, 0.2);
							floor.animation.play('b');
							fleetwaybgshit.animation.play('b');
							pebles.animation.play('b');
							emeraldbeamyellow.visible = true;
							emeraldbeam.visible = false;
						});
					}
					else
						lol.reset();
				});
			default:
				startCountdown();
		}

		if (!loadRep)
			rep = new Replay("na");

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, releaseInput);
		super.create();
	}

	function staticHitMiss()
	{
		trace('lol you missed the static note!');
		daNoteStatic = new FlxSprite(0, 0);
		daNoteStatic.frames = Paths.getSparrowAtlas('hitStatic', 'exe');

		daNoteStatic.setGraphicSize(FlxG.width, FlxG.height);

		daNoteStatic.screenCenter();

		daNoteStatic.cameras = [camHUD2];

		daNoteStatic.animation.addByPrefix('static', 'staticANIMATION', 24, false);

		daNoteStatic.animation.play('static', true);

		shakeCam2 = true;

		new FlxTimer().start(0.8, function(tmr:FlxTimer)
		{
			shakeCam2 = false;
		});

		FlxG.sound.play(Paths.sound("hitStatic1"));

		add(daNoteStatic);

		new FlxTimer().start(.38, function(trol:FlxTimer) // fixed lmao
		{
			daNoteStatic.alpha = 0;
			trace('ended HITSTATICLAWL');
			remove(daNoteStatic);
		});
	}

	function doStaticSign(lestatic:Int = 0, leopa:Bool = true)
	{
		trace('static MOMENT HAHAHAH ' + lestatic);
		var daStatic:FlxSprite = new FlxSprite(0, 0);

		daStatic.frames = Paths.getSparrowAtlas('daSTAT');

		daStatic.setGraphicSize(FlxG.width, FlxG.height);

		daStatic.screenCenter();

		daStatic.cameras = [camHUD2];

		switch (lestatic)
		{
			case 0:
				daStatic.animation.addByPrefix('static', 'staticFLASH', 24, false);
		}
		add(daStatic);

		FlxG.sound.play(Paths.sound('staticBUZZ'));

		if (leopa)
		{
			if (daStatic.alpha != 0)
				daStatic.alpha = FlxG.random.float(0.1, 0.5);
		}
		else
			daStatic.alpha = 1;

		daStatic.animation.play('static');

		daStatic.animation.finishCallback = function(pog:String)
		{
			trace('ended static');
			remove(daStatic);
		}
	}

	override public function onResize(Width:Int, Height:Int)
	{
		// definitely do the super call
		super.onResize(Width, Height);

		/// now pass the width and height to vlc, the following is just tracing them to debug consol
		trace('new size $Width $Height');
	}

	function doSimpleJump()
	{
		trace('SIMPLE JUMPSCARE');

		var simplejump:FlxSprite = new FlxSprite().loadGraphic(Paths.image('simplejump', 'exe'));

		simplejump.setGraphicSize(FlxG.width, FlxG.height);

		simplejump.screenCenter();

		simplejump.cameras = [camHUD2];

		FlxG.camera.shake(0.0025, 0.50);

		add(simplejump);

		FlxG.sound.play(Paths.sound('sppok', 'exe'), 1);

		new FlxTimer().start(0.2, function(tmr:FlxTimer)
		{
			trace('ended simple jump');
			remove(simplejump);
		});

		// now for static

		var daStatic:FlxSprite = new FlxSprite(0, 0);

		daStatic.frames = Paths.getSparrowAtlas('daSTAT');

		daStatic.setGraphicSize(FlxG.width, FlxG.height);

		daStatic.screenCenter();

		daStatic.cameras = [camHUD2];

		daStatic.animation.addByPrefix('static', 'staticFLASH', 24, false);

		add(daStatic);

		FlxG.sound.play(Paths.sound('staticBUZZ'));

		if (daStatic.alpha != 0)
			daStatic.alpha = FlxG.random.float(0.1, 0.5);

		daStatic.animation.play('static');

		daStatic.animation.finishCallback = function(pog:String)
		{
			trace('ended static');
			remove(daStatic);
		}
	}

	function doP3JumpTAILS()
	{
		trace('SIMPLE JUMPSCARE');

		var doP3JumpTAILS:FlxSprite = new FlxSprite().loadGraphic(Paths.image('JUMPSCARES/Tails', 'exe'));

		doP3JumpTAILS.setGraphicSize(FlxG.width, FlxG.height);

		doP3JumpTAILS.screenCenter();

		doP3JumpTAILS.cameras = [camHUD2];

		FlxG.camera.shake(0.0025, 0.50);

		add(doP3JumpTAILS);

		FlxG.sound.play(Paths.sound('P3Jumps/TailsScreamLOL', 'exe'), .1);

		new FlxTimer().start(0.2, function(tmr:FlxTimer)
		{
			trace('ended simple jump');
			remove(doP3JumpTAILS);
		});

		balling.frames = Paths.getSparrowAtlas('daSTAT', 'exe');
		balling.animation.addByPrefix('static', 'staticFLASH', 24, false);

		balling.setGraphicSize(FlxG.width, FlxG.height);

		balling.screenCenter();

		balling.cameras = [camHUD2];

		add(balling);

		FlxG.sound.play(Paths.sound('staticBUZZ'));

		if (balling.alpha != 0)
			balling.alpha = FlxG.random.float(0.1, 0.5);

		balling.animation.play('static');

		balling.animation.finishCallback = function(pog:String)
		{
			trace('ended static');
			remove(balling);
		}
	}

	function doP3JumpKNUCKLES()
	{
		trace('SIMPLE JUMPSCARE');

		var doP3JumpKNUCKLES:FlxSprite = new FlxSprite().loadGraphic(Paths.image('JUMPSCARES/Knuckles', 'exe'));

		doP3JumpKNUCKLES.setGraphicSize(FlxG.width, FlxG.height);

		doP3JumpKNUCKLES.screenCenter();

		doP3JumpKNUCKLES.cameras = [camHUD2];

		FlxG.camera.shake(0.0025, 0.50);

		add(doP3JumpKNUCKLES);

		FlxG.sound.play(Paths.sound('P3Jumps/KnucklesScreamLOL', 'exe'), .1);

		new FlxTimer().start(0.2, function(tmr:FlxTimer)
		{
			trace('ended simple jump');
			remove(doP3JumpKNUCKLES);
		});

		balling.frames = Paths.getSparrowAtlas('daSTAT');

		balling.setGraphicSize(FlxG.width, FlxG.height);

		balling.screenCenter();

		balling.cameras = [camHUD2];

		balling.animation.addByPrefix('static', 'staticFLASH', 24, false);

		add(balling);

		FlxG.sound.play(Paths.sound('staticBUZZ'));

		if (balling.alpha != 0)
			balling.alpha = FlxG.random.float(0.1, 0.5);

		balling.animation.play('static');

		balling.animation.finishCallback = function(pog:String)
		{
			trace('ended static');
			remove(balling);
		}
	}

	function doP3JumpEGGMAN()
	{
		trace('SIMPLE JUMPSCARE');

		var doP3JumpEGGMAN:FlxSprite = new FlxSprite().loadGraphic(Paths.image('JUMPSCARES/Eggman', 'exe'));

		doP3JumpEGGMAN.setGraphicSize(FlxG.width, FlxG.height);

		doP3JumpEGGMAN.screenCenter();

		doP3JumpEGGMAN.cameras = [camHUD2];

		FlxG.camera.shake(0.0025, 0.50);

		add(doP3JumpEGGMAN);

		FlxG.sound.play(Paths.sound('P3Jumps/EggmanScreamLOL', 'exe'), .1);

		new FlxTimer().start(0.2, function(tmr:FlxTimer)
		{
			trace('ended simple jump');
			remove(doP3JumpEGGMAN);
		});

		balling.frames = Paths.getSparrowAtlas('daSTAT');

		balling.setGraphicSize(FlxG.width, FlxG.height);

		balling.screenCenter();

		balling.cameras = [camHUD2];

		balling.animation.addByPrefix('static', 'staticFLASH', 24, false);

		add(balling);

		FlxG.sound.play(Paths.sound('staticBUZZ'));

		if (balling.alpha != 0)
			balling.alpha = FlxG.random.float(0.1, 0.5);

		balling.animation.play('static');

		balling.animation.finishCallback = function(pog:String)
		{
			trace('ended static');
			remove(balling);
		}
	}

	function doJumpscare()
	{
		trace('JUMPSCARE aaaa');

		daJumpscare.frames = Paths.getSparrowAtlas('sonicJUMPSCARE', 'exe');
		daJumpscare.animation.addByPrefix('jump', 'sonicSPOOK', 24, false);

		daJumpscare.screenCenter();

		daJumpscare.scale.x = 1.1;
		daJumpscare.scale.y = 1.1;

		daJumpscare.y += 370;

		daJumpscare.cameras = [camHUD2];

		FlxG.sound.play(Paths.sound('jumpscare', 'exe'), 1);
		FlxG.sound.play(Paths.sound('datOneSound', 'exe'), 1);

		add(daJumpscare);

		daJumpscare.animation.play('jump');

		daJumpscare.animation.finishCallback = function(pog:String)
		{
			trace('ended jump');
			remove(daJumpscare);
		}
	}

	function laserThingy(first:Bool)
	{
		var s:Int = 0;

		FlxG.sound.play(Paths.sound('laser_moment', 'exe'));

		var warning:FlxSprite = new FlxSprite();
		warning.frames = Paths.getSparrowAtlas('Warning', 'exe');
		warning.cameras = [camHUD2];
		warning.scale.set(0.5, 0.5);
		warning.screenCenter();
		warning.animation.addByPrefix('a', 'Warning Flash', 24, false);
		warning.alpha = 0;
		add(warning);
		canDodge = true;

		var dodgething:FlxSprite = new FlxSprite(0, 600);
		dodgething.frames = Paths.getSparrowAtlas('spacebar_icon', 'exe');
		dodgething.animation.addByPrefix('a', 'spacebar', 24, false);
		dodgething.scale.x = .5;
		dodgething.scale.y = .5;
		dodgething.screenCenter();
		dodgething.x -= 60;
		dodgething.cameras = [camHUD2];
		add(dodgething);

		new FlxTimer().start(0, function(a:FlxTimer)
		{
			s++;
			warning.animation.play('a', true);
			if (s < 4)
				a.reset(0.32);
			else
				remove(warning);
			if (s == 3)
			{
				remove(dad);
				tailscircle = '';
				dodgething.animation.play('a', true);
				dad = new Character(61.15, -74.75, 'fleetway-extras3');
				add(dad);
				dad.playAnim('a', true);
				dad.animation.finishCallback = function(a:String)
				{
					remove(dad);
					tailscircle = 'hovering';
					dad = new Character(61.15, -94.75, 'fleetway');
					add(dad);
				}
			}
			else if (s == 4)
			{
				remove(dodgething);
			}
		});
	}

	function doP3Static()
	{
		trace('p3static XDXDXD');

		daP3Static.frames = Paths.getSparrowAtlas('Phase3Static', 'exe');
		daP3Static.animation.addByPrefix('P3Static', 'Phase3Static', 24, false);

		daP3Static.screenCenter();

		daP3Static.scale.x = 4;
		daP3Static.scale.y = 4;
		daP3Static.alpha = 0.5;

		daP3Static.cameras = [camHUD2];

		add(daP3Static);

		daP3Static.animation.play('P3Static');

		daP3Static.animation.finishCallback = function(pog:String)
		{
			trace('ended p3static');
			daP3Static.alpha = 0;

			remove(daP3Static);
		}
	}

	function three():Void
	{
		var three:FlxSprite = new FlxSprite().loadGraphic(Paths.image('three', 'shared'));
		three.scrollFactor.set();
		three.updateHitbox();
		three.screenCenter();
		three.y -= 100;
		three.alpha = 0.5;
		add(three);
		FlxTween.tween(three, {y: three.y += 100, alpha: 0}, Conductor.crochet / 1000, {
			ease: FlxEase.cubeOut,
			onComplete: function(twn:FlxTween)
			{
				three.destroy();
			}
		});
	}

	function two():Void
	{
		var two:FlxSprite = new FlxSprite().loadGraphic(Paths.image('two', 'shared'));
		two.scrollFactor.set();
		two.screenCenter();
		two.y -= 100;
		two.alpha = 0.5;
		add(two);
		FlxTween.tween(two, {y: two.y += 100, alpha: 0}, Conductor.crochet / 1000, {
			ease: FlxEase.cubeOut,
			onComplete: function(twn:FlxTween)
			{
				two.destroy();
			}
		});
	}

	function one():Void
	{
		var one:FlxSprite = new FlxSprite().loadGraphic(Paths.image('one', 'shared'));
		one.scrollFactor.set();
		one.screenCenter();
		one.y -= 100;
		one.alpha = 0.5;

		add(one);
		FlxTween.tween(one, {y: one.y += 100, alpha: 0}, Conductor.crochet / 1000, {
			ease: FlxEase.cubeOut,
			onComplete: function(twn:FlxTween)
			{
				one.destroy();
			}
		});
	}

	function gofun():Void
	{
		var gofun:FlxSprite = new FlxSprite().loadGraphic(Paths.image('gofun', 'shared'));
		gofun.scrollFactor.set();

		gofun.updateHitbox();

		gofun.screenCenter();
		gofun.y -= 100;
		gofun.alpha = 0.5;

		add(gofun);
		FlxTween.tween(gofun, {y: gofun.y += 100, alpha: 0}, Conductor.crochet / 1000, {
			ease: FlxEase.cubeInOut,
			onComplete: function(twn:FlxTween)
			{
				gofun.destroy();
			}
		});
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	var luaWiggles:Array<WiggleEffect> = [];

	#if cpp
	public static var luaModchart:ModchartState = null;
	#end

	function startCountdown():Void
	{
		FlxG.log.add(storyPlaylist);

		ezTrail = new FlxTrail(dad, null, 2, 5, 0.3, 0.04);

		SONG.noteStyle = ChartingState.defaultnoteStyle;

		var theThing = curSong.toLowerCase();
		var doesitTween:Bool = false;

		inCutscene = false;

		switch (curSong) // null obj refrence so don't fuck with this
		{
			case "sunshine":

			default:
				generateStaticArrows(0, doesitTween);
				generateStaticArrows(1, doesitTween);
		}

		#if cpp
		// pre lowercasing the song name (startCountdown)
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
		if (executeModchart)
		{
			luaModchart = ModchartState.createModchartState();
			luaModchart.executeState('start', [songLowercase]);
		}
		#end

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dad.dance();
			gf.dance();
			boyfriend.playAnim('idle');

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter)

			{
				case 0:
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					ready.screenCenter();

					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});

				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					set.screenCenter();
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					go.updateHitbox();

					go.screenCenter();
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	private function getKey(charCode:Int):String
	{
		for (key => value in FlxKey.fromStringMap)
		{
			if (charCode == value)
				return key;
		}
		return null;
	}

	var keys = [false, false, false, false, false];

	private function releaseInput(evt:KeyboardEvent):Void // handles releases
	{
		@:privateAccess
		var key = FlxKey.toStringMap.get(Keyboard.__convertKeyCode(evt.keyCode));

		var binds:Array<String> = [
			FlxG.save.data.leftBind,
			FlxG.save.data.downBind,
			FlxG.save.data.upBind,
			FlxG.save.data.rightBind
		];

		var data = -1;

		if (!isRing)
		{
			switch (evt.keyCode) // arrow keys
			{
				case 37:
					data = 0;
				case 40:
					data = 1;
				case 38:
					data = 2;
				case 39:
					data = 3;
			}
		}
		else
		{
			binds = [
				FlxG.save.data.leftBind,
				FlxG.save.data.downBind,
				FlxG.save.data.middleBind,
				FlxG.save.data.upBind,
				FlxG.save.data.rightBind
			];
			switch (evt.keyCode) // arrow keys lol
			{
				case 37:
					data = 0;
				case 40:
					data = 1;
				case 38:
					data = 3;
				case 39:
					data = 4;
			}
		}

		for (i in 0...binds.length) // binds
		{
			if (binds[i].toLowerCase() == key.toLowerCase())
				data = i;
		}

		if (data == -1)
			return;

		keys[data] = false;
	}

	public var closestNotes:Array<Note> = [];

	private function handleInput(evt:KeyboardEvent):Void
	{ // this actually handles press inputs

		if (PlayStateChangeables.botPlay || loadRep || paused)
			return;

		// first convert it from openfl to a flixel key code
		// then use FlxKey to get the key's name based off of the FlxKey dictionary
		// this makes it work for special characters

		@:privateAccess
		var key = FlxKey.toStringMap.get(Keyboard.__convertKeyCode(evt.keyCode));

		var binds:Array<String> = [
			FlxG.save.data.leftBind,
			FlxG.save.data.downBind,
			FlxG.save.data.upBind,
			FlxG.save.data.rightBind
		];

		var data = -1;

		if (!isRing)
		{
			switch (evt.keyCode) // arrow keys
			{
				case 37:
					data = 0;
				case 40:
					data = 1;
				case 38:
					data = 2;
				case 39:
					data = 3;
			}
		}
		else
		{
			binds = [
				FlxG.save.data.leftBind,
				FlxG.save.data.downBind,
				FlxG.save.data.middleBind,
				FlxG.save.data.upBind,
				FlxG.save.data.rightBind
			];
			switch (evt.keyCode) // arrow keys lol
			{
				case 37:
					data = 0;
				case 40:
					data = 1;
				case 38:
					data = 3;
				case 39:
					data = 4;
			}
		}

		for (i in 0...binds.length) // binds
		{
			if (binds[i].toLowerCase() == key.toLowerCase())
				data = i;
		}
		if (data == -1)
		{
			trace("couldn't find a keybind with the code " + key);
			return;
		}
		if (keys[data])
		{
			trace("ur already holding " + key);
			return;
		}

		keys[data] = true;

		var ana = new Ana(Conductor.songPosition, null, false, "miss", data);

		var dataNotes = [];
		for (i in closestNotes)
			if (i.noteData == data)
				dataNotes.push(i);

		if (dataNotes.length != 0)
		{
			var coolNote = null;

			for (i in dataNotes)
				if (!i.isSustainNote)
				{
					coolNote = i;
					break;
				}

			if (coolNote == null) // Note is null, which means it's probably a sustain note. Update will handle this (HOPEFULLY???)
			{
				return;
			}

			if (dataNotes.length > 1) // stacked notes or really close ones
			{
				for (i in 0...dataNotes.length)
				{
					if (i == 0) // skip the first note
						continue;

					var note = dataNotes[i];

					if (!note.isSustainNote && (note.strumTime - coolNote.strumTime) < 2)
					{
						trace('found a stacked/really close note ' + (note.strumTime - coolNote.strumTime));
						// just fuckin remove it since it's a stacked note and shouldn't be there
						note.kill();
						notes.remove(note, true);
						note.destroy();
					}
				}
			}

			goodNoteHit(coolNote);
			var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
			ana.hit = true;
			ana.hitJudge = Ratings.CalculateRating(noteDiff, Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));
			ana.nearestNote = [coolNote.strumTime, coolNote.noteData, coolNote.sustainLength];
		}
		else if (!FlxG.save.data.ghost && songStarted)
		{
			if (!isRing || (isRing && data != 2))
			{
				noteMiss(data, null);
				ana.hit = false;
				ana.hitJudge = "shit";
				ana.nearestNote = [];
				if (curSong != 'white-moon' && cNum == 0)
					health -= 0.04;
				else
					health -= 0.20;
			}
		}
	}

	var songStarted = false;

	function startSong():Void
	{
		startingSong = false;
		songStarted = true;
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();

		if (!paused)
		{
			FlxG.sound.playMusic(Paths.inst(songLowercase), 1, false);
		}

		FlxG.sound.music.onComplete = function() // skill issue + ratio + blocked + didn't ask.
		{
			vocals.volume = 0;
			endSong();
		}
		vocals.play();

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		if (FlxG.save.data.songPosition)
		{
			remove(songPosBG);
			remove(songPosBar);
			remove(songName);

			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('healthBar'));
			if (PlayStateChangeables.useDownscroll)
				songPosBG.y = FlxG.height * 0.9 + 45;
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);

			songPosBar = new FlxBar(songPosBG.x
				+ 4, songPosBG.y
				+ 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, songLength
				- 1000);
			songPosBar.numDivisions = 1000;
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
			add(songPosBar);

			songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - (SONG.song.length * 5), songPosBG.y, 0, SONG.song, 16);
			if (PlayStateChangeables.useDownscroll)
				songName.y -= 3;
			songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songName.scrollFactor.set();
			add(songName);

			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
			songName.cameras = [camHUD];
		}

		// Song check real quick
		switch (curSong)
		{
			case 'Bopeebo' | 'Philly Nice' | 'Blammed' | 'Cocoa' | 'Eggnog':
				allowedToHeadbang = true;
			default:
				allowedToHeadbang = false;
		}

		if (useVideo)
			GlobalVideo.get().resume();

		#if windows
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end

		FlxG.sound.music.time = startTime;
		vocals.time = startTime;
		Conductor.songPosition = startTime;
		startTime = 0;

		for (i in 0...unspawnNotes.length)
			if (unspawnNotes[i].strumTime < startTime)
				unspawnNotes.remove(unspawnNotes[i]);
	}

	var debugNum:Int = 0;

	public function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = StringTools.replace(songData.song, " ", "-").toLowerCase();

		#if sys
		if (SONG.needsVoices && !isSM)
			vocals = new FlxSound().loadEmbedded(Paths.voices(curSong));
		else
			vocals = new FlxSound();
		#else
		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(curSong));
		else
			vocals = new FlxSound();
		#end

		trace('loaded vocals');

		FlxG.sound.list.add(vocals);

		if (!paused)
		{
			#if sys
			if (!isStoryMode && isSM)
			{
				trace("Loading " + pathToSm + "/" + sm.header.MUSIC);
				var bytes = File.getBytes(pathToSm + "/" + sm.header.MUSIC);
				var sound = new Sound();
				sound.loadCompressedDataFromByteArray(bytes.getData(), bytes.length);
				FlxG.sound.playMusic(sound);
			}
			else
				FlxG.sound.playMusic(Paths.inst(curSong), 1, false);
			#else
			FlxG.sound.playMusic(Paths.inst(curSong), 1, false);
			#end
		}

		FlxG.sound.music.onComplete = endSong;
		FlxG.sound.music.pause();

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		if (FlxG.save.data.songPosition)
		{
			remove(songPosBG);
			remove(songPosBar);
			remove(songName);

			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('healthBar'));
			if (PlayStateChangeables.useDownscroll)
				songPosBG.y = FlxG.height * 0.9 + 45;
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);

			songPosBar = new FlxBar(songPosBG.x
				+ 4, songPosBG.y
				+ 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, songLength
				- 1000);
			songPosBar.numDivisions = 1000;
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
			add(songPosBar);

			var songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - (SONG.song.length * 5), songPosBG.y, 0, SONG.song, 16);
			if (PlayStateChangeables.useDownscroll)
				songName.y -= 3;
			songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songName.scrollFactor.set();
			add(songName);

			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
			songName.cameras = [camHUD];
		}

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		// Per song offset check
		#if cpp
		// pre lowercasing the song name (generateSong)
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();

		var songPath = 'assets/data/' + songLowercase + '/';

		#if sys
		if (isSM && !isStoryMode)
			songPath = pathToSm;
		#end

		for (file in sys.FileSystem.readDirectory(songPath))
		{
			var path = haxe.io.Path.join([songPath, file]);
			if (!sys.FileSystem.isDirectory(path))
			{
				if (path.endsWith('.offset'))
				{
					trace('Found offset file: ' + path);
					songOffset = Std.parseFloat(file.substring(0, file.indexOf('.off')));
					break;
				}
				else
				{
					trace('Offset file not found. Creating one @: ' + songPath);
					sys.io.File.saveContent(songPath + songOffset + '.offset', '');
				}
			}
		}
		#end
		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		var a = 0;
		for (section in noteData)
		{
			if (daSection == 57 && curSong.toLowerCase() == 'circus')
				SONG.noteStyle = 'majinNOTES';

			if (daSection == 34 && curSong.toLowerCase() == 'you-cant-kusa')
				SONG.noteStyle = 'pixel';

			if (daSection == 50 && curSong.toLowerCase() == 'you-cant-kusa')
				SONG.noteStyle = 'normal';

			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				a++;

				// 1. Basically if it's the 50th, section, it changes the skin
				var daStrumTime:Float = songNotes[0] + FlxG.save.data.offset + songOffset;
				if (daStrumTime < 0)
					daStrumTime = 0;
				var daNoteData:Int = Std.int(songNotes[1] % deezNuts[ballsinyojaws]);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] >= deezNuts[ballsinyojaws])
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				// var isAlt = songNotes[3];
				var isAlt = section.altAnim;
				var daType = songNotes[3];

				// 2. I added a new parameter: daSkin which basically make the notes specific skins
				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, true, isAlt, daType);

				if (!gottaHitNote && PlayStateChangeables.Optimize)
					continue;

				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				if (susLength > 0)
					swagNote.isParent = true;

				var type = 0;

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}

					sustainNote.parent = swagNote;
					swagNote.children.push(sustainNote);
					sustainNote.spotInLine = type;
					type++;
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function removeStatics()
	{
		playerStrums.forEach(function(todel:FlxSprite)
		{
			playerStrums.remove(todel);
			todel.destroy();
		});
		cpuStrums.forEach(function(todel:FlxSprite)
		{
			cpuStrums.remove(todel);
			todel.destroy();
		});
		strumLineNotes.forEach(function(todel:FlxSprite)
		{
			strumLineNotes.remove(todel);
			todel.destroy();
		});
	}

	private function generateStaticArrows(player:Int, tweened:Bool):Void
	{
		var colorArray = isRing ? dataColor5k : dataColor;
		var suffixArray = isRing ? dataSuffix5k : dataSuffix;

		for (i in 0...deezNuts[ballsinyojaws])
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);

			var bloodSplash:FlxSprite = new FlxSprite(0, strumLine.y - 80); // i have no idea on what am i doing
			if (player == 1)
			{
				bloodSplash.frames = Paths.getSparrowAtlas('BloodSplash', 'exe');
				bloodSplash.animation.addByPrefix('a', 'Squirt', 24, false);
				bloodSplash.animation.play('a');
				bloodSplash.antialiasing = true;
				bloodSplash.animation.curAnim.curFrame = 10;
			}

			// defaults if no noteStyle was found in chart
			var noteTypeCheck:String = 'normal';

			if (PlayStateChangeables.Optimize && player == 0)
				continue;

			if (SONG.noteStyle == null)
			{
				switch (storyWeek)
				{
					case 6:
						noteTypeCheck = 'pixel';
				}
			}
			else
			{
				noteTypeCheck = SONG.noteStyle;
			}

			switch (noteTypeCheck)
			{
				case 'pixel':
					babyArrow.loadGraphic(Paths.image('arrows-pixels', 'exe'), true, 17, 17);
					for (j in 0...colorArray.length)
					{
						babyArrow.animation.add(colorArray[j], [j + 4]);
					}

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					babyArrow.x += Note.swagWidth * i;
					babyArrow.animation.add('static', [i]);
					babyArrow.animation.add('pressed', [i + 4, i + 8], 12, false);
					babyArrow.animation.add('confirm', [i + 12, i + 16], 24, false);
				case 'majinNOTES':
					babyArrow.frames = Paths.getSparrowAtlas('Majin_Notes', 'exe');
					for (j in 0...colorArray.length)
					{
						babyArrow.animation.addByPrefix(colorArray[j], 'arrow' + colorArray[j]);
					}

					var lowerDir:String = suffixArray[i].toLowerCase();

					babyArrow.animation.addByPrefix('static', 'arrow' + suffixArray[i]);
					babyArrow.animation.addByPrefix('pressed', lowerDir + ' press', 24, false);
					babyArrow.animation.addByPrefix('confirm', lowerDir + ' confirm', 24, false);

					babyArrow.x += Note.swagWidth * i;

					babyArrow.antialiasing = FlxG.save.data.antialiasing;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
				case 'normal':
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
					for (j in 0...colorArray.length)
					{
						babyArrow.animation.addByPrefix(colorArray[j], 'arrow' + colorArray[j]);
					}

					var lowerDir:String = suffixArray[i].toLowerCase();

					babyArrow.animation.addByPrefix('static', 'arrow' + suffixArray[i]);
					babyArrow.animation.addByPrefix('pressed', lowerDir + ' press', 24, false);
					babyArrow.animation.addByPrefix('confirm', lowerDir + ' confirm', 24, false);

					babyArrow.x += Note.swagWidth * i;

					babyArrow.antialiasing = FlxG.save.data.antialiasing;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
				default:
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
					for (j in 0...colorArray.length)
					{
						babyArrow.animation.addByPrefix(colorArray[j], 'arrow' + colorArray[j]);
					}

					var lowerDir:String = suffixArray[i].toLowerCase();

					babyArrow.animation.addByPrefix('static', 'arrow' + suffixArray[i]);
					babyArrow.animation.addByPrefix('pressed', lowerDir + ' press', 24, false);
					babyArrow.animation.addByPrefix('confirm', lowerDir + ' confirm', 24, false);

					babyArrow.x += Note.swagWidth * i;

					babyArrow.antialiasing = FlxG.save.data.antialiasing;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
			}

			if (curSong != 'circus' && curSong != 'asacoco' && ((isRing && i != 2) || !isRing) && player == 1)
			{
				bloodSplash.x = babyArrow.x + 520;
				playerSplashes.add(bloodSplash);
			}
			else if (curSong == 'white-moon' && player == 0)
			{
				babyArrow.alpha = 0; // I fucking hate doing thiss
				babyArrow.visible = false;
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (!isStoryMode && tweened)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			if ((isRing && i != 2) || !isRing && player == 1)
				bloodSplash.ID = i;
			else if (isRing && i == 2 && player == 1)
				bloodSplash.ID = -1;
			babyArrow.ID = i;

			switch (player)
			{
				case 0:
					cpuStrums.add(babyArrow);
				case 1:
					playerStrums.add(babyArrow);
			}

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			if (PlayStateChangeables.Optimize)
				babyArrow.x -= 275;

			if (FlxG.save.data.midscroll && player == 1)
				babyArrow.x -= 68.75 * deezNuts[ballsinyojaws];
			if (FlxG.save.data.midscroll && player == 0)
				babyArrow.alpha = 0;

			cpuStrums.forEach(function(spr:FlxSprite)
			{
				spr.centerOffsets(); // CPU arrows start out slightly off-center
			});

			strumLineNotes.add(babyArrow);
		}

		if (curSong == 'white-moon' && player == 0)
		{
			notes.forEachAlive(function(spr:Note)
			{
				spr.alpha = 0;
			});
			for (i in 0...closestNotes.length)
			{
				var spr = closestNotes[i];
				spr.alpha = 1;
			}
		}
	}

	private function appearStaticArrows():Void
	{
		strumLineNotes.forEach(function(babyArrow:FlxSprite)
		{
			if (isStoryMode)
				babyArrow.alpha = 1;
		});
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			#if cpp
			DiscordClient.changePresence("PAUSED on "
				+ SONG.song
				+ " ("
				+ storyDifficultyText
				+ ") "
				+ Ratings.GenerateLetterRank(accuracy),
				"Acc: "
				+ HelperFunctions.truncateFloat(accuracy, 2)
				+ "% | Score: "
				+ songScore
				+ " | Misses: "
				+ misses, iconRPC);
			#end
			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if cpp
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText
					+ " "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC, true,
					songLength
					- Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();

		#if cpp
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var nps:Int = 0;
	var maxNPS:Int = 0;

	public static var songRate = 1.5;

	public var stopUpdate = false;
	public var removedVideo = false;

	public var currentBPM = 0;

	public var updateFrame = 0;

	public var pastScrollChanges:Array<Song.Event> = [];

	override public function update(elapsed:Float)
	{
		if (curSong == 'koyochaos' && dad.curCharacter == 'fleetway-extras3' && dad.animation.curAnim.curFrame == 15 && !dodging)
			health = 0;

		if (isRing)
			counterNum.text = Std.string(cNum);

		if ((FlxG.keys.justPressed.SPACE
			|| FlxG.keys.anyJustPressed([FlxKey.fromString(FlxG.save.data.dodgeBind)])
			|| (PlayStateChangeables.botPlay && curStep == 269))
			&& canDodge)
		{
			dodging = true;
			boyfriend.playAnim('dodge', true);
			boyfriend.nonanimated = true;
			boyfriend.animation.finishCallback = function(a:String)
			{
				boyfriend.nonanimated = false;
				dodging = false;
				canDodge = false;
			}
		}

		switch (curSong)
		{
			case 'white-moon':
				{
					var ccap;

					ccap = combo;
					if (combo > 40)
						ccap = 40;

					heatlhDrop = 0.0000001; // this is the default drain, imma just add a 0 to it :troll:.
					health -= heatlhDrop * (500 / ((ccap + 1) / 8) * ((misses +
						1) / 1.9)); // alright so this is the code for the healthdrain, also i did + 1 cus i you were to multiply with 0.... yea
					vgblack.alpha = 1 - (health / 2);
					tentas.alpha = 1 - (health / 2);
				}
			default:
				health -= heatlhDrop;
		}

		floaty += 0.03;

		if (shakeCam)
		{
			FlxG.camera.shake(0.005, 0.10);
		}

		if (shakeCam2)
		{
			FlxG.camera.shake(0.0025, 0.10);
		}

		#if !debug
		perfectMode = false;
		#end

		// if (generatedMusic)
		// {
		// 	for (i in notes)
		// 	{
		// 		var diff = i.strumTime - Conductor.songPosition;
		// 		if (diff < 2650 && diff >= -2650)
		// 		{
		// 			i.active = true;
		// 			i.visible = true;
		// 		}
		// 		else
		// 		{
		// 			i.active = false;
		// 			i.visible = false;
		// 		}
		// 	}
		// }

		if (updateFrame == 4)
		{
			TimingStruct.clearTimings();

			var currentIndex = 0;
			if (SONG.eventObjects != null)
			{
				for (i in SONG.eventObjects)
				{
					if (i.type == "BPM Change")
					{
						var beat:Float = i.position;

						var endBeat:Float = Math.POSITIVE_INFINITY;

						TimingStruct.addTiming(beat, i.value, endBeat, 0); // offset in this case = start time since we don't have a offset

						if (currentIndex != 0)
						{
							var data = TimingStruct.AllTimings[currentIndex - 1];
							data.endBeat = beat;
							data.length = (data.endBeat - data.startBeat) / (data.bpm / 60);
							TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length;
						}

						currentIndex++;
					}
				}
			}
			updateFrame++;
		}
		else if (updateFrame != 5)
			updateFrame++;

		var timingSeg = TimingStruct.getTimingAtTimestamp(Conductor.songPosition);

		if (timingSeg != null)
		{
			var timingSegBpm = timingSeg.bpm;

			if (timingSegBpm != Conductor.bpm)
			{
				trace("BPM CHANGE to " + timingSegBpm);
				Conductor.changeBPM(timingSegBpm, false);
			}
		}

		var newScroll = PlayStateChangeables.scrollSpeed;

		if (SONG.eventObjects != null)
		{
			for (i in SONG.eventObjects)
			{
				switch (i.type)
				{
					case "Scroll Speed Change":
						if (i.position <= curDecimalBeat && !pastScrollChanges.contains(i))
						{
							pastScrollChanges.push(i);
							trace("SCROLL SPEED CHANGE to " + i.value);
							newScroll = i.value;
						}
				}
			}
		}

		PlayStateChangeables.scrollSpeed = newScroll;

		if (PlayStateChangeables.botPlay && FlxG.keys.justPressed.ONE)
			camHUD.visible = !camHUD.visible;

		if (useVideo && GlobalVideo.get() != null && !stopUpdate)
		{
			if (GlobalVideo.get().ended && !removedVideo)
			{
				remove(videoSprite);
				FlxG.stage.window.onFocusOut.remove(focusOut);
				FlxG.stage.window.onFocusIn.remove(focusIn);
				removedVideo = true;
			}
		}

		#if cpp
		if (executeModchart && luaModchart != null && songStarted)
		{
			luaModchart.setVar('songPos', Conductor.songPosition);
			luaModchart.setVar('hudZoom', camHUD.zoom);
			luaModchart.setVar('curBeat', HelperFunctions.truncateFloat(curDecimalBeat, 3));
			luaModchart.setVar('cameraZoom', FlxG.camera.zoom);
			luaModchart.executeState('update', [elapsed]);

			for (key => value in luaModchart.luaWiggles)
			{
				trace('wiggle le gaming');
				value.update(elapsed);
			}

			/*for (i in 0...strumLineNotes.length) {
				var member = strumLineNotes.members[i];
				member.x = luaModchart.getVar("strum" + i + "X", "float");
				member.y = luaModchart.getVar("strum" + i + "Y", "float");
				member.angle = luaModchart.getVar("strum" + i + "Angle", "float");
			}*/

			FlxG.camera.angle = luaModchart.getVar('cameraAngle', 'float');
			camHUD.angle = luaModchart.getVar('camHudAngle', 'float');

			if (luaModchart.getVar("showOnlyStrums", 'bool'))
			{
				healthBarBG.visible = false;
				kadeEngineWatermark.visible = false;
				healthBar.visible = false;
				iconP1.visible = false;
				iconP2.visible = false;
				scoreTxt.visible = false;
			}
			else
			{
				healthBarBG.visible = true;
				kadeEngineWatermark.visible = true;
				healthBar.visible = true;
				iconP1.visible = true;
				iconP2.visible = true;
				scoreTxt.visible = true;
			}

			var p1 = luaModchart.getVar("strumLine1Visible", 'bool');
			var p2 = luaModchart.getVar("strumLine2Visible", 'bool');

			for (i in 0...4)
			{
				strumLineNotes.members[i].visible = p1;
				if (i <= playerStrums.length)
					playerStrums.members[i].visible = p2;
			}

			camNotes.zoom = camHUD.zoom;
			camNotes.x = camHUD.x;
			camNotes.y = camHUD.y;
			camNotes.angle = camHUD.angle;
			camSustains.zoom = camHUD.zoom;
			camSustains.x = camHUD.x;
			camSustains.y = camHUD.y;
			camSustains.angle = camHUD.angle;
		}
		#end

		// reverse iterate to remove oldest notes first and not invalidate the iteration
		// stop iteration as soon as a note is not removed
		// all notes should be kept in the correct order and this is optimal, safe to do every frame/update
		{
			var balls = notesHitArray.length - 1;
			while (balls >= 0)
			{
				var cock:Date = notesHitArray[balls];
				if (cock != null && cock.getTime() + 1000 < Date.now().getTime())
					notesHitArray.remove(cock);
				else
					balls = 0;
				balls--;
			}
			nps = notesHitArray.length;
			if (nps > maxNPS)
				maxNPS = nps;
		}

		if (FlxG.keys.justPressed.NINE)
			iconP1.swapOldIcon();

		super.update(elapsed);

		scoreTxt.text = Ratings.CalculateRanking(songScore, songScoreDef, nps, maxNPS, accuracy);

		var lengthInPx = scoreTxt.textField.length * scoreTxt.frameHeight; // bad way but does more or less a better job

		scoreTxt.x = (originalX - (lengthInPx / 2)) + 335;

		if (controls.PAUSE && startedCountdown && canPause && !cannotDie)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				trace('GITAROO MAN EASTER EGG');
				FlxG.switchState(new GitarooPause());
				clean();
			}
			else
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		if (FlxG.keys.justPressed.SEVEN && songStarted)
		{
			if (useVideo)
			{
				GlobalVideo.get().stop();
				remove(videoSprite);
				#if sys
				FlxG.stage.window.onFocusOut.remove(focusOut);
				FlxG.stage.window.onFocusIn.remove(focusIn);
				#end
				removedVideo = true;
			}
			cannotDie = true;
			#if cpp
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end

			FlxG.switchState(new ChartingState());
			clean();
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if cpp
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		if (dad.curCharacter == "TDoll" || dad.curCharacter == "fleetway") // Do you really wanna see sonic.exe fly? Me neither.
		{
			if (tailscircle == 'hovering' || tailscircle == 'circling')
				dad.y += Math.sin(floaty) * 1.3;
			if (tailscircle == 'circling')
				dad.x += Math.cos(floaty) * 1.3; // math B)
		}
		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		if (healthBar.flipX)
			healthBar.value = 2 - health;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;
		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		switch (dad.curCharacter)
		{
			case 'exe':
				if (healthBar.percent < 20)
				{
					iconP2.animation.curAnim.curFrame = 1;
					iconP1.animation.curAnim.curFrame = 1;
				}
				else
				{
					iconP1.animation.curAnim.curFrame = 0;
					iconP2.animation.curAnim.curFrame = 0;
				}
		}

		#if debug
		if (FlxG.keys.justPressed.SIX)
		{
			if (useVideo)
			{
				GlobalVideo.get().stop();
				remove(videoSprite);
				FlxG.stage.window.onFocusOut.remove(focusOut);
				FlxG.stage.window.onFocusIn.remove(focusIn);
				removedVideo = true;
			}

			FlxG.switchState(new AnimationDebug(SONG.player2));
			clean();
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if cpp
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		if (FlxG.keys.justPressed.EIGHT)
		{
			if (useVideo)
			{
				GlobalVideo.get().stop();
				remove(videoSprite);
				FlxG.stage.window.onFocusOut.remove(focusOut);
				FlxG.stage.window.onFocusIn.remove(focusIn);
				removedVideo = true;
			}

			FlxG.switchState(new AnimationDebug(gf.curCharacter));
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if cpp
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		if (FlxG.keys.justPressed.ZERO)
		{
			FlxG.switchState(new AnimationDebug(SONG.player1));
			clean();
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if cpp
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		if (FlxG.keys.justPressed.TWO)
		{ // Go 10 seconds into the future, credit: Shadow Mario#9396
			if (!usedTimeTravel && Conductor.songPosition + 10000 < FlxG.sound.music.length)
			{
				usedTimeTravel = true;
				FlxG.sound.music.pause();
				vocals.pause();
				Conductor.songPosition += 10000;
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.strumTime - 500 < Conductor.songPosition)
					{
						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});

				FlxG.sound.music.time = Conductor.songPosition;
				FlxG.sound.music.play();

				vocals.time = Conductor.songPosition;
				vocals.play();
				new FlxTimer().start(0.5, function(tmr:FlxTimer)
				{
					usedTimeTravel = false;
				});
			}
		}
		#end

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					if (curSong.toLowerCase() != 'too-seiso' || curSong.toLowerCase() != 'ankimo')
					{
						startSong();
					}
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;
			/*@:privateAccess
				{
					FlxG.sound.music._channel.
			}*/
			songPositionBar = Conductor.songPosition;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			closestNotes = [];

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
					closestNotes.push(daNote);
			}); // Collect notes that can be hit

			closestNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

			if (closestNotes.length != 0)
				FlxG.watch.addQuick("Current Note", closestNotes[0].strumTime - Conductor.songPosition);

			#if cpp
			if (luaModchart != null)
				luaModchart.setVar("mustHit", PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			#end

			if (camLocked)
			{
				if (!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection) // This suprisingly works :shrug:
				{
					var offsetX = 0;
					var offsetY = 0;
					#if cpp
					if (luaModchart != null)
					{
						offsetX = luaModchart.getVar("followXOffset", "float");
						offsetY = luaModchart.getVar("followYOffset", "float");
					}
					#end
					camFollow.setPosition(dad.getMidpoint().x + 150 + offsetX, dad.getMidpoint().y - 100 + offsetY);
					#if cpp
					if (luaModchart != null)
						luaModchart.executeState('playerTwoTurn', []);
					#end
					// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

					switch (dad.curCharacter) // camerathingy for diffrent enemies
					{
						case 'suisei':
							camFollow.y = dad.getMidpoint().y - 30;
							camFollow.x = dad.getMidpoint().x + 120;
						case 'sonic.exe':
							camFollow.y = dad.getMidpoint().y - 50;
						case 'exe':
							FlxTween.tween(FlxG.camera, {zoom: 0.8}, 0.4, {ease: FlxEase.cubeOut});
							camFollow.y = dad.getMidpoint().y - 300;
							camFollow.x = dad.getMidpoint().x - 100;
						case 'sonicLordX':
							camFollow.y = dad.getMidpoint().y - 25;
							camFollow.x = dad.getMidpoint().x + 120;
						case 'coco':
							camFollow.y = dad.getMidpoint().y - 30;
							camFollow.x = dad.getMidpoint().x + 120;
						case 'TDoll' | 'TDollAlt':
							camFollow.y = dad.getMidpoint().y - 200;
							camFollow.x = dad.getMidpoint().x + 130;
						case 'sanic':
							camFollow.y = dad.getMidpoint().y + 700;
							camFollow.x = dad.getMidpoint().x + 700;
						case 'knucks':
							camFollow.y = dad.getMidpoint().y + 50;
							camFollow.x = dad.getMidpoint().x - 200;
						case 'sonic.exe alt':
							camFollow.y = dad.getMidpoint().y - 350;
							camFollow.x = dad.getMidpoint().x - 200;
						case 'eggdickface':
							camFollow.y = dad.getMidpoint().y - 50;
							camFollow.x = dad.getMidpoint().x + 100;
						case 'beast-cam-fix':
							camFollow.y = dad.getMidpoint().y - 100;
							camFollow.x = dad.getMidpoint().x - 300;
						case 'fleetway':
							camFollow.y = dad.getMidpoint().y - 100;
							camFollow.x = dad.getMidpoint().x + 100;
					}

					if (cameramove && tailscircle == '') // i rlly don't like how the camera moves while a character is flying.
					{
						camFollow.y += camY;
						camFollow.x += camX;
					}
				}

				if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
				{
					var offsetX = 0;
					var offsetY = 0;
					#if cpp
					if (luaModchart != null)
					{
						offsetX = luaModchart.getVar("followXOffset", "float");
						offsetY = luaModchart.getVar("followYOffset", "float");
					}
					#end
					camFollow.setPosition(boyfriend.getMidpoint().x - 100 + offsetX, boyfriend.getMidpoint().y - 100 + offsetY);

					#if cpp
					if (luaModchart != null)
						luaModchart.executeState('playerOneTurn', []);
					#end

					switch (dad.curCharacter)
					{
						case 'exe':
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.4, {ease: FlxEase.cubeOut});
					}

					switch (boyfriend.curCharacter) // camerathingy for diffrent bf's
					{
						case 'bf-perspective-flipped':
							camFollow.y = boyfriend.getMidpoint().y - 250;
							camFollow.x = boyfriend.getMidpoint().x - 300;

						case 'bf-perspective':
							camFollow.y = boyfriend.getMidpoint().y - 250;
							camFollow.x = boyfriend.getMidpoint().x + 300;
						case 'bf-pixel':
							camFollow.y = boyfriend.getMidpoint().y - 250;
							camFollow.x = boyfriend.getMidpoint().x - 300;
						case 'bf-flipped':
							camFollow.y = boyfriend.getMidpoint().y;
							camFollow.x = boyfriend.getMidpoint().x + 100;
						case 'bf-flipped-for-cam':
							camFollow.y = boyfriend.getMidpoint().y - 40;
							camFollow.x = boyfriend.getMidpoint().x + 100;
					}

					if (cameramove)
					{
						camFollow.x += bfcamX;
						camFollow.y += bfcamY;
					}
				}
			}
		}

		if (camZooming)
		{
			if (FlxG.save.data.zoom < 0.8)
				FlxG.save.data.zoom = 0.8;

			if (FlxG.save.data.zoom > 1.2)
				FlxG.save.data.zoom = 1.2;

			if (!executeModchart)
			{
				FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
				camHUD.zoom = FlxMath.lerp(FlxG.save.data.zoom, camHUD.zoom, 0.95);

				camNotes.zoom = camHUD.zoom;
				camSustains.zoom = camHUD.zoom;
			}
			else
			{
				FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
				camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);

				camNotes.zoom = camHUD.zoom;
				camSustains.zoom = camHUD.zoom;
			}
		}

		FlxG.watch.addQuick("curBPM", Conductor.bpm);
		FlxG.watch.addQuick("Closest Note", (unspawnNotes.length != 0 ? unspawnNotes[0].strumTime - Conductor.songPosition : "No note"));

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (health <= 0 && !cannotDie)
		{
			if (!usedTimeTravel)
			{
				boyfriend.stunned = true;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if cpp
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("GAME OVER -- "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC);
				#end

				// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			}
			else
				health = 1;
		}
		if (!inCutscene && FlxG.save.data.resetButton)
		{
			if (FlxG.keys.justPressed.R)
			{
				boyfriend.stunned = true;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if cpp
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("GAME OVER -- "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC);
				#end

				// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			}
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 3500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];

			notes.forEachAlive(function(daNote:Note)
			{
				// instead of doing stupid y > FlxG.height
				// we be men and actually calculate the time :)
				if (daNote.tooLate)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				if (!daNote.modifiedByLua)
				{
					if (PlayStateChangeables.useDownscroll)
					{
						if (daNote.mustPress)
							daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
								+
								0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2))
								- daNote.noteYOff;
						else
							daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
								+
								0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2))
								- daNote.noteYOff;
						if (daNote.isSustainNote)
						{
							// Remember = minus makes notes go up, plus makes them go down
							if (daNote.animation.curAnim.name.endsWith('end') && daNote.prevNote != null)
								daNote.y += daNote.prevNote.height;
							else
								daNote.y += daNote.height / 2;

							// If not in botplay, only clip sustain notes when properly hit, botplay gets to clip it everytime
							if (!PlayStateChangeables.botPlay)
							{
								if ((!daNote.mustPress
									|| daNote.wasGoodHit
									|| daNote.prevNote.wasGoodHit
									|| holdArray[Math.floor(Math.abs(daNote.noteData))]
									&& !daNote.tooLate)
									&& daNote.y
									- daNote.offset.y * daNote.scale.y
									+ daNote.height >= (strumLine.y + Note.swagWidth / 2))
								{
									// Clip to strumline
									var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
									swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
										+ Note.swagWidth / 2
										- daNote.y) / daNote.scale.y;
									swagRect.y = daNote.frameHeight - swagRect.height;

									daNote.clipRect = swagRect;
								}
							}
							else
							{
								var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
								swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
									+ Note.swagWidth / 2
									- daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;

								daNote.clipRect = swagRect;
							}
						}
					}
					else
					{
						if (daNote.mustPress)
							daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
								- 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2))
								+ daNote.noteYOff;
						else
							daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
								- 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2))
								+ daNote.noteYOff;
						if (daNote.isSustainNote)
						{
							daNote.y -= daNote.height / 2;

							if (!PlayStateChangeables.botPlay)
							{
								if ((!daNote.mustPress
									|| daNote.wasGoodHit
									|| daNote.prevNote.wasGoodHit
									|| holdArray[Math.floor(Math.abs(daNote.noteData))]
									&& !daNote.tooLate)
									&& daNote.y
									+ daNote.offset.y * daNote.scale.y <= (strumLine.y + Note.swagWidth / 2))
								{
									// Clip to strumline
									var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
									swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
										+ Note.swagWidth / 2
										- daNote.y) / daNote.scale.y;
									swagRect.height -= swagRect.y;

									daNote.clipRect = swagRect;
								}
							}
							else
							{
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
									+ Note.swagWidth / 2
									- daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;

								daNote.clipRect = swagRect;
							}
						}
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					if (tailscircle == 'circling' && dad.curCharacter == 'TDoll')
					{
						add(ezTrail);
					}

					if (dad.curCharacter == 'sonic.exe')
					{
						FlxG.camera.shake(0.005, 0.50);
					}

					if (curSong == 'sunshine' && curStep > 588 && curStep < 860 && !daNote.isSustainNote)
					{
						playerStrums.forEach(function(spr:FlxSprite)
						{
							spr.alpha = 0.7;
							if (spr.alpha != 0)
							{
								new FlxTimer().start(0.01, function(trol:FlxTimer)
								{
									spr.alpha -= 0.03;
									if (spr.alpha != 0)
										trol.reset();
								});
							}
						});
						notes.forEachAlive(function(spr:FlxSprite)
						{
							spr.alpha = 0.7;
							if (spr.alpha != 0)
							{
								new FlxTimer().start(0.01, function(trol:FlxTimer)
								{
									spr.alpha -= 0.03;
									if (spr.alpha != 0)
										trol.reset();
								});
							}
						});
					}

					var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();

					if (songLowercase != 'tutorial')
						camZooming = true;

					var altAnim:String = "";

					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].p1AltAnim)
							altAnim = '-alt';
					}

					if (daNote.isAlt)
					{
						altAnim = '-alt';
						trace("YOO WTF THIS IS AN ALT NOTE????");
					}

					var suffixArray = isRing ? dataSuffix5k : dataSuffix;

					// Accessing the animation name directly to play it
					if (!daNote.isParent && daNote.parent != null)
					{
						if (daNote.spotInLine != daNote.parent.children.length - 1)
						{
							var singData:Int = Std.int(Math.abs(daNote.noteData));
							if (!isRing || (isRing && singData != 2))
								dad.playAnim('sing' + suffixArray[singData] + altAnim, true);

							if (FlxG.save.data.cpuStrums)
							{
								cpuStrums.forEach(function(spr:FlxSprite)
								{
									if (Math.abs(daNote.noteData) == spr.ID)
									{
										spr.animation.play('confirm', true);
									}
									if (spr.animation.curAnim.name == 'confirm' && SONG.noteStyle != 'pixel')
									{
										spr.centerOffsets();
										spr.offset.x -= 13;
										spr.offset.y -= 13;
									}
									else
										spr.centerOffsets();
								});
							}

							#if cpp
							if (luaModchart != null)
								luaModchart.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition]);
							#end

							dad.holdTimer = 0;

							if (SONG.needsVoices)
								vocals.volume = 1;
						}
					}
					else
					{
						var singData:Int = Std.int(Math.abs(daNote.noteData));
						if (!isRing || (isRing && singData != 2))
							dad.playAnim('sing' + suffixArray[singData] + altAnim, true);

						if (FlxG.save.data.cpuStrums)
						{
							cpuStrums.forEach(function(spr:FlxSprite)
							{
								if (Math.abs(daNote.noteData) == spr.ID)
								{
									spr.animation.play('confirm', true);
								}
								if (spr.animation.curAnim.name == 'confirm' && SONG.noteStyle != 'pixel')
								{
									spr.centerOffsets();
									spr.offset.x -= 13;
									spr.offset.y -= 13;
								}
								else
									spr.centerOffsets();
							});
						}

						#if cpp
						if (luaModchart != null)
							luaModchart.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition]);
						#end

						dad.holdTimer = 0;

						if (SONG.needsVoices)
							vocals.volume = 1;
					}
					daNote.active = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				if (noteLink)
				{
					if (daNote.mustPress && !daNote.modifiedByLua)
					{
						daNote.visible = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].visible;
						daNote.x = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x;
						if (!daNote.isSustainNote)
							daNote.modAngle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
						if (daNote.sustainActive)
						{
							if (executeModchart)
								daNote.alpha = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha;
						}
						daNote.modAngle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
					}
					else if (!daNote.wasGoodHit && !daNote.modifiedByLua)
					{
						daNote.visible = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].visible;
						daNote.x = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].x;
						if (!daNote.isSustainNote)
							daNote.modAngle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].angle;
						if (daNote.sustainActive)
						{
							if (executeModchart)
								daNote.alpha = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha;
						}
						daNote.modAngle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].angle;
					}
				}

				playerSplashes.forEach(function(spr:FlxSprite)
				{
					playerStrums.forEach(function(spr2:FlxSprite)
					{
						if (spr.ID == spr2.ID)
						{
							spr.x = spr2.x - 68;
							spr.y = spr2.y - 20;
						}
					});
				});

				if (daNote.isSustainNote)
				{
					daNote.x += daNote.width / 2 + 20;
					if (SONG.noteStyle == 'pixel')
						daNote.x -= 11;
				}

				// trace(daNote.y);
				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				if (daNote.isSustainNote && daNote.wasGoodHit && Conductor.songPosition >= daNote.strumTime)
				{
					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
				else if ((daNote.mustPress && daNote.tooLate && !PlayStateChangeables.useDownscroll || daNote.mustPress && daNote.tooLate
					&& PlayStateChangeables.useDownscroll)
					&& daNote.mustPress)
				{
					if (daNote.isSustainNote && daNote.wasGoodHit)
					{
						daNote.kill();
						notes.remove(daNote, true);
					}
					else if (!daNote.isSustainNote && !daNote.wasGoodHit)
					{
						if (daNote.noteType == 2)
						{
							noteMiss(daNote.noteData, daNote);
							if (curSong != 'white-moon' && cNum == 0)
								health -= 0.3;
							staticHitMiss();
							new FlxTimer().start(.38, function(trol:FlxTimer) // fixed lmao
							{
								remove(daNoteStatic);
							});
							vocals.volume = 0;
							FlxG.sound.play(Paths.sound('ring'), .7);
						}
						if (daNote.noteType == 1 || daNote.noteType == 0)
						{
							if (isRing && daNote.noteData != 2)
							{
								if (curSong != 'white-moon' && cNum == 0)
									health -= 0.075;
								vocals.volume = 0;
								if (theFunne)
									noteMiss(daNote.noteData, daNote);
							}
							else if (!isRing)
							{
								if (curSong != 'white-moon' && cNum == 0)
									0.075;
								vocals.volume = 0;
								if (theFunne)
									noteMiss(daNote.noteData, daNote);
							}
						}
					}
					else
					{
						if (loadRep && daNote.isSustainNote)
						{
							// im tired and lazy this sucks I know i'm dumb
							if (findByTime(daNote.strumTime) != null)
								totalNotesHit += 1;
							else
							{
								vocals.volume = 0;
								if (theFunne && !daNote.isSustainNote)
								{
									noteMiss(daNote.noteData, daNote);
								}
								if (daNote.isParent)
								{
									health -= 0.15; // give a health punishment for failing a LN
									trace("hold fell over at the start");
									for (i in daNote.children)
									{
										i.alpha = 0.3;
										i.sustainActive = false;
									}
								}
								else
								{
									if (!daNote.wasGoodHit
										&& daNote.isSustainNote
										&& daNote.sustainActive
										&& daNote.spotInLine != daNote.parent.children.length)
									{
										health -= 0.2; // give a health punishment for failing a LN
										trace("hold fell over at " + daNote.spotInLine);
										for (i in daNote.parent.children)
										{
											i.alpha = 0.3;
											i.sustainActive = false;
										}
										if (daNote.parent.wasGoodHit)
											misses++;
										updateAccuracy();
									}
									else
									{
										health -= 0.15;
									}
								}
							}
						}
						else if (!PlayStateChangeables.botPlay)
						{
							vocals.volume = 0;
							if (theFunne && !daNote.isSustainNote)
							{
								if (PlayStateChangeables.botPlay && daNote.noteType != 3)
								{
									daNote.rating = "bad";
									goodNoteHit(daNote);
								}
								else
									noteMiss(daNote.noteData, daNote);
							}

							if (daNote.isParent)
							{
								health -= 0.15; // give a health punishment for failing a LN
								trace("hold fell over at the start");
								for (i in daNote.children)
								{
									i.alpha = 0.3;
									i.sustainActive = false;
									trace(i.alpha);
								}
							}
							else
							{
								if (!daNote.wasGoodHit
									&& daNote.isSustainNote
									&& daNote.sustainActive
									&& daNote.spotInLine != daNote.parent.children.length)
								{
									health -= 0.25; // give a health punishment for failing a LN
									trace("hold fell over at " + daNote.spotInLine);
									for (i in daNote.parent.children)
									{
										i.alpha = 0.3;
										i.sustainActive = false;
										trace(i.alpha);
									}
									if (daNote.parent.wasGoodHit)
										misses++;
									updateAccuracy();
								}
								else
								{
									health -= 0.15;
								}
							}
						}
					}

					daNote.visible = false;
					daNote.kill();
					notes.remove(daNote, true);
				}
			});
		}

		if (FlxG.save.data.cpuStrums)
		{
			cpuStrums.forEach(function(spr:FlxSprite)
			{
				if (spr.animation.finished)
				{
					spr.animation.play('static');
					spr.centerOffsets();
				}
			});
			if (PlayStateChangeables.botPlay)
			{
				playerStrums.forEach(function(spr:FlxSprite)
				{
					if (spr.animation.finished)
					{
						spr.animation.play('static');
						spr.centerOffsets();
					}
				});
			}
		}

		if (!inCutscene && songStarted)
			keyShit();

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
	}

	function endSong():Void
	{
		camHUD.visible = false;

		endingSong = true;
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
		if (useVideo)
		{
			GlobalVideo.get().stop();
			FlxG.stage.window.onFocusOut.remove(focusOut);
			FlxG.stage.window.onFocusIn.remove(focusIn);
			PlayState.instance.remove(PlayState.instance.videoSprite);
		}

		if (isStoryMode)
			campaignMisses = misses;

		if (!loadRep)
			rep.SaveReplay(saveNotes, saveJudge, replayAna);
		else
		{
			PlayStateChangeables.botPlay = false;
			PlayStateChangeables.scrollSpeed = 1;
			PlayStateChangeables.useDownscroll = false;
		}

		if (FlxG.save.data.fpsCap > 290)
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(290);

		#if cpp
		if (luaModchart != null)
		{
			luaModchart.die();
			luaModchart = null;
		}
		#end

		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		FlxG.sound.music.pause();
		vocals.pause();
		if (SONG.validScore)
		{
			// adjusting the highscore song name to be compatible
			// would read original scores if we didn't change packages
			var songHighscore = StringTools.replace(PlayState.SONG.song, " ", "-");

			#if !switch
			Highscore.saveScore(songHighscore, Math.round(songScore), storyDifficulty);
			Highscore.saveCombo(songHighscore, Ratings.GenerateLetterRank(accuracy), storyDifficulty);
			#end
		}

		if (offsetTesting)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			offsetTesting = false;
			PlayStateChangeables.nocheese = true;
			LoadingState.loadAndSwitchState(new OptionsMenu());
			clean();
			FlxG.save.data.offset = offsetTest;
		}
		else
		{
			if (isStoryMode || isList)
			{
				campaignScore += Math.round(songScore);
				campaignMisses += misses;
				campaignSicks += sicks;
				campaignGoods += goods;
				campaignBads += bads;
				campaignShits += shits;

				FlxG.log.add('removing ' + storyPlaylist[0]);
				storyPlaylist.remove(storyPlaylist[0]);
				FlxG.log.add('loading ' + storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					transIn = FlxTransitionableState.defaultTransIn;
					transOut = FlxTransitionableState.defaultTransOut;

					paused = true;

					FlxG.sound.music.stop();
					vocals.stop();
					// if (FlxG.save.data.scoreScreen)
					// {
					// 	openSubState(new ResultsScreen());
					// 	new FlxTimer().start(1, function(tmr:FlxTimer)
					// 	{
					// 		inResults = true;
					// 	});
					// }
					// else
					// {
					// 	FlxG.sound.playMusic(Paths.music('freakyMenu'));
					// 	Conductor.changeBPM(102);
					// 	FlxG.switchState(new StoryMenuState());
					// 	clean();
					// }

					isList = false;

					if (isStoryMode && curSong == 'triple-talent')
					{
						var video:MP4Handler = new MP4Handler();
						video.playMP4(Paths.video('soundtestcodes'));
						video.finishCallback = function()
						{
							LoadingState.loadAndSwitchState(new MainMenuState());
						}
					}
					else
						FlxG.switchState(new MainMenuState());

					#if cpp
					if (luaModchart != null)
					{
						luaModchart.die();
						luaModchart = null;
					}
					#end

					if (SONG.validScore)
					{
						NGio.unlockMedal(60961);
						Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
					}

					FlxG.save.flush();
				}
				else
				{
					// adjusting the song name to be compatible
					var songFormat = StringTools.replace(PlayState.storyPlaylist[0], " ", "-");

					var poop:String = Highscore.formatSong(songFormat, storyDifficulty);

					trace('LOADING NEXT SONG');
					trace(poop);

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					prevCamFollow = camFollow;

					PlayState.SONG = Song.loadFromJson(poop, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					if (isStoryMode && curSong.toLowerCase() == 'too-seiso' && storyDifficulty >= 2)
					{
						if (FlxG.save.data.storyProgress < 1)
							FlxG.save.data.storyProgress = 1;
						var video:MP4Handler = new MP4Handler();
						video.playMP4(Paths.video('tooslowcutscene2'));
						video.finishCallback = function()
						{
							LoadingState.loadAndSwitchState(new PlayState());
						}
					}
					else if (isStoryMode && curSong.toLowerCase() == 'too-seiso' && storyDifficulty < 2)
					{
						LoadingState.loadAndSwitchState(new UnlockScreen(false, 'soundtest'));
					}
					else if (isStoryMode && curSong == 'you-cant-kusa')
					{
						if (FlxG.save.data.storyProgress < 2)
							FlxG.save.data.storyProgress = 2;
						FlxG.save.data.soundTestUnlocked = true;
						var video:MP4Handler = new MP4Handler();
						video.playMP4(Paths.video('youcantruncutscene2'));
						video.finishCallback = function()
						{
							LoadingState.loadAndSwitchState(new PlayState());
						}
					}
					else
						LoadingState.loadAndSwitchState(new PlayState());

					if (curSong == 'parent')
						if (!FlxG.save.data.songArray.contains('white-moon') && !FlxG.save.data.botplay)
							FlxG.save.data.songArray.push('white-moon');
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');

				paused = true;

				FlxG.sound.music.stop();
				vocals.stop();

				PlayStateChangeables.nocheese = true;
				switch (curSong)
				{
					default:
						if (!isFreeplay)
							FlxG.switchState(new SoundTestMenu());
						else
						{
							isFreeplay = false;
							FlxG.switchState(new FreeplayState());
						}
					case "asacoco":
						if (!isFreeplay)
							FlxG.switchState(new MainMenuState());
						else
						{
							isFreeplay = false;
							FlxG.switchState(new FreeplayState());
						}
					case 'too-seiso':
						if (isStoryMode)
						{
							var video:MP4Handler = new MP4Handler();
							video.playMP4(Paths.video('tooslowcutscene2'));
							video.finishCallback = function()
							{
								LoadingState.loadAndSwitchState(new MainMenuState());
							}
						}
						else
						{
							isFreeplay = false;
							FlxG.switchState(new FreeplayState());
						}
					case 'you-cant-kusa':
						if (isStoryMode)
						{
							var video:MP4Handler = new MP4Handler();
							video.playMP4(Paths.video('youcantruncutscene2'));
							video.finishCallback = function()
							{
								LoadingState.loadAndSwitchState(new MainMenuState());
							}
						}
						else
						{
							isFreeplay = false;
							FlxG.switchState(new FreeplayState());
						}
					case 'triple-talent':
						if (isStoryMode)
						{
							var video:MP4Handler = new MP4Handler();
							video.playMP4(Paths.video('soundtestcodes'));
							video.finishCallback = function()
							{
								LoadingState.loadAndSwitchState(new MainMenuState());
							}
						}
						else
						{
							isFreeplay = false;
							FlxG.switchState(new FreeplayState());
						}
				}
			}
		}
	}

	var endingSong:Bool = false;

	var hits:Array<Float> = [];
	var offsetTest:Float = 0;

	var timeShown = 0;
	var currentTimingShown:FlxText = null;

	private function popUpScore(daNote:Note):Void
	{
		var noteDiff:Float = -(daNote.strumTime - Conductor.songPosition);
		var wife:Float = EtternaFunctions.wife3(-noteDiff, Conductor.timeScale);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;
		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		coolText.y -= 350;
		coolText.cameras = [camHUD];
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Float = 350;

		if (FlxG.save.data.accuracyMod == 1)
			totalNotesHit += wife;

		var daRating = daNote.rating;

		switch (daRating)
		{
			case 'shit':
				if (daNote.noteType == 2)
				{
					if (curSong != 'white-moon')
						health -= 0.2;
				}
				if (daNote.noteType == 1 || daNote.noteType == 0)
				{
					score = -300;
					combo = 0;
					misses++;
					if (curSong != 'white-moon')
						health -= 0.2;
					ss = false;
					shits++;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 0.25;
				}
			case 'bad':
				if (daNote.noteType == 2)
				{
					if (curSong != 'white-moon')
						health -= 0.06;
				}
				if (daNote.noteType == 1 || daNote.noteType == 0)
				{
					daRating = 'bad';
					score = 0;
					if (curSong != 'white-moon')
						health -= 0.06;
					ss = false;
					bads++;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 0.50;
				}
			case 'good':
				if (daNote.noteType == 2)
				{
					daRating = 'good';
					score = 200;
					ss = false;
					goods++;
					if (health < 2 && curSong != 'white-moon')
						health += 0.04;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 0.75;
				}
				if (daNote.noteType == 1 || daNote.noteType == 0)
				{
					daRating = 'good';
					score = 200;
					ss = false;
					goods++;
					if (health < 2 && curSong != 'white-moon')
						health += 0.04;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 0.75;
				}
			case 'sick':
				if (daNote.noteType == 2)
				{
					if (health < 2 && curSong != 'white-moon')
						health += 0.1;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 1;
					sicks++;
				}
				if (daNote.noteType == 1 || daNote.noteType == 0)
				{
					if (health < 2 && curSong != 'white-moon')
						health += 0.1;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 1;
					sicks++;
				}
				playerSplashes.forEach(function(spr:FlxSprite)
				{
					if (spr.ID == daNote.noteData && FlxG.save.data.splashing)
						spr.animation.play('a', true);
				});
		}

		// trace('Wife accuracy loss: ' + wife + ' | Rating: ' + daRating + ' | Score: ' + score + ' | Weight: ' + (1 - wife));

		if (daRating != 'shit' || daRating != 'bad')
		{
			songScore += Math.round(score);
			songScoreDef += Math.round(ConvertScore.convertScore(noteDiff));

			/* if (combo > 60)
					daRating = 'sick';
				else if (combo > 12)
					daRating = 'good'
				else if (combo > 4)
					daRating = 'bad';
			 */

			var pixelShitPart1:String = "";
			var pixelShitPart2:String = '';

			if (curStage.startsWith('school'))
			{
				pixelShitPart1 = 'weeb/pixelUI/';
				pixelShitPart2 = '-pixel';
			}

			rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
			rating.screenCenter();
			rating.y -= 50;
			rating.x = coolText.x - 125;

			if (FlxG.save.data.changedHit)
			{
				rating.x = FlxG.save.data.changedHitX;
				rating.y = FlxG.save.data.changedHitY;
			}
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);

			var msTiming = HelperFunctions.truncateFloat(noteDiff, 3);
			if (PlayStateChangeables.botPlay && !loadRep)
				msTiming = 0;

			if (loadRep)
				msTiming = HelperFunctions.truncateFloat(findByTime(daNote.strumTime)[3], 3);

			if (currentTimingShown != null)
				remove(currentTimingShown);

			currentTimingShown = new FlxText(0, 0, 0, "0ms");
			timeShown = 0;
			switch (daRating)
			{
				case 'shit' | 'bad':
					currentTimingShown.color = FlxColor.RED;
				case 'good':
					currentTimingShown.color = FlxColor.GREEN;
				case 'sick':
					currentTimingShown.color = FlxColor.CYAN;
			}
			currentTimingShown.borderStyle = OUTLINE;
			currentTimingShown.borderSize = 1;
			currentTimingShown.borderColor = FlxColor.BLACK;
			currentTimingShown.text = msTiming + "ms";
			currentTimingShown.size = 20;

			if (msTiming >= 0.03 && offsetTesting)
			{
				// Remove Outliers
				hits.shift();
				hits.shift();
				hits.shift();
				hits.pop();
				hits.pop();
				hits.pop();
				hits.push(msTiming);

				var total = 0.0;

				for (i in hits)
					total += i;

				offsetTest = HelperFunctions.truncateFloat(total / hits.length, 2);
			}

			if (currentTimingShown.alpha != 1)
				currentTimingShown.alpha = 1;

			if (!PlayStateChangeables.botPlay || loadRep)
				add(currentTimingShown);

			var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
			comboSpr.screenCenter();
			comboSpr.x = rating.x;
			comboSpr.y = rating.y + 100;
			comboSpr.acceleration.y = 600;
			comboSpr.velocity.y -= 150;

			currentTimingShown.screenCenter();
			currentTimingShown.x = comboSpr.x + 100;
			currentTimingShown.y = rating.y + 100;
			currentTimingShown.acceleration.y = 600;
			currentTimingShown.velocity.y -= 150;

			comboSpr.velocity.x += FlxG.random.int(1, 10);
			currentTimingShown.velocity.x += comboSpr.velocity.x;
			if (!PlayStateChangeables.botPlay || loadRep)
				add(rating);

			if (!curStage.startsWith('school'))
			{
				rating.setGraphicSize(Std.int(rating.width * 0.7));
				rating.antialiasing = FlxG.save.data.antialiasing;
				comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
				comboSpr.antialiasing = FlxG.save.data.antialiasing;
			}
			else
			{
				rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
				comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
			}

			currentTimingShown.updateHitbox();
			comboSpr.updateHitbox();
			rating.updateHitbox();

			currentTimingShown.cameras = [camHUD];
			comboSpr.cameras = [camHUD];
			rating.cameras = [camHUD];

			var seperatedScore:Array<Int> = [];

			var comboSplit:Array<String> = (combo + "").split('');

			if (combo > highestCombo)
				highestCombo = combo;

			// make sure we have 3 digits to display (looks weird otherwise lol)
			if (comboSplit.length == 1)
			{
				seperatedScore.push(0);
				seperatedScore.push(0);
			}
			else if (comboSplit.length == 2)
				seperatedScore.push(0);

			for (i in 0...comboSplit.length)
			{
				var str:String = comboSplit[i];
				seperatedScore.push(Std.parseInt(str));
			}

			var daLoop:Int = 0;
			for (i in seperatedScore)
			{
				var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
				numScore.screenCenter();
				numScore.x = rating.x + (43 * daLoop) - 50;
				numScore.y = rating.y + 100;
				numScore.cameras = [camHUD];

				if (!curStage.startsWith('school'))
				{
					numScore.antialiasing = FlxG.save.data.antialiasing;
					numScore.setGraphicSize(Std.int(numScore.width * 0.5));
				}
				else
				{
					numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
				}
				numScore.updateHitbox();

				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);

				add(numScore);

				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						numScore.destroy();
					},
					startDelay: Conductor.crochet * 0.002
				});

				daLoop++;
			}
			/* 
				trace(combo);
				trace(seperatedScore);
			 */

			coolText.text = Std.string(seperatedScore);
			// add(coolText);

			FlxTween.tween(rating, {alpha: 0}, 0.2, {
				startDelay: Conductor.crochet * 0.001,
				onUpdate: function(tween:FlxTween)
				{
					if (currentTimingShown != null)
						currentTimingShown.alpha -= 0.02;
					timeShown++;
				}
			});

			FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					coolText.destroy();
					comboSpr.destroy();
					if (currentTimingShown != null && timeShown >= 20)
					{
						remove(currentTimingShown);
						currentTimingShown = null;
					}
					rating.destroy();
				},
				startDelay: Conductor.crochet * 0.001
			});

			curSection += 1;
		}
	}

	public function NearlyEquals(value1:Float, value2:Float, unimportantDifference:Float = 10):Bool
	{
		return Math.abs(FlxMath.roundDecimal(value1, 1) - FlxMath.roundDecimal(value2, 1)) < unimportantDifference;
	}

	var upHold:Bool = false;
	var downHold:Bool = false;
	var spaceHold:Bool = false;
	var rightHold:Bool = false;
	var leftHold:Bool = false;

	// THIS FUNCTION JUST FUCKS WIT HELD NOTES AND BOTPLAY/REPLAY (also gamepad shit)

	private function keyShit():Void // I've invested in emma stocks
	{
		// control arrays, order L D R U
		var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
		var pressArray:Array<Bool> = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];
		var releaseArray:Array<Bool> = [controls.LEFT_R, controls.DOWN_R, controls.UP_R, controls.RIGHT_R];
		var keynameArray:Array<String> = ['left', 'down', 'up', 'right'];
		if (isRing)
		{
			holdArray = [controls.LEFT, controls.DOWN, controls.SPACEB, controls.UP, controls.RIGHT];
			pressArray = [
				controls.LEFT_P,
				controls.DOWN_P,
				controls.SPACE_P,
				controls.UP_P,
				controls.RIGHT_P
			];
			releaseArray = [
				controls.LEFT_R,
				controls.DOWN_R,
				controls.SPACE_R,
				controls.UP_R,
				controls.RIGHT_R
			];
			keynameArray = ['left', 'down', 'space', 'up', 'right'];
		}

		#if cpp
		if (luaModchart != null)
		{
			for (i in 0...pressArray.length)
			{
				if (pressArray[i] == true)
				{
					luaModchart.executeState('keyPressed', [keynameArray[i]]);
				}
			};

			for (i in 0...releaseArray.length)
			{
				if (releaseArray[i] == true)
				{
					luaModchart.executeState('keyReleased', [keynameArray[i]]);
				}
			};
		};
		#end

		// Prevent player input if botplay is on
		if (PlayStateChangeables.botPlay)
		{
			holdArray = [false, false, false, false];
			pressArray = [false, false, false, false];
			releaseArray = [false, false, false, false];
			if (isRing)
			{
				holdArray = [false, false, false, false, false];
				pressArray = [false, false, false, false, false];
				releaseArray = [false, false, false, false, false];
			}
		}

		var anas:Array<Ana> = [null, null, null, null];
		if (isRing)
		{
			anas = [null, null, null, null, null];
		}

		for (i in 0...pressArray.length)
			if (pressArray[i])
				anas[i] = new Ana(Conductor.songPosition, null, false, "miss", i);

		// HOLDS, check for sustain notes
		if (holdArray.contains(true) && /*!boyfriend.stunned && */ generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData] && daNote.sustainActive)
				{
					trace(daNote.sustainActive);
					goodNoteHit(daNote);
				}
			});
		}

		if (KeyBinds.gamepad && !FlxG.keys.justPressed.ANY)
		{
			// PRESSES, check for note hits
			if (pressArray.contains(true) && generatedMusic)
			{
				boyfriend.holdTimer = 0;

				var possibleNotes:Array<Note> = []; // notes that can be hit
				var directionList:Array<Int> = []; // directions that can be hit
				var dumbNotes:Array<Note> = []; // notes to kill later
				var directionsAccounted:Array<Bool> = [false, false, false, false]; // we don't want to do judgments for more than one presses
				if (isRing)
					directionsAccounted = [false, false, false, false, false];

				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !directionsAccounted[daNote.noteData])
					{
						if (directionList.contains(daNote.noteData))
						{
							directionsAccounted[daNote.noteData] = true;
							for (coolNote in possibleNotes)
							{
								if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
								{ // if it's the same note twice at < 10ms distance, just delete it
									// EXCEPT u cant delete it in this loop cuz it fucks with the collection lol
									dumbNotes.push(daNote);
									break;
								}
								else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
								{ // if daNote is earlier than existing note (coolNote), replace
									possibleNotes.remove(coolNote);
									possibleNotes.push(daNote);
									break;
								}
							}
						}
						else
						{
							directionsAccounted[daNote.noteData] = true;
							possibleNotes.push(daNote);
							directionList.push(daNote.noteData);
						}
					}
				});

				for (note in dumbNotes)
				{
					FlxG.log.add("killing dumb ass note at " + note.strumTime);
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}

				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				var hit = [false, false, false, false];
				if (isRing)
				{
					hit = [false, false, false, false, false];
				}

				if (perfectMode)
					goodNoteHit(possibleNotes[0]);
				else if (possibleNotes.length > 0)
				{
					if (!FlxG.save.data.ghost)
					{
						for (shit in 0...pressArray.length)
						{ // if a direction is hit that shouldn't be
							if (pressArray[shit] && !directionList.contains(shit))
								noteMiss(shit, null);
						}
					}
					for (coolNote in possibleNotes)
					{
						if (pressArray[coolNote.noteData] && !hit[coolNote.noteData])
						{
							if (mashViolations != 0)
								mashViolations--;
							hit[coolNote.noteData] = true;
							scoreTxt.color = FlxColor.WHITE;
							var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
							anas[coolNote.noteData].hit = true;
							anas[coolNote.noteData].hitJudge = Ratings.CalculateRating(noteDiff, Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));
							anas[coolNote.noteData].nearestNote = [coolNote.strumTime, coolNote.noteData, coolNote.sustainLength];
							goodNoteHit(coolNote);
						}
					}
				}
				else if (!FlxG.save.data.ghost)
				{
					for (shit in 0...pressArray.length)
						if (pressArray[shit])
							noteMiss(shit, null);
				}

				if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || PlayStateChangeables.botPlay))
				{
					if (boyfriend.animation.curAnim.name.startsWith('sing')
						&& !boyfriend.animation.curAnim.name.endsWith('miss')
						&& (boyfriend.animation.curAnim.curFrame >= 10 || boyfriend.animation.curAnim.finished))
						boyfriend.playAnim('idle');
				}
				else if (!FlxG.save.data.ghost)
				{
					for (shit in 0...pressArray.length)
						if (pressArray[shit])
							noteMiss(shit, null);
				}
			}

			if (!loadRep)
				for (i in anas)
					if (i != null)
						replayAna.anaArray.push(i); // put em all there
		}
		if (PlayStateChangeables.botPlay)
			notes.forEachAlive(function(daNote:Note)
			{
				var diff = -(daNote.strumTime - Conductor.songPosition);

				daNote.rating = Ratings.CalculateRating(diff, Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));
				if (daNote.mustPress && daNote.rating == "sick" || (diff > 0 && daNote.mustPress))
				{
					// Force good note hit regardless if it's too late to hit it or not as a fail safe
					if (loadRep)
					{
						// trace('ReplayNote ' + tmpRepNote.strumtime + ' | ' + tmpRepNote.direction);
						var n = findByTime(daNote.strumTime);
						trace(n);
						if (n != null && daNote.noteType != 3)
						{
							goodNoteHit(daNote);
							boyfriend.holdTimer = daNote.sustainLength;
							if (FlxG.save.data.cpuStrums)
							{
								playerStrums.forEach(function(spr:FlxSprite)
								{
									if (Math.abs(daNote.noteData) == spr.ID)
									{
										spr.animation.play('confirm', true);
									}
									if (spr.animation.curAnim.name == 'confirm' && SONG.noteStyle != 'pixel')
									{
										spr.centerOffsets();
										spr.offset.x -= 13;
										spr.offset.y -= 13;
									}
									else
										spr.centerOffsets();
								});
							}
						}
					}
					else if (daNote.noteType != 3)
					{
						goodNoteHit(daNote);
						boyfriend.holdTimer = daNote.sustainLength;
						if (FlxG.save.data.cpuStrums)
						{
							playerStrums.forEach(function(spr:FlxSprite)
							{
								if (Math.abs(daNote.noteData) == spr.ID)
								{
									spr.animation.play('confirm', true);
								}
								if (spr.animation.curAnim.name == 'confirm' && SONG.noteStyle != 'pixel')
								{
									spr.centerOffsets();
									spr.offset.x -= 13;
									spr.offset.y -= 13;
								}
								else
									spr.centerOffsets();
							});
						}
					}
				}
			});

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || PlayStateChangeables.botPlay))
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing')
				&& !boyfriend.animation.curAnim.name.endsWith('miss')
				&& (boyfriend.animation.curAnim.curFrame >= 10 || boyfriend.animation.curAnim.finished))
				boyfriend.playAnim('idle');
		}

		if (!PlayStateChangeables.botPlay)
		{
			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (keys[spr.ID] && spr.animation.curAnim.name != 'confirm' && spr.animation.curAnim.name != 'pressed')
					spr.animation.play('pressed', false);
				if (!keys[spr.ID])
					spr.animation.play('static', false);

				if (spr.animation.curAnim.name == 'confirm' && SONG.noteStyle != 'pixel')
				{
					spr.centerOffsets();
					spr.offset.x -= 13;
					spr.offset.y -= 13;
				}
				else
					spr.centerOffsets();
			});
		}
	}

	public function findByTime(time:Float):Array<Dynamic>
	{
		for (i in rep.replay.songNotes)
		{
			// trace('checking ' + Math.round(i[0]) + ' against ' + Math.round(time));
			if (i[0] == time)
				return i;
		}
		return null;
	}

	public function findByTimeIndex(time:Float):Int
	{
		for (i in 0...rep.replay.songNotes.length)
		{
			// trace('checking ' + Math.round(i[0]) + ' against ' + Math.round(time));
			if (rep.replay.songNotes[i][0] == time)
				return i;
		}
		return -1;
	}

	public var fuckingVolume:Float = 1;
	public var useVideo = false;

	public static var webmHandler:WebmHandler;

	public var playingDathing = false;

	public var videoSprite:FlxSprite;

	public function focusOut()
	{
		if (paused)
			return;
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.pause();
			vocals.pause();
		}

		openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
	}

	public function focusIn()
	{
		// nada
	}

	public function backgroundVideo(source:String) // for background videos
	{
		#if cpp
		useVideo = true;

		FlxG.stage.window.onFocusOut.add(focusOut);
		FlxG.stage.window.onFocusIn.add(focusIn);

		var ourSource:String = "assets/videos/daWeirdVid/dontDelete.webm";
		// WebmPlayer.SKIP_STEP_LIMIT = 90;
		var str1:String = "WEBM SHIT";
		webmHandler = new WebmHandler();
		webmHandler.source(ourSource);
		webmHandler.makePlayer();
		webmHandler.webm.name = str1;

		GlobalVideo.setWebm(webmHandler);

		GlobalVideo.get().source(source);
		GlobalVideo.get().clearPause();
		if (GlobalVideo.isWebm)
		{
			GlobalVideo.get().updatePlayer();
		}
		GlobalVideo.get().show();

		if (GlobalVideo.isWebm)
		{
			GlobalVideo.get().restart();
		}
		else
		{
			GlobalVideo.get().play();
		}

		var data = webmHandler.webm.bitmapData;

		videoSprite = new FlxSprite(-470, -30).loadGraphic(data);

		videoSprite.setGraphicSize(Std.int(videoSprite.width * 1.2));

		remove(gf);
		remove(boyfriend);
		remove(dad);
		add(videoSprite);
		add(gf);
		add(boyfriend);
		add(dad);

		trace('poggers');

		if (!songStarted)
			webmHandler.pause();
		else
			webmHandler.resume();
		#end
	}

	function noteMiss(direction:Int = 1, daNote:Note):Void
	{
		if (daNote.noteType != 3)
		{
			if (!boyfriend.stunned)
			{
				if (curSong != 'white-moon' && cNum == 0)
				{
					health -= 0.04;
				}
				else
					cNum -= 1;
				if (combo > 5 && gf.animOffsets.exists('sad'))
				{
					gf.playAnim('sad');
				}
				combo = 0;
				misses++;

				if (daNote != null)
				{
					if (!loadRep)
					{
						saveNotes.push([
							daNote.strumTime,
							0,
							direction,
							166 * Math.floor((PlayState.rep.replay.sf / 60) * 1000) / 166
						]);
						saveJudge.push("miss");
					}
				}
				else if (!loadRep)
				{
					saveNotes.push([
						Conductor.songPosition,
						0,
						direction,
						166 * Math.floor((PlayState.rep.replay.sf / 60) * 1000) / 166
					]);
					saveJudge.push("miss");
				}

				// var noteDiff:Float = Math.abs(daNote.strumTime - Conductor.songPosition);
				// var wife:Float = EtternaFunctions.wife3(noteDiff, FlxG.save.data.etternaMode ? 1 : 1.7);

				if (FlxG.save.data.accuracyMod == 1)
					totalNotesHit -= 1;

				songScore -= 10;

				FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
				// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
				// FlxG.log.add('played imss note');

				if (isRing)
				{
					switch (direction)
					{
						case 0:
							boyfriend.playAnim('singLEFTmiss', true);
						case 1:
							boyfriend.playAnim('singDOWNmiss', true);
						case 3:
							boyfriend.playAnim('singUPmiss', true);
						case 4:
							boyfriend.playAnim('singRIGHTmiss', true);
					}
				}
				else
				{
					switch (direction)
					{
						case 0:
							boyfriend.playAnim('singLEFTmiss', true);
						case 1:
							boyfriend.playAnim('singDOWNmiss', true);
						case 2:
							boyfriend.playAnim('singUPmiss', true);
						case 3:
							boyfriend.playAnim('singRIGHTmiss', true);
					}
				}

				#if windows
				if (luaModchart != null)
					luaModchart.executeState('playerOneMiss', [direction, Conductor.songPosition]);
				#end

				updateAccuracy();
			}
		}
	}

	/*function badNoteCheck()
		{
			// just double pasting this shit cuz fuk u
			// REDO THIS SYSTEM!
			var upP = controls.UP_P;
			var rightP = controls.RIGHT_P;
			var downP = controls.DOWN_P;
			var leftP = controls.LEFT_P;

			if (leftP)
				noteMiss(0);
			if (upP)
				noteMiss(2);
			if (rightP)
				noteMiss(3);
			if (downP)
				noteMiss(1);
			updateAccuracy();
		}
	 */
	function updateAccuracy()
	{
		totalPlayed += 1;
		accuracy = Math.max(0, totalNotesHit / totalPlayed * 100);
		accuracyDefault = Math.max(0, totalNotesHitDefault / totalPlayed * 100);
	}

	function getKeyPresses(note:Note):Int
	{
		var possibleNotes:Array<Note> = []; // copypasted but you already know that

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
			{
				possibleNotes.push(daNote);
				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
			}
		});
		if (possibleNotes.length == 1)
			return possibleNotes.length + 1;
		return possibleNotes.length;
	}

	var mashing:Int = 0;
	var mashViolations:Int = 0;
	var etternaModeScore:Int = 0;

	function noteCheck(controlArray:Array<Bool>, note:Note):Void // sorry lol
	{
		var noteDiff:Float = -(note.strumTime - Conductor.songPosition);

		note.rating = Ratings.CalculateRating(noteDiff, Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));

		/* if (loadRep)
			{
				if (controlArray[note.noteData])
					goodNoteHit(note, false);
				else if (rep.replay.keyPresses.length > repPresses && !controlArray[note.noteData])
				{
					if (NearlyEquals(note.strumTime,rep.replay.keyPresses[repPresses].time, 4))
					{
						goodNoteHit(note, false);
					}
				}
		}*/

		if (controlArray[note.noteData])
		{
			goodNoteHit(note, (mashing > getKeyPresses(note)));

			/*if (mashing > getKeyPresses(note) && mashViolations <= 2)
				{
					mashViolations++;

					goodNoteHit(note, (mashing > getKeyPresses(note)));
				}
				else if (mashViolations > 2)
				{
					// this is bad but fuck you
					playerStrums.members[0].animation.play('static');
					playerStrums.members[1].animation.play('static');
					playerStrums.members[2].animation.play('static');
					playerStrums.members[3].animation.play('static');
					health -= 0.4;
					trace('mash ' + mashing);
					if (mashing != 0)
						mashing = 0;
				}
				else
					goodNoteHit(note, false); */
		}
	}

	function goodNoteHit(note:Note, resetMashViolation = true):Void
	{
		var colorArray = isRing ? dataColor5k : dataColor;
		var suffixArray = isRing ? dataSuffix5k : dataSuffix;

		if (isRing && note.noteData == 2 && !note.isSustainNote)
		{
			FlxG.sound.play(Paths.sound('Ring', 'exe'));
			cNum += 1;
		}

		if (note.noteType == 3)
		{
			var fuckyou:Int = 0;
			heatlhDrop += 0.00025;
			if (heatlhDrop == 0.00025)
			{
				new FlxTimer().start(0.1, function(sex:FlxTimer)
				{
					fuckyou += 1;

					if (fuckyou >= 100)
						heatlhDrop = 0;

					if (!paused && fuckyou < 100)
						sex.reset();
				});
			}
			else
				fuckyou = 0;
		}
		if (mashing != 0)
			mashing = 0;

		var noteDiff:Float = -(note.strumTime - Conductor.songPosition);

		if (loadRep)
		{
			noteDiff = findByTime(note.strumTime)[3];
			note.rating = rep.replay.songJudgements[findByTimeIndex(note.strumTime)];
		}
		else
			note.rating = Ratings.CalculateRating(noteDiff);

		if (note.rating == "miss")
			return;

		// add newest note to front of notesHitArray
		// the oldest notes are at the end and are removed first
		if (!note.isSustainNote)
			notesHitArray.unshift(Date.now());

		if (!resetMashViolation && mashViolations >= 1)
			mashViolations--;

		if (mashViolations < 0)
			mashViolations = 0;

		if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
				if (isRing && note.noteData != 2 && note.noteType != 3)
				{
					if (popup)
						popUpScore(note);
					combo += 1;
				}
				else if (!isRing && note.noteType != 3)
				{
					if (popup)
						popUpScore(note);
					combo += 1;
				}
			}
			else
				totalNotesHit += 1;

			var altAnim:String = "";
			if (note.isAlt)
			{
				altAnim = '-alt';
				trace("Alt note on BF");
			}

			if (!isRing || (isRing && note.noteData != 2))
				boyfriend.playAnim('sing' + suffixArray[note.noteData] + altAnim, true);

			#if cpp
			if (luaModchart != null)
				luaModchart.executeState('playerOneSing', [note.noteData, Conductor.songPosition]);
			#end

			if (!loadRep && note.mustPress)
			{
				var array = [note.strumTime, note.sustainLength, note.noteData, noteDiff];
				if (note.isSustainNote)
					array[1] = -1;
				saveNotes.push(array);
				saveJudge.push(note.rating);
			}

			if (!PlayStateChangeables.botPlay)
			{
				playerStrums.forEach(function(spr:FlxSprite)
				{
					if (Math.abs(note.noteData) == spr.ID)
					{
						spr.animation.play('confirm', true);
					}
				});
			}

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
			else
			{
				note.wasGoodHit = true;
			}

			updateAccuracy();
		}
	}

	var danced:Bool = false;
	var stepOfLast = 0;

	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();

		if (dad.curCharacter == 'suisei' && songLowercase == 'too-seiso')
		{
			switch (curStep)
			{
				case 765:
					shakeCam = true;
					FlxG.camera.flash(FlxColor.RED, 4);
				case 1305:
					cameramove = false;
					FlxTween.tween(camHUD, {alpha: 0}, 0.3);
					FlxTween.tween(camNotes, {alpha: 0}, 0.3);
					if (dad.curCharacter == 'suisei')
						dad.playAnim('iamgod', true);
					dad.nonanimated = true;
				case 1362:
					FlxG.camera.shake(0.002, 0.6);
					camHUD.camera.shake(0.002, 0.6);
				case 1432:
					cameramove = FlxG.save.data.cammove;
					FlxTween.tween(camHUD, {alpha: 1}, 0.3);
					FlxTween.tween(camNotes, {alpha: 1}, 0.3);
					dad.nonanimated = false;
			}
		}

		if (dad.curCharacter == 'sonicfun' && songLowercase == 'circus')
		{
			switch (curStep)
			{
				case 10:
					FlxG.sound.play(Paths.sound('laugh1', 'shared'), 0.7);
			}
			if (spinArray.contains(curStep))
			{
				strumLineNotes.forEach(function(tospin:FlxSprite)
				{
					FlxTween.angle(tospin, 0, 360, 0.2, {ease: FlxEase.quintOut});
				});
			}
		}

		if (dad.curCharacter == 'suisei' && songLowercase == 'too-seiso' && curStep == 791)
		{
			shakeCam = false;
			shakeCam2 = false;
		}

		if (curStage == 'sonicFUNSTAGE' && curStep != stepOfLast)
		{
			switch (curStep)
			{
				case 888:
					camLocked = false;
					camFollow.setPosition(GameDimensions.width / 2 + 50, GameDimensions.height / 4 * 3 + 280);
					FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.3}, 0.7, {ease: FlxEase.cubeInOut});
					three();
				case 891:
					FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.3}, 0.7, {ease: FlxEase.cubeInOut});
					two();
				case 896:
					FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.3}, 0.7, {ease: FlxEase.cubeInOut});
					one();
				case 899:
					camLocked = true;
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.7, {ease: FlxEase.cubeInOut});
					gofun();
					SONG.noteStyle = 'majinNOTES';
					removeStatics();
					generateStaticArrows(0, false);
					generateStaticArrows(1, false);
			}
		}

		if (curStage == 'SONICstage' && curStep != stepOfLast && FlxG.save.data.jumpscares)
		{
			var staticSteps:Array<Int> = [
				27, 130, 265, 450, 645, 800, 855, 889, 921, 938, 981, 1030, 1065, 1105, 1123, 1245, 1345, 1432, 1454, 1495, 1521, 1558, 1578, 1599, 1618,
				1647, 1657, 1692, 1713, 1738, 1747, 1761, 1785, 1806, 1816, 1832, 1849, 1868, 1887, 1909
			];

			for (i in staticSteps)
			{
				if (curStep == i)
					doStaticSign(0);
			}

			// SUBTRACTED EVERY EVERY BY 20
			switch (curStep)
			{
				case 921:
					doSimpleJump();
				case 1178:
					doSimpleJump();
				case 1337:
					doSimpleJump();
				case 1723:
					doJumpscare();
			}
			stepOfLast = curStep;
		}

		if (curSong == 'ankimo')
		{
			switch (curStep)
			{
				case 320:
					FlxTween.tween(FlxG.camera, {zoom: .9}, 2, {ease: FlxEase.cubeOut});
					defaultCamZoom = .9;
				case 1103:
					FlxTween.tween(FlxG.camera, {zoom: .8}, 2, {ease: FlxEase.cubeOut});
					defaultCamZoom = .8;
			}
		}

		if (curSong == 'you-cant-kusa')
		{
			var vg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('RedVG', 'exe'));
			vg.alpha = 0;
			vg.cameras = [camHUD];
			add(vg);

			var amongus:Bool = true;

			switch (curStep) // haha laugh funny
			{
				case 128, 328, 1288:
					dad.playAnim('laugh', true);
					dad.nonanimated = true;
				case 130, 132, 134, 136, 138, 140, 330, 332, 334, 1290, 1292, 1294:
					dad.nonanimated = false;
					dad.playAnim('laugh', true);
					dad.nonanimated = true;
				case 142, 336, 1296:
					dad.nonanimated = false;
			}

			if (curStep == 528) // PIXEL MOMENT LAWLALWALAWL
			{
				healthBar.createFilledBar(FlxColor.fromRGB(0, 128, 7), FlxColor.fromRGB(49, 176, 209));

				doStaticSign(0, false);
				SONG.noteStyle = 'pixel';
				removeStatics();
				generateStaticArrows(0, false);
				generateStaticArrows(1, false);

				remove(dad);
				dad = new Character(100, 100 + 300 - 50, 'sonic.exe alt');
				add(dad);

				iconP2.changeIcon('sonic.exe alt');

				remove(gf);
				gf = new Character(400, 130, 'gf-pixel');
				add(gf);

				remove(boyfriend);
				boyfriend = new Boyfriend(770, 450, 'bf-pixel');
				boyfriend.setPosition(530 + 100, 170 + 200);
				add(boyfriend);

				iconP1.changeIcon('bf-pixel');

				bgspec.visible = true;
			}
			else if (curStep == 784) // BACK TO NORMAL MF!!!
			{
				healthBar.createFilledBar(FlxColor.fromRGB(0, 19, 102), FlxColor.fromRGB(49, 176, 209));

				doStaticSign(0, false);
				SONG.noteStyle = 'normal';
				removeStatics();
				generateStaticArrows(0, false);
				generateStaticArrows(1, false);

				remove(dad);
				dad = new Character(116 - 20, 107, 'sonic.exe');
				add(dad);

				iconP2.changeIcon('sonic.exe');

				dad.y -= 125;
				dad.scrollFactor.set(1.37, 1);

				remove(gf);
				gf = new Character(635.5 - 50 - 100, 265.1 - 250, 'gf');
				add(gf);

				remove(boyfriend);
				boyfriend = new Boyfriend(1036 - 100, 300, 'bf');
				add(boyfriend);

				iconP1.changeIcon('bf');

				dad.scrollFactor.set(1.3, 1);
				boyfriend.scrollFactor.set(1.3, 1);
				gf.scrollFactor.set(1.25, 1);

				bgspec.visible = false;
			}
			else if (curStep == 521 && curStep == 1160)
			{
				camGame.shake(0.03, 1.5);
				camHUD.shake(0.05, 1);
			}
			else if (curStep == 80 || curStep == 785) // MaliciousBunny did this
			{
				new FlxTimer().start(.085, function(sex:FlxTimer)
				{
					if (curStep >= 528 && curStep <= 784)
						vg.visible = false;
					else
						vg.visible = true;

					if (!paused)
						vg.alpha += 0.1;
					if (vg.alpha < 1)
					{
						sex.reset();
					}
					if (vg.alpha == 1)
					{
						new FlxTimer().start(.085, function(sex2:FlxTimer)
						{
							if (!paused)
								vg.alpha -= 0.1;
							if (vg.alpha > 0)
							{
								sex2.reset();
							}
							if (vg.alpha == 0)
								sex.reset();
						});
					}
				});
			}
		}
		if (curSong == 'asacoco')
		{
			if (curStep == 538 || curStep == 2273)
			{
				var sponge:FlxSprite = new FlxSprite(dad.getGraphicMidpoint().x - 200,
					dad.getGraphicMidpoint().y - 120).loadGraphic(Paths.image('SpingeBinge', 'exe'));

				add(sponge);

				dad.visible = false;

				new FlxTimer().start(0.7, function(tmr:FlxTimer)
				{
					remove(sponge);
					dad.visible = true;
				});
			}
			if (curStep == 69) // holy fuck niceeee
			{
				FlxTween.tween(FlxG.camera, {zoom: 2.2}, 4);
			}
			if (curStep == 96) // holy fuck niceeee
			{
				FlxTween.cancelTweensOf(FlxG.camera);
				FlxG.camera.zoom = defaultCamZoom;
			}
		}
		if (curSong == 'sunshine')
		{
			if (curStep == 64)
				tailscircle = 'hovering';
			if (curStep == 128 || curStep == 319 || curStep == 866)
				tailscircle = 'circling';
			if (curStep == 256 || curStep == 575) // this is to return tails to it's original positions (me very smart B))
			{
				FlxTween.tween(dad, {x: -150, y: 330}, 0.2, {
					onComplete: function(twn:FlxTween)
					{
						dad.setPosition(-150, 330);
						tailscircle = 'hovering';
						floaty = 41.82;
					}
				});
			}
			if (curStep == 588) // kill me 588
			{
				playerStrums.forEach(function(spr:FlxSprite)
				{
					if (!FlxG.save.data.midscroll)
						spr.x -= 275;
				});
				popup = false;
				gf.visible = false;
				boyfriend.alpha = 0;
				bgspec.visible = false;
				kadeEngineWatermark.visible = false;
				healthBarBG.visible = false;
				healthBar.visible = false;
				botPlayState.visible = false;
				iconP1.visible = false;
				iconP2.visible = false;
				scoreTxt.visible = false;

				remove(dad);
				dad = new Character(-150, 330, 'TDollAlt');
				add(dad);
				cpuStrums.forEach(function(spr:FlxSprite)
				{
					spr.alpha = 0;
					spr.visible = false;
				});
				playerStrums.forEach(function(spr:FlxSprite)
				{
					spr.alpha = 0;
				});
				notes.forEachAlive(function(spr:Note)
				{
					spr.alpha = 0;
				});
			}
			if (curStep == 860) // kill me
			{
				playerStrums.forEach(function(spr:FlxSprite)
				{
					if (!FlxG.save.data.midscroll)
						spr.x += 275;
				});
				popup = true;
				gf.visible = true;
				boyfriend.alpha = 1;
				bgspec.visible = true;
				kadeEngineWatermark.visible = true;
				botPlayState.visible = true;
				healthBarBG.visible = true;
				healthBar.visible = true;
				iconP1.visible = true;
				iconP2.visible = true;
				scoreTxt.visible = true;
				remove(dad);
				dad = new Character(-150, 330, 'TDoll');
				add(dad);
				ezTrail = new FlxTrail(dad, null, 2, 5, 0.3, 0.04);
				tailscircle = '';
				cpuStrums.forEach(function(spr:FlxSprite)
				{
					if (!FlxG.save.data.midscroll)
					{
						spr.alpha = 1;
						spr.visible = true;
					}
				});
				playerStrums.forEach(function(spr:FlxSprite)
				{
					spr.alpha = 1;
				});
				notes.forEachAlive(function(spr:Note)
				{
					spr.alpha = 1;
				});
			}
			if (curStep == 1120)
			{
				FlxTween.tween(dad, {x: -150, y: 330}, 0.2, {
					onComplete: function(twn:FlxTween)
					{
						dad.setPosition(-150, 330);
						tailscircle = '';
						remove(ezTrail);
					}
				});
			}
		}

		if (curSong == 'parent')
		{
			switch (curStep)
			{
				case 787, 795, 902, 800, 811, 819, 823, 827, 832, 835, 839, 847, 847:
					doStaticSign(0, false);
					camX = -35;
				case 768:
					FlxTween.tween(camHUD, {alpha: 0}, 1);
					FlxTween.tween(camNotes, {alpha: 0}, 0.3);
				case 801: // 800
					fakertransform.frames = Paths.getSparrowAtlas('Faker_Transformation', 'exe');
					fakertransform.animation.addByPrefix('1', 'TransformationRIGHT');
					fakertransform.animation.addByPrefix('2', 'TransformationLEFT');
					fakertransform.animation.addByPrefix('3', 'TransformationUP');
					fakertransform.animation.addByPrefix('4', 'TransformationDOWN');
					fakertransform.animation.play('1', true);
					fakertransform.animation.play('2', true);
					fakertransform.animation.play('3', true);
					fakertransform.animation.play('4', true);
					fakertransform.alpha = 0;

					add(fakertransform);
					fakertransform.setPosition(dad.getGraphicMidpoint().x - 460, dad.getGraphicMidpoint().y - 700);
					fakertransform.x += 20;
					fakertransform.y += 128;
					fakertransform.alpha = 1;
					dad.visible = false;
					fakertransform.animation.play('1');
				case 824: // 824
					fakertransform.setPosition(dad.getGraphicMidpoint().x - 460, dad.getGraphicMidpoint().y - 700);
					fakertransform.x += -19;
					fakertransform.y += 138;
					fakertransform.animation.play('2');
				case 836: // 836
					fakertransform.setPosition(dad.getGraphicMidpoint().x - 460, dad.getGraphicMidpoint().y - 700);
					fakertransform.x += 76;
					fakertransform.y -= 110;
					fakertransform.animation.play('3');
				case 848: // 848
					fakertransform.setPosition(dad.getGraphicMidpoint().x - 460, dad.getGraphicMidpoint().y - 700);
					fakertransform.x += -110;
					fakertransform.y += 318;
					fakertransform.animation.play('4');
				case 884:
					remove(fakertransform);
					add(blackFuck);
					blackFuck.alpha = 1;
					blackFuck.visible = true;
			}
			if (curStep > 858 && curStep < 884)
				doStaticSign(0, false); // Honestly quite incredible
		}

		if (curSong == 'koyochaos')
		{
			if (curStep == 15)
			{
				dad.playAnim('fastanim', true);
				dad.nonanimated = true;
				FlxTween.tween(dad, {x: 61.15, y: -94.75}, 2, {ease: FlxEase.cubeOut});
			}
			else if (curStep == 9)
			{
				dad.visible = true;
				FlxTween.tween(dad, {y: dad.y - 500}, 0.5, {ease: FlxEase.cubeOut});
			}
			else if (curStep == 64)
			{
				dad.nonanimated = false;
				tailscircle = 'hovering';
				camHUD.visible = true;
				camHUD.alpha = 0;
				FlxTween.tween(camHUD, {alpha: 1}, 0.2, {ease: FlxEase.cubeOut});
			}
			switch (curStep)
			{
				case 256:
					laserThingy(true);

				case 399, 528, 656, 784, 1040, 1168, 1296, 1552, 1680, 1808, 1952:
					remove(dad);
					dad = new Character(61.15, -94.75, 'fleetway');
					add(dad);
					tailscircle = 'hovering';

				case 1008:
					remove(boyfriend);
					boyfriend = new Boyfriend(2040.55 - 200, 685.6 - 130 - 46, 'bf-super');
					add(boyfriend);

					FlxG.camera.shake(0.02, 0.2);
					FlxG.camera.flash(FlxColor.YELLOW, 0.2);

					FlxG.sound.play(Paths.sound('SUPERBF', 'exe'));

					boyfriend.scrollFactor.set(1.1, 1);

					boyfriend.addOffset('idle', 56, 11);
					boyfriend.addOffset("singUP", 51, 40);
					boyfriend.addOffset("singRIGHT", 0, 9);
					boyfriend.addOffset("singLEFT", 74, 14);
					boyfriend.addOffset("singDOWN", 60, -71);
					boyfriend.addOffset("singUPmiss", 48, 36);
					boyfriend.addOffset("singRIGHTmiss", 3, 11);
					boyfriend.addOffset("singLEFTmiss", 55, 13);
					boyfriend.addOffset("singDOWNmiss", 56, -72);

				case 1261, 1543, 1672, 1792, 1936:
					remove(dad);
					dad = new Character(61.15, -94.75, 'fleetway-extras2');
					add(dad);
					switch (curStep)
					{
						case 1261:
							dad.playAnim('a', true);

						case 1543:
							dad.playAnim('b', true);

						case 1672:
							dad.playAnim('c', true);

						case 1792:
							dad.playAnim('d', true);

						case 1936:
							dad.playAnim('e', true);
					}
				case 383, 512, 640, 776, 1036, 1152:
					remove(dad);
					dad = new Character(61.15, -94.75, 'fleetway-extras');
					add(dad);
					switch (curStep)
					{
						case 383:
							dad.playAnim('a', true);

						case 512:
							dad.playAnim('b', true);

						case 640:
							dad.playAnim('c', true);

						case 776:
							dad.playAnim('d', true);

						case 1036:
							dad.playAnim('e', true);

						case 1152:
							dad.playAnim('f', true);
					}
				case 380, 509, 637, 773, 1033, 1149, 1261, 1543, 1672, 1792, 1936:
					tailscircle = '';
					FlxTween.tween(dad, {x: 61.15, y: -94.75}, 0.2);
					dad.setPosition(61.15, -94.75);
			}
		}

		if (curSong.toLowerCase() == 'triple-talent')
		{
			switch (curStep)
			{
				case 1:
					doP3Static(); // cool static
					FlxTween.tween(FlxG.camera, {zoom: 1.1}, 2, {ease: FlxEase.cubeOut});
					defaultCamZoom = 1.1;
				case 144:
					doP3JumpTAILS();
				case 1024, 1088, 1216, 1280, 2305, 2810, 3199, 4096:
					doP3Static();
				case 1040: // switch to sonic facing right

					FlxTween.tween(FlxG.camera, {zoom: 0.9}, 2, {ease: FlxEase.cubeOut});
					defaultCamZoom = 0.9;

					healthBar.createFilledBar(FlxColor.fromRGB(182, 0, 205), FlxColor.fromRGB(49, 176, 209));

					p3staticbg.visible = true;

					remove(dad);
					dad = new Character(20 - 200, -94.75 + 100, 'beast');
					add(dad);

					dad.addOffset('idle', -18, 70); // BEAST SONIC LOOKING RIGHT
					dad.addOffset("singUP", 22, 143);
					dad.addOffset("singRIGHT", -260, 11);
					dad.addOffset("singLEFT", 177, -24);
					dad.addOffset("singDOWN", -15, -57);
					dad.addOffset("laugh", -78, -128);

					iconP2.changeIcon('beast');

					remove(boyfriend);
					boyfriend = new Boyfriend(502.45 + 200, 370.45, 'bf-perspective-flipped');
					add(boyfriend);

				case 1296: // switch to knuckles facing left facing right and bf facing right, and cool static

					FlxTween.tween(FlxG.camera, {zoom: 1.1}, 2, {ease: FlxEase.cubeOut});
					defaultCamZoom = 1.1;

					p3staticbg.visible = false;

					remove(dad);
					dad = new Character(1300 + 100 - 206, 260 + 44, 'knucks');
					add(dad);
					healthBar.createFilledBar(FlxColor.fromRGB(150, 0, 0), FlxColor.fromRGB(49, 176, 209));

					iconP2.changeIcon('knucks');
					iconP1.changeIcon('bf');

					cpuStrums.forEach(function(spr:FlxSprite)
					{
						if (!FlxG.save.data.midscroll)
							FlxTween.tween(spr, {x: spr.x += 700, y: spr.y}, 5, {ease: FlxEase.quartOut});
						// spr.x += 700;
					});
					playerStrums.forEach(function(spr:FlxSprite)
					{
						if (!FlxG.save.data.midscroll)
							FlxTween.tween(spr, {x: spr.x -= 600, y: spr.y}, 5, {ease: FlxEase.quartOut});
						// spr.x -= 600;
					});

					dad.addOffset("singRIGHT", -59, -65);
					dad.addOffset("singLEFT", 124, -59);
					dad.addOffset("singUP", 29, 49);
					dad.addOffset("singDOWN", 26, -95);

					dad.flipX = true;

					remove(boyfriend);
					boyfriend = new Boyfriend(466.1, 685.6 - 300, 'bf-flipped-for-cam');
					add(boyfriend);

					boyfriend.flipX = true;

					boyfriend.addOffset('idle', 0, -2); // flipped offsets for flipped normal bf
					boyfriend.addOffset("singUP", 10, 27);
					boyfriend.addOffset("singRIGHT", 44, -7);
					boyfriend.addOffset("singLEFT", -22, -7);
					boyfriend.addOffset("singDOWN", -13, -52);
					boyfriend.addOffset("singUPmiss", 13, 24);
					boyfriend.addOffset("singRIGHTmiss", 44, 20);
					boyfriend.addOffset("singLEFTmiss", -26, 15);
					boyfriend.addOffset("singDOWNmiss", -11, -20);

					doP3JumpKNUCKLES();

				case 2320:
					FlxTween.tween(FlxG.camera, {zoom: 0.9}, 2, {ease: FlxEase.cubeOut});
					defaultCamZoom = 0.9;

					p3staticbg.visible = true;

					remove(dad);
					dad = new Character(1300 - 250, -94.75 + 100, 'beast-cam-fix');
					add(dad);

					dad.addOffset('idle', -13, 79); // cam fix BEAST SONIC LOOKING LEFT OFFSETS
					dad.addOffset("singUP", 11, 156);
					dad.addOffset("singRIGHT", 451, 24);
					dad.addOffset("singLEFT", 174, -13);
					dad.addOffset("singDOWN", 4, -15);
					dad.addOffset("laugh", 103, -144);

					// dad.camFollow.y = dad.getMidpoint().y - 100;
					// dad.camFollow.x = dad.getMidpoint().x - 500;

					healthBar.createFilledBar(FlxColor.fromRGB(182, 0, 205), FlxColor.fromRGB(49, 176, 209));

					iconP2.changeIcon('beast');

					remove(boyfriend);
					boyfriend = new Boyfriend(502.45 - 350, 370.45, 'bf-perspective');
					add(boyfriend);

					boyfriend.flipX = false;

					boyfriend.addOffset('idle', 5, 4);
					boyfriend.addOffset("singUP", 23, 63);
					boyfriend.addOffset("singLEFT", 31, 9);
					boyfriend.addOffset("singRIGHT", -75, -15);
					boyfriend.addOffset("singDOWN", -51, -1);
					boyfriend.addOffset("singUPmiss", 20, 135);
					boyfriend.addOffset("singLEFTmiss", 10, 92);
					boyfriend.addOffset("singRIGHTmiss", -70, 85);
					boyfriend.addOffset("singDOWNmiss", -53, 10);

					dad.flipX = true;
				case 2823:
					doP3JumpEGGMAN();

					FlxTween.tween(FlxG.camera, {zoom: 1}, 2, {ease: FlxEase.cubeOut});
					defaultCamZoom = 1;

					cpuStrums.forEach(function(spr:FlxSprite)
					{
						if (!FlxG.save.data.midscroll)
							FlxTween.tween(spr, {x: spr.x -= 700, y: spr.y}, 5, {ease: FlxEase.quartOut});
						// spr.x -= 700;
					});
					playerStrums.forEach(function(spr:FlxSprite)
					{
						if (!FlxG.save.data.midscroll)
							FlxTween.tween(spr, {x: spr.x += 600, y: spr.y}, 5, {ease: FlxEase.quartOut});
						// spr.x += 600;
					});

					p3staticbg.visible = false;

					remove(dad);
					dad = new Character(20 - 200, 30 + 200, 'eggdickface');
					add(dad);

					// dad.camFollow.y = dad.getMidpoint().y;
					// dad.camFollow.x = dad.getMidpoint().x + 300;

					healthBar.createFilledBar(FlxColor.fromRGB(194, 80, 0), FlxColor.fromRGB(49, 176, 209));

					iconP2.changeIcon('eggdickface');

					dad.flipX = false;

					dad.addOffset('idle', -5, 5);
					dad.addOffset("singUP", 110, 231);
					dad.addOffset("singRIGHT", 40, 174);
					dad.addOffset("singLEFT", 237, 97);
					dad.addOffset("singDOWN", 49, -95);
					dad.addOffset('laugh', -10, 210);

					remove(boyfriend);
					boyfriend = new Boyfriend(466.1 + 200, 685.6 - 250, 'bf');
					add(boyfriend);

					boyfriend.addOffset('idle', -5);
					boyfriend.addOffset("singUP", -29, 27);
					boyfriend.addOffset("singRIGHT", -38, -7);
					boyfriend.addOffset("singLEFT", 12, -6);
					boyfriend.addOffset("singDOWN", -10, -50);
					boyfriend.addOffset("singUPmiss", -29, 27);
					boyfriend.addOffset("singRIGHTmiss", -30, 21);
					boyfriend.addOffset("singLEFTmiss", 12, 24);
					boyfriend.addOffset("singDOWNmiss", -11, -19);

				case 2887, 3015, 4039:
					dad.playAnim('laugh', true);
					dad.nonanimated = true;
				case 2895, 3023, 4048:
					dad.nonanimated = false;

				case 4111:
					p3staticbg.visible = true;
					remove(dad);
					dad = new Character(20 - 200, -94.75 + 100, 'beast');
					add(dad);

					dad.addOffset('idle', -18, 70); // BEAST SONIC LOOKING RIGHT
					dad.addOffset("singUP", 22, 143);
					dad.addOffset("singRIGHT", -260, 11);
					dad.addOffset("singLEFT", 177, -24);
					dad.addOffset("singDOWN", -15, -57);
					dad.addOffset("laugh", -78, -128);

					healthBar.createFilledBar(FlxColor.fromRGB(182, 0, 205), FlxColor.fromRGB(49, 176, 209));

					iconP2.changeIcon('beast');

					remove(boyfriend);
					boyfriend = new Boyfriend(502.45, 370.45, 'bf-perspective-flipped');
					add(boyfriend);
			}
		}

		#if windows
		if (executeModchart && luaModchart != null)
		{
			luaModchart.setVar('curStep', curStep);
			luaModchart.executeState('stepHit', [curStep]);
		}
		#end

		// yes this updates every step.
		// yes this is bad
		// but i'm doing it to update misses and accuracy
		#if windows
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText
			+ " "
			+ cooltext
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"Acc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC, true,
			songLength
			- Conductor.songPosition);
		#end
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, (PlayStateChangeables.useDownscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));
		}

		#if cpp
		if (executeModchart && luaModchart != null)
		{
			luaModchart.setVar('curBeat', curBeat);
			luaModchart.executeState('beatHit', [curBeat]);
		}
		#end

		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();

		if (songLowercase == 'tutorial' && dad.curCharacter == 'gf' && SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].mustHitSection)
				dad.dance();
			else
			{
				if (curBeat == 73 || curBeat % 4 == 0 || curBeat % 4 == 1)
					dad.playAnim('danceLeft', true);
				else
					dad.playAnim('danceRight', true);
			}
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			if ((!dad.animation.curAnim.name.startsWith("sing")) && dad.curCharacter != 'gf')
			{
				if (tailscircle == 'circling' && dad.curCharacter == 'TDoll')
					remove(ezTrail);
				if ((curBeat % idleBeat == 0 || !idleToBeat) || dad.curCharacter == "spooky")
					dad.dance(idleToBeat, SONG.notes[Math.floor(curStep / 16)].p1AltAnim);
			}
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		if (FlxG.save.data.camzoom)
		{
			if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0)
		{
			gf.dance();
		}

		if (!boyfriend.animation.curAnim.name.startsWith("sing") && (curBeat % idleBeat == 0 || !idleToBeat))
		{
			boyfriend.playAnim('idle' + ((SONG.notes[Math.floor(curStep / 16)].p2AltAnim
				&& boyfriend.animation.getByName('idle-alt') != null) ? '-alt' : ''),
				idleToBeat);
		}

		if (curBeat % 16 == 15 && songLowercase == 'tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
		}

		switch (curStage)
		{
			case 'sonicFUNSTAGE':
				if (FlxG.save.data.distractions)
				{
					funpillarts1ANIM.animation.play('bumpypillar', true);
					funpillarts2ANIM.animation.play('bumpypillar', true);
					funboppers1ANIM.animation.play('bumpypillar', true);
					funboppers2ANIM.animation.play('bumpypillar', true);
				}
			case 'chamber':
				if (FlxG.save.data.distractions)
				{
					porker.animation.play('porkerbop');
				}
		}
	}

	var curLight:Int = 0;
}
