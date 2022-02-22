package;

import flixel.util.FlxSpriteUtil;
#if FEATURE_LUAMODCHART
import LuaClass.LuaCamera;
import LuaClass.LuaCharacter;
import LuaClass.LuaNote;
#end
import lime.media.openal.AL;
import Song.Event;
import openfl.media.Sound;
#if FEATURE_STEPMANIA
import smTools.SMFile;
#end
#if FEATURE_FILESYSTEM
import sys.io.File;
import Sys;
import sys.FileSystem;
#end
import openfl.ui.KeyLocation;
import openfl.events.Event;
import haxe.EnumTools;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import Replay.Ana;
import Replay.Analysis;
#if FEATURE_WEBM
import webm.WebmPlayer;
#end
import flixel.input.keyboard.FlxKey;
import haxe.Exception;
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import openfl.utils.AssetType;
import lime.graphics.Image;
import flixel.graphics.FlxGraphic;
import openfl.utils.AssetManifest;
import openfl.utils.AssetLibrary;
import lime.app.Application;
import lime.media.AudioContext;
import lime.media.AudioManager;
import openfl.Lib;
import Section.SwagSection;
import Song.SongData;
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
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
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
import haxe.Json;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
#if FEATURE_DISCORD
import Discord.DiscordClient;
#end

using StringTools;

class PlayState extends MusicBeatState
{
	public static var instance:PlayState = null;

	public static var SONG:SongData;
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

	public static var songPosBG:FlxSprite;

	public var visibleCombos:Array<FlxSprite> = [];

	public var addedBotplay:Bool = false;

	public var visibleNotes:Array<Note> = [];

	public static var songPosBar:FlxBar;

	public static var noteskinSprite:FlxAtlasFrames;
	public static var noteskinPixelSprite:BitmapData;
	public static var noteskinPixelSpriteEnds:BitmapData;

	public static var rep:Replay;
	public static var loadRep:Bool = false;
	public static var inResults:Bool = false;

	public static var inDaPlay:Bool = false;

	public static var noteBools:Array<Bool> = [false, false, false, false, false];

	var songLength:Float = 0;
	var kadeEngineWatermark:FlxText;

	#if FEATURE_DISCORD
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	public var vocals:FlxSound;

	public static var isSM:Bool = false;
	#if FEATURE_STEPMANIA
	public static var sm:SMFile;
	public static var pathToSm:String;
	#end

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

	public var laneunderlay:FlxSprite;
	public var laneunderlayOpponent:FlxSprite;

	public static var strumLineNotes:FlxTypedGroup<StaticArrow> = null;
	public static var playerStrums:FlxTypedGroup<StaticArrow> = null;
	public static var playerSplashes:FlxTypedGroup<FlxSprite> = null;
	public static var cpuStrums:FlxTypedGroup<StaticArrow> = null;

	private var camZooming:Bool = false;
	private var curSong:String = "";

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
	var forcedToIdle:Bool = false; // change if bf and dad are forced to idle to every (idleBeat) beats of the song
	var allowedToHeadbang:Bool = true; // Will decide if gf is allowed to headbang depending on the song
	var allowedToCheer:Bool = false; // Will decide if gf is allowed to cheer depending on the song

	public var dialogue:Array<String> = ['dad:blah blah blah', 'bf:coolswag'];

	var lowQuality:Bool = FlxG.save.data.lq;

	var songName:FlxText;

	var balling:FlxSprite = new FlxSprite(0, 0);

	var blackFuck:FlxSprite;
	var startCircle:FlxSprite;
	var startText:FlxSprite;
	var cooltext:String = '';
	var isRing:Bool = SONG.isRing;
	var floaty:Float = 0;
	var tailscircle:String = '';
	var ezTrail:FlxTrail;
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

	var altSuffix:String = "";

	public var currentSection:SwagSection;

	var fc:Bool = true;

	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;

	public static var currentSong = "noneYet";

	public var songScore:Int = 0;

	var songScoreDef:Int = 0;
	var scoreTxt:FlxText;
	var judgementCounter:FlxText;
	var replayTxt:FlxText;

	var ringCounter:FlxSprite;
	var counterNum:FlxText;
	var cNum:Int = 0;

	var needSkip:Bool = false;
	var skipActive:Bool = false;
	var skipText:FlxText;
	var skipTo:Float;

	public static var campaignScore:Int = 0;

	public static var theFunne:Bool = true;

	var funneEffect:FlxSprite;
	var inCutscene:Bool = false;
	var usedTimeTravel:Bool = false;

	public static var stageTesting:Bool = false;

	var camPos:FlxPoint;

	public var randomVar = false;

	public static var Stage:Stage;

	public static var repPresses:Int = 0;
	public static var repReleases:Int = 0;

	public static var timeCurrently:Float = 0;
	public static var timeCurrentlyR:Float = 0;

	// Will fire once to prevent debug spam messages and broken animations
	private var triggeredAlready:Bool = false;

	// Per song additive offset
	public static var songOffset:Float = 0;

	// BotPlay text
	private var botPlayState:FlxText;
	// Replay shit
	private var saveNotes:Array<Dynamic> = [];
	private var saveJudge:Array<String> = [];
	private var replayAna:Analysis = new Analysis(); // replay analysis

	public static var highestCombo:Int = 0;

	public var executeModchart = false;

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
		FlxG.mouse.visible = false;
		instance = this;

		// grab variables here too or else its gonna break stuff later on
		GameplayCustomizeState.freeplayBf = SONG.player1;
		GameplayCustomizeState.freeplayDad = SONG.player2;
		GameplayCustomizeState.freeplayGf = SONG.gfVersion;
		GameplayCustomizeState.freeplayNoteStyle = SONG.noteStyle;
		GameplayCustomizeState.freeplayStage = SONG.stage;
		GameplayCustomizeState.freeplaySong = SONG.songId;
		GameplayCustomizeState.freeplayWeek = storyWeek;

		dataColor = isRing ? dataColor5k : dataColor;
		dataSuffix = isRing ? dataSuffix5k : dataSuffix;

		previousRate = songMultiplier - 0.05;

		if (previousRate < 1.00)
			previousRate = 1;

		if (FlxG.save.data.fpsCap > 290)
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(800);

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		inDaPlay = true;

		if (currentSong != SONG.songName)
		{
			currentSong = SONG.songName;
			Main.dumpCache();

			// PRELOADING STUFFS
			if (SONG.songId == 'too-seiso' && FlxG.save.data.jumpscares)
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
			else if (SONG.songId == 'caretaker')
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
			else if (SONG.songId == 'you-cant-kusa')
			{
				daNoteStatic.frames = Paths.getSparrowAtlas('hitStatic', 'exe');
				daNoteStatic.animation.addByPrefix('static', 'staticANIMATION', 24, false);
				daNoteStatic.animation.play('static');

				remove(daNoteStatic);

				dad = new Character(100, 100, 'sonic.exe alt');
				add(dad);
				remove(dad);
			}
			else if (SONG.songId == 'triple-talent')
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
			else if (SONG.songId == 'sunshine')
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
			else if (SONG.songId == 'koyochaos')
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
		}
		else
			preloaded = true;

		if (PlayStateChangeables.nocheese)
		{
			cooltext = SONG.songName;
		}
		else
		{
			cooltext = '???';
		}

		SONG.noteStyle = ChartingState.defaultnoteStyle;

		blackFuck = new FlxSprite().makeGraphic(1280, 720, FlxColor.BLACK);

		startCircle = new FlxSprite();
		startText = new FlxSprite();

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
		PlayStateChangeables.scrollSpeed = FlxG.save.data.scrollSpeed * songMultiplier;
		PlayStateChangeables.botPlay = FlxG.save.data.botplay;
		PlayStateChangeables.Optimize = FlxG.save.data.optimize;
		PlayStateChangeables.zoom = FlxG.save.data.zoom;

		removedVideo = false;

		#if FEATURE_LUAMODCHART
		// TODO: Refactor this to use OpenFlAssets.
		executeModchart = FileSystem.exists(Paths.lua('songs/${PlayState.SONG.songId}/modchart'));
		if (isSM)
			executeModchart = FileSystem.exists(pathToSm + "/modchart.lua");
		if (executeModchart)
			PlayStateChangeables.Optimize = false;
		#end
		#if !cpp
		executeModchart = false; // FORCE disable for non cpp targets
		#end

		Debug.logInfo('Searching for mod chart? ($executeModchart) at ${Paths.lua('songs/${PlayState.SONG.songId}/modchart')}');

		if (executeModchart)
			songMultiplier = 1;

		#if FEATURE_DISCORD
		// Making difficulty text for Discord Rich Presence.
		storyDifficultyText = CoolUtil.difficultyFromInt(storyDifficulty);

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

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

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.songName
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
		// FlxG.cameras.setDefaultDrawTarget(camGame, true);

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial', '');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		Conductor.bpm = SONG.bpm;

		if (SONG.eventObjects == null)
		{
			SONG.eventObjects = [new Song.Event("Init BPM", 0, SONG.bpm, "BPM Change")];
		}

		TimingStruct.clearTimings();

		var currentIndex = 0;
		for (i in SONG.eventObjects)
		{
			if (i.type == "BPM Change")
			{
				var beat:Float = i.position;

				var endBeat:Float = Math.POSITIVE_INFINITY;

				var bpm = i.value * songMultiplier;

				TimingStruct.addTiming(beat, bpm, endBeat, 0); // offset in this case = start time since we don't have a offset

				if (currentIndex != 0)
				{
					var data = TimingStruct.AllTimings[currentIndex - 1];
					data.endBeat = beat;
					data.length = ((data.endBeat - data.startBeat) / (data.bpm / 60)) / songMultiplier;
					var step = ((60 / data.bpm) * 1000) / 4;
					TimingStruct.AllTimings[currentIndex].startStep = Math.floor((((data.endBeat / (data.bpm / 60)) * 1000) / step) / songMultiplier);
					TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length / songMultiplier;
				}

				currentIndex++;
			}
		}

		recalculateAllSectionTimes();

		trace('INFORMATION ABOUT WHAT U PLAYIN WIT:\nFRAMES: ' + PlayStateChangeables.safeFrames + '\nZONE: ' + Conductor.safeZoneOffset + '\nTS: '
			+ Conductor.timeScale + '\nBotPlay : ' + PlayStateChangeables.botPlay);

		// if the song has dialogue, so we don't accidentally try to load a nonexistant file and crash the game
		if (Paths.doesTextAssetExist(Paths.txt('data/songs/${PlayState.SONG.songId}/dialogue')))
		{
			dialogue = CoolUtil.coolTextFile(Paths.txt('data/songs/${PlayState.SONG.songId}/dialogue'));
		}

		// defaults if no stage was found in chart
		var stageCheck:String = 'stage';

		// If the stage isn't specified in the chart, we use the story week value.
		if (SONG.stage == null)
		{
			switch (storyWeek)
			{
				case 2:
					stageCheck = 'halloween';
				case 3:
					stageCheck = 'philly';
				case 4:
					stageCheck = 'limo';
				case 5:
					if (SONG.songId == 'winter-horrorland')
					{
						stageCheck = 'mallEvil';
					}
					else
					{
						stageCheck = 'mall';
					}
				case 6:
					if (SONG.songId == 'thorns')
					{
						stageCheck = 'schoolEvil';
					}
					else
					{
						stageCheck = 'school';
					}
					// i should check if its stage (but this is when none is found in chart anyway)
			}
		}
		else
		{
			stageCheck = SONG.stage;
		}

		if (isStoryMode)
			songMultiplier = 1;

		// defaults if no gf was found in chart
		var gfCheck:String = 'gf';

		if (SONG.gfVersion == null)
		{
			switch (storyWeek)
			{
				case 4:
					gfCheck = 'gf-car';
				case 5:
					gfCheck = 'gf-christmas';
				case 6:
					gfCheck = 'gf-pixel';
			}
		}
		else
		{
			gfCheck = SONG.gfVersion;
		}

		if (!stageTesting)
		{
			gf = new Character(400, 130, gfCheck);

			if (gf.frames == null)
			{
				#if debug
				FlxG.log.warn(["Couldn't load gf: " + gfCheck + ". Loading default gf"]);
				#end
				gf = new Character(400, 130, 'gf');
			}

			boyfriend = new Boyfriend(770, 450, SONG.player1);

			if (boyfriend.frames == null)
			{
				#if debug
				FlxG.log.warn(["Couldn't load boyfriend: " + SONG.player1 + ". Loading default boyfriend"]);
				#end
				boyfriend = new Boyfriend(770, 450, 'bf');
			}

			dad = new Character(100, 100, SONG.player2);

			if (dad.frames == null)
			{
				#if debug
				FlxG.log.warn(["Couldn't load opponent: " + SONG.player2 + ". Loading default opponent"]);
				#end
				dad = new Character(100, 100, 'dad');
			}
		}

		if (!stageTesting)
			Stage = new Stage(SONG.stage);

