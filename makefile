releases/LED-Master.love: main.lua conf.lua UI/ lib/
	love-release

releases/LED-Master.apk: releases/LED-Master.love
	cp releases/LED-Master.love ../love2apk/love_decoded/assets/game.love
	cp ressource/AndroidManifest.xml ../love2apk/love_decoded/
	apktool b -o releases/LED-Master.apk ../love2apk/love_decoded

releases/LED-Master-aligned-debugSigned.apk: releases/LED-Master.apk
	java -jar ~/dev/prog/uber-apk-signer.jar --apks releases/LED-Master.apk

releases/LED-Master-macos.zip: releases/LED-Master.love
	love-release -M

releases/LED-Master-win32.zip: releases/LED-Master.love
	love-release -W 32

releases/LED-Master-win64.zip: releases/LED-Master.love
	love-release -W 64

releases/LED-Master.deb: releases/LED-Master.love
	love-release -D
	mv releases/LED-Master-0.9.0_all.deb releases/LED-Master.deb

clean:
	rm -f releases/*.apk releases/*.love* releases/*.zip releases/*.deb

clean_love:
	rm -f releases/*.love*

apk_install: releases/LED-Master-aligned-debugSigned.apk
	adb install releases/LED-Master-aligned-debugSigned.apk

apk_run: apk_install
	adb shell am force-stop org.spectre.ledmaster
	adb shell am start -n org.spectre.ledmaster/org.love2d.android.GameActivity

apk_log:
	adb logcat --pid=`adb shell pidof -s org.spectre.ledmaster`

debug_install:
	~/dev/git/adb-sync/adb-sync main.lua ressource UI conf.lua lib frame thread_led_controller.lua /sdcard/lovegame

debug_run: debug_install
	adb shell am force-stop org.love2d.android
	adb shell am start -n org.love2d.android/.GameActivity

debug_log:
	adb logcat --pid=`adb shell pidof -s org.love2d.android`

all: clean releases/LED-Master-aligned-debugSigned.apk releases/LED-Master-macos.zip releases/LED-Master-win32.zip releases/LED-Master-win64.zip releases/LED-Master.deb
	echo "Done"


.PHONY: clean clean_love debug apk_install apk_run apk_log debug_install debug_run debug_log all
