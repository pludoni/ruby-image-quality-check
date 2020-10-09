# ImageQuality

Thin gem wrapper that uses ``imagemagick`` and ``python-opencv`` to help determine image quality.


## Installation

System dependencies:

- Have imagemagick installed (Tool uses ``identify``).
- have python3 + OpenCV installed: Install OpenCV, e.g. on Ubuntu 18.04:

```
apt-get install python3-pywt python3-opencv
```

---

Add this line to your application's Gemfile:

```ruby
gem 'image_quality'
```

## Usage

### Direct usage without model integration

```
result = ImageQualityCheck.analyze(path_to_file)

{
  blur: {
    LPScale: 100
  }
  face: null,
  haseSmile: false,
  width: 836,
  format: 'jpeg',
  height: 604,
  quality: 90,
  mime_type: 'image/jpeg',
}
```

This tool uses a shipped Python executable from https://github.com/pedrofrodenas/blur-Detection-Haar-Wavelet

The ``blur.LPScale`` gives you info if the image is blurry on a scale of 0..100

### DSL for defining rules for Models

**LIMITS**:

- currently only Paperclip attachment is implemented. Feel free to add other get-the-tmpfile adapter to ``ImageQualityCheck::DetermineQuality#read``

---

Create a initializer in your app:

```ruby
# config/initializers/image_quality.rb

# define your quality rules per attachment:
ImageQuality.define_rules_for Person, attachment: :photo do
  # jpeg and png yields 100 score in this segment
  preferred_formats_rule(jpeg: 100, png: 100)

  # Sizes with w>400 and h>500 will give 100 score,
  # otherwise linearly between 0 .. 100
  preferred_size_rule(400, 500)
  rule "Photo of a person" do |result, on_error|
    if result[:blur].slice(:face, :hasSmile, :eyes).any?
      # detector has either detected face, smile or eyes
      100
    else
      on_error.call("No face found")
      0
    end
  end

  rule "Bluriness/Sharpness" do |result, on_error|
    blur = result[:blur]
    # overall picture is sharp (0...100)
    if blur[:LPScale] > 70
      100
    else
      # also including: you could check LPScale for eyes, face only
      result = (blur[:LPScale] / 80 * 100).round
      on_error.call("Contrast or focus is not optimal")
      result
    end
  end
end

ImageQuality.define_rules_for Organisation, attachment: :logo do
  preferred_formats_rule(png: 100, svg: 100, jpeg: 50, gif: 50)
  preferred_size_rule(600, 400)
end

```

Then you can query for the quality rules to evaluate an attachment:

```ruby
ImageQuality.determine_quality(some_organisation, :logo) do |result|
```

### Using example Result model

There is an ActiveRecord example model included in this Gem to save the ImageQuality Results to the database. It uses json column so that (modern) mysql/psql are both supported without any conditionals.

Run:

```
bundle exec rake image_quality_check_engine:install:migrations
bin/rails db:migrate
```

Then you can use this class like so (Example):

```ruby
  # add to initializer:
  require 'image_quality/model'
  ImageQuality.determine_quality(some_organisation, :logo) do |result|
    ImageQualityCheck::Result.create_for_result(some_organisation, column, result)
  end
```

You also want to add a has_one relationship to the host models:

```ruby
class Person < AR
  has_one :image_quality_check_result, -> { where(attachable_column: :logo) }, as: :attachable, dependent: :destroy, class_name: "ImageQualityCheck::Result"
end
```


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/zealot128/image_quality.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
