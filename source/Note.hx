package;

import flixel.addons.effects.FlxSkewedSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
#if polymod
import polymod.format.ParseRules.TargetSignatureElement;
#end
import PlayState;

using StringTools;

class Note extends FlxSprite
{
	public var strumTime:Float = 0;
	public var baseStrum:Float = 0;

	public var charterSelected:Bool = false;

	public var rStrumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var rawNoteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;
	public var modifiedByLua:Bool = false;
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var noteType:Int = 0;

	public var isRing:Bool = PlayState.SONG.isRing;
	public var originColor:Int = 0; // The sustain note's original note's color
	public var noteSection:Int = 0;

	public var isAlt:Bool = false;

	public var noteCharterObject:FlxSprite;

	public var noteScore:Float = 1;

	public var noteYOff:Int = 0;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var BLUE_NOTE:Int = 1;
	public static var GREEN_NOTE:Int = 2;
	public static var RED_NOTE:Int = 3;

	public var rating:String = "shit";

	public var modAngle:Float = 0; // The angle set by modcharts
	public var localAngle:Float = 0; // The angle to be edited inside Note.hx

	public var dataColor:Array<String> = ['purple', 'blue', 'green', 'red'];
	public var dataColor5k:Array<String> = ['purple', 'blue', 'gold', 'green', 'red'];
	public var quantityColor:Array<Int> = [PURP_NOTE, 2, BLUE_NOTE, 2, GREEN_NOTE, 2, RED_NOTE, 2]; // Maybe I should figure out why the previous array only had two alternating colors...
	public var quantityColor5k:Array<Int> = [PURP_NOTE, 2, BLUE_NOTE, 2, GREEN_NOTE, 2, RED_NOTE, 2, 4, 2];
	public var arrowAngles:Array<Int> = [180, 90, 270, 0];
	public var arrowAngles5k:Array<Int> = [180, 90, 0, 270, 0];

	public var isParent:Bool = false;
	public var parent:Note = null;
	public var spotInLine:Int = 0;
	public var sustainActive:Bool = true;

