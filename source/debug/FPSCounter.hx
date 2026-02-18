package debug;

import flixel.FlxG;
import flixel.util.FlxStringUtil;
import funkin.util.MemoryUtil;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.system.System as OpenFlSystem;
import lime.system.System as LimeSystem;

#if cpp
@:access(lime._internal.backend.native.NativeCFFI)
#end

class FPSCounter extends Sprite
{
	// ================= CONFIG =================
	public var currentFPS(default, null):Int = 0;
	public var isAdvanced(default, set):Bool = false;
	public var backgroundOpacity(default, set):Float = 0.5;

	public var os:String = '';

	static final UPDATE_DELAY:Int = 100;
	static final INNER_RECT_DIFF:Int = 3;
	static final OUTER_RECT_DIMENSIONS:Array<Int> = [234, 201];
	static final OTHERS_OFFSET:Int = 8;

	// ================= VARS =================
	var times:Array<Float> = [];
	var deltaTimeout:Float = 0.0;

	var background:Shape;
	var infoDisplay:TextField;

	#if !html5
	var gcMem:Float = 0.0;
	var gcMemPeak:Float = 0.0;
	var taskMem:Float = 0.0;
	var taskMemPeak:Float = 0.0;
	#end

	// ================= CONSTRUCTOR =================
	public function new(x:Float = 10, y:Float = 10, color:Int = 0xFFFFFF)
	{
		super();
		this.x = x;
		this.y = y;

		buildOSString();
		buildDisplay(color, false);
	}

	// ================= OS INFO =================
	function buildOSString()
	{
		if (LimeSystem.platformName == LimeSystem.platformVersion || LimeSystem.platformVersion == null)
			os = 'OS: ${LimeSystem.platformName}';
		else
			os = 'OS: ${LimeSystem.platformName} - ${LimeSystem.platformVersion}';
	}

	// ================= BUILD DISPLAY =================
	function buildDisplay(color:Int, advanced:Bool)
	{
		removeChildren();

		background = new Shape();
		background.graphics.beginFill(0x2c2f30, 1);
		background.graphics.drawRect(0, 0, 260, advanced ? 180 : 80);
		background.graphics.endFill();
		background.alpha = backgroundOpacity;
		addChild(background);

		infoDisplay = new TextField();
		infoDisplay.x = OTHERS_OFFSET;
		infoDisplay.y = OTHERS_OFFSET;
		infoDisplay.width = 240;
		infoDisplay.selectable = false;
		infoDisplay.mouseEnabled = false;
		infoDisplay.defaultTextFormat = new TextFormat("_sans", 12, color);
		infoDisplay.multiline = true;
		addChild(infoDisplay);
	}

	// ================= ENTER FRAME =================
	override function __enterFrame(deltaTime:Float):Void
	{
		#if cpp
		final now:Float = lime._internal.backend.native.NativeCFFI.lime_sdl_get_ticks();
		#else
		final now:Float = haxe.Timer.stamp() * 1000;
		#end

		times.push(now);
		while (times[0] < now - 1000)
			times.shift();

		if (deltaTimeout < UPDATE_DELAY)
		{
			deltaTimeout += deltaTime;
			return;
		}

		currentFPS = times.length;

		#if !html5
		gcMem = MemoryUtil.getGCMemory();
		if (gcMem > gcMemPeak) gcMemPeak = gcMem;

		if (MemoryUtil.supportsTaskMem())
		{
			taskMem = MemoryUtil.getTaskMemory();
			if (taskMem > taskMemPeak) taskMemPeak = taskMem;
		}
		#end

		updateDisplay();
		deltaTimeout = 0.0;
	}

	// ================= UPDATE DISPLAY =================
	function updateDisplay()
	{
		var info:Array<String> = [];

		info.push('FPS: $currentFPS');

		#if !html5
		info.push('GC MEM: ${FlxStringUtil.formatBytes(gcMem)} / ${FlxStringUtil.formatBytes(gcMemPeak)}');

		if (MemoryUtil.supportsTaskMem())
			info.push('TASK MEM: ${FlxStringUtil.formatBytes(taskMem)} / ${FlxStringUtil.formatBytes(taskMemPeak)}');
		#end

		if (isAdvanced)
			info.push(os);

		infoDisplay.text = info.join('\n');

		infoDisplay.textColor = 0xFFFFFFFF;
		if (currentFPS < FlxG.drawFramerate * 0.5)
			infoDisplay.textColor = 0xFFFF0000;
	}

	// ================= SETTERS =================
	function set_isAdvanced(value:Bool):Bool
	{
		buildDisplay(0xFFFFFF, value);
		return isAdvanced = value;
	}

	function set_backgroundOpacity(value:Float):Float
	{
		if (background != null)
			background.alpha = value;
		return backgroundOpacity = value;
	}

	// ================= MEMORY =================
	inline function get_memoryMegas():Float
		return cast(OpenFlSystem.totalMemory, UInt);
}