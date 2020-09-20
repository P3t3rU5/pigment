# pigment

To install:

```
gem install pigment
```

## Usage
### RGB Color Format
The RGB color format is represented with four components between 0.0 and 1.0, representing 0 to 255
- `@red`
- `@green`
- `@blue`
- `@alpha`

```ruby
require 'pigment/color/rgb'

red = Pigment::Color::RGB.new(1.0, 0.0, 0.0)
# RGB Color(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.0)

red.to_a
# [1.0, 0.0, 0.0, 1.0]

semitransparent_red = Pigment::Color::RGB.new(1.0, 0.0, 0.0, 0.5)
# RGB Color(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.5)

red + semitransparent_red
# RGB Color(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)

semitransparent_red + red 
# RGB Color(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.5)

red - semitransparent_red
# RGB Color(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)

half_red = red / 2
# RGB Color(red: 0.5, green: 0.0, blue: 0.0, alpha: 1.0)

half_red * 2 == red
# true

gray50 = Pigment::Color::RGB.new(1.0, 0.5, 0.0).grayscale
# RGB Color(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)

gray50.grayscale?
# true

cyan = red.inverse
# RGB Color(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0)

green, blue = red.triadic
# [RGB Color(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0), RGB Color(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)]

red.to_hex
# '0xff0000ff'

red.to_hex(with_alpha: false)
# '0xff0000'

Pigment::Color::RGB.convert(Pigment::Color::HSL.new(0.0, 1, 0.5))
# RGB Color(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
```

### HSL Color Format

The HSL color format is represented with

- `@hue` - a value from 0.0 to 1.0, representing 0 to 360 degrees
- `@saturation` - a value from 0.0 to 1.0 
- `@lightness` - a value from 0.0 to 1.0
- `@alpha` - a value from 0.0 to 1.0

This format is useful to calculate related colors:

- triadic
- split
- analogous
- tetradic
- rectangular
- tertiary

```ruby
require 'pigment/color/hsl'

hsl_red = Pigment::Color::HSL.convert(red)
# HSL Color(hue: 0.0, saturation: 1.0, lightness: 0.5, alpha: 1.0)

hsl_red == Pigment::Color::HSL(0.0, 1, 0.5)
# HSL Color(hue: 0.0, saturation: 1.0, lightness: 0.5, alpha: 1.0)

hsl_red.triadic
hsl_red.split
hsl_red.analogous
hsl_red.tetradic
hsl_red.rectangular
hsl_red.tertiary

```

### Color Module

The color module works as the base for any possible color format, implementing common methods

```ruby
red.to_html
# '#ff0000'

red.into(Pigment::HSL)
# HSL Color(hue: 0.0, saturation: 1.0, lightness: 0.5, alpha: 1.0)

red.inverse?(cyan)
# true

red.triadic_of?(blue)
# true

red.triadic_include?(green, blue)
# true

red.split_of?
red.split_include?
red.analogous_of?
red.analogous_include?
red.tetradic_of?
red.tetradic_include?
red.rectangular_of?
red.rectangular_include?
red.tertiary_of?
red.tertiary_include?
# of -> checks if self is included in argument result  
# include -> checks if arguments are included in self result  
```

### Color Palette

```ruby
require 'pigment/palette'

pallete = Pigment::Palette.new(
  red: red,
  blue: blue,
)

pallete[:red]
# RGB Color(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)

pallete[:green] = green
# RGB Color(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)

# Pigment::Palette is enumerable

palette.map.to_a
# [RGB Color(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0), RGB Color(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0), RGB Color(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)]
```

### Default Color Palette

```ruby
require 'pigment/default_rgb_palette'

Pigment::Palette::RGB::DEFAULT[:Red]
# RGB Color(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)


Pigment::Palette::RGB::Green
# RGB Color(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)

Pigment::Palette::RGB.Blue
# RGB Color(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
```

## Changes
See [Changelog](CHANGELOG.md)


## Future Work
- [ ] new color formats:
    - [ ] Y'CbCr
    - [ ] RYB
    - [ ] CMYK
- [ ] redesign of Base Color module to support Additive color formats
- [ ] Palette Loader to load palette files

## License
See [License](LICENSE.md)

## Related interests
- [color-names](https://github.com/meodai/color-names): javascript collection of 25586 color names  