package;

#if FEATURE_STEPMANIA
import smTools.SMFile;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;
import flixel.input.keyboard.FlxKey;

using StringTools;

class TitleState extends MusicBeatState
{
	var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;
	var code:Int = 0;

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	override public function create():Void
	{
		// TODO: Refactor this to use OpenFlAssets.
		#if FEATURE_FILESYSTEM
		if (!sys.FileSystem.exists(Sys.getCwd() + "/assets/replays"))
			sys.FileSystem.createDirectory(Sys.getCwd() + "/assets/replays");
		#end

		@:privateAccess
		{
			Debug.logTrace("We loaded " + openfl.Assets.getLibrary("default").assetsLoaded + " assets into the default library");
		}

		FlxG.autoPause = false;

		FlxG.save.bind('funkin', 'ninjamuffin99');

		PlayerSettings.init();

		KadeEngineData.initSave();

		KeyBinds.keyCheck();
		// It doesn't reupdate the list before u restart rn lmao

		NoteskinHelpers.updateNoteskins();

		if (FlxG.save.data.volDownBind == null)
			FlxG.save.data.volDownBind = "MINUS";
		if (FlxG.save.data.volUpBind == null)
			FlxG.save.data.volUpBind = "PLUS";

		FlxG.sound.muteKeys = [FlxKey.fromString(FlxG.save.data.muteBind)];
		FlxG.sound.volumeDownKeys = [FlxKey.fromString(FlxG.save.data.volDownBind)];
		FlxG.sound.volumeUpKeys = [FlxKey.fromString(FlxG.save.data.volUpBind)];

		FlxG.mouse.visible = false;

		FlxG.worldBounds.set(0, 0);

		FlxGraphic.defaultPersist = FlxG.save.data.cacheImages;

		MusicBeatState.initSave = true;

		fullscreenBind = FlxKey.fromString(FlxG.save.data.fullscreenBind);

		Highscore.load();

		curWacky = FlxG.random.getObject(getIntroTextShit());

		trace('hello');

		// DEBUG BULLSHIT

		super.create();

		#if FREEPLAY
		FlxG.switchState(new FreeplayState());
		clean();
		#elseif CHARTING
		FlxG.switchState(new ChartingState());
		clean();
		#else
		#if !cpp
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			startIntro();
		});
		#else
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			startIntro();
		});
		#end
		#end
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var bg:FlxSprite;

	function startIntro()
	{
		if (!initialized)
		{
			var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
				new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;

			// HAD TO MODIFY SOME BACKEND SHIT
			// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
			// https://github.com/HaxeFlixel/flixel-addons/pull/348

			// var music:FlxSound = new FlxSound();
			// music.loadStream(Paths.music('freakyMenu'));
			// FlxG.sound.list.add(music);
			// music.play();
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);

			FlxG.sound.music.fadeIn(5, 0, 0.7);
			Conductor.changeBPM(102);
			initialized = true;
		}

		Conductor.changeBPM(190);
		persistentUpdate = true;

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height);
		bg.frames = Paths.getSparrowAtlas('NewTitleMenuBG', 'exe');
		bg.animation.addByPrefix('idle', "TitleMenuSSBG", 24);
		bg.animation.play('idle');
		bg.alpha = 0.75;
		bg.scale.x = 3;
		bg.scale.y = 3;
		bg.antialiasing = FlxG.save.data.antialiasing;
		// bg.setGraphicSize(Std.int(bg.width * 0.6));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		// if (Main.watermarks)
		// {
		// 	logoBl = new FlxSprite(-150, 1500);
		// 	logoBl.frames = Paths.getSparrowAtlas('KadeEngineLogoBumpin');
		// }
		// else
		// {
		// 	logoBl = new FlxSprite(-150, -100);
		// 	logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		// }
		// logoBl.antialiasing = FlxG.save.data.antialiasing;
		// logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		// logoBl.updateHitbox();
		// // logoBl.screenCenter();

		logoBl = new FlxSprite(0, 0);
		logoBl.loadGraphic(Paths.image('Logo', 'exe'));
		logoBl.antialiasing = FlxG.save.data.antialiasing;
		logoBl.scale.x = 0.5;
		logoBl.scale.y = 0.5;
		logoBl.updateHitbox();
		logoBl.screenCenter();
		add(logoBl);

		// gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		// gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		// gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		// gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		// gfDance.antialiasing = FlxG.save.data.antialiasing;
		// add(gfDance);
		// add(logoBl);

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('titleEnterNEW');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24, false);
		titleText.antialiasing = FlxG.save.data.antialiasing;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		titleText.screenCenter();
		add(titleText);

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage('logo'));
		logo.screenCenter();
		logo.antialiasing = FlxG.save.data.antialiasing;
		// add(logo);

		// FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "ninjamuffin99\nPhantomArcade\nkawaisprite\nevilsk8er", true);
		credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.loadImage('newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = FlxG.save.data.antialiasing;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		FlxG.mouse.visible = false;

		FlxG.sound.play(Paths.sound('TitleLaugh'), 1, false, null, false, function()
		{
			skipIntro();
		});

		/*if (initialized)
				skipIntro();
			else
			{
				var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
				diamond.persist = true;
				diamond.destroyOnNoUse = false;

				FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
					new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
				FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
					{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				// HAD TO MODIFY SOME BACKEND SHIT
				// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
				// https://github.com/HaxeFlixel/flixel-addons/pull/348

				// var music:FlxSound = new FlxSound();
				// music.loadStream(Paths.music('freakyMenu'));
				// FlxG.sound.list.add(music);
				// music.play();
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);

				FlxG.sound.music.fadeIn(4, 0, 0.7);
				Conductor.changeBPM(102);
				initialized = true;
		}*/

		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('data/introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;
	var fullscreenBind:FlxKey;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (FlxG.keys.anyJustPressed([fullscreenBind]))
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		var pressedEnter:Bool = controls.ACCEPT;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		if (FlxG.keys.justPressed.UP)
			if (code == 0)
				code = 1;
			else
				code == 0;

		if (FlxG.keys.justPressed.DOWN)
			if (code == 1)
				code = 2;
			else
				code == 0;

		if (FlxG.keys.justPressed.LEFT)
			if (code == 2)
				code = 3;
			else
				code == 0;

		if (FlxG.keys.justPressed.RIGHT)
			if (code == 3)
				code = 4;
			else
				code == 0;

		if (pressedEnter && !transitioning && skippedIntro && code != 4)
		{
			if (FlxG.save.data.flashing)
				titleText.animation.play('press');

			FlxG.camera.flash(FlxColor.RED, 0.2);
			FlxG.sound.play(Paths.sound('menumomentclick', 'exe'));
			FlxG.sound.play(Paths.sound('menulaugh', 'exe'));
			// FlxG.camera.flash(FlxColor.WHITE, 1);
			// FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			FlxTween.tween(bg, {alpha: 0}, 1);

			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				FlxTween.tween(logoBl, {alpha: 0}, 1);
			});

			transitioning = true;
			// FlxG.sound.music.stop();

			MainMenuState.firstStart = true;
			MainMenuState.finishedFunnyMove = false;

			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				// Get current version of Kade Engine

				var http = new haxe.Http("https://raw.githubusercontent.com/KadeDev/Kade-Engine/master/version.downloadMe");
				var returnedData:Array<String> = [];

				// I'm sick of skipping this manually.
				// var video:MP4Handler = new MP4Handler();
				// video.playMP4(Paths.video('bothCreditsAndIntro'));

				http.onData = function(data:String)
				{
					returnedData[0] = data.substring(0, data.indexOf(';'));
					returnedData[1] = data.substring(data.indexOf('-'), data.length);
					if (!MainMenuState.kadeEngineVer.contains(returnedData[0].trim()) && !OutdatedSubState.leftState)
					{
						trace('outdated lmao! ' + returnedData[0] + ' != ' + MainMenuState.kadeEngineVer);
						OutdatedSubState.needVer = returnedData[0];
						OutdatedSubState.currChanges = returnedData[1];
						// video.finishCallback = function()
						// {
						// 	LoadingState.loadAndSwitchState(new OutdatedSubState());
						// }
						LoadingState.loadAndSwitchState(new OutdatedSubState());
						clean();
					}
					else
					{
						// video.finishCallback = function()
						// {
						// 	LoadingState.loadAndSwitchState(new MainMenuState());
						// }
						LoadingState.loadAndSwitchState(new MainMenuState());
						clean();
					}
				}

				http.onError = function(error)
				{
					trace('error: $error');
					FlxG.switchState(new MainMenuState()); // fail but we go anyway
					clean();
				}

				http.request();
			});
			// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
		}
		else if (pressedEnter && !transitioning && skippedIntro && code == 4)
		{
			transitioning = true;
			PlayStateChangeables.nocheese = false;
			PlayState.SONG = Song.loadFromJson('asacoco', 'asacoco');
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = 1;
			PlayState.storyWeek = 1;
			FlxG.camera.fade(FlxColor.WHITE, 0.5, false);
			FlxG.sound.play(Paths.sound('confirmMenu'));
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			if (!FlxG.save.data.songArray.contains('asacoco') && !FlxG.save.data.botplay)
				FlxG.save.data.songArray.push('asacoco');
			new FlxTimer().start(1.5, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState());
			});
		}

		if (pressedEnter && !skippedIntro && initialized)
		{
			skipIntro();
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	override function beatHit()
	{
		super.beatHit();

		/*
			logoBl.animation.play('bump', true);
			danceLeft = !danceLeft;

			if (danceLeft)
				gfDance.animation.play('danceRight');
			else
				gfDance.animation.play('danceLeft');

			switch (curBeat)
			{
				case 0:
					deleteCoolText();
				case 1:
					createCoolText(['RightBurst', 'MarStarBro', 'Razencro', 'Comgaming_Nz', 'Zekuta', 'Crybit']);
				case 3:
					addMoreText('present');
				case 4:
					deleteCoolText();
				case 5:
					createCoolText(['Programming', 'by']);
				case 7:
					addMoreText('Razencro and Crybit');
				case 8:
					deleteCoolText();
				case 9:
					addMoreText('Mod Idea');
				case 10:
					addMoreText('and Art by');
				case 11:
					addMoreText('Rightburst');
				case 12:
					deleteCoolText();
				case 13:
					createCoolText(['Art by']);
				case 14:
					addMoreText('Comgaming_Nz');
				case 15:
					addMoreText('Music by');
				case 16:
					addMoreText('MarStarBro');
				case 17:
					addMoreText('Art by');
				case 18:
					addMoreText('Zekuta');
				case 19:
					deleteCoolText();
				case 20:
					createCoolText([curWacky[0]]);
				case 21:
					addMoreText(curWacky[1]);
				case 22:
					addMoreText(curWacky[2]);
				case 23:
					addMoreText(curWacky[3]);
				case 24:
					deleteCoolText();
				case 25:
					addMoreText('Friday');
				case 26:
					addMoreText('Night');
				case 27:
					addMoreText('Funkin');
				case 28:
					skipIntro();
			}
		 */
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			Debug.logInfo("Skipping intro...");

			remove(ngSpr);

			FlxG.sound.play(Paths.sound('showMoment', 'shared'), .4);

			FlxG.camera.flash(FlxColor.RED, 2);
			// FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(credGroup);

			/*FlxTween.tween(logoBl, {y: -100}, 1.4, {ease: FlxEase.expoInOut});

				logoBl.angle = -4;

				new FlxTimer().start(0.01, function(tmr:FlxTimer)
				{
					if (logoBl.angle == -4)
						FlxTween.angle(logoBl, logoBl.angle, 4, 4, {ease: FlxEase.quartInOut});
					if (logoBl.angle == 4)
						FlxTween.angle(logoBl, logoBl.angle, -4, 4, {ease: FlxEase.quartInOut});
				}, 0);

				// It always bugged me that it didn't do this before.
				// Skip ahead in the song to the drop.
				FlxG.sound.music.time = 9400; // 9.4 seconds
			 */

			skippedIntro = true;
		}
	}
}
