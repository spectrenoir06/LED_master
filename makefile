build/game.love: main.lua conf.lua lib ressource thread_led_controller.lua UI
	zip -r build/game.love  main.lua conf.lua lib ressource thread_led_controller.lua UI

build/game.apk: build/game.love
	cp build/game.love ../love2apk/love_decoded/assets/
	cp ressource/AndroidManifest.xml ../love2apk/love_decoded/
	apktool b -o build/game.apk ../love2apk/love_decoded

build/game-aligned-debugSigned.apk: build/game.apk
	java -jar ~/dev/prog/uber-apk-signer.jar --apks build/game.apk

clean:
	rm -f build/*.apk build/*.love

apk_install: build/game-aligned-debugSigned.apk
	adb install build/game-aligned-debugSigned.apk

apk_run: apk_install
	adb shell am force-stop org.spectre.ledmaster
	adb shell am start -n org.spectre.ledmaster/.GameActivity

apk_log:
	adb logcat --pid=`adb shell pidof -s org.spectre.ledmaster`

debug_install:
	~/dev/git/adb-sync/adb-sync main.lua ressource UI conf.lua lib frame thread_led_controller.lua /sdcard/lovegame

debug_run: debug_install
	adb shell am force-stop org.love2d.android
	adb shell am start -n org.love2d.android/.GameActivity

debug_log:
	adb logcat --pid=`adb shell pidof -s org.love2d.android`


.PHONY: clean debug apk_install apk_run apk_log debug_install debug_run debug_log
