game.love: main.lua conf.lua lib ressource thread_led_controller.lua UI
	zip -r game.love  main.lua conf.lua lib ressource thread_led_controller.lua UI

game.apk: game.love
	cp game.love ../love2apk/love_decoded/assets/
	apktool b -o game.apk ../love2apk/love_decoded

game-aligned-debugSigned.apk: game.apk
	java -jar ~/dev/prog/uber-apk-signer.jar --apks game.apk

clean:
	rm -f *.apk *.love

install_apk: game-aligned-debugSigned.apk
	adb install game-aligned-debugSigned.apk

debug_install:
	~/dev/git/adb-sync/adb-sync main.lua ressource UI conf.lua lib frame thread_led_controller.lua /sdcard/lovegame

debug_launch: debug_install
	adb shell am force-stop org.love2d.android
	adb shell am start -n org.love2d.android/.GameActivity

.PHONY: clean debug install_apk debug_launch
