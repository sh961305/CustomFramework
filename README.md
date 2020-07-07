## 建立專案
![NewProject](https://github.com/sh961305/CustomFramework/blob/master/Screenshot/NewProject.png?raw=true)

## 建立Class
```swift
open class CsutomClass: NSObject {
    
    func textfunction() { NSLog("testLog") }
}
```
## 準備產生Framework

首先，先確保剛剛建立的.swift檔案有出現在Compile Sources 

![Compile Sources](https://github.com/sh961305/CustomFramework/blob/master/Screenshot/compile%20sources.png?raw=true)

之後在這兩種Scheme下Build專案

![scheme_iphone](https://github.com/sh961305/CustomFramework/blob/master/Screenshot/scheme_iphone.png?raw=true)
![scheme_simulator](https://github.com/sh961305/CustomFramework/blob/master/Screenshot/scheme_simulator.png?raw=true)

build成功後，就會產生相對應的Framework

![framework](https://github.com/sh961305/CustomFramework/blob/master/Screenshot/framework.png?raw=true)

一個是在Debug-iphoneos底下給實體裝置使用的framework，一個是在Debug-iphonesimulator底下給模擬器使用的framework

![framework_path](https://github.com/sh961305/CustomFramework/blob/master/Screenshot/framework_path.png?raw=true)

## Universal Framework

若是想要在裝置或是模擬器上使用，就必須引入兩個framework嗎？答案是：不必。

Apple有提供一個叫做 Universal Framework 的東西

![universal_framework](https://github.com/sh961305/CustomFramework/blob/master/Screenshot/universal_framework.png?raw=true)

選擇 Aggregate 後幫你的 universal framework 命名，我偷懶都命名為「Univ」。
universal framework 的概念是將剛剛兩個編譯的 framework 合而為一，因此在產生時需要整合的 Run Script。

![new_script](https://github.com/sh961305/CustomFramework/blob/master/Screenshot/new_script.png?raw=true)
![new_script_2](https://github.com/sh961305/CustomFramework/blob/master/Screenshot/new_script_2.png?raw=true)
![enter_script](https://github.com/sh961305/CustomFramework/blob/master/Screenshot/enter_script.png?raw=true)

並且放入統整用的 Run Script
```AppleScript
#!/bin/sh

UNIVERSAL_OUTPUTFOLDER=${BUILD_DIR}/${CONFIGURATION}-universal

# make sure the output directory exists
mkdir -p "${UNIVERSAL_OUTPUTFOLDER}"

# Step 1. Build Device and Simulator versions
xcodebuild -target "${PROJECT_NAME}" ONLY_ACTIVE_ARCH=NO -configuration ${CONFIGURATION} -sdk iphoneos  BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}" clean build
xcodebuild -target "${PROJECT_NAME}" -configuration ${CONFIGURATION} -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}" clean build

# Step 2. Copy the framework structure (from iphoneos build) to the universal folder
cp -R "${BUILD_DIR}/${CONFIGURATION}-iphoneos/${PROJECT_NAME}.framework" "${UNIVERSAL_OUTPUTFOLDER}/"

# Step 3. Copy Swift modules from iphonesimulator build (if it exists) to the copied framework directory
SIMULATOR_SWIFT_MODULES_DIR="${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/${PROJECT_NAME}.framework/Modules/${PROJECT_NAME}.swiftmodule/."
if [ -d "${SIMULATOR_SWIFT_MODULES_DIR}" ]; then
cp -R "${SIMULATOR_SWIFT_MODULES_DIR}" "${UNIVERSAL_OUTPUTFOLDER}/${PROJECT_NAME}.framework/Modules/${PROJECT_NAME}.swiftmodule"
fi

# Step 4. Create universal binary file using lipo and place the combined executable in the copied framework directory
lipo -create -output "${UNIVERSAL_OUTPUTFOLDER}/${PROJECT_NAME}.framework/${PROJECT_NAME}" "${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/${PROJECT_NAME}.framework/${PROJECT_NAME}" "${BUILD_DIR}/${CONFIGURATION}-iphoneos/${PROJECT_NAME}.framework/${PROJECT_NAME}"

# Step 5. Convenience step to copy the framework to the project's directory
cp -R "${UNIVERSAL_OUTPUTFOLDER}/${PROJECT_NAME}.framework" "${PROJECT_DIR}"

# Step 6. Convenience step to open the project's directory in Finder
open "${PROJECT_DIR}"
```

最後在這個scheme下build，並且在專案目錄下取得framework

![univ_scheme](https://github.com/sh961305/CustomFramework/blob/master/Screenshot/univ_scheme.png?raw=true)
![univ_framework_path](https://github.com/sh961305/CustomFramework/blob/master/Screenshot/univ_framework_path.png?raw=true)

## 使用 Framework

將剛剛產生的framework拖曳至您要引入的專案目錄底下，然後引入並使用。
![add_framework](https://github.com/sh961305/CustomFramework/blob/master/Screenshot/add_framework.png?raw=true)
![add_files](https://github.com/sh961305/CustomFramework/blob/master/Screenshot/add_files.png?raw=true)
```swift
import UIKit
import CustomFramework

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let aaa = CsutomClass()
    }
}
```
