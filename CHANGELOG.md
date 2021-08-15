# 0.3.1
- Fixes creating colors with approximation errors:
```ruby
# before 0.3.1
BrilliantLavender.analogous
# Invalid Format [0.8063725490196079, 1.0000000000000004, 0.8666666666666667, 1.0]

# after 0.3.1 
BrilliantLavender.analogous
# RGB Color(red: 0.8063725490196079, green: 1.0, blue: 0.8666666666666667, alpha: 1.0)
```

# 0.3.0
- New classes per Color Format
    - Pigment::Color::RGB
    - Pigment::Color::HSL
- Base module for Color Formats Pigment::Color
- Palette class to handle a collection of colors