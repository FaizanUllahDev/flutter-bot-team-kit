# Feature module reference (generic)

## Layout
- Header: Stack + centered title + close button aligned right (min 40x40 hit area)
- Spacing and sizes from the design file, scaled with the project's scale helper
- Colors from a feature palette class that reads the app theme

## State
- Enums for exclusive UI modes (not competing bools)
- Value objects + copyWith + derived getters
- React to state changes for sheets and navigation

## Tests
- Test mode on; inject stubs via constructor; assert on state value
