begin

  require 'fileutils'
  require 'pathname'

  realpath = lambda do |path|
    begin
      (path.is_a?(Pathname) ? path : Pathname.new(path.to_s)).realpath.to_s
    rescue Errno::ENOENT
      nil
    end
  end

  rails_root = realpath[Rails.root]

  Dir.chdir(rails_root) do
# directories we'll want to be knowing about
#
    # cap
    shared_path = File.expand_path('../../shared')
    shared_public_system_path = File.expand_path('../../shared/system')
    shared_private_system_path = File.expand_path('../../shared/private')
    shared_system_path = shared_public_system_path

    public_path = Rails.public_path.to_s
    public_system_path = File.join(Rails.public_path.to_s, 'system')

    private_path = File.join(rails_root, 'private')
    private_system_path = File.join(private_path, 'system')
    private_system_db_path = File.join(private_system_path, 'db')

    db_path = File.join(rails_root, 'db')

# are we likely a cap deploy?
#
    cap_deploy =
      test(?e, shared_public_system_path) and
      test(?l, public_system_path) and
      realpath[shared_public_system_path] == realpath[public_system_path]

# setup private directory
#
    FileUtils.mkdir_p(private_path)
    FileUtils.chmod(0777, private_path)

# setup private system dependent on whether or not we are cap deploy
#
    if cap_deploy
      FileUtils.mkdir_p(shared_private_system_path)
      FileUtils.chmod(0777, shared_private_system_path)

      begin
        FileUtils.ln_s(shared_private_system_path, private_system_path) unless test(?l, private_system_path)
      rescue Object
        raise unless(
          test(?l, private_system_path) and
          realpath[shared_private_system_path] == realpath[private_system_path]
        )
      end
    else
      shared_path = nil
      shared_public_system_path = nil
      shared_private_system_path = nil
      shared_system_path = nil
      FileUtils.mkdir_p(private_system_path)
      FileUtils.chmod(0777, private_system_path)
    end

# setup db path under private space
#
      FileUtils.mkdir_p(private_system_db_path)
      FileUtils.chmod(0777, private_system_db_path)

# barf iff fail
#
    fail 'no ./private/system!' unless test(?d, private_system_path)
    fail 'no ./private/system/db!' unless test(?d, private_system_db_path)

# export the directories we just learned about/created via
# Rails.shortcut_method_named_by_variable_name
#
    %w[
      shared_path
      shared_public_system_path
      shared_private_system_path
      shared_system_path
      private_path
      private_system_path
      private_system_db_path
    ].each do |path_method|
      unless Rails.respond_to?(path_method)
        path = eval(path_method)
        exists = path ? test(?e, path) : false
        path = nil unless exists
        value = exists ? path : nil
        Rails.singleton_class{ define_method(path_method){ value } }
      end
    end
  end

rescue Object => e
  warn "#{ e.message } (#{ e.class.name })"
end
