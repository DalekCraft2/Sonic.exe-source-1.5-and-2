package;

import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.Assets as OpenFlAssets;
import haxe.Json;

using StringTools;

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';
	public var barColor:FlxColor;

	public var holdTimer:Float = 0;

	public var nonanimated:Bool = false;

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super(x, y);

		barColor = isPlayer ? 0xFF66FF33 : 0xFFFF0000;
		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;

		antialiasing = FlxG.save.data.antialiasing;

		switch (curCharacter)
		{
			/*case 'gf-exe':
				// GIRLFRIEND CODE
				frames = Paths.getSparrowAtlas('exe_gf_assets', 'shared', true);
				animation.addByIndices('sad', 'gf miss', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'gf dance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'gf dance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				loadOffsetFile(curCharacter);

				playAnim('danceRight'); */

			case 'gf-pixel':
				// GIRLFRIEND CODE
				frames = Paths.getSparrowAtlas('Pixel_gf', 'shared', true);
				animation.addByIndices('sad', 'Pixel gf miss', [0, 1, 2, 3, 4], "", 24, false);
				animation.addByIndices('danceLeft', 'Pixel gf dance', [0, 1, 2, 3], "", 24, false);
				animation.addByIndices('danceRight', 'Pixel gf dance', [4, 5, 6, 7], "", 24, false);

				loadOffsetFile(curCharacter);

				playAnim('danceRight');

				setGraphicSize(Std.int(width * 10));
				updateHitbox();
				antialiasing = false;
			/*case 'bf':
				frames = Paths.getSparrowAtlas('BOYFRIEND', 'shared', true);

				trace(frames.frames.length);

				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, false);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				animation.addByPrefix('dodge', "boyfriend dodge", 24, false);

				animation.addByPrefix('scared', 'BF idle shaking', 24);

				loadOffsetFile(curCharacter);

				playAnim('idle');

				barColor = 0xFF31b0d1;

				flipX = true; */
			/*case 'bf-flipped-for-cam':
				frames = Paths.getSparrowAtlas('BOYFRIEND', 'shared', true);

				trace(frames.frames.length);

				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, false);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				animation.addByPrefix('dodge', "boyfriend dodge", 24, false);

				animation.addByPrefix('scared', 'BF idle shaking', 24);

				loadOffsetFile(curCharacter);

				playAnim('idle');

				flipX = true; */
			/*case 'bf-perspective':
				frames = Paths.getSparrowAtlas('BFPhase3_Perspective', 'shared', true);

				trace(frames.frames.length);

				animation.addByPrefix('idle', 'Idle', 24, false);
				animation.addByPrefix('singUP', 'Sing_Up', 24, false);
				animation.addByPrefix('singRIGHT', 'Sing_Left', 24, false);
				animation.addByPrefix('singLEFT', 'Sing_Right', 24, false);
				animation.addByPrefix('singDOWN', 'Sing_Down', 24, false);
				animation.addByPrefix('singUPmiss', 'Up_Miss', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'Left_Miss', 24, false);
				animation.addByPrefix('singLEFTmiss', 'Miss_Right', 24, false);
				animation.addByPrefix('singDOWNmiss', 'Down_Miss', 24, false);

				loadOffsetFile(curCharacter);

				playAnim('idle');

				flipX = true; */
			/*case 'bf-perspective-flipped':
				frames = Paths.getSparrowAtlas('BFPhase3_Perspective_Flipped', 'shared', true);

				trace(frames.frames.length);

				animation.addByPrefix('idle', 'Idle_Flip', 24, false);
				animation.addByPrefix('singUP', 'Sing_Up_Flip', 24, false);
				animation.addByPrefix('singLEFT', 'Sing_Left_Flip', 24, false);
				animation.addByPrefix('singRIGHT', 'Sing_Right_Flip', 24, false);
				animation.addByPrefix('singDOWN', 'Sing_Down_Flip', 24, false);
				animation.addByPrefix('singUPmiss', 'Up_Miss_Flip', 24, false);
				animation.addByPrefix('singLEFTmiss', 'Left_Miss_Flip', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'Right_Miss_Flip', 24, false);
				animation.addByPrefix('singDOWNmiss', 'Down_Miss_Flip', 24, false);

				loadOffsetFile(curCharacter);

				playAnim('idle');

				flipX = true; */
			/*case 'bf-blue':
				frames = Paths.getSparrowAtlas('endless_bf', 'shared', true);

				trace(frames.frames.length);

				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('premajin', 'Majin Reveal Windup', 24, false);
				animation.addByPrefix('majin', 'Majin BF Reveal', 24, false);

				loadOffsetFile(curCharacter);

				playAnim('idle');

				flipX = true; */

			case 'bf-pixel':
				frames = Paths.getSparrowAtlas('BF', 'shared', true);
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);

				loadOffsetFile(curCharacter);

				setGraphicSize(Std.int(width * 10));
				updateHitbox();

				playAnim('idle');

				// width -= 100;
				// height -= 100;

				antialiasing = false;

				barColor = 0xFF31b0d1;

				flipX = true;
			/*case 'bf-SS':
				frames = Paths.getSparrowAtlas('SSBF_Assets', 'shared', true);

				animation.addByPrefix('idle', 'SSBF IDLE instance 1', 24);
				animation.addByPrefix('singUP', 'SSBF UP instance 1', 24);
				animation.addByPrefix('singLEFT', 'SSBF LEFT instance 1', 24);
				animation.addByPrefix('singRIGHT', 'SSBF RIGHT instance 1', 24);
				animation.addByPrefix('singDOWN', 'SSBF DOWN instance 1', 24);
				animation.addByPrefix('singUPmiss', 'SSBF UPmiss instance 1', 24);
				animation.addByPrefix('singLEFTmiss', 'SSBF LEFTmiss instance 1', 24);
				animation.addByPrefix('singRIGHTmiss', 'SSBF RIGHTmiss instance 1', 24);
				animation.addByPrefix('singDOWNmiss', 'SSBF DOWNmiss instance 1', 24);

				loadOffsetFile(curCharacter);

				playAnim('idle');

				flipX = true; */
			/*case 'bf-super':
				frames = Paths.getSparrowAtlas('Super_BoyFriend_Assets', 'shared', true);

				animation.addByPrefix('idle', 'BF Super idle dance instance 1', 24);
				animation.addByPrefix('singUP', 'BF NOTE UP instance 1', 24);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT instance 1', 24);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT instance 1', 24);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN instance 1', 24);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS instance 1', 24);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS instance 1', 24);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS instance 1', 24);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS instance 1', 24);

				loadOffsetFile(curCharacter);

				playAnim('idle');

				flipX = true; */
			/*case 'dad':
				// DAD ANIMATION LOADING CODE
				frames = Paths.getSparrowAtlas('DADDY_DEAREST', 'shared', true);
				animation.addByPrefix('idle', 'Dad idle dance', 24, false);
				animation.addByPrefix('singUP', 'Dad Sing Note UP', 24, false);
				animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24, false);
				animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24, false);
				animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24, false);
				animation.addByIndices('idleLoop', "Dad idle dance", [11, 12], "", 12, true);

				loadOffsetFile(curCharacter);
				barColor = 0xFFaf66ce;

				playAnim('idle'); */
			/*case 'suisei':
				frames = Paths.getSparrowAtlas('Suisei', 'shared', true);
				animation.addByPrefix('idle', 'suiseiIDLE', 24, false);
				animation.addByPrefix('singUP', 'suiseiUP', 24, false);
				animation.addByPrefix('singRIGHT', 'suiseiRIGHT', 24, false);
				animation.addByPrefix('singDOWN', 'suiseiDOWN', 24, false);
				animation.addByPrefix('singLEFT', 'suiseiLEFT', 24, false);
				animation.addByPrefix('iamgod', 'suiseiIDLE', 24, false); // TODO animation

				animation.addByPrefix('singDOWN-alt', 'suiseiUP', 24, false);

				animation.addByPrefix('singLAUGH', 'suiseiUP', 24, false);

				loadOffsetFile(curCharacter);

				playAnim('idle'); */
			/*case 'sonic':
				frames = Paths.getSparrowAtlas('Sonic_EXE_Assets', 'shared', true);
				animation.addByPrefix('idle', 'SONICmoveIDLE', 24);
				animation.addByPrefix('singUP', 'SONICmoveUP', 24);
				animation.addByPrefix('singRIGHT', 'SONICmoveRIGHT', 24);
				animation.addByPrefix('singDOWN', 'SONICmoveDOWN', 24);
				animation.addByPrefix('singLEFT', 'SONICmoveLEFT', 24);
				animation.addByPrefix('iamgod', 'sonicImmagetya', 24, false);

				animation.addByPrefix('singDOWN-alt', 'SONIClaugh', 24);

				animation.addByPrefix('singLAUGH', 'SONIClaugh', 24);

				loadOffsetFile(curCharacter);

				playAnim('idle'); */
			/*case 'sonicfun':
				frames = Paths.getSparrowAtlas('SonicFunAssets', 'shared', true);
				animation.addByPrefix('idle', 'SONICFUNIDLE', 24);
				animation.addByPrefix('singUP', 'SONICFUNUP', 24);
				animation.addByPrefix('singRIGHT', 'SONICFUNRIGHT', 24);
				animation.addByPrefix('singDOWN', 'SONICFUNDOWN', 24);
				animation.addByPrefix('singLEFT', 'SONICFUNLEFT', 24);

				loadOffsetFile(curCharacter);

				playAnim('idle'); */
			/*case 'sonicLordX':
				frames = Paths.getSparrowAtlas('SONIC_X', 'shared', true);
				animation.addByPrefix('idle', 'X_Idle', 24, false);
				animation.addByPrefix('singUP', 'X_Up', 24, false);
				animation.addByPrefix('singDOWN', 'X_Down', 24, false);
				animation.addByPrefix('singLEFT', 'X_Left', 24, false);
				animation.addByPrefix('singRIGHT', 'X_Right', 24, false);

				loadOffsetFile(curCharacter);

				playAnim('idle');

				setGraphicSize(Std.int(width * 1.2));

				updateHitbox(); */
			/*case 'coco':
				frames = Paths.getSparrowAtlas('Coco', 'shared', true);
				animation.addByPrefix('idle', 'sunkyIDLE', 24);
				animation.addByPrefix('singUP', 'sunkyUP', 24);
				animation.addByPrefix('singRIGHT', 'sunkyRIGHT', 24);
				animation.addByPrefix('singDOWN', 'sunkyDOWN', 24);
				animation.addByPrefix('singLEFT', 'sunkyLEFT', 24);

				loadOffsetFile(curCharacter);

				playAnim('idle'); */
			/*case 'sunky':
				tex = Paths.getSparrowAtlas('characters/Sunky');
				frames = tex;
				animation.addByPrefix('idle', 'sunkyIDLE instance 1', 24);
				animation.addByPrefix('singUP', 'sunkyUP instance 1', 24);
				animation.addByPrefix('singRIGHT', 'sunkyRIGHT instance 1', 24);
				animation.addByPrefix('singDOWN', 'sunkyDOWN instance 1', 24);
				animation.addByPrefix('singLEFT', 'sunkyLEFT instance 1', 24);

				addOffset('idle');
				addOffset("singUP");
				addOffset("singRIGHT");
				addOffset("singLEFT");
				addOffset("singDOWN");

				playAnim('idle'); */
			/*case 'TDoll':
				frames = Paths.getSparrowAtlas('Tails_Doll', 'shared', true);
				animation.addByPrefix('idle', 'TailsDoll IDLE instance 1', 24);
				animation.addByPrefix('singUP', 'TailsDoll UP instance 1', 24);
				animation.addByPrefix('singRIGHT', 'TailsDoll RIGHT instance 1', 24);
				animation.addByPrefix('singDOWN', 'TailsDoll DOWN instance 1', 24);
				animation.addByPrefix('singLEFT', 'TailsDoll LEFT instance 1', 24);

				loadOffsetFile(curCharacter);

				playAnim('idle'); */
			/*case 'TDollAlt':
				frames = Paths.getSparrowAtlas('Tails_Doll_Alt', 'shared', true);
				animation.addByPrefix('idle', 'TailsDoll IDLE instance', 24);
				animation.addByPrefix('singUP', 'TailsDoll UP instance', 24);
				animation.addByPrefix('singRIGHT', 'TailsDoll RIGHT instance', 24);
				animation.addByPrefix('singDOWN', 'TailsDoll DOWN instance', 24);
				animation.addByPrefix('singLEFT', 'TailsDoll LEFT instance', 24);

				loadOffsetFile(curCharacter);

				playAnim('idle'); */
			/*case 'sonic.exe':
				frames = Paths.getSparrowAtlas('P2Sonic_Assets', 'shared', true);
				animation.addByPrefix('idle', 'NewPhase2Sonic Idle instance 1', 24, false);
				animation.addByPrefix('singUP', 'NewPhase2Sonic Up instance 1', 24, false);
				animation.addByPrefix('singDOWN', 'NewPhase2Sonic Down instance 1', 24, false);
				animation.addByPrefix('singLEFT', 'NewPhase2Sonic Left instance 1', 24, false);
				animation.addByPrefix('singRIGHT', 'NewPhase2Sonic Right instance 1', 24, false);
				animation.addByPrefix('laugh', 'NewPhase2Sonic Laugh instance 1', 24, false);

				loadOffsetFile(curCharacter);

				playAnim('idle'); */

			case 'sonic.exe alt':
				frames = Paths.getSparrowAtlas('Sonic_EXE_Pixel', 'shared', true);
				animation.addByPrefix('idle', 'Sonic_EXE_Pixel idle', 24, false);
				animation.addByPrefix('singUP', 'Sonic_EXE_Pixel NOTE UP', 24, false);
				animation.addByPrefix('singDOWN', 'Sonic_EXE_Pixel NOTE DOWN', 24, false);
				animation.addByPrefix('singLEFT', 'Sonic_EXE_Pixel NOTE LEFT', 24, false);
				animation.addByPrefix('singRIGHT', 'Sonic_EXE_Pixel NOTE RIGHT', 24, false);

				loadOffsetFile(curCharacter);

				antialiasing = false;

				playAnim('idle');

				setGraphicSize(Std.int(width * 12));
				updateHitbox();

			/*case 'beast':
				frames = Paths.getSparrowAtlas('Beast', 'shared', true);
				animation.addByPrefix('idle', 'Beast_IDLE', 24, false);
				animation.addByPrefix('singUP', 'Beast_UP', 24, false);
				animation.addByPrefix('singDOWN', 'Beast_DOWN', 24, false);
				animation.addByPrefix('singLEFT', 'Beast_LEFT', 24, false);
				animation.addByPrefix('singRIGHT', 'Beast_RIGHT', 24, false);
				animation.addByPrefix('laugh', 'Beast_LAUGH', 24, false);

				loadOffsetFile(curCharacter);

				playAnim('idle'); */
			/*case 'beast-cam-fix':
				frames = Paths.getSparrowAtlas('Beast', 'shared', true);
				animation.addByPrefix('idle', 'Beast_IDLE', 24, false);
				animation.addByPrefix('singUP', 'Beast_UP', 24, false);
				animation.addByPrefix('singDOWN', 'Beast_DOWN', 24, false);
				animation.addByPrefix('singLEFT', 'Beast_LEFT', 24, false);
				animation.addByPrefix('singRIGHT', 'Beast_RIGHT', 24, false);
				animation.addByPrefix('laugh', 'Beast_LAUGH', 24, false);

				loadOffsetFile(curCharacter);

				playAnim('idle'); */
			/*case 'mio':
				frames = Paths.getSparrowAtlas('FakerMio', 'shared', true);
				animation.addByPrefix('idle', 'FAKER IDLE', 24);
				animation.addByPrefix('singUP', 'FAKER UP', 24);
				animation.addByPrefix('singRIGHT', 'FAKER RIGHT', 24);
				animation.addByPrefix('singDOWN', 'FAKER DOWN', 24);
				animation.addByPrefix('singLEFT', 'FAKER LEFT', 24);

				loadOffsetFile(curCharacter);

				playAnim('idle'); */
			/*case 'faker':
				frames = Paths.getSparrowAtlas('Faker_EXE_Assets', 'shared', true);
				animation.addByPrefix('idle', 'FAKER IDLE instance 1', 24);
				animation.addByPrefix('singUP', 'FAKER UP instance 1', 24);
				animation.addByPrefix('singRIGHT', 'FAKER RIGHT instance 1', 24);
				animation.addByPrefix('singDOWN', 'FAKER DOWN instance 1', 24);
				animation.addByPrefix('singLEFT', 'FAKER LEFT instance 1', 24);

				loadOffsetFile(curCharacter); */
			/*case 'exe':
				frames = Paths.getSparrowAtlas('Exe_Assets', 'shared', true);
				animation.addByPrefix('idle', 'Exe Idle', 24);
				animation.addByPrefix('singUP', 'Exe Up', 24);
				animation.addByPrefix('singRIGHT', 'Exe Right', 24);
				animation.addByPrefix('singDOWN', 'Exe Down', 24);
				animation.addByPrefix('singLEFT', 'Exe left', 24);

				loadOffsetFile(curCharacter);

				playAnim('idle'); */

			case 'sanic':
				frames = Paths.getSparrowAtlas('sanic', 'shared', true);
				animation.addByPrefix('idle', 'sanic idle', 24);
				animation.addByPrefix('singUP', 'sanic up', 24);
				animation.addByPrefix('singRIGHT', 'sanic right', 24);
				animation.addByPrefix('singDOWN', 'sanic down', 24);
				animation.addByPrefix('singLEFT', 'sanic left', 24);

				loadOffsetFile(curCharacter);

				playAnim('idle');

				setGraphicSize(Std.int(width * 0.3));
				updateHitbox();

			/*case 'knucks':
				frames = Paths.getSparrowAtlas('KnucklesEXE', 'shared', true);
				animation.addByPrefix('idle', 'Knux Idle', 24);
				animation.addByPrefix('singUP', 'Knux Up', 24);
				animation.addByPrefix('singRIGHT', 'Knux Left', 24);
				animation.addByPrefix('singDOWN', 'Knux Down', 24);
				animation.addByPrefix('singLEFT', 'Knux Right', 24);

				loadOffsetFile(curCharacter);

				playAnim('idle'); */

			case 'tails':
				frames = Paths.getSparrowAtlas('Tails', 'shared', true);
				animation.addByPrefix('idle', 'Tails IDLE', 24);
				animation.addByPrefix('singUP', 'Tails UP', 24);
				animation.addByPrefix('singRIGHT', 'Tails RIGHT', 24);
				animation.addByPrefix('singDOWN', 'Tails DOWN', 24);
				animation.addByPrefix('singLEFT', 'Tails LEFT', 24);

				loadOffsetFile(curCharacter);

				playAnim('idle');

				setGraphicSize(Std.int(width * 1.2));

				updateHitbox();

				barColor = 0xff6c6c6c;

			/*case 'eggdickface':
				frames = Paths.getSparrowAtlas('eggman_soul', 'shared', true);
				animation.addByPrefix('idle', 'Eggman_Idle', 24);
				animation.addByPrefix('singUP', 'Eggman_Up', 24);
				animation.addByPrefix('singRIGHT', 'Eggman_Right', 24);
				animation.addByPrefix('singDOWN', 'Eggman_Down', 24);
				animation.addByPrefix('singLEFT', 'Eggman_Left', 24);
				animation.addByPrefix('laugh', 'Eggman_Laugh', 35, false);

				loadOffsetFile(curCharacter);

				playAnim('idle');

				updateHitbox(); */
			/*case 'fleetway':
				frames = Paths.getSparrowAtlas('Fleetway_Super_Sonic', 'shared', true);
				animation.addByPrefix('idle', 'Fleetway Idle', 24);
				animation.addByPrefix('singUP', 'Fleetway Up', 24);
				animation.addByPrefix('singRIGHT', 'Fleetway Right', 24);
				animation.addByPrefix('singDOWN', 'Fleetway Down', 24);
				animation.addByPrefix('singLEFT', 'Fleetway Left', 24);
				animation.addByPrefix('fastanim', 'Fleetway HowFast', 24, false);

				loadOffsetFile(curCharacter);

				playAnim('idle');

				updateHitbox(); */
			/*case 'fleetway-extras':
				frames = Paths.getSparrowAtlas('fleetway1', 'shared', true);
				animation.addByPrefix('a', 'Fleetway StepItUp', 24, false);
				animation.addByPrefix('b', 'Fleetway Laugh', 24, false);
				animation.addByPrefix('c', 'Fleetway Too Slow', 24, false);
				animation.addByPrefix('d', 'Fleetway YoureFinished', 24, false);
				animation.addByPrefix('e', 'Fleetway WHAT?!', 24, false);
				animation.addByPrefix('f', 'Fleetway Grrr', 24, false);

				loadOffsetFile(curCharacter);

				updateHitbox();

				playAnim('a', true);
				playAnim('b', true);
				playAnim('c', true);
				playAnim('d', true);
				playAnim('e', true);
				playAnim('f', true); */
			/*case 'fleetway-extras2':
				frames = Paths.getSparrowAtlas('fleetway2', 'shared', true);
				animation.addByPrefix('a', 'Fleetway Show You', 24, false);
				animation.addByPrefix('b', 'Fleetway Scream', 24, false);
				animation.addByPrefix('c', 'Fleetway Growl', 24, false);
				animation.addByPrefix('d', 'Fleetway Shut Up', 24, false);
				animation.addByPrefix('e', 'Fleetway Right Alt', 24, true);

				loadOffsetFile(curCharacter);

				updateHitbox();

				playAnim('a', true);
				playAnim('b', true);
				playAnim('c', true);
				playAnim('d', true);
				playAnim('e', true); */
			/*case 'fleetway-extras3':
				frames = Paths.getSparrowAtlas('fleetway3', 'shared', true);
				animation.addByPrefix('a', 'Fleetway Laser Blast', 24, false);

				loadOffsetFile(curCharacter);

				updateHitbox();

				playAnim('a', true); */

			default:
				parseDataFile();
		}

		if (curCharacter.startsWith('bf'))
			dance();

		if (isPlayer && frames != null)
		{
			flipX = !flipX;

			// Doesn't flip for BF, since his are already in the right place???
			if (!curCharacter.startsWith('bf'))
			{
				// var animArray
				var oldRight = animation.getByName('singRIGHT').frames;
				animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
				animation.getByName('singLEFT').frames = oldRight;

				// IF THEY HAVE MISS ANIMATIONS??
				if (animation.getByName('singRIGHTmiss') != null)
				{
					var oldMiss = animation.getByName('singRIGHTmiss').frames;
					animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
					animation.getByName('singLEFTmiss').frames = oldMiss;
				}
			}
		}
	}

	function parseDataFile()
	{
		Debug.logInfo('Generating character (${curCharacter}) from JSON data...');

		// Load the data from JSON and cast it to a struct we can easily read.
		var jsonData = Paths.loadJSON('characters/${curCharacter}');
		if (jsonData == null)
		{
			Debug.logError('Failed to parse JSON data for character ${curCharacter}');
			return;
		}

		var data:CharacterData = cast jsonData;

		var tex:FlxAtlasFrames = Paths.getSparrowAtlas(data.asset, 'shared');
		frames = tex;
		if (frames != null)
			for (anim in data.animations)
			{
				var frameRate = anim.frameRate == null ? 24 : anim.frameRate;
				var looped = anim.looped == null ? false : anim.looped;
				var flipX = anim.flipX == null ? false : anim.flipX;
				var flipY = anim.flipY == null ? false : anim.flipY;

				if (anim.frameIndices != null)
				{
					animation.addByIndices(anim.name, anim.prefix, anim.frameIndices, "", frameRate, looped, flipX, flipY);
				}
				else
				{
					animation.addByPrefix(anim.name, anim.prefix, frameRate, looped, flipX, flipY);
				}

				animOffsets[anim.name] = anim.offsets == null ? [0, 0] : anim.offsets;
			}

		barColor = FlxColor.fromString(data.barColor);

		playAnim(data.startingAnim);
	}

	public function loadOffsetFile(character:String, library:String = 'shared')
	{
		var offset:Array<String> = CoolUtil.coolTextFile(Paths.txt('images/characters/' + character + "Offsets", library));

		for (i in 0...offset.length)
		{
			var data:Array<String> = offset[i].split(' ');
			addOffset(data[0], Std.parseInt(data[1]), Std.parseInt(data[2]));
		}
	}

	override function update(elapsed:Float)
	{
		if (!isPlayer && !curCharacter.startsWith('gf-') && !curCharacter.contains('-extras'))
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}

			if (curCharacter.endsWith('-car')
				&& !animation.curAnim.name.startsWith('sing')
				&& animation.curAnim.finished
				&& animation.getByName('idleHair') != null)
				playAnim('idleHair');

			if (animation.getByName('idleLoop') != null)
			{
				if (!animation.curAnim.name.startsWith('sing') && animation.curAnim.finished)
					playAnim('idleLoop');
			}

			var dadVar:Float = 4;

			if (curCharacter == 'dad')
				dadVar = 6.1;
			else if (curCharacter == 'gf' || curCharacter == 'spooky')
				dadVar = 4.1; // fix double dances
			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
			{
				if (curCharacter == 'gf' || curCharacter == 'spooky')
					playAnim('danceLeft'); // overridden by dance correctly later
				dance();
				holdTimer = 0;
			}
		}

		switch (curCharacter)
		{
			case 'gf':
				if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
				{
					danced = true;
					playAnim('danceRight');
				}
		}

		super.update(elapsed);
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance(forced:Bool = false, altAnim:Bool = false)
	{
		if (!debugMode && !nonanimated)
		{
			switch (curCharacter)
			{
				case 'gf' | 'gf-exe' | 'gf-pixel':
					if (!animation.curAnim.name.startsWith('hair') && !animation.curAnim.name.startsWith('sing'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}
				case 'fleetway-extras', 'fleetway-extras2', 'fleetway-extras3':
				/*
					// new dance code is gonna end up cutting off animation with the idle
					// so here's example code that'll fix it. just adjust it to ya character 'n shit
					case 'custom character':
						if (!animation.curAnim.name.endsWith('custom animation'))
							playAnim('idle', forced);
				 */
				default:
					if (altAnim && animation.getByName('idle-alt') != null)
						playAnim('idle-alt', forced);
					else
						playAnim('idle', forced);
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		if (!nonanimated)
		{
			if (AnimName.endsWith('alt') && animation.getByName(AnimName) == null)
			{
				#if debug
				FlxG.log.warn(['Such alt animation doesnt exist: ' + AnimName]);
				#end
				AnimName = AnimName.split('-')[0];
			}

			animation.play(AnimName, Force, Reversed, Frame);

			var daOffset = animOffsets.get(AnimName);
			if (animOffsets.exists(AnimName))
			{
				offset.set(daOffset[0], daOffset[1]);
			}
			else
				offset.set(0, 0);

			if (curCharacter == 'gf')
			{
				if (AnimName == 'singLEFT')
				{
					danced = true;
				}
				else if (AnimName == 'singRIGHT')
				{
					danced = false;
				}

				if (AnimName == 'singUP' || AnimName == 'singDOWN')
				{
					danced = !danced;
				}
			}
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}
}

typedef CharacterData =
{
	var name:String;
	var asset:String;
	var startingAnim:String;

	/**
	 * The color of this character's health bar.
	 */
	var barColor:String;

	var animations:Array<AnimationData>;
}

typedef AnimationData =
{
	var name:String;
	var prefix:String;
	var ?offsets:Array<Int>;

	/**
	 * Whether this animation is looped.
	 * @default false
	 */
	var ?looped:Bool;

	var ?flipX:Bool;
	var ?flipY:Bool;

	/**
	 * The frame rate of this animation.
	 		* @default 24
	 */
	var ?frameRate:Int;

	var ?frameIndices:Array<Int>;
}
