# ImageQuality

Thin gem wrapper that uses ``imagemagick`` and ``python-opencv`` to help determine image quality.

## Installation

Have imagemagick installed (Tool uses ``identify``).

Add this line to your application's Gemfile:

```ruby
gem 'image_quality'
```

Install OpenCV, e.g. on Ubuntu 18.04:

```
apt-get install python3-pywt python3-opencv
```


## Usage

```
result = ImageQuality.analyze(path_to_file)

{
  blur: {
    per: 0.10468920392584516,
    isBlur: false,
    blurExtent: 0.5807770961145194,
  }
  width: 836,
  format: 'jpeg',
  height: 604,
  quality: 90,
  mime_type: 'image/jpeg',
}
```

This tool uses a shipped Python executable from https://github.com/pedrofrodenas/blur-Detection-Haar-Wavelet

The ``blur.per`` gives you info if the image is blurry. Small values 0...0.001 is very blurry, everything over 0.3 or so is quite ok. Feel free to add documentation if you understand the linked algorithm.


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/zealot128/image_quality.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
