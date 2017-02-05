SHELL := /bin/bash
# Install Tasks

install-iOS:
	xcrun instruments -w "iPhone 6s (10.0)" || true

install-carthage:
	brew remove carthage --force || true
	brew install carthage

install-cocoapods:
	gem install cocoapods --pre --no-rdoc --no-ri --no-document --quiet

test-iOS:
	set -o pipefail && xcodebuild -project ReusableView.xcodeproj -scheme ReusableView -destination 'name=iPhone 6s' -enableCodeCoverage YES test | xcpretty -ct
	bash <(curl -s https://codecov.io/bash)

test-cocoapods:
	pod lib lint ReusableView.podspec --verbose
