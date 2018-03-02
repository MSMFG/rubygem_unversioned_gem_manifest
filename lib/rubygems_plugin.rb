# Manifest recording of unversioned gems
require 'rubygems'
require 'singleton'
require 'timeout'
require 'json'
require 'yaml'
require 'gem_pre_unversioned_install'

# Encapsulate our helpers
class GemManifest
  include Singleton

  ENV_MANIFEST_FILE = 'RUBYGEMS_UNVERSIONED_MANIFEST'.freeze
  ENV_FS_MUTEX      = 'RUBYGEMS_UNVERSIONED_MANIFEST_MUTEX'.freeze
  MANIFEST_DEFAULT  = '/tmp/unversioned_gems.yaml'.freeze
  # Used to control write locking of the manifest
  FS_MUTEX          = '/tmp/manifest.lock'.freeze
  FS_MUTEX_TIMEOUT  = 10

  def initialize
    @manifest_file = ENV[ENV_MANIFEST_FILE] || MANIFEST_DEFAULT
    @fs_mutex = ENV[ENV_FS_MUTEX] || FS_MUTEX
    @json_form = (File.extname(@manifest_file) == '.json')
  end

  # We coerce version into a string for persistence
  def record(name, version)
    fs_mutex do
      load
      @content[name] ||= []
      @content[name] |= [version.to_s]
      save
    end
  end

  private

  def load
    content = File.read(@manifest_file)
    @content = @json_form ? JSON.parse(content) : YAML.safe_load(content)
  rescue Errno::ENOENT
    @content = {}
  end

  def save
    content = @json_form ? @content.to_json : @content.to_yaml
    File.write(@manifest_file, content)
  end

  # Crude filesystem mutex
  def fs_mutex(lock_wait = FS_MUTEX_TIMEOUT)
    # Acquire fs lock with timeout
    Timeout.timeout(lock_wait) do
      sleep(0.1) until fs_lock?
    end
    # Callback
    yield
  rescue Timeout::Error # Assume a previous crash/unlock failure
    fs_unlock
    retry
  ensure
    fs_unlock
  end

  def fs_lock?
    File.new(@fs_mutex, File::CREAT | File::EXCL).close
    true
  rescue Errno::EEXIST
    false
  end

  def fs_unlock
    FileUtils.rm_f(@fs_mutex)
  end
end

Gem.pre_unversioned_install do |name, version|
  GemManifest.instance.record(name, version)
  true
end