	public var children:Array<Note> = [];

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inCharter:Bool = false, ?isAlt:Bool = false,
			?noteType:Int = 0)
	{
		super();

		if (prevNote == null)
			prevNote = this;

		this.isAlt = isAlt;

		this.noteType = noteType;
		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		if (isRing)
		{
			swagWidth = 140 * 0.8;
		}

		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;

		if (inCharter)
		{
			this.strumTime = strumTime;
			rStrumTime = strumTime;
		}
		else
		{
			this.strumTime = strumTime;
			#if sys
			if (PlayState.isSM)
			{
				rStrumTime = strumTime;
			}
			else
				rStrumTime = (strumTime - FlxG.save.data.offset + PlayState.songOffset);
			#else
			rStrumTime = (strumTime - FlxG.save.data.offset + PlayState.songOffset);
			#end
		}

		if (this.strumTime < 0)
			this.strumTime = 0;

		this.noteData = noteData;

		var colorArray = isRing ? dataColor5k : dataColor;
		var quantityColorArray = isRing ? quantityColor5k : quantityColor;
		var angleArray = isRing ? arrowAngles5k : arrowAngles;

		// defaults if no noteStyle was found in chart
		var noteTypeCheck:String = 'normal';

		if (inCharter)
		{
			frames = Paths.getSparrowAtlas('NOTE_assets');
			var fuckingSussy = Paths.getSparrowAtlas('staticNotes', 'exe');
			for (amogus in fuckingSussy.frames)
			{
				this.frames.pushFrame(amogus);
			}

			var animSuffix = ' alone';

			switch (noteType)
			{
				case 3:
					frames = Paths.getSparrowAtlas('PhantomNote', 'exe');
					animSuffix = ' withered';
				case 2:
					frames = Paths.getSparrowAtlas('staticNotes', 'exe');
					animSuffix = ' static';
				default:
					frames = Paths.getSparrowAtlas('NOTE_assets');
					animSuffix = ' alone';
			}

			for (i in 0...colorArray.length)
			{
				animation.addByPrefix(colorArray[i] + 'Scroll', colorArray[i] + animSuffix); // Normal
				animation.addByPrefix(colorArray[i] + 'hold', colorArray[i] + ' hold'); // Hold
				animation.addByPrefix(colorArray[i] + 'holdend', colorArray[i] + ' tail'); // Tails
			}

			setGraphicSize(Std.int(width * 0.7));
			updateHitbox();

			antialiasing = FlxG.save.data.antialiasing;
		}
		else
		{
			if (PlayState.SONG.noteStyle == null)
			{
				switch (PlayState.storyWeek)
				{
					case 6:
						noteTypeCheck = 'pixel';
				}
			}
			else
			{
				noteTypeCheck = PlayState.SONG.noteStyle;
			}

			switch (noteTypeCheck)
			{
				case 'pixel':
					loadGraphic(Paths.image('arrows-pixels', 'exe'), true, 17, 17);
					if (isSustainNote)
						loadGraphic(Paths.image('arrowEnds', 'exe'), true, 7, 6);

					for (i in 0...colorArray.length)
					{
						if (noteType == 2)
						{
							animation.add(colorArray[i] + 'Scroll', [i + 20]); // Normal notes
						}
						else
						{
							animation.add(colorArray[i] + 'Scroll', [i + 4]); // Normal notes
						}
						animation.add(colorArray[i] + 'hold', [i]); // Hold
						animation.add(colorArray[i] + 'holdend', [i + 4]); // Tails
					}

					setGraphicSize(Std.int(width * PlayState.daPixelZoom));
					updateHitbox();
				case 'majinNOTES':
					frames = Paths.getSparrowAtlas('Majin_Notes', 'exe');
					var fuckingSussy = Paths.getSparrowAtlas('Majin_Notes', 'exe');
					for (amogus in fuckingSussy.frames)
					{
						this.frames.pushFrame(amogus);
					}

					for (i in 0...colorArray.length)
					{
						animation.addByPrefix(colorArray[i] + 'Scroll', colorArray[i] + ' alone'); // Normal
						animation.addByPrefix(colorArray[i] + 'hold', colorArray[i] + ' hold'); // Hold
						animation.addByPrefix(colorArray[i] + 'holdend', colorArray[i] + ' tail'); // Tails
					}

					setGraphicSize(Std.int(width * 0.7));
					updateHitbox();

					antialiasing = FlxG.save.data.antialiasing;
				default:
					frames = Paths.getSparrowAtlas('NOTE_assets');
					var fuckingSussy = Paths.getSparrowAtlas('staticNotes', 'exe');
					for (amogus in fuckingSussy.frames)
					{
						this.frames.pushFrame(amogus);
					}

					var animSuffix = ' alone';

					switch (noteType)
					{
						case 3:
							frames = Paths.getSparrowAtlas('PhantomNote', 'exe');
							animSuffix = ' withered';
						case 2:
							frames = Paths.getSparrowAtlas('staticNotes', 'exe');
							animSuffix = ' static';
						default:
							frames = Paths.getSparrowAtlas('NOTE_assets');
							animSuffix = ' alone';
					}

					for (i in 0...colorArray.length)
					{
						animation.addByPrefix(colorArray[i] + 'Scroll', colorArray[i] + animSuffix); // Normal
						animation.addByPrefix(colorArray[i] + 'hold', colorArray[i] + ' hold'); // Hold
						animation.addByPrefix(colorArray[i] + 'holdend', colorArray[i] + ' tail'); // Tails
					}

					setGraphicSize(Std.int(width * 0.7));
					updateHitbox();

					antialiasing = FlxG.save.data.antialiasing;
			}
		}

		x += swagWidth * noteData;
		animation.play(colorArray[noteData] + 'Scroll');
		originColor = noteData; // The note's origin color will be checked by its sustain notes

		if (FlxG.save.data.stepMania && !isSustainNote)
		{
			var strumCheck:Float = rStrumTime;

			// I give up on fluctuating bpms. something has to be subtracted from strumCheck to make them look right but idk what.
			// I'd use the note's section's start time but neither the note's section nor its start time are accessible by themselves
			// strumCheck -= ???

			var ind:Int = Std.int(Math.round(strumCheck / (Conductor.stepCrochet / 2)));

			var col:Int = 0;
			col = quantityColorArray[ind % quantityColorArray.length]; // Set the color depending on the beats

			animation.play(colorArray[col] + 'Scroll');
			localAngle -= angleArray[col];
			localAngle += angleArray[noteData];
			originColor = col;
		}

		// we make sure its downscroll and its a SUSTAIN NOTE (aka a trail, not a note)
		// and flip it so it doesn't look weird.
		// THIS DOESN'T FUCKING FLIP THE NOTE, CONTRIBUTERS DON'T JUST COMMENT THIS OUT JESUS
		// then what is this lol
		// BRO IT LITERALLY SAYS IT FLIPS IF ITS A TRAIL AND ITS DOWNSCROLL
		if (FlxG.save.data.downscroll && sustainNote)
			flipY = true;

		var stepHeight = (0.45 * Conductor.stepCrochet * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? PlayState.SONG.speed : PlayStateChangeables.scrollSpeed,
			2));

		if (isSustainNote && prevNote != null)
		{
			noteScore * 0.2;
			alpha = 0.6;

			x += width / 2;

			originColor = prevNote.originColor;

			animation.play(colorArray[originColor] + 'holdend'); // This works both for normal colors and quantization colors
			updateHitbox();

			x -= width / 2;

			// if (noteTypeCheck == 'pixel')
			//	x += 30;
			if (inCharter)
				x += 30;

			if (prevNote.isSustainNote)
			{
				prevNote.animation.play(colorArray[prevNote.originColor] + 'hold');
				prevNote.updateHitbox();

				prevNote.scale.y *= (stepHeight + 1) / prevNote.height; // + 1 so that there's no odd gaps as the notes scroll
				prevNote.updateHitbox();
				prevNote.noteYOff = Math.round(-prevNote.offset.y);

				// prevNote.setGraphicSize();

				noteYOff = Math.round(-offset.y);
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		angle = modAngle + localAngle;

		if (!modifiedByLua)
		{
			if (!sustainActive)
			{
				alpha = 0.3;
			}
		}

		if (mustPress)
		{
			if (isSustainNote && noteType != 2)
			{
				if (strumTime - Conductor.songPosition <= ((166 * Conductor.timeScale) * 0.5)
					&& strumTime - Conductor.songPosition >= (-166 * Conductor.timeScale))
					canBeHit = true;
				else
					canBeHit = false;
			}
			else
			{
				if (strumTime - Conductor.songPosition <= (166 * Conductor.timeScale)
					&& strumTime - Conductor.songPosition >= (-166 * Conductor.timeScale))
					canBeHit = true;
				else
					canBeHit = false;
			}
			if (strumTime - Conductor.songPosition < -166 && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
				wasGoodHit = true;
		}

		if (tooLate && !wasGoodHit)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}
