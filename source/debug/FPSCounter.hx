package debug;

import flixel.FlxG;
import flixel.util.FlxStringUtil;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.system.System;

/**
 * FPSCounter compatível com Psych 0.6 / Ultimate Engine
 */
class FPSCounter extends Sprite
{
	public var currentFPS(default, null):Int = 0;
	public var isAdvanced:Bool = false;
	public var backgroundOpacity:Float = 0.5;

	var times:Array<Float> = [];
	var deltaTimeout:Float = 0.0;

	var background:Shape;
	var infoDisplay:TextField;

	static final UPDATE_DELAY:Int = 100;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0xFFFFFF)
	{
		super();
		this.x = x;
		this.y = y;

		buildDisplay(color);
	}

	// ================= BUILD =================
	function buildDisplay(color:Int)
	{
		background = new Shape();
		background.graphics.beginFill(0x2c2f30, 1);
		background.graphics.drawRect(0, 0, 320, 100);
		background.graphics.endFill();
		background.alpha = backgroundOpacity;
		addChild(background);

		infoDisplay = new TextField();
		infoDisplay.x = 8;
		infoDisplay.y = 8;
		infoDisplay.width = 300;
		infoDisplay.selectable = false;
		infoDisplay.mouseEnabled = false;
		infoDisplay.defaultTextFormat = new TextFormat("_sans", 12, color);
		infoDisplay.multiline = true;
		addChild(infoDisplay);
	}

	// ================= ENTER FRAME =================
	override function __enterFrame(deltaTime:Float):Void
	{
		var now:Float = haxe.Timer.stamp() * 1000;

		times.push(now);
		while (times[0] < now - 1000)
			times.shift();

		if (deltaTimeout < UPDATE_DELAY)
		{
			deltaTimeout += deltaTime;
			return;
		}

		currentFPS = times.length;

		updateDisplay();
		deltaTimeout = 0.0;
	}

	// ================= UPDATE =================
	function updateDisplay()
	{
		var mem:Float = System.totalMemory;

		var info:Array<String> = [];
		info.push('FPS: $currentFPS');
		info.push('Memory: ${FlxStringUtil.formatBytes(mem)}');
		info.push('Ultimate Engine Alpha'); // ← watermark

		infoDisplay.text = info.join('\n');

		infoDisplay.textColor = 0xFFFFFFFF;
		if (currentFPS < FlxG.drawFramerate * 0.5)
			infoDisplay.textColor = 0xFFFF0000;
	}

	// ================= COMPAT COM MAIN =================
	public inline function positionFPS(X:Float, Y:Float, ?scale:Float = 1)
	{
		scaleX = scaleY = scale;
		x = FlxG.game.x + X;
		y = FlxG.game.y + Y;
	}
}