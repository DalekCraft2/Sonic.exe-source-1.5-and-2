package;

import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.group.FlxGroup;
import flixel.system.FlxSound;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class Stage extends MusicBeatState
{
	public var curStage:String = '';
	public var camZoom:Float; // The zoom of the camera to have at the start of the game
	public var hideLastBG:Bool = false; // True = hide last BGs and show ones from slowBacks on certain step, False = Toggle visibility of BGs from SlowBacks on certain step
	// Use visible property to manage if BG would be visible or not at the start of the game
	public var tweenDuration:Float = 2; // How long will it tween hiding/showing BGs, variable above must be set to True for tween to activate
	public var toAdd:Array<Dynamic> = []; // Add BGs on stage startup, load BG in by using "toAdd.push(bgVar);"
	// Layering algorithm for noobs: Everything loads by the method of "On Top", example: You load wall first(Every other added BG layers on it), then you load road(comes on top of wall and doesn't clip through it), then loading street lights(comes on top of wall and road)
	public var swagBacks:Map<String,
		Dynamic> = []; // Store BGs here to use them later (for example with slowBacks, using your custom stage event or to adjust position in stage debug menu(press 8 while in PlayState with debug build of the game))
	public var swagGroup:Map<String, FlxTypedGroup<Dynamic>> = []; // Store Groups
	public var animatedBacks:Array<FlxSprite> = []; // Store animated backgrounds and make them play animation(Animation must be named Idle!! Else use swagGroup/swagBacks and script it in stepHit/beatHit function of this file!!)
	public var layInFront:Array<Array<FlxSprite>> = [[], [], []]; // BG layering, format: first [0] - in front of GF, second [1] - in front of opponent, third [2] - in front of boyfriend(and technically also opponent since Haxe layering moment)
	public var slowBacks:Map<Int,
		Array<FlxSprite>> = []; // Change/add/remove backgrounds mid song! Format: "slowBacks[StepToBeActivated] = [Sprites,To,Be,Changed,Or,Added];"

	// BGs still must be added by using toAdd Array for them to show in game after slowBacks take effect!!
	// BGs still must be added by using toAdd Array for them to show in game after slowBacks take effect!!
	// All of the above must be set or used in your stage case code block!!
	public var positions:Map<String, Map<String, Array<Int>>> = [
		// Assign your characters positions on stage here!
		'halloween' => ['spooky' => [100, 300], 'monster' => [100, 200]],
		'philly' => ['pico' => [100, 400]],
		'limo' => ['bf-car' => [1030, 230]],
		'mall' => ['bf-christmas' => [970, 450], 'parents-christmas' => [-400, 100]],
		'mallEvil' => ['bf-christmas' => [1090, 450], 'monster-christmas' => [100, 150]],
		'school' => [
			'gf-pixel' => [580, 430],
			'bf-pixel' => [970, 670],
			'senpai' => [250, 460],
			'senpai-angry' => [250, 460]
		],
		'schoolEvil' => ['gf-pixel' => [580, 430], 'bf-pixel' => [970, 670], 'spirit' => [-50, 200]],
		'SONICstage' => ['gf' => [400, 130], 'bf' => [770, 475], 'suisei' => [100, 125]],
		'FAKERSTAGE' => ['gf-exe' => [600, 80], 'bf' => [819, 344], 'mio' => [160, 114]],
		'SONICexestage' => ['gf' => [486, 15], 'bf' => [936, 300], 'sonic.exe' => [100, -25]],
		'sonicFUNSTAGE' => ['gf' => [400, 430], 'bf-blue' => [850, 784], 'sonicfun' => [100, 570]],
		'LordXStage' => ['gf' => [400, 130], 'bf' => [770, 600], 'sonicLordX' => [-163, 200]],
		'sunkStage' => ['gf' => [400, 130], 'bf' => [670, 450], 'coco' => [-180, 200]],
		'TDStage' => ['gf' => [400, 130], 'bf-SS' => [770, 450], 'TDoll' => [-150, 330]],
		'sanicStage' => ['gf' => [400, 130], 'bf' => [770, 450], 'sanic' => [-900, -460]],
		'EXEStage' => ['gf-exe' => [830, 300], 'bf' => [1070, 550], 'exe' => [100, 100]],
		'TrioStage' => ['gf' => [400, 130], 'bf' => [466, 373], 'tails' => [-44, 298]],
		'chamber' => ['gf' => [400, 130], 'bf' => [2041, 686], 'fleetway' => [61, -95]]
	];

	// 'default' => ['gf' => [400, 130], 'bf' => [770, 450], 'dad' => [100, 100]]

	public function new(daStage:String)
	{
		super();
		this.curStage = daStage;
		camZoom = 1.05; // Don't change zoom here, unless you want to change zoom of every stage that doesn't have custom one
		if (PlayStateChangeables.Optimize)
			return;

		switch (daStage)
		{
			case 'halloween':
				{
					var hallowTex = Paths.getSparrowAtlas('halloween_bg', 'week2');

					var halloweenBG = new FlxSprite(-200, -80);
					halloweenBG.frames = hallowTex;
					halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
					halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
					halloweenBG.animation.play('idle');
					halloweenBG.antialiasing = FlxG.save.data.antialiasing;
					swagBacks['halloweenBG'] = halloweenBG;
					toAdd.push(halloweenBG);
				}
			case 'philly':
				{
					var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.loadImage('philly/sky', 'week3'));
					bg.scrollFactor.set(0.1, 0.1);
					swagBacks['bg'] = bg;
					toAdd.push(bg);

					var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.loadImage('philly/city', 'week3'));
					city.scrollFactor.set(0.3, 0.3);
					city.setGraphicSize(Std.int(city.width * 0.85));
					city.updateHitbox();
					swagBacks['city'] = city;
					toAdd.push(city);

					var phillyCityLights = new FlxTypedGroup<FlxSprite>();
					if (FlxG.save.data.distractions)
					{
						swagGroup['phillyCityLights'] = phillyCityLights;
						toAdd.push(phillyCityLights);
					}

					for (i in 0...5)
					{
						var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.loadImage('philly/win' + i, 'week3'));
						light.scrollFactor.set(0.3, 0.3);
						light.visible = false;
						light.setGraphicSize(Std.int(light.width * 0.85));
						light.updateHitbox();
						light.antialiasing = FlxG.save.data.antialiasing;
						phillyCityLights.add(light);
					}

					var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.loadImage('philly/behindTrain', 'week3'));
					swagBacks['streetBehind'] = streetBehind;
					toAdd.push(streetBehind);

					var phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.loadImage('philly/train', 'week3'));
					if (FlxG.save.data.distractions)
					{
						swagBacks['phillyTrain'] = phillyTrain;
						toAdd.push(phillyTrain);
					}

					trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes', 'shared'));
					FlxG.sound.list.add(trainSound);

					// var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

					var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.loadImage('philly/street', 'week3'));
					swagBacks['street'] = street;
					toAdd.push(street);
				}
			case 'limo':
				{
					camZoom = 0.90;

					var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.loadImage('limo/limoSunset', 'week4'));
					skyBG.scrollFactor.set(0.1, 0.1);
					skyBG.antialiasing = FlxG.save.data.antialiasing;
					swagBacks['skyBG'] = skyBG;
					toAdd.push(skyBG);

					var bgLimo:FlxSprite = new FlxSprite(-200, 480);
					bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo', 'week4');
					bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
					bgLimo.animation.play('drive');
					bgLimo.scrollFactor.set(0.4, 0.4);
					bgLimo.antialiasing = FlxG.save.data.antialiasing;
					swagBacks['bgLimo'] = bgLimo;
					toAdd.push(bgLimo);

					var fastCar:FlxSprite;
					fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.loadImage('limo/fastCarLol', 'week4'));
					fastCar.antialiasing = FlxG.save.data.antialiasing;
					fastCar.visible = false;

					if (FlxG.save.data.distractions)
					{
						var grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
						swagGroup['grpLimoDancers'] = grpLimoDancers;
						toAdd.push(grpLimoDancers);

						for (i in 0...5)
						{
							var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
							dancer.scrollFactor.set(0.4, 0.4);
							grpLimoDancers.add(dancer);
							swagBacks['dancer' + i] = dancer;
						}

						swagBacks['fastCar'] = fastCar;
						layInFront[2].push(fastCar);
						resetFastCar();
					}

					var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.loadImage('limo/limoOverlay', 'week4'));
					overlayShit.alpha = 0.5;
					// add(overlayShit);

					// var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);

					// FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);

					// overlayShit.shader = shaderBullshit;

					var limoTex = Paths.getSparrowAtlas('limo/limoDrive', 'week4');

					var limo = new FlxSprite(-120, 550);
					limo.frames = limoTex;
					limo.animation.addByPrefix('drive', "Limo stage", 24);
					limo.animation.play('drive');
					limo.antialiasing = FlxG.save.data.antialiasing;
					layInFront[0].push(limo);
					swagBacks['limo'] = limo;
				}
			case 'mall':
				{
					camZoom = 0.80;

					var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.loadImage('christmas/bgWalls', 'week5'));
					bg.antialiasing = FlxG.save.data.antialiasing;
					bg.scrollFactor.set(0.2, 0.2);
					bg.active = false;
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					bg.updateHitbox();
					swagBacks['bg'] = bg;
					toAdd.push(bg);

					var upperBoppers = new FlxSprite(-240, -90);
					upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop', 'week5');
					upperBoppers.animation.addByPrefix('idle', "Upper Crowd Bob", 24, false);
					upperBoppers.antialiasing = FlxG.save.data.antialiasing;
					upperBoppers.scrollFactor.set(0.33, 0.33);
					upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
					upperBoppers.updateHitbox();
					if (FlxG.save.data.distractions)
					{
						swagBacks['upperBoppers'] = upperBoppers;
						toAdd.push(upperBoppers);
						animatedBacks.push(upperBoppers);
					}

					var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.loadImage('christmas/bgEscalator', 'week5'));
					bgEscalator.antialiasing = FlxG.save.data.antialiasing;
					bgEscalator.scrollFactor.set(0.3, 0.3);
					bgEscalator.active = false;
					bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
					bgEscalator.updateHitbox();
					swagBacks['bgEscalator'] = bgEscalator;
					toAdd.push(bgEscalator);

					var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.loadImage('christmas/christmasTree', 'week5'));
					tree.antialiasing = FlxG.save.data.antialiasing;
					tree.scrollFactor.set(0.40, 0.40);
					swagBacks['tree'] = tree;
					toAdd.push(tree);

					var bottomBoppers = new FlxSprite(-300, 140);
					bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop', 'week5');
					bottomBoppers.animation.addByPrefix('idle', 'Bottom Level Boppers', 24, false);
					bottomBoppers.antialiasing = FlxG.save.data.antialiasing;
					bottomBoppers.scrollFactor.set(0.9, 0.9);
					bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
					bottomBoppers.updateHitbox();
					if (FlxG.save.data.distractions)
					{
						swagBacks['bottomBoppers'] = bottomBoppers;
						toAdd.push(bottomBoppers);
						animatedBacks.push(bottomBoppers);
					}

					var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.loadImage('christmas/fgSnow', 'week5'));
					fgSnow.active = false;
					fgSnow.antialiasing = FlxG.save.data.antialiasing;
					swagBacks['fgSnow'] = fgSnow;
					toAdd.push(fgSnow);

					var santa = new FlxSprite(-840, 150);
					santa.frames = Paths.getSparrowAtlas('christmas/santa', 'week5');
					santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
					santa.antialiasing = FlxG.save.data.antialiasing;
					if (FlxG.save.data.distractions)
					{
						swagBacks['santa'] = santa;
						toAdd.push(santa);
						animatedBacks.push(santa);
					}
				}
			case 'mallEvil':
				{
					var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.loadImage('christmas/evilBG', 'week5'));
					bg.antialiasing = FlxG.save.data.antialiasing;
					bg.scrollFactor.set(0.2, 0.2);
					bg.active = false;
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					bg.updateHitbox();
					swagBacks['bg'] = bg;
					toAdd.push(bg);

					var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.loadImage('christmas/evilTree', 'week5'));
					evilTree.antialiasing = FlxG.save.data.antialiasing;
					evilTree.scrollFactor.set(0.2, 0.2);
					swagBacks['evilTree'] = evilTree;
					toAdd.push(evilTree);

					var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.loadImage("christmas/evilSnow", 'week5'));
					evilSnow.antialiasing = FlxG.save.data.antialiasing;
					swagBacks['evilSnow'] = evilSnow;
					toAdd.push(evilSnow);
				}
			case 'school':
				{
					// camZoom = 0.9;

					var bgSky = new FlxSprite().loadGraphic(Paths.loadImage('weeb/weebSky', 'week6'));
					bgSky.scrollFactor.set(0.1, 0.1);
					swagBacks['bgSky'] = bgSky;
					toAdd.push(bgSky);

					var repositionShit = -200;

					var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.loadImage('weeb/weebSchool', 'week6'));
					bgSchool.scrollFactor.set(0.6, 0.90);
					swagBacks['bgSchool'] = bgSchool;
					toAdd.push(bgSchool);

					var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.loadImage('weeb/weebStreet', 'week6'));
					bgStreet.scrollFactor.set(0.95, 0.95);
					swagBacks['bgStreet'] = bgStreet;
					toAdd.push(bgStreet);

					var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.loadImage('weeb/weebTreesBack', 'week6'));
					fgTrees.scrollFactor.set(0.9, 0.9);
					swagBacks['fgTrees'] = fgTrees;
					toAdd.push(fgTrees);

					var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
					var treetex = Paths.getPackerAtlas('weeb/weebTrees', 'week6');
					bgTrees.frames = treetex;
					bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
					bgTrees.animation.play('treeLoop');
					bgTrees.scrollFactor.set(0.85, 0.85);
					swagBacks['bgTrees'] = bgTrees;
					toAdd.push(bgTrees);

					var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
					treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals', 'week6');
					treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
					treeLeaves.animation.play('leaves');
					treeLeaves.scrollFactor.set(0.85, 0.85);
					swagBacks['treeLeaves'] = treeLeaves;
					toAdd.push(treeLeaves);

					var widShit = Std.int(bgSky.width * 6);

					bgSky.setGraphicSize(widShit);
					bgSchool.setGraphicSize(widShit);
					bgStreet.setGraphicSize(widShit);
					bgTrees.setGraphicSize(Std.int(widShit * 1.4));
					fgTrees.setGraphicSize(Std.int(widShit * 0.8));
					treeLeaves.setGraphicSize(widShit);

					fgTrees.updateHitbox();
					bgSky.updateHitbox();
					bgSchool.updateHitbox();
					bgStreet.updateHitbox();
					bgTrees.updateHitbox();
					treeLeaves.updateHitbox();

					var bgGirls = new BackgroundGirls(-100, 190);
					bgGirls.scrollFactor.set(0.9, 0.9);

					// if (PlayState.SONG.songId.toLowerCase() == 'roses')
					if (GameplayCustomizeState.freeplaySong == 'roses')
					{
						if (FlxG.save.data.distractions)
							bgGirls.getScared();
					}

					bgGirls.setGraphicSize(Std.int(bgGirls.width * CoolUtil.daPixelZoom));
					bgGirls.updateHitbox();
					if (FlxG.save.data.distractions)
					{
						swagBacks['bgGirls'] = bgGirls;
						toAdd.push(bgGirls);
					}
				}
			case 'schoolEvil':
				{
					var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
					var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);

					var posX = 400;
					var posY = 200;

					var bg:FlxSprite = new FlxSprite(posX, posY);
					bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool', 'week6');
					bg.animation.addByPrefix('idle', 'background 2', 24);
					bg.animation.play('idle');
					bg.scrollFactor.set(0.8, 0.9);
					bg.scale.set(6, 6);
					swagBacks['bg'] = bg;
					toAdd.push(bg);

					/* 
						var bg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.loadImage('weeb/evilSchoolBG'));
						bg.scale.set(6, 6);
						// bg.setGraphicSize(Std.int(bg.width * 6));
						// bg.updateHitbox();
						add(bg);
						var fg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.loadImage('weeb/evilSchoolFG'));
						fg.scale.set(6, 6);
						// fg.setGraphicSize(Std.int(fg.width * 6));
						// fg.updateHitbox();
						add(fg);
						wiggleShit.effectType = WiggleEffectType.DREAMY;
						wiggleShit.waveAmplitude = 0.01;
						wiggleShit.waveFrequency = 60;
						wiggleShit.waveSpeed = 0.8;
					 */

					// bg.shader = wiggleShit.shader;
					// fg.shader = wiggleShit.shader;

					/* 
						var waveSprite = new FlxEffectSprite(bg, [waveEffectBG]);
						var waveSpriteFG = new FlxEffectSprite(fg, [waveEffectFG]);
						// Using scale since setGraphicSize() doesnt work???
						waveSprite.scale.set(6, 6);
						waveSpriteFG.scale.set(6, 6);
						waveSprite.setPosition(posX, posY);
						waveSpriteFG.setPosition(posX, posY);
						waveSprite.scrollFactor.set(0.7, 0.8);
						waveSpriteFG.scrollFactor.set(0.9, 0.8);
						// waveSprite.setGraphicSize(Std.int(waveSprite.width * 6));
						// waveSprite.updateHitbox();
						// waveSpriteFG.setGraphicSize(Std.int(fg.width * 6));
						// waveSpriteFG.updateHitbox();
						add(waveSprite);
						add(waveSpriteFG);
					 */
				}
			// SONG 1 STAGE
			case 'sonicStage':
				{
					camZoom = 1.0;
					curStage = 'SONICstage';

					var sSKY:FlxSprite = new FlxSprite(-222, -64 + 150).loadGraphic(Paths.image('PolishedP1/SKY', 'exe'));
					sSKY.antialiasing = FlxG.save.data.antialiasing;
					sSKY.scrollFactor.set(0.1, 1);
					sSKY.active = false;
					swagBacks['sSKY'] = sSKY;
					toAdd.push(sSKY);

					var hills:FlxSprite = new FlxSprite(-264, -156 + 150).loadGraphic(Paths.image('PolishedP1/HILLS', 'exe'));
					hills.antialiasing = FlxG.save.data.antialiasing;
					hills.scrollFactor.set(0.8, 1);
					hills.active = false;
					if (!FlxG.save.data.lq)
					{
						swagBacks['hills'] = hills;
						toAdd.push(hills);
					}

					var bg2:FlxSprite = new FlxSprite(-345, -289 + 170).loadGraphic(Paths.image('PolishedP1/trees', 'exe'));
					bg2.updateHitbox();
					bg2.antialiasing = FlxG.save.data.antialiasing;
					bg2.scrollFactor.set(0.88, 1);
					bg2.active = false;
					if (!FlxG.save.data.lq)
					{
						swagBacks['bg2'] = bg2;
						toAdd.push(bg2);
					}

					var bg:FlxSprite = new FlxSprite(-297, -246 + 150).loadGraphic(Paths.image('PolishedP1/FLOOR1', 'exe'));
					bg.antialiasing = FlxG.save.data.antialiasing;
					bg.scrollFactor.set(0.95, 1);
					bg.active = false;
					swagBacks['bg'] = bg;
					toAdd.push(bg);

					var eggman:FlxSprite = new FlxSprite(-218, -219 + 150).loadGraphic(Paths.image('PolishedP1/mikoTree', 'exe'));
					eggman.updateHitbox();
					eggman.antialiasing = FlxG.save.data.antialiasing;
					eggman.scrollFactor.set(0.96, 1);
					eggman.active = false;
					swagBacks['eggman'] = eggman;
					toAdd.push(eggman);

					var tail:FlxSprite = new FlxSprite(-199 - 150, -259 + 150).loadGraphic(Paths.image('PolishedP1/TAIL', 'exe'));
					tail.updateHitbox();
					tail.antialiasing = FlxG.save.data.antialiasing;
					tail.scrollFactor.set(0.98, 1);
					tail.active = false;
					swagBacks['tail'] = tail;
					toAdd.push(tail);

					var knuckle:FlxSprite = new FlxSprite(185 + 100, -350 + 150).loadGraphic(Paths.image('PolishedP1/matsuri', 'exe'));
					knuckle.updateHitbox();
					knuckle.antialiasing = FlxG.save.data.antialiasing;
					knuckle.scrollFactor.set(0.99, 1);
					knuckle.active = false;
					swagBacks['knuckle'] = knuckle;
					toAdd.push(knuckle);

					var sticklol:FlxSprite = new FlxSprite(-100, 50);
					sticklol.frames = Paths.getSparrowAtlas('PolishedP1/TailsSpikeAnimated', 'exe');
					sticklol.animation.addByPrefix('a', 'Tails Spike Animated', 4, true);
					sticklol.setGraphicSize(Std.int(sticklol.width * 1.2));
					sticklol.updateHitbox();
					sticklol.antialiasing = FlxG.save.data.antialiasing;
					sticklol.scrollFactor.set(1, 1);
					swagBacks['sticklol'] = sticklol;
					toAdd.push(sticklol);

					if (!FlxG.save.data.lq)
						sticklol.animation.play('a', true);
				}
			case 'LordXStage': // epic
				{
					camZoom = 0.8;
					curStage = 'LordXStage';

					var sky:FlxSprite = new FlxSprite(-1900, -1006).loadGraphic(Paths.image('LordXStage/sky', 'exe'));
					sky.setGraphicSize(Std.int(sky.width * .5));
					sky.antialiasing = FlxG.save.data.antialiasing;
					sky.scrollFactor.set(0.1, 1);
					sky.active = false;
					swagBacks['sky'] = sky;
					toAdd.push(sky);

					var hills1:FlxSprite = new FlxSprite(-1440, -806 + 200).loadGraphic(Paths.image('LordXStage/hills1', 'exe'));
					hills1.setGraphicSize(Std.int(hills1.width * .5));
					hills1.scale.x = 0.6;
					hills1.antialiasing = FlxG.save.data.antialiasing;
					hills1.scrollFactor.set(0.72, 1);
					hills1.active = false;
					swagBacks['hills1'] = hills1;
					toAdd.push(hills1);

					var floor:FlxSprite = new FlxSprite(-1400, -496).loadGraphic(Paths.image('LordXStage/floor', 'exe'));
					floor.setGraphicSize(Std.int(floor.width * .5));
					floor.antialiasing = FlxG.save.data.antialiasing;
					floor.scrollFactor.set(0.98, 1);
					floor.scale.x = 1;
					floor.active = false;
					swagBacks['floor'] = floor;
					toAdd.push(floor);

					var eyeflower = new FlxSprite(100 - 500, 100);
					eyeflower.frames = Paths.getSparrowAtlas('LordXStage/WeirdAssFlower_Assets', 'exe');
					eyeflower.animation.addByPrefix('animatedeye', 'flower', 30, true);
					eyeflower.setGraphicSize(Std.int(eyeflower.width * 0.8));
					eyeflower.antialiasing = FlxG.save.data.antialiasing;
					eyeflower.scrollFactor.set(0.98, 1);
					swagBacks['eyeflower'] = eyeflower;
					toAdd.push(eyeflower);

					var hands = new FlxSprite(100 - 300, -400 + 25);
					hands.frames = Paths.getSparrowAtlas('LordXStage/NotKnuckles_Assets', 'exe');
					hands.animation.addByPrefix('handss', 'Notknuckles', 30, true);
					hands.setGraphicSize(Std.int(hands.width * .5));
					hands.antialiasing = FlxG.save.data.antialiasing;
					hands.scrollFactor.set(0.98, 1);
					swagBacks['hands'] = hands;
					toAdd.push(hands);

					var smallflower:FlxSprite = new FlxSprite(-1500, -506).loadGraphic(Paths.image('LordXStage/smallflower', 'exe'));
					smallflower.setGraphicSize(Std.int(smallflower.width * .6));
					smallflower.antialiasing = FlxG.save.data.antialiasing;
					smallflower.scrollFactor.set(0.98, 1);
					smallflower.active = false;
					swagBacks['smallflower'] = smallflower;
					toAdd.push(smallflower);

					var bFsmallflower:FlxSprite = new FlxSprite(-1500 + 300, -506 - 50).loadGraphic(Paths.image('LordXStage/smallflower', 'exe'));
					bFsmallflower.setGraphicSize(Std.int(bFsmallflower.width * .6));
					bFsmallflower.antialiasing = FlxG.save.data.antialiasing;
					bFsmallflower.scrollFactor.set(0.98, 1);
					bFsmallflower.active = false;
					bFsmallflower.flipX = true;
					swagBacks['bFsmallflower'] = bFsmallflower;
					toAdd.push(bFsmallflower);

					var smallflowe2:FlxSprite = new FlxSprite(-1500, -506).loadGraphic(Paths.image('LordXStage/smallflowe2', 'exe'));
					smallflowe2.setGraphicSize(Std.int(smallflower.width * .6));
					smallflowe2.antialiasing = FlxG.save.data.antialiasing;
					smallflowe2.scrollFactor.set(0.98, 1);
					smallflowe2.active = false;
					swagBacks['smallflowe2'] = smallflowe2;
					toAdd.push(smallflowe2);

					var tree:FlxSprite = new FlxSprite(-1900 + 650 - 100, -1006 + 350).loadGraphic(Paths.image('LordXStage/tree', 'exe'));
					tree.setGraphicSize(Std.int(tree.width * .7));
					tree.antialiasing = FlxG.save.data.antialiasing;
					tree.scrollFactor.set(0.98, 1);
					tree.active = false;
					swagBacks['tree'] = tree;
					toAdd.push(tree);

					if (FlxG.save.data.distractions && !FlxG.save.data.lq)
					{ // My brain is constantly expanding
						hands.animation.play('handss', true);
						eyeflower.animation.play('animatedeye', true);
					}
				}
			// SECRET SONG STAGE!!! Real B)

			case 'sonicfunStage':
				{
					camZoom = 0.9;
					curStage = 'sonicFUNSTAGE';

					var funsky:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('FunInfiniteStage/sonicFUNsky', 'exe'));
					funsky.setGraphicSize(Std.int(funsky.width * 0.9));
					funsky.antialiasing = FlxG.save.data.antialiasing;
					funsky.scrollFactor.set(0.1, 0.3);
					funsky.active = false;
					swagBacks['funsky'] = funsky;
					toAdd.push(funsky);

					var funbush:FlxSprite = new FlxSprite(-42, 171).loadGraphic(Paths.image('FunInfiniteStage/Bush2', 'exe'));
					funbush.antialiasing = FlxG.save.data.antialiasing;
					funbush.scrollFactor.set(0.3, 0.3);
					funbush.active = false;
					swagBacks['funbush'] = funbush;
					toAdd.push(funbush);

					var funpillarts2ANIM = new FlxSprite(182, -100); // Zekuta why...
					funpillarts2ANIM.frames = Paths.getSparrowAtlas('FunInfiniteStage/Majin Boppers Back', 'exe');
					funpillarts2ANIM.animation.addByPrefix('bumpypillar', 'MajinBop2', 24);
					// funpillarts2ANIM.setGraphicSize(Std.int(funpillarts2ANIM.width * 0.7));
					funpillarts2ANIM.antialiasing = FlxG.save.data.antialiasing;
					funpillarts2ANIM.scrollFactor.set(0.6, 0.6);
					swagBacks['funpillarts2ANIM'] = funpillarts2ANIM;
					toAdd.push(funpillarts2ANIM);

					var funbush2:FlxSprite = new FlxSprite(132, 354).loadGraphic(Paths.image('FunInfiniteStage/Bush 1', 'exe'));
					funbush2.antialiasing = FlxG.save.data.antialiasing;
					funbush2.scrollFactor.set(0.3, 0.3);
					funbush2.active = false;
					swagBacks['funbush2'] = funbush2;
					toAdd.push(funbush2);

					var funpillarts1ANIM = new FlxSprite(-169, -167);
					funpillarts1ANIM.frames = Paths.getSparrowAtlas('FunInfiniteStage/Majin Boppers Front', 'exe');
					funpillarts1ANIM.animation.addByPrefix('bumpypillar', 'MajinBop1', 24);
					// funpillarts1ANIM.setGraphicSize(Std.int(funpillarts1ANIM.width * 0.7));
					funpillarts1ANIM.antialiasing = FlxG.save.data.antialiasing;
					funpillarts1ANIM.scrollFactor.set(0.6, 0.6);
					swagBacks['funpillarts1ANIM'] = funpillarts1ANIM;
					toAdd.push(funpillarts1ANIM);

					var funfloor:FlxSprite = new FlxSprite(-340, 660).loadGraphic(Paths.image('FunInfiniteStage/floor BG', 'exe'));
					funfloor.antialiasing = FlxG.save.data.antialiasing;
					funfloor.scrollFactor.set(0.5, 0.5);
					funfloor.active = false;
					swagBacks['funfloor'] = funfloor;
					toAdd.push(funfloor);

					var funboppers1ANIM = new FlxSprite(1126, 903);
					funboppers1ANIM.frames = Paths.getSparrowAtlas('FunInfiniteStage/majin FG1', 'exe');
					funboppers1ANIM.animation.addByPrefix('bumpypillar', 'majin front bopper1', 24);
					funboppers1ANIM.antialiasing = FlxG.save.data.antialiasing;
					funboppers1ANIM.scrollFactor.set(0.8, 0.8);
					swagBacks['funboppers1ANIM'] = funboppers1ANIM;
					toAdd.push(funboppers1ANIM);

					var funboppers2ANIM = new FlxSprite(-293, 871);
					funboppers2ANIM.frames = Paths.getSparrowAtlas('FunInfiniteStage/majin FG2', 'exe');
					funboppers2ANIM.animation.addByPrefix('bumpypillar', 'majin front bopper2', 24);
					funboppers2ANIM.antialiasing = FlxG.save.data.antialiasing;
					funboppers2ANIM.scrollFactor.set(0.8, 0.8);
					swagBacks['funboppers2ANIM'] = funboppers2ANIM;
					toAdd.push(funboppers2ANIM);
				}

			case 'sunkStage':
				{
					camZoom = 0.9;
					curStage = 'sunkStage';

					var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('SunkBG', 'exe'));
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					bg.antialiasing = FlxG.save.data.antialiasing;
					bg.scrollFactor.set(.91, .91);
					bg.x -= 670;
					bg.y -= 260;
					bg.active = false;
					swagBacks['bg'] = bg;
					toAdd.push(bg);
				}
			case 'TDStage':
				{
					camZoom = 0.9;
					curStage = 'TDStage';

					var bgspec = new FlxSprite().loadGraphic(Paths.image('TailsBG', 'exe'));
					bgspec.setGraphicSize(Std.int(bgspec.width * 1.2));
					bgspec.antialiasing = FlxG.save.data.antialiasing;
					bgspec.scrollFactor.set(.91, .91);
					bgspec.x -= 370;
					bgspec.y -= 130;
					bgspec.active = false;
					swagBacks['bgspec'] = bgspec;
					toAdd.push(bgspec);
				}

			case 'sanicStage':
				{
					camZoom = 0.9;
					curStage = 'sanicStage';

					var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('sanicbg', 'exe'));
					bg.setGraphicSize(Std.int(bg.width * 1.2));
					bg.antialiasing = FlxG.save.data.antialiasing;
					bg.scrollFactor.set(.91, .91);
					bg.x -= 370;
					bg.y -= 130;
					bg.active = false;
					swagBacks['bg'] = bg;
					toAdd.push(bg);
				}

			case 'sonicexeStage': // i fixed the bgs and shit!!! - razencro part 1
				{
					camZoom = .9;
					curStage = 'SONICexestage';

					var sSKY:FlxSprite = new FlxSprite(-414, -440.8).loadGraphic(Paths.image('SonicP2/sky', 'exe'));
					sSKY.antialiasing = FlxG.save.data.antialiasing;
					sSKY.scrollFactor.set(0.1, 1);
					sSKY.active = false;
					sSKY.scale.x = 1.4;
					sSKY.scale.y = 1.4;
					swagBacks['sSKY'] = sSKY;
					toAdd.push(sSKY);

					var trees:FlxSprite = new FlxSprite(-290.55, -298.3).loadGraphic(Paths.image('SonicP2/backtrees', 'exe'));
					trees.antialiasing = FlxG.save.data.antialiasing;
					trees.scrollFactor.set(0.8, 1);
					trees.active = false;
					trees.scale.x = 1.2;
					trees.scale.y = 1.2;
					swagBacks['trees'] = trees;
					toAdd.push(trees);

					var bg2:FlxSprite = new FlxSprite(-306, -334.65).loadGraphic(Paths.image('SonicP2/trees', 'exe'));
					bg2.updateHitbox();
					bg2.antialiasing = FlxG.save.data.antialiasing;
					bg2.scrollFactor.set(0.88, 1);
					bg2.active = false;
					bg2.scale.x = 1.2;
					bg2.scale.y = 1.2;
					swagBacks['bg2'] = bg2;
					toAdd.push(bg2);

					var bg:FlxSprite = new FlxSprite(-309.95, -240.2).loadGraphic(Paths.image('SonicP2/ground', 'exe'));
					bg.antialiasing = FlxG.save.data.antialiasing;
					bg.scrollFactor.set(0.95, 1);
					bg.active = false;
					bg.scale.x = 1.2;
					bg.scale.y = 1.2;
					swagBacks['bg'] = bg;
					toAdd.push(bg);

					var bgspec = new FlxSprite(-428.5 + 50 + 700, -449.35 + 25 + 392 + 105 + 50).loadGraphic(Paths.image('SonicP2/GreenHill', 'exe'));
					bgspec.antialiasing = false;
					bgspec.scrollFactor.set(0.73, 1);
					bgspec.active = false;
					bgspec.visible = false;
					bgspec.scale.x = 8;
					bgspec.scale.y = 8;
					swagBacks['bgspec'] = bgspec;
					toAdd.push(bgspec);
				}
			case 'trioStage': // i fixed the bgs and shit!!! - razencro part 1
				{
					camZoom = .9;
					curStage = 'TrioStage';

					var sSKY:FlxSprite = new FlxSprite(-621.1, -395.65).loadGraphic(Paths.image('Phase3/Glitch', 'exe'));
					sSKY.antialiasing = FlxG.save.data.antialiasing;
					sSKY.scrollFactor.set(0.82, 1);
					sSKY.active = false;
					sSKY.scale.x = 1.2;
					sSKY.scale.y = 1.2;
					swagBacks['sSKY'] = sSKY;
					toAdd.push(sSKY);

					var p3staticbg = new FlxSprite(0, 0);
					p3staticbg.frames = Paths.getSparrowAtlas('NewTitleMenuBG', 'exe');
					p3staticbg.animation.addByPrefix('P3Static', 'TitleMenuSSBG', 24, true);
					p3staticbg.animation.play('P3Static');
					p3staticbg.screenCenter();
					p3staticbg.scale.x = 4.5;
					p3staticbg.scale.y = 4.5;
					p3staticbg.visible = false;
					swagBacks['p3staticbg'] = p3staticbg;
					toAdd.push(p3staticbg);

					var trees:FlxSprite = new FlxSprite(-607.35, -401.55).loadGraphic(Paths.image('Phase3/Trees', 'exe'));
					trees.antialiasing = FlxG.save.data.antialiasing;
					trees.scrollFactor.set(0.86, 1);
					trees.active = false;
					trees.scale.x = 1.2;
					trees.scale.y = 1.2;
					swagBacks['trees'] = trees;
					toAdd.push(trees);

					var bg2:FlxSprite = new FlxSprite(-623.5, -410.4).loadGraphic(Paths.image('Phase3/Trees2', 'exe'));
					bg2.updateHitbox();
					bg2.antialiasing = FlxG.save.data.antialiasing;
					bg2.scrollFactor.set(0.91, 1);
					bg2.active = false;
					bg2.scale.x = 1.2;
					bg2.scale.y = 1.2;
					swagBacks['bg2'] = bg2;
					toAdd.push(bg2);

					var bg:FlxSprite = new FlxSprite(-630.4, -266).loadGraphic(Paths.image('Phase3/Grass', 'exe'));
					bg.antialiasing = FlxG.save.data.antialiasing;
					bg.scrollFactor.set(1, 1);
					bg.active = false;
					bg.scale.x = 1.2;
					bg.scale.y = 1.2;
					swagBacks['bg'] = bg;
					toAdd.push(bg);

					var bgspec = new FlxSprite(-428.5 + 50, -449.35 + 25).makeGraphic(2199, 1203, FlxColor.BLACK);
					bgspec.antialiasing = FlxG.save.data.antialiasing;
					bgspec.scrollFactor.set(0.91, 1);
					bgspec.active = false;
					bgspec.visible = false;
					bgspec.scale.x = 1.2;
					bgspec.scale.y = 1.2;
					swagBacks['bgspec'] = bgspec;
					toAdd.push(bgspec);
				}
			case 'fakerStage': // i fixed the bgs and shit!!! - razencro part 1
				{
					camZoom = 0.95;
					curStage = 'FAKERSTAGE';

					var sky:FlxSprite = new FlxSprite(-631.8, -493.15).loadGraphic(Paths.image('fakerBG/sky', 'exe'));
					sky.antialiasing = FlxG.save.data.antialiasing;
					sky.scrollFactor.set(0.8, 1);
					sky.active = false;
					sky.scale.x = .9;
					sky.scale.y = .9;
					swagBacks['sky'] = sky;
					toAdd.push(sky);

					var mountains:FlxSprite = new FlxSprite(-631.8, -475.5).loadGraphic(Paths.image('fakerBG/mountains', 'exe'));
					mountains.antialiasing = FlxG.save.data.antialiasing;
					mountains.scrollFactor.set(0.88, 1);
					mountains.active = false;
					mountains.scale.x = .9;
					mountains.scale.y = .9;
					swagBacks['mountains'] = mountains;
					toAdd.push(mountains);

					var grass:FlxSprite = new FlxSprite(-631.8, -475.5).loadGraphic(Paths.image('fakerBG/grass', 'exe'));
					grass.antialiasing = FlxG.save.data.antialiasing;
					grass.scrollFactor.set(0.96, 1);
					grass.active = false;
					grass.scale.x = .9;
					grass.scale.y = .9;
					swagBacks['grass'] = grass;
					toAdd.push(grass);

					var tree2:FlxSprite = new FlxSprite(-631.8, -475.5).loadGraphic(Paths.image('fakerBG/tree2', 'exe'));
					tree2.antialiasing = FlxG.save.data.antialiasing;
					tree2.scrollFactor.set(0.98, 1);
					tree2.active = false;
					tree2.scale.x = .9;
					tree2.scale.y = .9;
					swagBacks['tree2'] = tree2;
					toAdd.push(tree2);

					var pillar2:FlxSprite = new FlxSprite(-631.8, -459.55).loadGraphic(Paths.image('fakerBG/pillar2', 'exe'));
					pillar2.antialiasing = FlxG.save.data.antialiasing;
					pillar2.scrollFactor.set(1, 1);
					pillar2.active = false;
					pillar2.scale.x = .9;
					pillar2.scale.y = .9;
					swagBacks['pillar2'] = pillar2;
					toAdd.push(pillar2);

					var plant:FlxSprite = new FlxSprite(-631.8, -493.15).loadGraphic(Paths.image('fakerBG/plant', 'exe'));
					plant.antialiasing = FlxG.save.data.antialiasing;
					plant.scrollFactor.set(1, 1);
					plant.active = false;
					plant.scale.x = .9;
					plant.scale.y = .9;
					swagBacks['plant'] = plant;
					toAdd.push(plant);

					var tree1:FlxSprite = new FlxSprite(-631.8, -493.15).loadGraphic(Paths.image('fakerBG/tree1', 'exe'));
					tree1.antialiasing = FlxG.save.data.antialiasing;
					tree1.scrollFactor.set(1, 1);
					tree1.active = false;
					tree1.scale.x = .9;
					tree1.scale.y = .9;
					swagBacks['tree1'] = tree1;
					toAdd.push(tree1);

					var pillar1:FlxSprite = new FlxSprite(-631.8, -493.15).loadGraphic(Paths.image('fakerBG/pillar1', 'exe'));
					pillar1.antialiasing = FlxG.save.data.antialiasing;
					pillar1.scrollFactor.set(1, 1);
					pillar1.active = false;
					pillar1.scale.x = .9;
					pillar1.scale.y = .9;
					swagBacks['pillar1'] = pillar1;
					toAdd.push(pillar1);

					var flower1:FlxSprite = new FlxSprite(-631.8, -493.15).loadGraphic(Paths.image('fakerBG/flower1', 'exe'));
					flower1.antialiasing = FlxG.save.data.antialiasing;
					flower1.scrollFactor.set(1, 1);
					flower1.active = false;
					flower1.scale.x = .9;
					flower1.scale.y = .9;
					swagBacks['flower1'] = flower1;
					toAdd.push(flower1);

					var flower2:FlxSprite = new FlxSprite(-631.8, -493.15).loadGraphic(Paths.image('fakerBG/flower2', 'exe'));
					flower2.antialiasing = FlxG.save.data.antialiasing;
					flower2.scrollFactor.set(1, 1);
					flower2.active = false;
					flower2.scale.x = .9;
					flower2.scale.y = .9;
					swagBacks['flower2'] = flower2;
					toAdd.push(flower2);
				}

			case 'exeStage': // if this doesn't work i swear i will beat krillin to death /j
				{
					curStage = 'EXEStage';
					camZoom = 0.9;

					var sSKY:FlxSprite = new FlxSprite(-414, -240.8).loadGraphic(Paths.image('exeBg/sky', 'exe'));
					sSKY.antialiasing = FlxG.save.data.antialiasing;
					sSKY.scrollFactor.set(1, 1);
					sSKY.active = false;
					sSKY.scale.x = 1.2;
					sSKY.scale.y = 1.2;
					swagBacks['sSKY'] = sSKY;
					toAdd.push(sSKY);

					var trees:FlxSprite = new FlxSprite(-290.55, -298.3).loadGraphic(Paths.image('exeBg/backtrees', 'exe'));
					trees.antialiasing = FlxG.save.data.antialiasing;
					trees.scrollFactor.set(1.1, 1);
					trees.active = false;
					trees.scale.x = 1.2;
					trees.scale.y = 1.2;
					swagBacks['trees'] = trees;
					toAdd.push(trees);

					var bg2:FlxSprite = new FlxSprite(-306, -334.65).loadGraphic(Paths.image('exeBg/trees', 'exe'));
					bg2.updateHitbox();
					bg2.antialiasing = FlxG.save.data.antialiasing;
					bg2.scrollFactor.set(1.2, 1);
					bg2.active = false;
					bg2.scale.x = 1.2;
					bg2.scale.y = 1.2;
					swagBacks['bg2'] = bg2;
					toAdd.push(bg2);

					var bg:FlxSprite = new FlxSprite(-309.95, -240.2).loadGraphic(Paths.image('exeBg/ground', 'exe'));
					bg.antialiasing = FlxG.save.data.antialiasing;
					bg.scrollFactor.set(1.3, 1);
					bg.active = false;
					bg.scale.x = 1.2;
					bg.scale.y = 1.2;
					swagBacks['bg'] = bg;
					toAdd.push(bg);

					var treething:FlxSprite = new FlxSprite(-409.95, -340.2);
					treething.frames = Paths.getSparrowAtlas('exeBg/ExeAnimatedBG_Assets', 'exe');
					treething.animation.addByPrefix('a', 'ExeBGAnim', 24, true);
					treething.antialiasing = FlxG.save.data.antialiasing;
					treething.scrollFactor.set(1, 1);
					swagBacks['treething'] = treething;
					toAdd.push(treething);

					var tails:FlxSprite = new FlxSprite(700, 500).loadGraphic(Paths.image('exeBg/TailsCorpse', 'exe'));
					tails.antialiasing = FlxG.save.data.antialiasing;
					tails.scrollFactor.set(1, 1);
					swagBacks['tails'] = tails;
					toAdd.push(tails);

					if (FlxG.save.data.distractions)
					{
						treething.animation.play('a', true);
					}
				}
			case 'chamber': // fleetway my beloved
				{
					camZoom = .7;
					curStage = 'chamber';

					var wall = new FlxSprite(-2379.05, -1211.1);
					wall.frames = Paths.getSparrowAtlas('Chamber/Wall', 'exe');
					wall.animation.addByPrefix('a', 'Wall instance 1');
					wall.animation.play('a');
					wall.antialiasing = FlxG.save.data.antialiasing;
					wall.scrollFactor.set(1, 1.1);
					swagBacks['wall'] = wall;
					toAdd.push(wall);

					var floor = new FlxSprite(-2349, 921.25);
					floor.antialiasing = FlxG.save.data.antialiasing;
					swagBacks['floor'] = floor;
					toAdd.push(floor);
					floor.frames = Paths.getSparrowAtlas('Chamber/Floor', 'exe');
					floor.animation.addByPrefix('a', 'floor blue');
					floor.animation.addByPrefix('b', 'floor yellow');
					floor.animation.play('b', true);
					floor.animation.play('a', true); // whenever song starts make sure this is playing
					floor.scrollFactor.set(1, 1);
					floor.antialiasing = FlxG.save.data.antialiasing;

					var fleetwaybgshit = new FlxSprite(-2629.05, -1344.05);
					swagBacks['fleetwaybgshit'] = fleetwaybgshit;
					toAdd.push(fleetwaybgshit);
					fleetwaybgshit.frames = Paths.getSparrowAtlas('Chamber/FleetwayBGshit', 'exe');
					fleetwaybgshit.animation.addByPrefix('a', 'BGblue');
					fleetwaybgshit.animation.addByPrefix('b', 'BGyellow');
					fleetwaybgshit.animation.play('b', true);
					fleetwaybgshit.animation.play('a', true);
					fleetwaybgshit.antialiasing = FlxG.save.data.antialiasing;
					fleetwaybgshit.scrollFactor.set(1, 1);

					var emeraldbeam = new FlxSprite(0, -1376.95 - 200);
					emeraldbeam.antialiasing = FlxG.save.data.antialiasing;
					emeraldbeam.frames = Paths.getSparrowAtlas('Chamber/Emerald Beam', 'exe');
					emeraldbeam.animation.addByPrefix('a', 'Emerald Beam', 24, true);
					emeraldbeam.animation.play('a');
					emeraldbeam.scrollFactor.set(1, 1);
					emeraldbeam.visible = true; // this starts true, then when sonic falls in and screen goes white, this turns into flase
					swagBacks['emeraldbeam'] = emeraldbeam;
					toAdd.push(emeraldbeam);

					var emeraldbeamyellow = new FlxSprite(-300, -1376.95 - 200);
					emeraldbeamyellow.antialiasing = FlxG.save.data.antialiasing;
					emeraldbeamyellow.frames = Paths.getSparrowAtlas('Chamber/Emerald Beam Charged', 'exe');
					emeraldbeamyellow.animation.addByPrefix('a', 'Emerald Beam Charged', 24, true);
					emeraldbeamyellow.animation.play('a');
					emeraldbeamyellow.scrollFactor.set(1, 1);
					emeraldbeamyellow.visible = false; // this starts off on false and whenever emeraldbeam dissapears, this turns true so its visible once song starts
					swagBacks['emeraldbeamyellow'] = emeraldbeamyellow;
					toAdd.push(emeraldbeamyellow);

					var emeralds:FlxSprite = new FlxSprite(326.6, -191.75);
					emeralds.antialiasing = FlxG.save.data.antialiasing;
					emeralds.frames = Paths.getSparrowAtlas('Chamber/Emeralds', 'exe');
					emeralds.animation.addByPrefix('a', 'TheEmeralds', 24, true);
					emeralds.animation.play('a');
					emeralds.scrollFactor.set(1, 1);
					emeralds.antialiasing = FlxG.save.data.antialiasing;
					swagBacks['emeralds'] = emeralds;
					toAdd.push(emeralds);

					var thechamber = new FlxSprite(-225.05, 463.9);
					thechamber.frames = Paths.getSparrowAtlas('Chamber/The Chamber', 'exe');
					thechamber.animation.addByPrefix('a', 'Chamber Sonic Fall', 24, false);
					thechamber.scrollFactor.set(1, 1);
					thechamber.antialiasing = FlxG.save.data.antialiasing;
					swagBacks['thechamber'] = thechamber;
					toAdd.push(thechamber);

					var pebles = new FlxSprite(-562.15 + 100, 1043.3);
					swagBacks['pebles'] = pebles;
					toAdd.push(pebles);
					pebles.frames = Paths.getSparrowAtlas('Chamber/pebles', 'exe');
					pebles.animation.addByPrefix('a', 'pebles instance 1');
					pebles.animation.addByPrefix('b', 'pebles instance 2');
					pebles.animation.play('b', true);
					pebles.animation.play('a', true); // during cutscene this is gonna play first and then whenever the yellow beam appears, make it play "a"
					pebles.scrollFactor.set(1.1, 1);
					pebles.antialiasing = FlxG.save.data.antialiasing;

					var porker = new FlxSprite(2880.15, -762.8);
					porker.frames = Paths.getSparrowAtlas('Chamber/Porker Lewis', 'exe');
					porker.animation.addByPrefix('porkerbop', 'Porker FG');
					porker.scrollFactor.set(1.27, 1);
					porker.antialiasing = FlxG.save.data.antialiasing;
					swagBacks['porker'] = porker;
					toAdd.push(porker);
				}
			default:
				{
					camZoom = 0.9;
					curStage = 'stage';
					var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.loadImage('stageback', 'shared'));
					bg.antialiasing = FlxG.save.data.antialiasing;
					bg.scrollFactor.set(0.9, 0.9);
					bg.active = false;
					swagBacks['bg'] = bg;
					toAdd.push(bg);

					var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.loadImage('stagefront', 'shared'));
					stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
					stageFront.updateHitbox();
					stageFront.antialiasing = FlxG.save.data.antialiasing;
					stageFront.scrollFactor.set(0.9, 0.9);
					stageFront.active = false;
					swagBacks['stageFront'] = stageFront;
					toAdd.push(stageFront);

					var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.loadImage('stagecurtains', 'shared'));
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					stageCurtains.antialiasing = FlxG.save.data.antialiasing;
					stageCurtains.scrollFactor.set(1.3, 1.3);
					stageCurtains.active = false;

					swagBacks['stageCurtains'] = stageCurtains;
					toAdd.push(stageCurtains);
				}
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!PlayStateChangeables.Optimize)
		{
			switch (curStage)
			{
				case 'philly':
					if (trainMoving)
					{
						trainFrameTiming += elapsed;

						if (trainFrameTiming >= 1 / 24)
						{
							updateTrainPos();
							trainFrameTiming = 0;
						}
					}
					// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;
			}
		}
	}

	override function stepHit()
	{
		super.stepHit();

		if (!PlayStateChangeables.Optimize)
		{
			var array = slowBacks[curStep];
			if (array != null && array.length > 0)
			{
				if (hideLastBG)
				{
					for (bg in swagBacks)
					{
						if (!array.contains(bg))
						{
							var tween = FlxTween.tween(bg, {alpha: 0}, tweenDuration, {
								onComplete: function(tween:FlxTween):Void
								{
									bg.visible = false;
								}
							});
						}
					}
					for (bg in array)
					{
						bg.visible = true;
						FlxTween.tween(bg, {alpha: 1}, tweenDuration);
					}
				}
				else
				{
					for (bg in array)
						bg.visible = !bg.visible;
				}
			}
		}
	}

	override function beatHit()
	{
		super.beatHit();

		if (FlxG.save.data.distractions && animatedBacks.length > 0)
		{
			for (bg in animatedBacks)
				bg.animation.play('idle', true);
		}

		if (!PlayStateChangeables.Optimize)
		{
			switch (curStage)
			{
				case 'halloween':
					if (FlxG.random.bool(Conductor.bpm > 320 ? 100 : 10) && curBeat > lightningStrikeBeat + lightningOffset)
					{
						if (FlxG.save.data.distractions)
						{
							lightningStrikeShit();
							trace('spooky');
						}
					}
				case 'school':
					if (FlxG.save.data.distractions)
					{
						swagBacks['bgGirls'].dance();
					}
				case 'limo':
					if (FlxG.save.data.distractions)
					{
						swagGroup['grpLimoDancers'].forEach(function(dancer:BackgroundDancer)
						{
							dancer.dance();
						});

						if (FlxG.random.bool(10) && fastCarCanDrive)
							fastCarDrive();
					}
				case "philly":
					if (FlxG.save.data.distractions)
					{
						if (!trainMoving)
							trainCooldown += 1;

						if (curBeat % 4 == 0)
						{
							var phillyCityLights = swagGroup['phillyCityLights'];
							phillyCityLights.forEach(function(light:FlxSprite)
							{
								light.visible = false;
							});

							curLight = FlxG.random.int(0, phillyCityLights.length - 1);

							phillyCityLights.members[curLight].visible = true;
							// phillyCityLights.members[curLight].alpha = 1;
						}
					}

					if (curBeat % 8 == 4 && FlxG.random.bool(Conductor.bpm > 320 ? 150 : 30) && !trainMoving && trainCooldown > 8)
					{
						if (FlxG.save.data.distractions)
						{
							trainCooldown = FlxG.random.int(-4, 0);
							trainStart();
							trace('train');
						}
					}
				case 'sonicFUNSTAGE':
					if (FlxG.save.data.distractions)
					{
						var funpillarts1ANIM = swagBacks['funpillarts1ANIM'];
						var funpillarts2ANIM = swagBacks['funpillarts2ANIM'];
						var funboppers1ANIM = swagBacks['funboppers1ANIM'];
						var funboppers2ANIM = swagBacks['funboppers2ANIM'];
						funpillarts1ANIM.animation.play('bumpypillar', true);
						funpillarts2ANIM.animation.play('bumpypillar', true);
						funboppers1ANIM.animation.play('bumpypillar', true);
						funboppers2ANIM.animation.play('bumpypillar', true);
					}
				case 'chamber':
					if (FlxG.save.data.distractions)
					{
						var porker = swagBacks['porker'];
						porker.animation.play('porkerbop');
					}
			}
		}
	}

	// Variables and Functions for Stages
	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;
	var curLight:Int = 0;

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2, 'shared'));
		swagBacks['halloweenBG'].animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		if (PlayState.boyfriend != null)
		{
			PlayState.boyfriend.playAnim('scared', true);
			PlayState.gf.playAnim('scared', true);
		}
		else
		{
			GameplayCustomizeState.boyfriend.playAnim('scared', true);
			GameplayCustomizeState.gf.playAnim('scared', true);
		}
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;
	var trainSound:FlxSound;

	function trainStart():Void
	{
		if (FlxG.save.data.distractions)
		{
			trainMoving = true;
			trainSound.play(true);
		}
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (FlxG.save.data.distractions)
		{
			if (trainSound.time >= 4700)
			{
				startedMoving = true;

				if (PlayState.gf != null)
					PlayState.gf.playAnim('hairBlow');
				else
					GameplayCustomizeState.gf.playAnim('hairBlow');
			}

			if (startedMoving)
			{
				var phillyTrain = swagBacks['phillyTrain'];
				phillyTrain.x -= 400;

				if (phillyTrain.x < -2000 && !trainFinishing)
				{
					phillyTrain.x = -1150;
					trainCars -= 1;

					if (trainCars <= 0)
						trainFinishing = true;
				}

				if (phillyTrain.x < -4000 && trainFinishing)
					trainReset();
			}
		}
	}

	function trainReset():Void
	{
		if (FlxG.save.data.distractions)
		{
			if (PlayState.gf != null)
				PlayState.gf.playAnim('hairFall');
			else
				GameplayCustomizeState.gf.playAnim('hairFall');

			swagBacks['phillyTrain'].x = FlxG.width + 200;
			trainMoving = false;
			// trainSound.stop();
			// trainSound.time = 0;
			trainCars = 8;
			trainFinishing = false;
			startedMoving = false;
		}
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		if (FlxG.save.data.distractions)
		{
			var fastCar = swagBacks['fastCar'];
			fastCar.x = -12600;
			fastCar.y = FlxG.random.int(140, 250);
			fastCar.velocity.x = 0;
			fastCar.visible = false;
			fastCarCanDrive = true;
		}
	}

	function fastCarDrive()
	{
		if (FlxG.save.data.distractions)
		{
			FlxG.sound.play(Paths.soundRandom('carPass', 0, 1, 'shared'), 0.7);

			swagBacks['fastCar'].visible = true;
			swagBacks['fastCar'].velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
			fastCarCanDrive = false;
			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				resetFastCar();
			});
		}
	}
}