		var positions = Stage.positions[Stage.curStage];
		if (positions != null && !stageTesting)
		{
			for (char => pos in positions)
				for (person in [boyfriend, gf, dad])
					if (person.curCharacter == char)
						person.setPosition(pos[0], pos[1]);
		}
		for (i in Stage.toAdd)
		{
			add(i);
		}
		if (!PlayStateChangeables.Optimize)
			for (index => array in Stage.layInFront)
			{
				switch (index)
				{
					case 0:
						if (Stage.curStage == 'SONICstage' || Stage.curStage == 'SONICexestage' || Stage.curStage == 'FAKERSTAGE'
							|| Stage.curStage == 'EXEStage')
						{
							add(gf);
							gf.scrollFactor.set(0.95, 0.95);
						}
						for (bg in array)
							add(bg);
					case 1:
						add(dad);
						for (bg in array)
							add(bg);
					case 2:
						add(boyfriend);
						for (bg in array)
							add(bg);
				}
			}

		camPos = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (dad.curCharacter)
		{
			case 'gf':
				if (!stageTesting)
					dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}
			case 'dad':
				camPos.x += 400;
			case 'suisei':
				dad.x += 130;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y - 100);
			case 'coco':
				dad.x += 100;
				dad.y += 100;
			case 'tails':
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'sonic.exe alt':
				camPos.set(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);
			case 'mio':
				dad.x -= 200;
				dad.y -= 150;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'sonicLordX':
				dad.y += 50;
				camPos.set(dad.getGraphicMidpoint().x + 200, dad.getGraphicMidpoint().y);
		}

		Stage.update(0);

		switch (Stage.curStage)
		{
			case 'SONICstage':
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y - 100);
			case 'FAKERSTAGE':
			case 'SONICexestage': // i fixed the bgs and shit!!! - razencro part 3
				camPos.set(boyfriend.getGraphicMidpoint().x, boyfriend.getGraphicMidpoint().y);
			case 'sonicFUNSTAGE':
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y - 200);
			case 'LordXStage':
				camPos.set(dad.getGraphicMidpoint().x + 200, dad.getGraphicMidpoint().y);
			case 'sunkStage':
			case 'TDStage':
			case 'sanicStage':
			case 'EXEStage':
			case 'TrioStage':
				camPos.set(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);
			case 'chamber':
		}

		if (loadRep)
		{
			FlxG.watch.addQuick('rep presses', repPresses);
			FlxG.watch.addQuick('rep releases', repReleases);
			// FlxG.watch.addQuick('Queued',inputsQueued);

			PlayStateChangeables.useDownscroll = rep.replay.isDownscroll;
			PlayStateChangeables.safeFrames = rep.replay.sf;
			PlayStateChangeables.botPlay = true;
		}

		trace('uh ' + PlayStateChangeables.safeFrames);

		trace("SF CALC: " + Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));

		var doof = null;

		if (isStoryMode)
		{
			doof = new DialogueBox(false, dialogue);
			// doof.x += 70;
			// doof.y = FlxG.height * 0.5;
			doof.scrollFactor.set();
			doof.finishThing = startCountdown;
		}

		if (!isStoryMode && songMultiplier == 1)
		{
			var firstNoteTime = Math.POSITIVE_INFINITY;
			var playerTurn = false;
			for (index => section in SONG.notes)
			{
				if (section.sectionNotes.length > 0 && !isSM)
				{
					if (section.startTime > 5000)
					{
						needSkip = true;
						skipTo = section.startTime - 1000;
					}
					break;
				}
				else if (isSM)
				{
					for (note in section.sectionNotes)
					{
						if (note[0] < firstNoteTime)
						{
							if (!PlayStateChangeables.Optimize)
							{
								firstNoteTime = note[0];
								if (note[1] > 3)
									playerTurn = true;
								else
									playerTurn = false;
							}
							else if (note[1] > 3)
							{
								firstNoteTime = note[0];
							}
						}
					}
					if (index + 1 == SONG.notes.length)
					{
						var timing = ((!playerTurn && !PlayStateChangeables.Optimize) ? firstNoteTime : TimingStruct.getTimeFromBeat(TimingStruct.getBeatFromTime(firstNoteTime)
							- 4));
						if (timing > 5000)
						{
							needSkip = true;
							skipTo = timing - 1000;
						}
					}
				}
			}
		}

		Conductor.songPosition = -5000;
		Conductor.rawPosition = Conductor.songPosition;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		if (PlayStateChangeables.useDownscroll)
			strumLine.y = FlxG.height - 165;

		laneunderlayOpponent = new FlxSprite(0, 0).makeGraphic(110 * 4 + 50, FlxG.height * 2);
		laneunderlayOpponent.alpha = FlxG.save.data.laneTransparency;
		laneunderlayOpponent.color = FlxColor.BLACK;
		laneunderlayOpponent.scrollFactor.set();

		laneunderlay = new FlxSprite(0, 0).makeGraphic(110 * 4 + 50, FlxG.height * 2);
		laneunderlay.alpha = FlxG.save.data.laneTransparency;
		laneunderlay.color = FlxColor.BLACK;
		laneunderlay.scrollFactor.set();

		if (FlxG.save.data.laneUnderlay && !PlayStateChangeables.Optimize)
		{
			if (!FlxG.save.data.middleScroll || executeModchart)
			{
				add(laneunderlayOpponent);
			}
			add(laneunderlay);
		}

		strumLineNotes = new FlxTypedGroup<StaticArrow>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<StaticArrow>();
		playerSplashes = new FlxTypedGroup<FlxSprite>();
		add(playerSplashes);
		cpuStrums = new FlxTypedGroup<StaticArrow>();

		noteskinPixelSprite = NoteskinHelpers.generatePixelSprite(FlxG.save.data.noteskin);
		noteskinSprite = NoteskinHelpers.generateNoteskinSprite(FlxG.save.data.noteskin);
		noteskinPixelSpriteEnds = NoteskinHelpers.generatePixelSprite(FlxG.save.data.noteskin, true);

		generateStaticArrows(0, false);
		generateStaticArrows(1, false);

		// Update lane underlay positions AFTER static arrows :)

		laneunderlay.x = playerStrums.members[0].x - 25;
		laneunderlayOpponent.x = cpuStrums.members[0].x - 25;

		laneunderlay.screenCenter(Y);
		laneunderlayOpponent.screenCenter(Y);

		if (SONG.songId == null)
			trace('song is null???');
		else
			trace('song looks gucci');

		generateSong(SONG.songId);

		#if FEATURE_LUAMODCHART
		if (executeModchart)
		{
			luaModchart = ModchartState.createModchartState(isStoryMode);
			luaModchart.executeState('start', [PlayState.SONG.songId]);
		}
		#end

		#if FEATURE_LUAMODCHART
		if (executeModchart)
		{
			new LuaCamera(camGame, "camGame").Register(ModchartState.lua);
			new LuaCamera(camHUD, "camHUD").Register(ModchartState.lua);
			new LuaCamera(camSustains, "camSustains").Register(ModchartState.lua);
			new LuaCamera(camSustains, "camNotes").Register(ModchartState.lua);
			new LuaCharacter(dad, "dad").Register(ModchartState.lua);
			new LuaCharacter(gf, "gf").Register(ModchartState.lua);
			new LuaCharacter(boyfriend, "boyfriend").Register(ModchartState.lua);
		}
		#end

		var index = 0;

		if (startTime != 0)
		{
			var toBeRemoved = [];
			for (i in 0...unspawnNotes.length)
			{
				var dunceNote:Note = unspawnNotes[i];

				if (dunceNote.strumTime <= startTime)
					toBeRemoved.push(dunceNote);
			}

			for (i in toBeRemoved)
				unspawnNotes.remove(i);

			Debug.logTrace("Removed " + toBeRemoved.length + " cuz of start time");
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

		switch (SONG.songId)
		{
			case 'too-seiso':
				FlxG.camera.follow(camFollow, LOCKON, 0.05 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
			case 'ankimo':
				FlxG.camera.follow(camFollow, LOCKON, 0.08 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
			case 'caretaker':
				fakertransform.setPosition(dad.getGraphicMidpoint().x - 400, dad.getGraphicMidpoint().y - 400);
				FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
			case 'koyochaos':
				FlxG.camera.follow(camFollow, LOCKON, 0.06 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
			case 'sunshine':
				if (FlxG.save.data.vfx)
				{
					var vcr:VCRDistortionShader;
					vcr = new VCRDistortionShader();

					var daStatic:FlxSprite = new FlxSprite(0, 0);

					daStatic.frames = Paths.getSparrowAtlas('daSTAT', 'exe');

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
			case 'you-cant-kusa':
				FlxG.camera.follow(camFollow, LOCKON, 0.06 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
			case 'triple-talent':
				FlxG.camera.follow(camFollow, LOCKON, 0.12 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
			case 'white-moon':
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
			case 'too-fest':
				camFollow.y = dad.getMidpoint().y + 700;
				camFollow.x = dad.getMidpoint().x + 700;
				FlxG.camera.follow(camFollow, LOCKON, 0.05 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
			default:
				FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
		}

		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = Stage.camZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.loadImage('healthBar'));
		if (PlayStateChangeables.useDownscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();

		// Add Kade Engine watermark
		kadeEngineWatermark = new FlxText(4, healthBarBG.y
			+ 50, 0,
			SONG.songName
			+ (FlxMath.roundDecimal(songMultiplier, 2) != 1.00 ? " (" + FlxMath.roundDecimal(songMultiplier, 2) + "x)" : "")
			+ " - "
			+ CoolUtil.difficultyFromInt(storyDifficulty),
			16);
		kadeEngineWatermark.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		kadeEngineWatermark.scrollFactor.set();
		add(kadeEngineWatermark);

		if (PlayStateChangeables.useDownscroll)
			kadeEngineWatermark.y = FlxG.height * 0.9 + 45;

		scoreTxt = new FlxText(FlxG.width / 2 - 235, healthBarBG.y + 50, 0, "", 20);
		scoreTxt.screenCenter(X);
		scoreTxt.scrollFactor.set();
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.text = Ratings.CalculateRanking(songScore, songScoreDef, nps, maxNPS, accuracy);
		if (!FlxG.save.data.healthBar)
			scoreTxt.y = healthBarBG.y;

		add(scoreTxt);

		judgementCounter = new FlxText(20, 0, 0, "", 20);
		judgementCounter.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		judgementCounter.borderSize = 2;
		judgementCounter.borderQuality = 2;
		judgementCounter.scrollFactor.set();
		judgementCounter.cameras = [camHUD];
		judgementCounter.screenCenter(Y);
		judgementCounter.text = 'Sicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}\nMisses: ${misses}';
		if (FlxG.save.data.judgementCounter)
		{
			add(judgementCounter);
		}

		replayTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0, "REPLAY",
			20);
		replayTxt.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		replayTxt.borderSize = 4;
		replayTxt.borderQuality = 2;
		replayTxt.scrollFactor.set();
		replayTxt.cameras = [camHUD];
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
		botPlayState.cameras = [camHUD];
		if (PlayStateChangeables.botPlay && !loadRep)
			add(botPlayState);

		addedBotplay = PlayStateChangeables.botPlay;

		iconP1 = new HealthIcon(boyfriend.curCharacter, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);

		iconP2 = new HealthIcon(dad.curCharacter, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);

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

		if (FlxG.save.data.healthBar)
		{
			add(healthBarBG);
			add(healthBar);
			add(iconP1);
			add(iconP2);

			if (FlxG.save.data.colour)
				healthBar.createFilledBar(dad.barColor, boyfriend.barColor);
			else
				healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		}

		strumLineNotes.cameras = [camHUD];
		playerSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		laneunderlay.cameras = [camHUD];
		laneunderlayOpponent.cameras = [camHUD];

		if (isStoryMode)
			doof.cameras = [camHUD];
		kadeEngineWatermark.cameras = [camHUD];
		if (loadRep)
			replayTxt.cameras = [camHUD];
		startCircle.cameras = [camHUD2];
		startText.cameras = [camHUD2];
		blackFuck.cameras = [camHUD2];

		startingSong = true;

		trace('starting');

		dad.dance();
		boyfriend.dance();
		gf.dance();

		switch (SONG.songId)
		{
			case 'too-seiso':
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
				startCountdown();
				startSong();
			case 'you-cant-kusa':
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
				startCountdown();
				startSong();
			case 'triple-talent':
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
				startCountdown();
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
				startSong();
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
				Stage.swagBacks['bgspec'].visible = false;
				kadeEngineWatermark.visible = false;
				healthBarBG.visible = false;
				healthBar.visible = false;
				botPlayState.visible = false;
				iconP1.visible = false;
				iconP2.visible = false;
				scoreTxt.visible = false;
				gf.visible = true;
				boyfriend.alpha = 1;
				Stage.swagBacks['bgspec'].visible = true;
				kadeEngineWatermark.visible = true;
				botPlayState.visible = true;
				healthBarBG.visible = true;
				healthBar.visible = true;
				iconP1.visible = true;
				iconP2.visible = true;
				scoreTxt.visible = true;
				// generateStaticArrows(0, false);
				// generateStaticArrows(1, false);
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
			case 'caretaker':
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
				FlxG.camera.zoom = Stage.camZoom;
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
							Stage.swagBacks['thechamber'].animation.play('a');
						});
						new FlxTimer().start(6, function(lol:FlxTimer)
						{
							startCountdown();
							FlxG.sound.play(Paths.sound('beam', 'exe'));
							FlxTween.tween(FlxG.camera, {zoom: Stage.camZoom}, 0.2, {ease: FlxEase.cubeOut});
							FlxG.camera.shake(0.02, 0.2);
							FlxG.camera.flash(FlxColor.WHITE, 0.2);
							Stage.swagBacks['floor'].animation.play('b');
							Stage.swagBacks['fleetwaybgshit'].animation.play('b');
							Stage.swagBacks['pebles'].animation.play('b');
							Stage.swagBacks['emeraldbeamyellow'].visible = true;
							Stage.swagBacks['emeraldbeam'].visible = false;
						});
					}
					else
						lol.reset();
				});
			default:
				new FlxTimer().start(1, function(timer)
				{
					startCountdown();
				});
		}

		if (!loadRep)
			rep = new Replay("na");

		// This allow arrow key to be detected by flixel. See https://github.com/HaxeFlixel/flixel/issues/2190
		FlxG.keys.preventDefaultKeys = [];
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

		daStatic.frames = Paths.getSparrowAtlas('daSTAT', 'exe');

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

		daStatic.frames = Paths.getSparrowAtlas('daSTAT', 'exe');

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

		balling.frames = Paths.getSparrowAtlas('daSTAT', 'exe');

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

		balling.frames = Paths.getSparrowAtlas('daSTAT', 'exe');

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

	#if FEATURE_LUAMODCHART
	public static var luaModchart:ModchartState = null;
	#end

	function startCountdown():Void
	{
		FlxG.log.add(storyPlaylist);

		ezTrail = new FlxTrail(dad, null, 2, 5, 0.3, 0.04);

		SONG.noteStyle = ChartingState.defaultnoteStyle;

		inCutscene = false;

		appearStaticArrows();

		// switch (SONG.songId) // null obj refrence so don't fuck with this
		// {
		// 	case "sunshine":

		// 	default:
		// 		generateStaticArrows(0, false);
		// 		generateStaticArrows(1, false);
		// }

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		if (FlxG.sound.music.playing)
			FlxG.sound.music.stop();
		if (vocals != null)
			vocals.stop();

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			// this just based on beatHit stuff but compact
			if (allowedToHeadbang && swagCounter % gfSpeed == 0)
				gf.dance();
			if (swagCounter % idleBeat == 0)
			{
				if (idleToBeat && !boyfriend.animation.curAnim.name.endsWith("miss"))
				{
					boyfriend.dance(forcedToIdle);
					// bfcamX = 0;
					// bfcamY = 0;
				}
				if (idleToBeat)
				{
					dad.dance(forcedToIdle);
					// camX = 0;
					// camY = 0;
				}
			}
			else if (dad.curCharacter == 'spooky' || dad.curCharacter == 'gf')
			{
				dad.dance();
				// camX = 0;
				// camY = 0;
			}

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('pixel', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var week6Bullshit:String = null;

			if (SONG.noteStyle == 'pixel')
			{
				introAlts = introAssets.get('pixel');
				altSuffix = '-pixel';
				week6Bullshit = 'exe';
			}

			switch (swagCounter)

			{
				case 0:
				// FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage(introAlts[0], week6Bullshit));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (SONG.noteStyle == 'pixel')
						ready.setGraphicSize(Std.int(ready.width * CoolUtil.daPixelZoom));

					ready.screenCenter();
					// add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
				// FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage(introAlts[1], week6Bullshit));
					set.scrollFactor.set();

					if (SONG.noteStyle == 'pixel')
						set.setGraphicSize(Std.int(set.width * CoolUtil.daPixelZoom));

					set.screenCenter();
					// add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
				// FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage(introAlts[2], week6Bullshit));
					go.scrollFactor.set();

					if (SONG.noteStyle == 'pixel')
						go.setGraphicSize(Std.int(go.width * CoolUtil.daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					// add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					// FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
			}

			swagCounter += 1;
		}, 4);
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
		var key = FlxKey.toStringMap.get(evt.keyCode);

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
		var key = FlxKey.toStringMap.get(evt.keyCode);

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

		closestNotes = [];

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.wasGoodHit)
				closestNotes.push(daNote);
		}); // Collect notes that can be hit

		closestNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

		var dataNotes = [];
		for (i in closestNotes)
			if (i.noteData == data && !i.isSustainNote)
				dataNotes.push(i);

		trace("notes able to hit for " + key.toString() + " " + dataNotes.length);

		if (dataNotes.length != 0)
		{
			var coolNote = null;

			for (i in dataNotes)
			{
				coolNote = i;
				break;
			}

			if (dataNotes.length > 1) // stacked notes or really close ones
			{
				for (i in 0...dataNotes.length)
				{
					if (i == 0) // skip the first note
						continue;

					var note = dataNotes[i];

					if (!note.isSustainNote && ((note.strumTime - coolNote.strumTime) < 2) && note.noteData == data)
					{
						trace('found a stacked/really close note ' + (note.strumTime - coolNote.strumTime));
						// just fuckin remove it since it's a stacked note and shouldn't be there
						note.kill();
						notes.remove(note, true);
						note.destroy();
					}
				}
			}

			boyfriend.holdTimer = 0;
			goodNoteHit(coolNote);
			var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
			ana.hit = true;
			ana.hitJudge = Ratings.judgeNote(noteDiff);
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
				if (SONG.songId != 'white-moon' && cNum == 0)
					health -= 0.2;
			}
		}
	}

	public var songStarted = false;

	public var doAnything = false;

	public static var songMultiplier = 1.0;

	public var bar:FlxSprite;

	public var previousRate = songMultiplier;

	function startSong():Void
	{
		startingSong = false;
		songStarted = true;
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FlxG.sound.music.onComplete = function() // skill issue + ratio + blocked + didn't ask.
		{
			endSong();
		}

		FlxG.sound.music.play();
		vocals.play();

		// have them all dance when the song starts
		if (allowedToHeadbang)
			gf.dance();
		if (idleToBeat && !boyfriend.animation.curAnim.name.startsWith("sing"))
		{
			boyfriend.dance(forcedToIdle);
			bfcamX = 0;
			bfcamY = 0;
		}
		if (idleToBeat && !dad.animation.curAnim.name.startsWith("sing"))
		{
			dad.dance(forcedToIdle);
			camX = 0;
			camY = 0;
		}

		// Song check real quick
		switch (curSong)
		{
			case 'Bopeebo' | 'Philly Nice' | 'Blammed' | 'Cocoa' | 'Eggnog':
				allowedToCheer = true;
			default:
				allowedToCheer = false;
		}

		if (useVideo)
			GlobalVideo.get().resume();

		#if FEATURE_LUAMODCHART
		if (executeModchart)
			luaModchart.executeState("songStart", [null]);
		#end

		#if FEATURE_DISCORD
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
		if (vocals != null)
			vocals.time = startTime;
		Conductor.songPosition = startTime;
		startTime = 0;

		/*@:privateAccess
			{
				var aux = AL.createAux();
				var fx = AL.createEffect();
				AL.effectf(fx,AL.PITCH,songMultiplier);
				AL.auxi(aux, AL.EFFECTSLOT_EFFECT, fx);
				var instSource = FlxG.sound.music._channel.__source;

				var backend:lime._internal.backend.native.NativeAudioSource = instSource.__backend;

				AL.source3i(backend.handle, AL.AUXILIARY_SEND_FILTER, aux, 1, AL.FILTER_NULL);
				if (vocals != null)
				{
					var vocalSource = vocals._channel.__source;

					backend = vocalSource.__backend;
					AL.source3i(backend.handle, AL.AUXILIARY_SEND_FILTER, aux, 1, AL.FILTER_NULL);
				}

				trace("pitched to " + songMultiplier);
		}*/

		#if cpp
		@:privateAccess
		{
			lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
			if (vocals.playing)
				lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
		}
		trace("pitched inst and vocals to " + songMultiplier);
		#end

		for (i in 0...unspawnNotes.length)
			if (unspawnNotes[i].strumTime < startTime)
				unspawnNotes.remove(unspawnNotes[i]);

		if (needSkip)
		{
			skipActive = true;
			skipText = new FlxText(healthBarBG.x + 80, healthBarBG.y - 110, 500);
			skipText.text = "Press Space to Skip Intro";
			skipText.size = 30;
			skipText.color = FlxColor.WHITE;
			skipText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2, 1);
			skipText.cameras = [camHUD];
			skipText.alpha = 0;
			FlxTween.tween(skipText, {alpha: 1}, 0.2);
			add(skipText);
		}
	}

	var debugNum:Int = 0;

	public function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.songId;

		#if FEATURE_STEPMANIA
		if (SONG.needsVoices && !isSM)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.songId));
		else
			vocals = new FlxSound();
		#else
		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.songId));
		else
			vocals = new FlxSound();
		#end

		trace('loaded vocals');

		FlxG.sound.list.add(vocals);

		if (!paused)
		{
			#if FEATURE_STEPMANIA
			if (!isStoryMode && isSM)
			{
				trace("Loading " + pathToSm + "/" + sm.header.MUSIC);
				var bytes = File.getBytes(pathToSm + "/" + sm.header.MUSIC);
				var sound = new Sound();
				sound.loadCompressedDataFromByteArray(bytes.getData(), bytes.length);
				FlxG.sound.playMusic(sound);
			}
			else
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.songId), 1, false);
			#else
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.songId), 1, false);
			#end
		}

		FlxG.sound.music.pause();

		if (SONG.needsVoices && !PlayState.isSM)
			FlxG.sound.cache(Paths.voices(PlayState.SONG.songId));
		if (!PlayState.isSM)
			FlxG.sound.cache(Paths.inst(PlayState.SONG.songId));

		// Song duration in a float, useful for the time left feature
		songLength = ((FlxG.sound.music.length / songMultiplier) / 1000);

		Conductor.crochet = ((60 / (SONG.bpm) * 1000));
		Conductor.stepCrochet = Conductor.crochet / 4;

		if (FlxG.save.data.songPosition)
		{
			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.loadImage('healthBar'));
			if (PlayStateChangeables.useDownscroll)
				songPosBG.y = FlxG.height * 0.9 + 35;
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();

			songPosBar = new FlxBar(640 - (Std.int(songPosBG.width - 100) / 2), songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 100),
				Std.int(songPosBG.height + 6), this, 'songPositionBar', 0, songLength);
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.BLACK, FlxColor.fromRGB(0, 255, 128));
			add(songPosBar);

			bar = new FlxSprite(songPosBar.x, songPosBar.y).makeGraphic(Math.floor(songPosBar.width), Math.floor(songPosBar.height), FlxColor.TRANSPARENT);

			add(bar);

			FlxSpriteUtil.drawRect(bar, 0, 0, songPosBar.width, songPosBar.height, FlxColor.TRANSPARENT, {thickness: 4, color: FlxColor.BLACK});

			songPosBG.width = songPosBar.width;

			songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - (SONG.songName.length * 5), songPosBG.y - 15, 0, SONG.songName, 16);
			songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songName.scrollFactor.set();

			songName.text = SONG.songName + ' (' + FlxStringUtil.formatTime(songLength, false) + ')';
			songName.y = songPosBG.y + (songPosBG.height / 3);

			add(songName);

			songName.screenCenter(X);

			songPosBG.cameras = [camHUD];
			bar.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
			songName.cameras = [camHUD];
		}

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		for (section in noteData)
		{
			if (daSection == 57 && SONG.songId == 'circus')
				SONG.noteStyle = 'majin';

			if (daSection == 34 && SONG.songId == 'you-cant-kusa')
				SONG.noteStyle = 'pixel';

			if (daSection == 50 && SONG.songId == 'you-cant-kusa')
				SONG.noteStyle = 'normal';

			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0] / songMultiplier;
				if (daStrumTime < 0)
					daStrumTime = 0;
				var daNoteData:Int = Std.int(songNotes[1] % dataColor.length);

				var gottaHitNote:Bool = true;

				if (songNotes[1] > dataColor.length - 1 && section.mustHitSection)
					gottaHitNote = false;
				else if (songNotes[1] < dataColor.length && !section.mustHitSection)
					gottaHitNote = false;

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var isAlt = songNotes[3];
				var daBeat = songNotes[4];
				var daType = songNotes[5];

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, false, isAlt, daBeat, daType);

				if (!gottaHitNote && PlayStateChangeables.Optimize)
					continue;

				swagNote.sustainLength = TimingStruct.getTimeFromBeat((TimingStruct.getBeatFromTime(songNotes[2] / songMultiplier)));
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				swagNote.isAlt = songNotes[3]
					|| ((section.altAnim || section.CPUAltAnim) && !gottaHitNote)
					|| (section.playerAltAnim && gottaHitNote);

				if (susLength > 0)
					swagNote.isParent = true;

				var type = 0;

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true, false,
						false, 0, daType);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);
					sustainNote.isAlt = songNotes[3]
						|| ((section.altAnim || section.CPUAltAnim) && !gottaHitNote)
						|| (section.playerAltAnim && gottaHitNote);

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
			daSection += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;

		Debug.logTrace("whats the fuckin shit");
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function removeStatics()
	{
		playerStrums.forEach(function(todel:StaticArrow)
		{
			playerStrums.remove(todel);
			todel.destroy();
		});
		cpuStrums.forEach(function(todel:StaticArrow)
		{
			cpuStrums.remove(todel);
			todel.destroy();
		});
		strumLineNotes.forEach(function(todel:StaticArrow)
		{
			strumLineNotes.remove(todel);
			todel.destroy();
		});
	}

	private function generateStaticArrows(player:Int, ?tweened:Bool = true):Void
	{
		for (i in 0...dataColor.length)
		{
			// FlxG.log.add(i);
			var babyArrow:StaticArrow = new StaticArrow(-10, strumLine.y);

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

			if (SONG.noteStyle == null && FlxG.save.data.overrideNoteskins)
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
					babyArrow.loadGraphic(noteskinPixelSprite, true, 17, 17);
					for (j in 0...dataColor.length)
					{
						babyArrow.animation.add(dataColor[j], [j + 4]);
					}

					babyArrow.setGraphicSize(Std.int(babyArrow.width * CoolUtil.daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					babyArrow.x += Note.swagWidth * i;
					babyArrow.animation.add('static', [i]);
					babyArrow.animation.add('pressed', [i + 4, i + 8], 12, false);
					babyArrow.animation.add('confirm', [i + 12, i + 16], 24, false);

					for (j in 0...dataColor.length)
					{
						babyArrow.animation.add('dirCon' + j, [12 + j, 16 + j], 24, false);
					}
				case 'majin':
					babyArrow.frames = Paths.getSparrowAtlas('noteskins/Arrows-majin');
					for (j in 0...dataColor.length)
					{
						babyArrow.animation.addByPrefix(dataColor[j], 'arrow' + dataColor[j]);
						babyArrow.animation.addByPrefix('dirCon' + j, dataSuffix[j].toLowerCase() + ' confirm', 24, false);
					}

					var lowerDir:String = dataSuffix[i].toLowerCase();

					babyArrow.animation.addByPrefix('static', 'arrow' + dataSuffix[i]);
					babyArrow.animation.addByPrefix('pressed', lowerDir + ' press', 24, false);
					babyArrow.animation.addByPrefix('confirm', lowerDir + ' confirm', 24, false);

					babyArrow.x += Note.swagWidth * i;

					babyArrow.antialiasing = FlxG.save.data.antialiasing;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
				default:
					babyArrow.frames = noteskinSprite;
					// Debug.logTrace(babyArrow.frames);
					for (j in 0...dataColor.length)
					{
						babyArrow.animation.addByPrefix(dataColor[j], 'arrow' + dataSuffix[j]);
						babyArrow.animation.addByPrefix('dirCon' + j, dataSuffix[j].toLowerCase() + ' confirm', 24, false);
					}

					var lowerDir:String = dataSuffix[i].toLowerCase();

					babyArrow.animation.addByPrefix('static', 'arrow' + dataSuffix[i]);
					babyArrow.animation.addByPrefix('pressed', lowerDir + ' press', 24, false);
					babyArrow.animation.addByPrefix('confirm', lowerDir + ' confirm', 24, false);

					babyArrow.x += Note.swagWidth * i;

					babyArrow.antialiasing = FlxG.save.data.antialiasing;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
			}

			if (SONG.songId != 'circus' && SONG.songId != 'asacoco' && ((isRing && i != 2) || !isRing) && player == 1)
			{
				bloodSplash.x = babyArrow.x + 520;
				playerSplashes.add(bloodSplash);
			}
			else if (SONG.songId == 'white-moon' && player == 0)
			{
				babyArrow.visible = false;
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			// babyArrow.alpha = 0;
			if (!isStoryMode && tweened)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				if (!FlxG.save.data.middleScroll || executeModchart || player == 1)
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
					babyArrow.x += 20;
					cpuStrums.add(babyArrow);
				case 1:
					playerStrums.add(babyArrow);
			}

			babyArrow.playAnim('static');
			babyArrow.x += 110;
			babyArrow.x += ((FlxG.width / 2) * player);

			if (PlayStateChangeables.Optimize || (FlxG.save.data.middleScroll && !executeModchart))
				babyArrow.x -= 80 * dataColor.length;

			cpuStrums.forEach(function(spr:StaticArrow)
			{
				spr.centerOffsets(); // CPU arrows start out slightly off-center
			});

			strumLineNotes.add(babyArrow);
		}
	}

	private function appearStaticArrows():Void
	{
		var index = 0;
		strumLineNotes.forEach(function(babyArrow:StaticArrow)
		{
			if (isStoryMode && !FlxG.save.data.middleScroll || executeModchart)
				babyArrow.alpha = 1;
			if (index > dataColor.length - 1 && FlxG.save.data.middleScroll)
				babyArrow.alpha = 1;
			index++;
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
			// if (FlxG.sound.music != null && FlxG.sound.music.playing)
			// 	FlxG.sound.music.pause();
			// if (vocals != null && vocals.playing)
			// 	vocals.pause();

			if (FlxG.sound.music.playing)
			{
				FlxG.sound.music.pause();
				if (vocals != null)
					if (vocals.playing)
						vocals.pause();
			}

			#if FEATURE_DISCORD
			DiscordClient.changePresence("PAUSED on "
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
			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (PauseSubState.goToOptions)
		{
			Debug.logTrace("pause thingyt");
			if (PauseSubState.goBack)
			{
				Debug.logTrace("pause thingyt");
				PauseSubState.goToOptions = false;
				PauseSubState.goBack = false;
				openSubState(new PauseSubState());
			}
			else
				openSubState(new OptionsMenu(true));
		}
		else if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if FEATURE_DISCORD
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
				DiscordClient.changePresence(detailsText, SONG.songName + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	function resyncVocals():Void
	{
		vocals.stop();
		FlxG.sound.music.stop();

		FlxG.sound.music.play();
		vocals.play();
		FlxG.sound.music.time = Conductor.songPosition * songMultiplier;
		vocals.time = FlxG.sound.music.time;

		@:privateAccess
		{
			#if desktop
			// The __backend.handle attribute is only available on native.
			lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
			if (vocals.playing)
				lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
			#end
		}

		#if FEATURE_DISCORD
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

	public var paused:Bool = false;

	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var nps:Int = 0;
	var maxNPS:Int = 0;

	public var stopUpdate = false;
	public var removedVideo = false;

	public var currentBPM = 0;

	public var updateFrame = 0;

	public var pastScrollChanges:Array<Song.Event> = [];

	var currentLuaIndex = 0;

	override public function update(elapsed:Float)
	{
		if (SONG.songId == 'koyochaos' && dad.curCharacter == 'fleetway-extras3' && dad.animation.curAnim.curFrame == 15 && !dodging)
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

		switch (SONG.songId)
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
		if (!PlayStateChangeables.Optimize)
			Stage.update(elapsed);

		if (!addedBotplay && FlxG.save.data.botplay)
		{
			PlayStateChangeables.botPlay = true;
			addedBotplay = true;
			add(botPlayState);
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 14000 * songMultiplier)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				#if FEATURE_LUAMODCHART
				if (executeModchart)
				{
					new LuaNote(dunceNote, currentLuaIndex);
					dunceNote.luaID = currentLuaIndex;
				}
				#end

				if (executeModchart)
				{
					#if FEATURE_LUAMODCHART
					if (!dunceNote.isSustainNote)
						dunceNote.cameras = [camNotes];
					else
						dunceNote.cameras = [camSustains];
					#end
				}
				else
				{
					dunceNote.cameras = [camHUD];
				}

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
				currentLuaIndex++;
			}
		}

		#if cpp
		if (FlxG.sound.music.playing)
			@:privateAccess
		{
			lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
			if (vocals.playing)
				lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
		}
		#end

		/*if (generatedMusic)
			{
				if (songStarted && !endingSong)
				{
					// Song ends abruptly on slow rate even with second condition being deleted,
					// and if it's deleted on songs like cocoa then it would end without finishing instrumental fully,
					// so no reason to delete it at all
					if (unspawnNotes.length == 0 && notes.length == 0 && FlxG.sound.music.time / songMultiplier > (songLength - 100))
					{
						Debug.logTrace("we're fuckin ending the song ");

						endingSong = true;
						new FlxTimer().start(2, function(timer)
						{
							endSong();
						});
					}
				}
		}*/

		if (updateFrame == 4)
		{
			TimingStruct.clearTimings();

			var currentIndex = 0;
			for (i in SONG.eventObjects)
			{
				if (i.type == "BPM Change")
				{
					var beat:Float = i.position;

					var endBeat:Float = Math.POSITIVE_INFINITY;

					var bpm = i.value * songMultiplier;

					TimingStruct.addTiming(beat, bpm, endBeat, 0); // offset in this case = start time since we don't have a offset

					if (currentIndex != 0)
					{
						var data = TimingStruct.AllTimings[currentIndex - 1];
						data.endBeat = beat;
						data.length = ((data.endBeat - data.startBeat) / (data.bpm / 60)) / songMultiplier;
						var step = ((60 / data.bpm) * 1000) / 4;
						TimingStruct.AllTimings[currentIndex].startStep = Math.floor((((data.endBeat / (data.bpm / 60)) * 1000) / step) / songMultiplier);
						TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length / songMultiplier;
					}

					currentIndex++;
				}
			}

			updateFrame++;
		}
		else if (updateFrame != 5)
			updateFrame++;

		if (FlxG.sound.music.playing)
		{
			var timingSeg = TimingStruct.getTimingAtBeat(curDecimalBeat);

			if (timingSeg != null)
			{
				var timingSegBpm = timingSeg.bpm;

				if (timingSegBpm != Conductor.bpm)
				{
					trace("BPM CHANGE to " + timingSegBpm);
					Conductor.changeBPM(timingSegBpm, false);
					Conductor.crochet = ((60 / (timingSegBpm) * 1000)) / songMultiplier;
					Conductor.stepCrochet = Conductor.crochet / 4;
				}
			}

			var newScroll = 1.0;

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

			if (newScroll != 0)
				PlayStateChangeables.scrollSpeed *= newScroll;
		}

		if (PlayStateChangeables.botPlay && FlxG.keys.justPressed.ONE)
			camHUD.visible = !camHUD.visible;

		if (useVideo && GlobalVideo.get() != null && !stopUpdate)
		{
			if (GlobalVideo.get().ended && !removedVideo)
			{
				remove(videoSprite);
				removedVideo = true;
			}
		}

		#if FEATURE_LUAMODCHART
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

			PlayStateChangeables.useDownscroll = luaModchart.getVar("downscroll", "bool");

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

			for (i in 0...dataColor.length)
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

		scoreTxt.screenCenter(X);

		var pauseBind = FlxKey.fromString(FlxG.save.data.pauseBind);
		var gppauseBind = FlxKey.fromString(FlxG.save.data.gppauseBind);

		if ((FlxG.keys.anyJustPressed([pauseBind]) || KeyBinds.gamepad && FlxG.keys.anyJustPressed([gppauseBind]))
			&& startedCountdown
			&& canPause
			&& !cannotDie)
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
				openSubState(new PauseSubState());
		}

		if (FlxG.keys.justPressed.FIVE && songStarted)
		{
			songMultiplier = 1;
			if (useVideo)
			{
				GlobalVideo.get().stop();
				remove(videoSprite);
				removedVideo = true;
			}
			cannotDie = true;

			FlxG.switchState(new WaveformTestState());
			clean();
			PlayState.stageTesting = false;
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		if (FlxG.keys.justPressed.SEVEN && songStarted)
		{
			songMultiplier = 1;
			if (useVideo)
			{
				GlobalVideo.get().stop();
				remove(videoSprite);
				removedVideo = true;
			}
			cannotDie = true;

			FlxG.switchState(new ChartingState());
			clean();
			PlayState.stageTesting = false;
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if FEATURE_LUAMODCHART
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
				removedVideo = true;
			}

			FlxG.switchState(new AnimationDebug(dad.curCharacter));
			clean();
			PlayState.stageTesting = false;
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		if (!PlayStateChangeables.Optimize)
			if (FlxG.keys.justPressed.EIGHT && songStarted)
			{
				paused = true;
				if (useVideo)
				{
					GlobalVideo.get().stop();
					remove(videoSprite);
					removedVideo = true;
				}
				new FlxTimer().start(0.3, function(tmr:FlxTimer)
				{
					for (bg in Stage.toAdd)
					{
						remove(bg);
					}
					for (array in Stage.layInFront)
					{
						for (bg in array)
							remove(bg);
					}
					for (group in Stage.swagGroup)
					{
						remove(group);
					}
					remove(boyfriend);
					remove(dad);
					remove(gf);
				});
				FlxG.switchState(new StageDebugState(Stage.curStage, gf.curCharacter, boyfriend.curCharacter, dad.curCharacter));
				clean();
				FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
				FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
				#if FEATURE_LUAMODCHART
				if (luaModchart != null)
				{
					luaModchart.die();
					luaModchart = null;
				}
				#end
			}

		if (FlxG.keys.justPressed.ZERO)
		{
			FlxG.switchState(new AnimationDebug(boyfriend.curCharacter));
			clean();
			PlayState.stageTesting = false;
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		if (FlxG.keys.justPressed.TWO && songStarted)
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

		if (skipActive && Conductor.songPosition >= skipTo)
		{
			remove(skipText);
			skipActive = false;
		}

		if (FlxG.keys.justPressed.SPACE && skipActive)
		{
			FlxG.sound.music.pause();
			vocals.pause();
			Conductor.songPosition = skipTo;
			Conductor.rawPosition = skipTo;

			FlxG.sound.music.time = Conductor.songPosition;
			FlxG.sound.music.play();

			vocals.time = Conductor.songPosition;
			vocals.play();
			FlxTween.tween(skipText, {alpha: 0}, 0.2, {
				onComplete: function(tw)
				{
					remove(skipText);
				}
			});
			skipActive = false;
		}

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				Conductor.rawPosition = Conductor.songPosition;
				if (Conductor.songPosition >= 0)
					// if (SONG.songId != 'too-seiso' || SONG.songId != 'ankimo')
					// {
					// 	startSong();
					// }
					startSong();
			}
		}
		else
		{
			Conductor.songPosition += FlxG.elapsed * 1000;
			Conductor.rawPosition = FlxG.sound.music.time;
			songPositionBar = (Conductor.songPosition - songLength) / 1000;

			currentSection = getSectionByTime(Conductor.songPosition);

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
				}

				var curTime:Float = FlxG.sound.music.time / songMultiplier;
				if (curTime < 0)
					curTime = 0;

				var secondsTotal:Int = Math.floor(((curTime - songLength) / 1000));
				if (secondsTotal < 0)
					secondsTotal = 0;

				if (FlxG.save.data.songPosition)
					songName.text = SONG.songName + ' (' + FlxStringUtil.formatTime((songLength - secondsTotal), false) + ')';
			}
		}

		if (generatedMusic && currentSection != null)
		{
			// Make sure Girlfriend cheers only for certain songs
			if (allowedToCheer)
			{
				// Don't animate GF if something else is already animating her (eg. train passing)
				if (gf.animation.curAnim.name == 'danceLeft'
					|| gf.animation.curAnim.name == 'danceRight'
					|| gf.animation.curAnim.name == 'idle')
				{
					// Per song treatment since some songs will only have the 'Hey' at certain times
					switch (curSong)
					{
						case 'Philly Nice':
							{
								// General duration of the song
								if (curBeat < 250)
								{
									// Beats to skip or to stop GF from cheering
									if (curBeat != 184 && curBeat != 216)
									{
										if (curBeat % 16 == 8)
										{
											// Just a garantee that it'll trigger just once
											if (!triggeredAlready)
											{
												gf.playAnim('cheer');
												triggeredAlready = true;
											}
										}
										else
											triggeredAlready = false;
									}
								}
							}
						case 'Bopeebo':
							{
								// Where it starts || where it ends
								if (curBeat > 5 && curBeat < 130)
								{
									if (curBeat % 8 == 7)
									{
										if (!triggeredAlready)
										{
											gf.playAnim('cheer');
											triggeredAlready = true;
										}
									}
									else
										triggeredAlready = false;
								}
							}
						case 'Blammed':
							{
								if (curBeat > 30 && curBeat < 190)
								{
									if (curBeat < 90 || curBeat > 128)
									{
										if (curBeat % 4 == 2)
										{
											if (!triggeredAlready)
											{
												gf.playAnim('cheer');
												triggeredAlready = true;
											}
										}
										else
											triggeredAlready = false;
									}
								}
							}
						case 'Cocoa':
							{
								if (curBeat < 170)
								{
									if (curBeat < 65 || curBeat > 130 && curBeat < 145)
									{
										if (curBeat % 16 == 15)
										{
											if (!triggeredAlready)
											{
												gf.playAnim('cheer');
												triggeredAlready = true;
											}
										}
										else
											triggeredAlready = false;
									}
								}
							}
						case 'Eggnog':
							{
								if (curBeat > 10 && curBeat != 111 && curBeat < 220)
								{
									if (curBeat % 8 == 7)
									{
										if (!triggeredAlready)
										{
											gf.playAnim('cheer');
											triggeredAlready = true;
										}
									}
									else
										triggeredAlready = false;
								}
							}
					}
				}
			}
			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
				luaModchart.setVar("mustHit", currentSection.mustHitSection);
			#end
			if (camLocked)
			{
				if (camFollow.x != dad.getMidpoint().x + 150 && !currentSection.mustHitSection)
				{
					var offsetX = 0;
					var offsetY = 0;

					#if FEATURE_LUAMODCHART
					if (luaModchart != null)
					{
						offsetX = luaModchart.getVar("followXOffset", "float");
						offsetY = luaModchart.getVar("followYOffset", "float");
					}
					#end
					camFollow.setPosition(dad.getMidpoint().x + 150 + offsetX, dad.getMidpoint().y - 100 + offsetY);
					#if FEATURE_LUAMODCHART
					if (luaModchart != null)
						luaModchart.executeState('playerTwoTurn', []);
					#end
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
						camFollow.x += camX;
						camFollow.y += camY;
					}
				}
				if (currentSection.mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
				{
					var offsetX = 0;
					var offsetY = 0;

					#if FEATURE_LUAMODCHART
					if (luaModchart != null)
					{
						offsetX = luaModchart.getVar("followXOffset", "float");
						offsetY = luaModchart.getVar("followYOffset", "float");
					}
					#end
					camFollow.setPosition(boyfriend.getMidpoint().x - 100 + offsetX, boyfriend.getMidpoint().y - 100 + offsetY);
					#if FEATURE_LUAMODCHART
					if (luaModchart != null)
						luaModchart.executeState('playerOneTurn', []);
					#end
					if (!PlayStateChangeables.Optimize)
					{
						switch (Stage.curStage)
						{
							case 'limo':
								camFollow.x = boyfriend.getMidpoint().x - 300;
							case 'mall':
								camFollow.y = boyfriend.getMidpoint().y - 200;
							case 'school':
								camFollow.x = boyfriend.getMidpoint().x - 200;
								camFollow.y = boyfriend.getMidpoint().y - 200;
							case 'schoolEvil':
								camFollow.x = boyfriend.getMidpoint().x - 200;
								camFollow.y = boyfriend.getMidpoint().y - 200;
							case 'SONICexestage':
								camFollow.x = boyfriend.getMidpoint().x - 170;
						}

						switch (dad.curCharacter)
						{
							case 'exe':
								FlxTween.tween(FlxG.camera, {zoom: Stage.camZoom}, 0.4, {ease: FlxEase.cubeOut});
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
					}
					if (cameramove)
					{
						// TODO Get the camera to move with BF's animations again
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
				FlxG.camera.zoom = FlxMath.lerp(Stage.camZoom, FlxG.camera.zoom, 0.95);
				camHUD.zoom = FlxMath.lerp(FlxG.save.data.zoom, camHUD.zoom, 0.95);
				camNotes.zoom = camHUD.zoom;
				camSustains.zoom = camHUD.zoom;
			}
			else
			{
				FlxG.camera.zoom = FlxMath.lerp(Stage.camZoom, FlxG.camera.zoom, 0.95);
				camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
				camNotes.zoom = camHUD.zoom;
				camSustains.zoom = camHUD.zoom;
			}
		}
		FlxG.watch.addQuick("curBPM", Conductor.bpm);
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
				if (FlxG.save.data.InstantRespawn)
				{
					FlxG.switchState(new PlayState());
				}
				else
				{
					openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				}
				#if FEATURE_DISCORD
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
			}
			else
				health = 1;
		}
		if (!inCutscene && FlxG.save.data.resetButton)
		{
			var resetBind = FlxKey.fromString(FlxG.save.data.resetBind);
			var gpresetBind = FlxKey.fromString(FlxG.save.data.gpresetBind);

			if ((FlxG.keys.anyJustPressed([resetBind]) || KeyBinds.gamepad && FlxG.keys.anyJustPressed([gpresetBind])))
			{
				boyfriend.stunned = true;
				persistentUpdate = false;
				persistentDraw = false;
				paused = true;
				vocals.stop();
				FlxG.sound.music.stop();
				if (FlxG.save.data.InstantRespawn)
				{
					FlxG.switchState(new PlayState());
				}
				else
				{
					openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				}
				#if FEATURE_DISCORD
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
			}
		}
		if (generatedMusic)
		{
			var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
			var stepHeight = (0.45 * Conductor.stepCrochet * FlxMath.roundDecimal(PlayState.SONG.speed, 2));

			notes.forEachAlive(function(daNote:Note)
			{
				// instead of doing stupid y > FlxG.height
				// we be men and actually calculate the time :)
				if (!daNote.modifiedByLua)
				{
					if (PlayStateChangeables.useDownscroll)
					{
						if (daNote.mustPress)
							daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
								+
								0.45 * ((Conductor.songPosition - daNote.strumTime) / songMultiplier) * (FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2)))
								- daNote.noteYOff;
						else
							daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
								+
								0.45 * ((Conductor.songPosition - daNote.strumTime) / songMultiplier) * (FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2)))
								- daNote.noteYOff;
						if (daNote.isSustainNote)
						{
							daNote.y -= daNote.height - stepHeight;
							// If not in botplay, only clip sustain notes when properly hit, botplay gets to clip it everytime
							if ((PlayStateChangeables.botPlay
								|| !daNote.mustPress
								|| daNote.wasGoodHit
								|| holdArray[Math.floor(Math.abs(daNote.noteData))])
								&& daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= (strumLine.y + Note.swagWidth / 2))
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
						if (daNote.isParent)
						{
							for (i in 0...daNote.children.length)
							{
								var slide = daNote.children[i];
								slide.y = daNote.y - slide.height;
							}
						}
					}
					else
					{
						if (daNote.mustPress)
							daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
								- 0.45 * ((Conductor.songPosition - daNote.strumTime) / songMultiplier) * (FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2)))
								+ daNote.noteYOff;
						else
							daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
								- 0.45 * ((Conductor.songPosition - daNote.strumTime) / songMultiplier) * (FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2)))
								+ daNote.noteYOff;
						if (daNote.isSustainNote)
						{
							if ((PlayStateChangeables.botPlay
								|| !daNote.mustPress
								|| daNote.wasGoodHit
								|| holdArray[Math.floor(Math.abs(daNote.noteData))])
								&& daNote.y + daNote.offset.y * daNote.scale.y <= (strumLine.y + Note.swagWidth / 2))
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
					}
				}
				if (!daNote.mustPress && Conductor.songPosition >= daNote.strumTime)
				{
					if (tailscircle == 'circling' && dad.curCharacter == 'TDoll')
					{
						add(ezTrail);
					}
					if (dad.curCharacter == 'sonic.exe')
					{
						FlxG.camera.shake(0.005, 0.50);
					}
					if (SONG.songId == 'sunshine' && curStep > 588 && curStep < 860 && !daNote.isSustainNote)
					{
						playerStrums.forEach(function(spr:StaticArrow)
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
						notes.forEachAlive(function(spr:Note)
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
					if (SONG.songId != 'tutorial')
						camZooming = true;
					var altAnim:String = "";
					if (daNote.isAlt)
					{
						altAnim = '-alt';
						trace("YOO WTF THIS IS AN ALT NOTE????");
					}
					// Accessing the animation name directly to play it
					if (!daNote.isParent && daNote.parent != null)
					{
						if (daNote.spotInLine != daNote.parent.children.length - 1)
						{
							var singData:Int = Std.int(Math.abs(daNote.noteData));
							if (!isRing || (isRing && singData != 2) && daNote.noteType != 3)
								dad.playAnim('sing' + dataSuffix[singData] + altAnim, true);
							switch (singData)
							{
								case 0:
									camX = -15;
									camY = 0;
								case 1:
									camX = 0;
									camY = 15;
								case 2:
									if (!isRing)
									{
										camX = 0;
										camY = -15;
									}
								case 3:
									if (!isRing)
									{
										camX = 15;
										camY = 0;
									}
									else
									{
										camX = 0;
										camY = -15;
									}
								case 4:
									if (isRing)
									{
										camX = 15;
										camY = 0;
									}
							}
							if (FlxG.save.data.cpuStrums && daNote.noteType != 3)
							{
								cpuStrums.forEach(function(spr:StaticArrow)
								{
									pressArrow(spr, spr.ID, daNote);
								});
							}
							#if FEATURE_LUAMODCHART
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
						if (!isRing || (isRing && singData != 2) && daNote.noteType != 3)
							dad.playAnim('sing' + dataSuffix[singData] + altAnim, true);
						if (FlxG.save.data.cpuStrums && daNote.noteType != 3)
						{
							cpuStrums.forEach(function(spr:StaticArrow)
							{
								pressArrow(spr, spr.ID, daNote);
							});
						}
						#if FEATURE_LUAMODCHART
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
				if (daNote.mustPress && !daNote.modifiedByLua)
				{
					daNote.visible = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].visible;
					daNote.x = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x;
					if (!daNote.isSustainNote)
						daNote.modAngle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].modAngle;
					if (daNote.sustainActive)
					{
						if (executeModchart)
							daNote.alpha = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					}
					daNote.modAngle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].modAngle;
				}
				else if (!daNote.wasGoodHit && !daNote.modifiedByLua)
				{
					daNote.visible = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].visible;
					daNote.x = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].x;
					if (!daNote.isSustainNote)
						daNote.modAngle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].modAngle;
					if (daNote.sustainActive)
					{
						if (executeModchart)
							daNote.alpha = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					}
					daNote.modAngle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].modAngle;
				}
				if (!daNote.mustPress && FlxG.save.data.middleScroll && !executeModchart)
					daNote.alpha = 0;
				playerSplashes.forEach(function(spr:FlxSprite)
				{
					playerStrums.forEach(function(spr2:StaticArrow)
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
				else if ((daNote.mustPress && !PlayStateChangeables.useDownscroll || daNote.mustPress && PlayStateChangeables.useDownscroll)
					&& daNote.mustPress
					&& daNote.strumTime / songMultiplier - Conductor.songPosition / songMultiplier < -(166 * Conductor.timeScale)
					&& songStarted)
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
							if (SONG.songId != 'white-moon' && cNum == 0)
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
							if (!isRing || (isRing && daNote.noteData != 2))
							{
								if (SONG.songId != 'white-moon' && cNum == 0)
									health -= 0.075;
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
										// health -= 0.05; // give a health punishment for failing a LN
										trace("hold fell over at " + daNote.spotInLine);
										for (i in daNote.parent.children)
										{
											i.alpha = 0.3;
											i.sustainActive = false;
										}
										if (daNote.parent.wasGoodHit)
										{
											misses++;
											totalNotesHit -= 1;
										}
										updateAccuracy();
									}
									else if (!daNote.wasGoodHit && !daNote.isSustainNote)
									{
										health -= 0.15;
									}
								}
							}
						}
						else
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
							if (daNote.isParent && daNote.visible)
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
									// health -= 0.05; // give a health punishment for failing a LN
									trace("hold fell over at " + daNote.spotInLine);
									for (i in daNote.parent.children)
									{
										i.alpha = 0.3;
										i.sustainActive = false;
									}
									if (daNote.parent.wasGoodHit)
									{
										misses++;
										totalNotesHit -= 1;
									}
									updateAccuracy();
								}
								else if (!daNote.wasGoodHit && !daNote.isSustainNote)
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
			cpuStrums.forEach(function(spr:StaticArrow)
			{
				if (spr.animation.finished)
				{
					spr.playAnim('static');
					spr.centerOffsets();
				}
			});
		}
		if (!inCutscene && songStarted)
			keyShit();
		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
		super.update(elapsed);
	}

	public function getSectionByTime(ms:Float):SwagSection
	{
		for (i in SONG.notes)
		{
			var start = TimingStruct.getTimeFromBeat((TimingStruct.getBeatFromTime(i.startTime)));
			var end = TimingStruct.getTimeFromBeat((TimingStruct.getBeatFromTime(i.endTime)));

			if (ms >= start && ms < end)
			{
				return i;
			}
		}

		return null;
	}

	function recalculateAllSectionTimes()
	{
		trace("RECALCULATING SECTION TIMES");

		for (i in 0...SONG.notes.length) // loops through sections
		{
			var section = SONG.notes[i];

			var currentBeat = 4 * i;

			var currentSeg = TimingStruct.getTimingAtBeat(currentBeat);

			if (currentSeg == null)
				return;

			var start:Float = (currentBeat - currentSeg.startBeat) / ((currentSeg.bpm) / 60);

			section.startTime = (currentSeg.startTime + start) * 1000;

			if (i != 0)
				SONG.notes[i - 1].endTime = section.startTime;
			section.endTime = Math.POSITIVE_INFINITY;
		}
	}

	function endSong():Void
	{
		endingSong = true;
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
		if (useVideo)
		{
			GlobalVideo.get().stop();
			PlayState.instance.remove(PlayState.instance.videoSprite);
		}

		if (!loadRep)
			rep.SaveReplay(saveNotes, saveJudge, replayAna);
		else
		{
			PlayStateChangeables.botPlay = false;
			PlayStateChangeables.scrollSpeed = 1 / songMultiplier;
			PlayStateChangeables.useDownscroll = false;
		}

		if (FlxG.save.data.fpsCap > 290)
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(290);

		#if FEATURE_LUAMODCHART
		if (luaModchart != null)
		{
			luaModchart.die();
			luaModchart = null;
		}
		#end

		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		FlxG.sound.music.stop();
		vocals.stop();
		if (SONG.validScore)
		{
			#if !switch
			Highscore.saveScore(PlayState.SONG.songId, Math.round(songScore), storyDifficulty);
			Highscore.saveCombo(PlayState.SONG.songId, Ratings.GenerateLetterRank(accuracy), storyDifficulty);
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
		else if (stageTesting)
		{
			new FlxTimer().start(0.3, function(tmr:FlxTimer)
			{
				for (bg in Stage.toAdd)
				{
					remove(bg);
				}
				for (array in Stage.layInFront)
				{
					for (bg in array)
						remove(bg);
				}
				remove(boyfriend);
				remove(dad);
				remove(gf);
			});
			FlxG.switchState(new StageDebugState(Stage.curStage));
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

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					transIn = FlxTransitionableState.defaultTransIn;
					transOut = FlxTransitionableState.defaultTransOut;

					paused = true;

					FlxG.sound.music.stop();
					vocals.stop();

					if (FlxG.save.data.scoreScreen)
					{
						if (FlxG.save.data.songPosition)
						{
							FlxTween.tween(songPosBar, {alpha: 0}, 1);
							FlxTween.tween(bar, {alpha: 0}, 1);
							FlxTween.tween(songName, {alpha: 0}, 1);
						}
						openSubState(new ResultsScreen());
						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							inResults = true;
						});
					}
					else
					{
						GameplayCustomizeState.freeplayBf = 'bf';
						GameplayCustomizeState.freeplayDad = 'dad';
						GameplayCustomizeState.freeplayGf = 'gf';
						GameplayCustomizeState.freeplayNoteStyle = 'normal';
						GameplayCustomizeState.freeplayStage = 'stage';
						GameplayCustomizeState.freeplaySong = 'bopeebo';
						GameplayCustomizeState.freeplayWeek = 1;
						FlxG.sound.playMusic(Paths.music('freakyMenu'));
						Conductor.changeBPM(102);
						FlxG.switchState(new StoryMenuState());
						clean();
					}

					isList = false;

					if (SONG.songId == 'triple-talent')
					{
						var video:MP4Handler = new MP4Handler();
						video.playMP4(Paths.video('soundtestcodes'));
						video.finishCallback = function()
						{
							LoadingState.loadAndSwitchState(new StoryMenuState());
						}
					}

					#if FEATURE_LUAMODCHART
					if (luaModchart != null)
					{
						luaModchart.die();
						luaModchart = null;
					}
					#end

					if (SONG.validScore)
					{
						Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
					}

					StoryMenuState.unlockNextWeek(storyWeek);
				}
				else
				{
					var diff:String = ["-easy", "", "-hard"][storyDifficulty];

					Debug.logInfo('PlayState: Loading next story song ${PlayState.storyPlaylist[0]}-${diff}');

					if (StringTools.replace(PlayState.storyPlaylist[0], " ", "-").toLowerCase() == 'eggnog')
					{
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;

						FlxG.sound.play(Paths.sound('Lights_Shut_off'));
					}

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					prevCamFollow = camFollow;

					var previousSong = SONG.songId;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0], diff);
					FlxG.sound.music.stop();

					switch (previousSong)
					{
						case 'too-seiso':
							if (storyDifficulty >= 2)
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
							else
								LoadingState.loadAndSwitchState(new UnlockScreen(false, 'soundtest'));
						case 'you-cant-kusa':
							if (FlxG.save.data.storyProgress < 2)
								FlxG.save.data.storyProgress = 2;
							FlxG.save.data.soundTestUnlocked = true;
							var video:MP4Handler = new MP4Handler();
							video.playMP4(Paths.video('youcantruncutscene2'));
							video.finishCallback = function()
							{
								LoadingState.loadAndSwitchState(new PlayState());
							}
						default:
							LoadingState.loadAndSwitchState(new PlayState());
					}
					clean();

					if (SONG.songId == 'caretaker')
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

				if (FlxG.save.data.scoreScreen)
				{
					openSubState(new ResultsScreen());
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						inResults = true;
					});
				}
				else
				{
					FlxG.switchState(new FreeplayState());
					clean();
				}
			}
		}
	}

	public var endingSong:Bool = false;

	var hits:Array<Float> = [];
	var offsetTest:Float = 0;

	public function getRatesScore(rate:Float, score:Float):Float
	{
		var rateX:Float = 1;
		var lastScore:Float = score;
		var pr = rate - 0.05;
		if (pr < 1.00)
			pr = 1;

		while (rateX <= pr)
		{
			if (rateX > pr)
				break;
			lastScore = score + ((lastScore * rateX) * 0.022);
			rateX += 0.05;
		}

		var actualScore = Math.round(score + (Math.floor((lastScore * pr)) * 0.022));

		return actualScore;
	}

	var timeShown = 0;
	var currentTimingShown:FlxText = null;

	private function popUpScore(daNote:Note):Void
	{
		if (popup)
		{
			var noteDiff:Float;
			if (daNote != null)
				noteDiff = -(daNote.strumTime - Conductor.songPosition);
			else
				noteDiff = Conductor.safeZoneOffset; // Assumed SHIT if no note was given
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

			var daRating = Ratings.judgeNote(noteDiff);

			switch (daRating)
			{
				case 'shit':
					score = -300;
					combo = 0;
					misses++;
					if (SONG.songId != 'white-moon')
						health -= 0.1;
					ss = false;
					shits++;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit -= 1;
				case 'bad':
					daRating = 'bad';
					score = 0;
					if (SONG.songId != 'white-moon')
						health -= 0.06;
					ss = false;
					bads++;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 0.50;
				case 'good':
					daRating = 'good';
					score = 200;
					ss = false;
					goods++;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 0.75;
				case 'sick':
					if (health < 2 && SONG.songId != 'white-moon')
						health += 0.04;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 1;
					sicks++;
					playerSplashes.forEach(function(spr:FlxSprite)
					{
						if (spr.ID == daNote.noteData && FlxG.save.data.splashing)
							spr.animation.play('a', true);
					});
			}

			if (songMultiplier >= 1.05)
				score = getRatesScore(songMultiplier, score);

			// trace('Wife accuracy loss: ' + wife + ' | Rating: ' + daRating + ' | Score: ' + score + ' | Weight: ' + (1 - wife));

			if (daRating != 'shit' || daRating != 'bad')
			{
				songScore += Math.round(score);

				/* if (combo > 60)
						daRating = 'sick';
					else if (combo > 12)
						daRating = 'good'
					else if (combo > 4)
						daRating = 'bad';
				 */

				var pixelShitPart1:String = "";
				var pixelShitPart2:String = '';
				var pixelShitPart3:String = null;

				if (SONG.noteStyle == 'pixel')
				{
					pixelShitPart1 = 'weeb/pixelUI/';
					pixelShitPart2 = '-pixel';
					pixelShitPart3 = 'exe';
				}

				rating.loadGraphic(Paths.loadImage(pixelShitPart1 + daRating + pixelShitPart2, pixelShitPart3));
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

				var msTiming = HelperFunctions.truncateFloat(noteDiff / songMultiplier, 3);
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

				var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage(pixelShitPart1 + 'combo' + pixelShitPart2, pixelShitPart3));
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

				if (SONG.noteStyle != 'pixel')
				{
					rating.setGraphicSize(Std.int(rating.width * 0.7));
					rating.antialiasing = FlxG.save.data.antialiasing;
					comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
					comboSpr.antialiasing = FlxG.save.data.antialiasing;
				}
				else
				{
					rating.setGraphicSize(Std.int(rating.width * CoolUtil.daPixelZoom * 0.7));
					comboSpr.setGraphicSize(Std.int(comboSpr.width * CoolUtil.daPixelZoom * 0.7));
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
					var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2,
						pixelShitPart3));
					numScore.screenCenter();
					numScore.x = rating.x + (43 * daLoop) - 50;
					numScore.y = rating.y + 100;
					numScore.cameras = [camHUD];

					if (SONG.noteStyle != 'pixel')
					{
						numScore.antialiasing = FlxG.save.data.antialiasing;
						numScore.setGraphicSize(Std.int(numScore.width * 0.5));
					}
					else
					{
						numScore.setGraphicSize(Std.int(numScore.width * CoolUtil.daPixelZoom));
					}
					numScore.updateHitbox();

					numScore.acceleration.y = FlxG.random.int(200, 300);
					numScore.velocity.y -= FlxG.random.int(140, 160);
					numScore.velocity.x = FlxG.random.float(-5, 5);

					add(numScore);

					visibleCombos.push(numScore);

					FlxTween.tween(numScore, {alpha: 0}, 0.2, {
						onComplete: function(tween:FlxTween)
						{
							visibleCombos.remove(numScore);
							numScore.destroy();
						},
						onUpdate: function(tween:FlxTween)
						{
							if (!visibleCombos.contains(numScore))
							{
								tween.cancel();
								numScore.destroy();
							}
						},
						startDelay: Conductor.crochet * 0.002
					});

					if (visibleCombos.length > seperatedScore.length + 20)
					{
						for (i in 0...seperatedScore.length - 1)
						{
							visibleCombos.remove(visibleCombos[visibleCombos.length - 1]);
						}
					}

					daLoop++;
				}
				/* 
					/* 
						/* 
							/* 
								/* 
							/* 
								/* 
									/* 
										/* 
									/* 
										/* 
											/* 
												/* 
													/* 
														/* 
															/* 
																/* 
																	/* 
																		/* 
																			/* 
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
	}

	public function NearlyEquals(value1:Float, value2:Float, unimportantDifference:Float = 10):Bool
	{
		return Math.abs(FlxMath.roundDecimal(value1, 1) - FlxMath.roundDecimal(value2, 1)) < unimportantDifference;
	}

	var upHold:Bool = false;
	var downHold:Bool = false;
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

		#if FEATURE_LUAMODCHART
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
					if (daNote.canBeHit && daNote.mustPress && !daNote.wasGoodHit && !directionsAccounted[daNote.noteData])
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
							anas[coolNote.noteData].hitJudge = Ratings.judgeNote(noteDiff);
							anas[coolNote.noteData].nearestNote = [coolNote.strumTime, coolNote.noteData, coolNote.sustainLength];
							goodNoteHit(coolNote);
						}
					}
				}

				if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || PlayStateChangeables.botPlay))
				{
					if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
					{
						boyfriend.dance();
						// bfcamX = 0;
						// bfcamY = 0;
					}
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
				if (daNote.mustPress && Conductor.songPosition >= daNote.strumTime)
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
							boyfriend.holdTimer = 0;
						}
					}
					else if (daNote.noteType != 3)
					{
						goodNoteHit(daNote);
						boyfriend.holdTimer = 0;
					}
				}
			});

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || PlayStateChangeables.botPlay))
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing')
				&& !boyfriend.animation.curAnim.name.endsWith('miss')
				&& (boyfriend.animation.curAnim.curFrame >= 10 || boyfriend.animation.curAnim.finished))
			{
				boyfriend.dance();
				// bfcamX = 0;
				// bfcamY = 0;
			}
		}

		playerStrums.forEach(function(spr:StaticArrow)
		{
			if (!PlayStateChangeables.botPlay)
			{
				if (keys[spr.ID]
					&& spr.animation.curAnim.name != 'confirm'
					&& spr.animation.curAnim.name != 'pressed'
					&& !spr.animation.curAnim.name.startsWith('dirCon'))
					spr.playAnim('pressed', false);
				if (!keys[spr.ID])
					spr.playAnim('static', false);
			}
			else if (FlxG.save.data.cpuStrums)
			{
				if (spr.animation.finished)
					spr.playAnim('static');
			}
		});
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

	public function backgroundVideo(source:String) // for background videos
	{
		#if FEATURE_WEBM
		useVideo = true;

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
				if (SONG.songId != 'white-moon' && cNum == 0)
				{
					health -= 0.04;
				}
				else
					cNum -= 1;
				// health -= 0.2;
				if (combo > 5 && gf.animOffsets.exists('sad'))
				{
					gf.playAnim('sad');
				}
				if (combo != 0)
				{
					combo = 0;
					popUpScore(null);
				}
				misses++;

				if (daNote != null)
				{
					if (!loadRep)
					{
						saveNotes.push([
							daNote.strumTime,
							0,
							direction,
							-(166 * Math.floor((PlayState.rep.replay.sf / 60) * 1000) / 166)
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
						-(166 * Math.floor((PlayState.rep.replay.sf / 60) * 1000) / 166)
					]);
					saveJudge.push("miss");
				}

				// var noteDiff:Float = Math.abs(daNote.strumTime - Conductor.songPosition);
				// var wife:Float = EtternaFunctions.wife3(noteDiff, FlxG.save.data.etternaMode ? 1 : 1.7);

				totalNotesHit -= 1;

				if (daNote != null)
				{
					if (!daNote.isSustainNote)
						songScore -= 10;
				}
				else
					songScore -= 10;

				if (FlxG.save.data.missSounds)
				{
					FlxG.sound.play(Paths.soundRandom('missnote' + altSuffix, 1, 3), FlxG.random.float(0.1, 0.2));
					// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
					// FlxG.log.add('played imss note');
				}

				// Hole switch statement replaced with a single line :)
				if (!isRing || (isRing && direction != 2))
					boyfriend.playAnim('sing' + dataSuffix[direction] + 'miss', true);

				switch (direction)
				{
					case 0:
						bfcamX = -15;
						bfcamY = 0;
					case 1:
						bfcamX = 0;
						bfcamY = 15;
					case 2:
						if (!isRing)
						{
							bfcamX = 0;
							bfcamY = -15;
						}
					case 3:
						if (!isRing)
						{
							bfcamX = 15;
							bfcamY = 0;
						}
						else
						{
							bfcamX = 0;
							bfcamY = -15;
						}
					case 4:
						if (isRing)
						{
							bfcamX = 15;
							bfcamY = 0;
						}
				}

				#if FEATURE_LUAMODCHART
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

		scoreTxt.text = Ratings.CalculateRanking(songScore, songScoreDef, nps, maxNPS, accuracy);
		judgementCounter.text = 'Sicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}\nMisses: ${misses}';
	}

	function getKeyPresses(note:Note):Int
	{
		var possibleNotes:Array<Note> = []; // copypasted but you already know that

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress)
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

		note.rating = Ratings.judgeNote(noteDiff);

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
			note.rating = Ratings.judgeNote(noteDiff);

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
				if (!isRing || (isRing && note.noteData != 2) && note.noteType != 3)
				{
					combo += 1;
					popUpScore(note);
				}
			}

			var altAnim:String = "";
			if (note.isAlt)
			{
				altAnim = '-alt';
				trace("Alt note on BF");
			}

			if (!isRing || (isRing && note.noteData != 2))
				boyfriend.playAnim('sing' + dataSuffix[note.noteData] + altAnim, true);

			var singData:Int = Std.int(Math.abs(note.noteData));
			switch (singData)
			{
				case 0:
					bfcamX = -15;
					bfcamY = 0;
				case 1:
					bfcamX = 0;
					bfcamY = 15;
				case 2:
					if (!isRing)
					{
						bfcamX = 0;
						bfcamY = -15;
					}
				case 3:
					if (!isRing)
					{
						bfcamX = 15;
						bfcamY = 0;
					}
					else
					{
						bfcamX = 0;
						bfcamY = -15;
					}
				case 4:
					if (isRing)
					{
						bfcamX = 15;
						bfcamY = 0;
					}
			}

			#if FEATURE_LUAMODCHART
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

			if (!PlayStateChangeables.botPlay || FlxG.save.data.cpuStrums)
			{
				playerStrums.forEach(function(spr:StaticArrow)
				{
					pressArrow(spr, spr.ID, note);
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
			if (!note.isSustainNote)
				updateAccuracy();
		}
	}

	function pressArrow(spr:StaticArrow, idCheck:Int, daNote:Note)
	{
		if (Math.abs(daNote.noteData) == idCheck)
		{
			if (!FlxG.save.data.stepMania)
			{
				spr.playAnim('confirm', true);
			}
			else
			{
				spr.playAnim('dirCon' + daNote.originColor, true);
				spr.localAngle = daNote.originAngle;
			}
		}
	}

	var danced:Bool = false;
	var stepOfLast = 0;

	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.rawPosition + 20 || FlxG.sound.music.time < Conductor.rawPosition - 20)
		{
			resyncVocals();
		}

		if (dad.curCharacter == 'suisei' && SONG.songId == 'too-seiso')
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

		if (dad.curCharacter == 'sonicfun' && SONG.songId == 'circus')
		{
			switch (curStep)
			{
				case 10:
					FlxG.sound.play(Paths.sound('laugh1', 'shared'), 0.7);
			}

			var spinArray = [
				272, 276, 336, 340, 400, 404, 464, 468, 528, 532, 592, 596, 656, 660, 720, 724, 784, 788, 848, 852, 912, 916, 976, 980, 1040, 1044, 1104,
				1108, 1424, 1428, 1488, 1492, 1552, 1556, 1616, 1620
			];
			if (spinArray.contains(curStep))
			{
				// TODO Get this to work again
				strumLineNotes.forEach(function(tospin:StaticArrow)
				{
					FlxTween.angle(tospin, 0, 360, 0.2, {ease: FlxEase.quintOut});
				});
			}
		}

		if (dad.curCharacter == 'suisei' && SONG.songId == 'too-seiso' && curStep == 791)
		{
			shakeCam = false;
			shakeCam2 = false;
		}

		if (Stage.curStage == 'sonicFUNSTAGE' && curStep != stepOfLast)
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
					FlxTween.tween(FlxG.camera, {zoom: Stage.camZoom}, 0.7, {ease: FlxEase.cubeInOut});
					gofun();
					SONG.noteStyle = 'majin';
					removeStatics();
					generateStaticArrows(0, false);
					generateStaticArrows(1, false);
					appearStaticArrows();
			}
		}

		if (Stage.curStage == 'SONICstage' && curStep != stepOfLast && FlxG.save.data.jumpscares)
		{
			var staticSteps:Array<Int> = [
				27, 130, 265, 450, 645, 800, 855, 889, 921, 938, 981, 1030, 1065, 1105, 1123, 1245, 1345, 1432, 1454, 1495, 1521, 1558, 1578, 1599, 1618,
				1647, 1657, 1692, 1713, 1738, 1747, 1761, 1785, 1806, 1816, 1832, 1849, 1868, 1887, 1909
			];

			if (staticSteps.contains(curStep))
				doStaticSign(0);

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

		if (SONG.songId == 'ankimo')
		{
			switch (curStep)
			{
				case 320:
					FlxTween.tween(FlxG.camera, {zoom: .9}, 2, {ease: FlxEase.cubeOut});
					Stage.camZoom = .9;
				case 1103:
					FlxTween.tween(FlxG.camera, {zoom: .8}, 2, {ease: FlxEase.cubeOut});
					Stage.camZoom = .8;
			}
		}

		if (SONG.songId == 'you-cant-kusa')
		{
			var vg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('RedVG', 'exe'));
			vg.alpha = 0;
			vg.cameras = [camHUD];
			add(vg);

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
				appearStaticArrows();

				removeObject(dad);
				dad = new Character(100, 350, 'sonic.exe alt');
				addObject(dad);
				iconP2.changeIcon('sonic.exe alt');

				removeObject(gf);
				gf = new Character(400, 130, 'gf-pixel');
				addObject(gf);

				removeObject(boyfriend);
				boyfriend = new Boyfriend(630, 370, 'bf-pixel');
				addObject(boyfriend);
				iconP1.changeIcon('bf-pixel');

				Stage.swagBacks['bgspec'].visible = true;
			}
			else if (curStep == 784) // BACK TO NORMAL MF!!!
			{
				healthBar.createFilledBar(FlxColor.fromRGB(0, 19, 102), FlxColor.fromRGB(49, 176, 209));

				doStaticSign(0, false);
				SONG.noteStyle = 'normal';
				removeStatics();
				generateStaticArrows(0, false);
				generateStaticArrows(1, false);
				appearStaticArrows();

				removeObject(dad);
				dad = new Character(100, -25, 'sonic.exe');
				addObject(dad);
				iconP2.changeIcon('sonic.exe');

				removeObject(gf);
				gf = new Character(486, 15, 'gf');
				addObject(gf);

				removeObject(boyfriend);
				boyfriend = new Boyfriend(936, 300, 'bf');
				addObject(boyfriend);
				iconP1.changeIcon('bf');

				Stage.swagBacks['bgspec'].visible = false;
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
		if (SONG.songId == 'asacoco')
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
				FlxG.camera.zoom = Stage.camZoom;
			}
		}
		if (SONG.songId == 'sunshine')
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
				playerStrums.forEach(function(spr:StaticArrow)
				{
					if (!FlxG.save.data.midscroll)
						spr.x -= 275;
				});
				popup = false;
				gf.visible = false;
				boyfriend.alpha = 0;
				Stage.swagBacks['bgspec'].visible = false;
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
				cpuStrums.forEach(function(spr:StaticArrow)
				{
					spr.visible = false;
				});
				playerStrums.forEach(function(spr:StaticArrow)
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
				playerStrums.forEach(function(spr:StaticArrow)
				{
					if (!FlxG.save.data.midscroll)
						spr.x += 275;
				});
				popup = true;
				gf.visible = true;
				boyfriend.alpha = 1;
				Stage.swagBacks['bgspec'].visible = true;
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
				cpuStrums.forEach(function(spr:StaticArrow)
				{
					if (!FlxG.save.data.midscroll)
					{
						spr.visible = true;
					}
				});
				playerStrums.forEach(function(spr:StaticArrow)
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

		if (SONG.songId == 'caretaker')
		{
			switch (curStep)
			{
				case 787, 795, 902, 800, 811, 819, 823, 827, 832, 835, 839, 847:
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

		if (SONG.songId == 'koyochaos')
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
				case 380, 509, 637, 773, 1033, 1149:
					tailscircle = '';
					FlxTween.tween(dad, {x: 61.15, y: -94.75}, 0.2);
					dad.setPosition(61.15, -94.75);
			}
		}

		if (SONG.songId.toLowerCase() == 'triple-talent')
		{
			switch (curStep)
			{
				case 1:
					doP3Static(); // cool static
					FlxTween.tween(FlxG.camera, {zoom: 1.1}, 2, {ease: FlxEase.cubeOut});
					Stage.camZoom = 1.1;
				case 144:
					doP3JumpTAILS();
				case 1024, 1088, 1216, 1280, 2305, 2810, 3199, 4096:
					doP3Static();
				case 1040: // switch to sonic facing right

					FlxTween.tween(FlxG.camera, {zoom: 0.9}, 2, {ease: FlxEase.cubeOut});
					Stage.camZoom = 0.9;

					healthBar.createFilledBar(FlxColor.fromRGB(182, 0, 205), FlxColor.fromRGB(49, 176, 209));

					Stage.swagBacks['p3staticbg'].visible = true;

					remove(dad);
					dad = new Character(20 - 200, -94.75 + 100, 'beast');
					add(dad);

					// dad.addOffset('idle', -18, 70); // BEAST SONIC LOOKING RIGHT
					// dad.addOffset("singUP", 22, 143);
					// dad.addOffset("singRIGHT", -260, 11);
					// dad.addOffset("singLEFT", 177, -24);
					// dad.addOffset("singDOWN", -15, -57);
					// dad.addOffset("laugh", -78, -128);

					iconP2.changeIcon('beast');

					remove(boyfriend);
					boyfriend = new Boyfriend(502.45 + 200, 370.45, 'bf-perspective-flipped');
					add(boyfriend);

				case 1296: // switch to knuckles facing left facing right and bf facing right, and cool static

					FlxTween.tween(FlxG.camera, {zoom: 1.1}, 2, {ease: FlxEase.cubeOut});
					Stage.camZoom = 1.1;

					Stage.swagBacks['p3staticbg'].visible = false;

					remove(dad);
					dad = new Character(1300 + 100 - 206, 260 + 44, 'knucks');
					add(dad);
					healthBar.createFilledBar(FlxColor.fromRGB(150, 0, 0), FlxColor.fromRGB(49, 176, 209));

					iconP2.changeIcon('knucks');
					iconP1.changeIcon('bf');

					cpuStrums.forEach(function(spr:StaticArrow)
					{
						if (!FlxG.save.data.midscroll)
							FlxTween.tween(spr, {x: spr.x += 600, y: spr.y}, 5, {ease: FlxEase.quartOut});
					});
					playerStrums.forEach(function(spr:StaticArrow)
					{
						if (!FlxG.save.data.midscroll)
							FlxTween.tween(spr, {x: spr.x -= 700, y: spr.y}, 5, {ease: FlxEase.quartOut});
					});

					// dad.addOffset("singRIGHT", -59, -65);
					// dad.addOffset("singLEFT", 124, -59);
					// dad.addOffset("singUP", 29, 49);
					// dad.addOffset("singDOWN", 26, -95);

					dad.flipX = true;

					remove(boyfriend);
					boyfriend = new Boyfriend(466.1, 685.6 - 300, 'bf-flipped-for-cam');
					add(boyfriend);

					boyfriend.flipX = false;

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
					Stage.camZoom = 0.9;

					Stage.swagBacks['p3staticbg'].visible = true;

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

					boyfriend.flipX = true;

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
					Stage.camZoom = 1;

					cpuStrums.forEach(function(spr:StaticArrow)
					{
						if (!FlxG.save.data.midscroll)
							FlxTween.tween(spr, {x: spr.x -= 600, y: spr.y}, 5, {ease: FlxEase.quartOut});
					});
					playerStrums.forEach(function(spr:StaticArrow)
					{
						if (!FlxG.save.data.midscroll)
							FlxTween.tween(spr, {x: spr.x += 700, y: spr.y}, 5, {ease: FlxEase.quartOut});
					});

					Stage.swagBacks['p3staticbg'].visible = false;

					remove(dad);
					dad = new Character(20 - 200, 30 + 200, 'eggdickface');
					add(dad);

					// dad.camFollow.y = dad.getMidpoint().y;
					// dad.camFollow.x = dad.getMidpoint().x + 300;

					healthBar.createFilledBar(FlxColor.fromRGB(194, 80, 0), FlxColor.fromRGB(49, 176, 209));

					iconP2.changeIcon('eggdickface');

					dad.flipX = false;

					// dad.addOffset('idle', -5, 5);
					// dad.addOffset("singUP", 110, 231);
					// dad.addOffset("singRIGHT", 40, 174);
					// dad.addOffset("singLEFT", 237, 97);
					// dad.addOffset("singDOWN", 49, -95);
					// dad.addOffset('laugh', -10, 210);

					remove(boyfriend);
					boyfriend = new Boyfriend(466.1 + 200, 685.6 - 250, 'bf');
					add(boyfriend);

				// boyfriend.addOffset('idle', -5);
				// boyfriend.addOffset("singUP", -29, 27);
				// boyfriend.addOffset("singRIGHT", -38, -7);
				// boyfriend.addOffset("singLEFT", 12, -6);
				// boyfriend.addOffset("singDOWN", -10, -50);
				// boyfriend.addOffset("singUPmiss", -29, 27);
				// boyfriend.addOffset("singRIGHTmiss", -30, 21);
				// boyfriend.addOffset("singLEFTmiss", 12, 24);
				// boyfriend.addOffset("singDOWNmiss", -11, -19);

				case 2887, 3015, 4039:
					dad.playAnim('laugh', true);
					dad.nonanimated = true;
				case 2895, 3023, 4048:
					dad.nonanimated = false;

				case 4111:
					Stage.swagBacks['p3staticbg'].visible = true;
					remove(dad);
					dad = new Character(20 - 200, -94.75 + 100, 'beast');
					add(dad);

					// dad.addOffset('idle', -18, 70); // BEAST SONIC LOOKING RIGHT
					// dad.addOffset("singUP", 22, 143);
					// dad.addOffset("singRIGHT", -260, 11);
					// dad.addOffset("singLEFT", 177, -24);
					// dad.addOffset("singDOWN", -15, -57);
					// dad.addOffset("laugh", -78, -128);

					healthBar.createFilledBar(FlxColor.fromRGB(182, 0, 205), FlxColor.fromRGB(49, 176, 209));

					iconP2.changeIcon('beast');

					remove(boyfriend);
					boyfriend = new Boyfriend(502.45, 370.45, 'bf-perspective-flipped');
					add(boyfriend);
			}
		}

		#if FEATURE_LUAMODCHART
		if (executeModchart && luaModchart != null)
		{
			luaModchart.setVar('curStep', curStep);
			luaModchart.executeState('stepHit', [curStep]);
		}
		#end
	}

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, (PlayStateChangeables.useDownscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));
		}

		#if FEATURE_LUAMODCHART
		if (executeModchart && luaModchart != null)
		{
			luaModchart.executeState('beatHit', [curBeat]);
		}
		#end

		if (currentSection != null)
		{
			if (tailscircle == 'circling' && dad.curCharacter == 'TDoll')
				remove(ezTrail);
			if (curBeat % idleBeat == 0)
			{
				if (idleToBeat && !dad.animation.curAnim.name.startsWith('sing'))
				{
					dad.dance(forcedToIdle, currentSection.CPUAltAnim);
					camX = 0;
					camY = 0;
				}
				if (idleToBeat && !boyfriend.animation.curAnim.name.startsWith('sing'))
				{
					boyfriend.dance(forcedToIdle, currentSection.playerAltAnim);
					bfcamX = 0;
					bfcamY = 0;
				}
			}
			else if ((dad.curCharacter == 'spooky' || dad.curCharacter == 'gf') && !dad.animation.curAnim.name.startsWith('sing'))
			{
				dad.dance(forcedToIdle, currentSection.CPUAltAnim);
				camX = 0;
				camY = 0;
			}
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		if (FlxG.save.data.camzoom && songMultiplier == 1)
		{
			// HARDCODING FOR MILF ZOOMS!
			if (SONG.songId == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
			{
				FlxG.camera.zoom += 0.015 / songMultiplier;
				camHUD.zoom += 0.03 / songMultiplier;
			}

			if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
			{
				FlxG.camera.zoom += 0.015 / songMultiplier;
				camHUD.zoom += 0.03 / songMultiplier;
			}
		}
		if (songMultiplier == 1)
		{
			iconP1.setGraphicSize(Std.int(iconP1.width + 30));
			iconP2.setGraphicSize(Std.int(iconP2.width + 30));

			iconP1.updateHitbox();
			iconP2.updateHitbox();
		}
		else
		{
			iconP1.setGraphicSize(Std.int(iconP1.width + 4));
			iconP2.setGraphicSize(Std.int(iconP2.width + 4));

			iconP1.updateHitbox();
			iconP2.updateHitbox();
		}

		if (!endingSong && currentSection != null)
		{
			if (allowedToHeadbang)
			{
				gf.dance();
			}

			if (curBeat % 8 == 7 && curSong == 'Bopeebo')
			{
				boyfriend.playAnim('hey', true);
			}

			if (curBeat % 16 == 15 && SONG.songId == 'tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
			{
				if (vocals.volume != 0)
				{
					boyfriend.playAnim('hey', true);
					dad.playAnim('cheer', true);
				}
				else
				{
					dad.playAnim('sad', true);
					FlxG.sound.play(Paths.soundRandom('GF_', 1, 4, 'shared'), 0.3);
				}
			}

			if (PlayStateChangeables.Optimize)
				if (vocals.volume == 0 && !currentSection.mustHitSection)
					vocals.volume = 1;
		}
	}

	public var cleanedSong:SongData;

	function poggers(?cleanTheSong = false)
	{
		var notes = [];

		if (cleanTheSong)
		{
			cleanedSong = SONG;

			for (section in cleanedSong.notes)
			{
				var removed = [];

				for (note in section.sectionNotes)
				{
					// commit suicide
					var old = note[0];
					if (note[0] < section.startTime)
					{
						notes.push(note);
						removed.push(note);
					}
					if (note[0] > section.endTime)
					{
						notes.push(note);
						removed.push(note);
					}
				}

				for (i in removed)
				{
					section.sectionNotes.remove(i);
				}
			}

			for (section in cleanedSong.notes)
			{
				var saveRemove = [];

				for (i in notes)
				{
					if (i[0] >= section.startTime && i[0] < section.endTime)
					{
						saveRemove.push(i);
						section.sectionNotes.push(i);
					}
				}

				for (i in saveRemove)
					notes.remove(i);
			}

			trace("FUCK YOU BITCH FUCKER CUCK SUCK BITCH " + cleanedSong.notes.length);

			SONG = cleanedSong;
		}
		else
		{
			for (section in SONG.notes)
			{
				var removed = [];

				for (note in section.sectionNotes)
				{
					// commit suicide
					var old = note[0];
					if (note[0] < section.startTime)
					{
						notes.push(note);
						removed.push(note);
					}
					if (note[0] > section.endTime)
					{
						notes.push(note);
						removed.push(note);
					}
				}

				for (i in removed)
				{
					section.sectionNotes.remove(i);
				}
			}

			for (section in SONG.notes)
			{
				var saveRemove = [];

				for (i in notes)
				{
					if (i[0] >= section.startTime && i[0] < section.endTime)
					{
						saveRemove.push(i);
						section.sectionNotes.push(i);
					}
				}

				for (i in saveRemove)
					notes.remove(i);
			}

			trace("FUCK YOU BITCH FUCKER CUCK SUCK BITCH " + cleanedSong.notes.length);

			SONG = cleanedSong;
		}
	}
} // u looked :O -ides
