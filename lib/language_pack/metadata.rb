require "language_pack"
require "language_pack/base"

class LanguagePack::Metadata
  FOLDER = 'vendor/scalingo'

  def initialize(cache)
    ensure_sc_compat
    if cache
      @cache = cache
      @cache.load FOLDER
    end
  end

  def read(key)
    full_key = "#{FOLDER}/#{key}"
    File.read(full_key).chomp if exists?(key)
  end

  def exists?(key)
    full_key = "#{FOLDER}/#{key}"
    File.exists?(full_key) && !Dir.exists?(full_key)
  end

  def write(key, value, isave = true)
    FileUtils.mkdir_p(FOLDER)

    full_key = "#{FOLDER}/#{key}"
    File.open(full_key, 'w') {|f| f.puts value }
    save if isave

    return true
  end

  def touch(key)
    write(key, "true")
  end

  def fetch(key)
    return read(key) if exists?(key)

    value = yield

    write(key, value.to_s)
    return value
  end

  def save
    @cache ? @cache.add(FOLDER) : false
  end

  protected

  def ensure_sc_compat
    if File.exist?('vendor/heroku') && !File.exist?(FOLDER)
      FileUtils.mv('vendor/heroku', FOLDER)
    end
  end
end
