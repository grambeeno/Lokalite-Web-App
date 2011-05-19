# a little rake task to rename a Rails3 project.  handles editing files,
# renaming files, and renaming directories.  use NOOP=true to view
# edits/renames before performing them.
#

  begin
  ### gem install map
  #
  ### gem 'map'
  #
    require 'map'
  rescue LoadError
    class Map < ::ActiveSupport::OrderedHash
    end
  end

  namespace(:app) do
    desc('Build full-text indxen')
    task(:index) do
      Event.index!
      Organization.index!
    end

    desc('Rename the app (options: src=old_app dst=new_app noop=true)')
    task(:rename, [:src, :dst, :noop]) do |task, options|
    ## setup
    #
      options.with_defaults(
        :src  => (ENV['src']  || ENV['SRC']  || 'old_app'),
        :dst  => (ENV['dst']  || ENV['DST']  || 'new_app'),
        :noop => (ENV['noop'] || ENV['NOOP'] || false)
      )
      src = options[:src]
      dst = options[:dst]
      noop = options[:noop]

      abort('no SRC!') unless src
      abort('no DST!') unless dst
      noop = false if noop =~ /^f(?:alse)?|0$/i
      noop = true if noop =~ /^t(?:rue)?|1$/i

      src_camelize = src.camelize
      src_underscore = src_camelize.underscore

      dst_camelize = dst.camelize
      dst_underscore = dst_camelize.underscore

      glob = File.join(Rails.root, '**/**')
      files, directories, entries = [], [], []
      this = File.expand_path(__FILE__)

      Dir.glob(glob).sort_by{|entry| entry.size}.each do |entry|
        entry = File.expand_path(entry)
        next if entry == this
        entries.push(entry)
        stat = File.stat(entry)
        files.push(entry) if stat.file?
        directories.push(entry) if stat.directory?
      end

    ## edit any files that need editing
    #
      edits = {
        %r/\b#{ Regexp.escape(src_camelize) }/ => dst_camelize,
        %r/\b#{ Regexp.escape(src_underscore) }/ => dst_underscore
      }

      edit = lambda do |file|
        lines = IO.readlines(file)
        changes = []

        lineno = 0
        lines.map! do |line|
          lineno += 1
          edited = "#{ line }"
          edits.each do |re, replacement|
            edited.gsub!(re, replacement) if line =~ re
          end
          changes.push([lineno, line, edited]) if edited != line
          edited
        end

        unless noop
          bak = file + '.bak'
          FileUtils.cp(file, bak)
          open(file, 'w'){|fd| fd.write(lines)}
          FileUtils.rm_f(bak)
        end

        changes
      end

      list = []

      files.each do |file|
        changes = edit[file]
        changes.each do |change|
          lineno, line, edited = change
          list.push(Map[ 'file', file, 'lineno', lineno, 'src', line.strip, 'dst', edited.strip ])
        end
      end

      y('edits' => list)


    ## rename any files or directories that need renaming
    #
      rename = lambda do |src, dst|
        abort("#{ src } would clobber #{ dst }!") if test(?e, dst)
        FileUtils.mv(src, dst) unless noop
        [src, dst]
      end

      list = []

      re = %r/#{ Regexp.escape(src_underscore) }/
      entries.each do |entry|
        next unless test(?e, entry)
        dirname, basename = File.split(entry)
        next unless basename =~ re
        src = entry
        dst = File.join(dirname, basename.gsub(re, dst_underscore)) 
        rename[src, dst]
        list.push(Map[ 'src', src, 'dst', dst ])
      end

      y('renames' => list)

    ## rework the secret token
    #
      require 'active_support/secure_random'
      secret = ActiveSupport::SecureRandom.hex(64)

      unless noop
        path = File.join(Rails.root, 'config/initializers/secret_token.rb')
        content = <<-__
          #{ dst_camelize }::Application.config.secret_token = #{ secret.inspect } 
        __
        bak = path + '.bak'
        FileUtils.cp(path, bak)
        open(path, 'w'){|fd| fd.puts(content.strip)}
        FileUtils.rm_f(bak)
        puts(content.strip)
      end

      y('secret' => secret)
    end
  end
