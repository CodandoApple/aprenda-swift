build:
	swift build --package-path Actions/Validation -c release

test:
	swift test --package-path Actions/Validation

validate: build
	Actions/Validation/.build/release/validator $(file)