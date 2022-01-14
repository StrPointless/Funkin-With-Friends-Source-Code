package;

import flixel.math.FlxRandom;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.4.2'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = ['story_mode','freeplay', #if ACHIEVEMENTS_ALLOWED 'awards', #end 'credits', 'options'];

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var RandomScreen:Int;
	var freeplayffv:FlxSprite;
	var awardsstr:FlxSprite;
	var cretditsPlain:FlxSprite;
	var goodbg:FlxSprite;
	var newfreeplayemandodd:FlxSprite;
	var optionseli:FlxSprite;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		FlxTween.tween(FlxG.camera, {y: 100}, 1.6, {ease: FlxEase.expoInOut});
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;
		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		if(FlxG.random.bool(0.0000000001))
		{
			var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('STRMeme'));
			bg.scrollFactor.set(0, yScroll);
			bg.setGraphicSize(Std.int(bg.width * 1.175));
			bg.updateHitbox();
			bg.screenCenter();
			bg.antialiasing = ClientPrefs.globalAntialiasing;
			add(bg);
			Achievements.loadAchievements();
			var achieveID:Int = Achievements.getAchievementIndex('memeage');
			Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
			giveAchievement('memeage');
			ClientPrefs.saveSettings();

		}
		else if(FlxG.random.bool(0.0000000000000000000001))
		{
			var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('STRMEME2'));
			bg.scrollFactor.set(0, yScroll);
			bg.setGraphicSize(Std.int(bg.width * 1.175));
			bg.updateHitbox();
			bg.screenCenter();
			bg.antialiasing = ClientPrefs.globalAntialiasing;
			add(bg);
			Achievements.loadAchievements();
			var achieveID:Int = Achievements.getAchievementIndex('true_memeage');
			Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
			giveAchievement('true_memeage');
			ClientPrefs.saveSettings();
		}
		else
		{
			goodbg = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
			goodbg.scrollFactor.set(0,0);
			goodbg.setGraphicSize(Std.int(goodbg.width * 1.175));
			goodbg.updateHitbox();
			goodbg.screenCenter();
			goodbg.antialiasing = ClientPrefs.globalAntialiasing;
			add(goodbg);
		}


		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);


		for (i in 0...optionShit.length)
			{
				var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
				var menuItem:FlxSprite = new FlxSprite(500, (i * 140)  + offset);
				menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
				menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
				menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
				menuItem.animation.play('idle');
				menuItem.ID = i;
				FlxTween.tween(menuItem, { x : 75 }, 0.9, {ease: FlxEase.circInOut});
				menuItems.add(menuItem);
				var scr:Float = (optionShit.length - 4) * 0.135;
				if(optionShit.length < 6) scr = 0;
				menuItem.scrollFactor.set(0, scr);
				menuItem.antialiasing = ClientPrefs.globalAntialiasing;
				//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
				menuItem.updateHitbox();
			}

		FlxG.camera.follow(camFollowPos, null, 1);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 68, 0, "FWF V.1 | Join the discord you bish", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.BLUE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement('friday_night_play');
				ClientPrefs.saveSettings();
			}
		}
		freeplayffv = new FlxSprite(300,0).loadGraphic(Paths.image('mainmenu/MainMenuBois/freeplay_ffv'));
		freeplayffv.screenCenter(Y);
		freeplayffv.scrollFactor.set(0,0);
		freeplayffv.scale.set(0.7,0.7);
		add(freeplayffv);
		awardsstr = new FlxSprite(300,0).loadGraphic(Paths.image('mainmenu/MainMenuBois/awards_str'));
		awardsstr.screenCenter(Y);
		awardsstr.scrollFactor.set(0,0);
		awardsstr.scale.set(0.85,0.85);
		awardsstr.alpha = 0;
		add(awardsstr);
		cretditsPlain = new FlxSprite(400,0).loadGraphic(Paths.image('mainmenu/MainMenuBois/credits_plain'));
		cretditsPlain.screenCenter(Y);
		cretditsPlain.scrollFactor.set(0,0);
		cretditsPlain.scale.set(0.95,0.95);
		cretditsPlain.alpha = 0;
		add(cretditsPlain);
		newfreeplayemandodd = new FlxSprite(300,0).loadGraphic(Paths.image('mainmenu/MainMenuBois/freeplay_em&odd'));
		newfreeplayemandodd.screenCenter(Y);
		newfreeplayemandodd.scrollFactor.set(0,0);
		newfreeplayemandodd.scale.set(0.95,0.95);
		newfreeplayemandodd.alpha = 0;
		add(newfreeplayemandodd);
		optionseli = new FlxSprite(400,0).loadGraphic(Paths.image('mainmenu/MainMenuBois/options_eli'));
		optionseli.screenCenter(Y);
		optionseli.scrollFactor.set(0,0);
		optionseli.scale.set(0.95,0.95);
		optionseli.alpha = 0;
		add(optionseli);
		#end
		super.create();
	}


	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement(id:String) {
		add(new AchievementObject(id, camAchievement)); 
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement ' + id);
	}
	#end

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 5.6, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));


		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
				if(curSelected == 0)
				{
					freeplayffv.alpha = 1;
				}
				else
				{
					freeplayffv.alpha = 0;
				}
				if(curSelected == 1)
				{
					newfreeplayemandodd.alpha = 1;
				}
				else
				{
					newfreeplayemandodd.alpha = 0;
				}
				if(curSelected == 2)
				{
					awardsstr.alpha = 1;
				}
				else
				{
					awardsstr.alpha = 0;
				}
				if(curSelected == 3)
				{
					cretditsPlain.alpha = 1;
				}
				else
				{
					cretditsPlain.alpha = 0;
				}
				if(curSelected == 4)
				{
					optionseli.alpha = 1;
				}
				else
				{
					optionseli.alpha = 0;
				}
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
				if(curSelected == 0)
				{
					freeplayffv.alpha = 1;
				}
				else
				{
					freeplayffv.alpha = 0;
				}
				if(curSelected == 1)
				{
					newfreeplayemandodd.alpha = 1;
				}
				else
				{
					newfreeplayemandodd.alpha = 0;
				}
				if(curSelected == 2)
				{
					awardsstr.alpha = 1;
				}
				else
				{
					awardsstr.alpha = 0;
				}
				if(curSelected == 3)
				{
					cretditsPlain.alpha = 1;
				}
				else
				{
					cretditsPlain.alpha = 0;
				}
				if(curSelected == 4)
				{
					optionseli.alpha = 1;
				}
				else
				{
					optionseli.alpha = 0;
				}
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));
					FlxTween.tween(FlxG.camera, {'zoom' : 4, 'angle' : 360}, 0.5, {ease: FlxEase.backIn, startDelay: 0.9});
					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {x: -1000}, 0.4, {
								ease: FlxEase.backInOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story_mode':
										MusicBeatState.switchState(new StoryMenuState());
									case 'freeplay':
										MusicBeatState.switchState(new FreeplayState());
									case 'awards':
										MusicBeatState.switchState(new AchievementsMenuState());
									case 'credits':
										MusicBeatState.switchState(new CreditsState());
									case 'options':
										MusicBeatState.switchState(new OptionsState());
								}
							});
						}
					});
				}
			}
			#if desktop
			else if (FlxG.keys.justPressed.SEVEN)
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.offset.y = 0;
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
				spr.offset.x = 0.05 * (spr.frameWidth / 2 + 180);
				spr.offset.y = 0.05 * spr.frameHeight;
				FlxG.log.add(spr.frameWidth);
			}
		});
	}
}
