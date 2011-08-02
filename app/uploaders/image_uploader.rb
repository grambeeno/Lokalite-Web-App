# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base

  # Include RMagick or ImageScience support:
  # include CarrierWave::RMagick
  # include CarrierWave::ImageScience
  include CarrierWave::MiniMagick

  Dir = "system/images/uploads"

  def ImageUploader.initializer
    dir = File.join(Rails.root, 'public', ImageUploader::Dir)
    FileUtils.mkdir_p(dir)
  end

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :s3

  def uuid
    @uuid ||= App.uuid
  end

  
  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    if model
      if model.is_a?(Image)
        "#{ Dir }/#{ model.id }"
      else
        "#{ Dir }/#{ model.class.to_s.underscore }/#{ mounted_as }/#{ model.id }"
      end
    else
      "#{ Dir }/#{ uuid }"
    end
  end

  def cache_dir
    "#{ Dir }/tmp"
  end
  #changed from resize_to_fill to resize_to_fit June 2011 Paul
  #there may be problems with this due to keeping the aspect ratio
  version :thumb do
    process :resize_to_fit => [50, 50] 
  end

  version :small do
    process :resize_to_fit => [150, 150]
  end

  version :medium do
    process :resize_to_fit => [300, 300]
  end

  ExtensionWhiteList = %w( jpg jpeg gif png )

  def ImageUploader.extension_white_list
    ExtensionWhiteList
  end

  def ImageUploader.accepts
    %w( image/gif image/jpeg image/jpg image/png )
  end

  def extension_white_list
    ExtensionWhiteList
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url
    basename =
      if version_name.blank?
        ['default', version_name, 'png' ].compact.join('.')
      else
        'default.png'
      end

    if model
      "public/images/fallback/#{ model.class.to_s.underscore }/#{ mounted_as }/" + basename
    else
      "public/images/fallback/" + basename
    end
  end

  def ImageUploader.default_url(*args)
    new.default_url(*args)
  end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end


  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_white_list
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # def filename
  #   "something.jpg" if original_filename
  # end

end
