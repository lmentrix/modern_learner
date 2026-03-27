.PHONY: get gen clean build-dev build-prod run analyze format test

get:
	flutter pub get

# Run code generators (injectable, json_serializable, freezed, retrofit)
gen:
	flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode for code generation
gen-watch:
	flutter pub run build_runner watch --delete-conflicting-outputs

clean:
	flutter clean && flutter pub get

run:
	flutter run --dart-define-from-file=.env

analyze:
	flutter analyze

format:
	dart format lib test --line-length 100

test:
	flutter test --coverage

coverage:
	flutter test --coverage && genhtml coverage/lcov.info -o coverage/html && open coverage/html/index.html
