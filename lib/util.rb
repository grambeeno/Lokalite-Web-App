module Util
  def normalize_email(email)
    email.to_s.strip.downcase
  end

  def slowhash(string)
    BCrypt::Password.create(string.to_s).to_s
  end

  def load_config_yml(path)
    YAML::load(ERB.new((IO.read(path))).result)
  end

  def parse_seconds(time)
    return time unless time
    return time if time.is_a?(Numeric)

    parts = time.to_s.gsub(/[^\d:]/,'').split(/:/)
    seconds = parts.pop
    minutes = parts.pop
    hours = parts.pop

    seconds = Float(seconds).to_i
    seconds += Float(minutes).to_i * 60 if minutes
    seconds += Float(hours).to_i * 60 * 60 if hours

    seconds
  end

  def hours_minutes_seconds(seconds)
    return unless seconds
    seconds = Float(seconds).to_i
    hours, seconds = seconds.divmod(3600)
    minutes, seconds = seconds.divmod(60)
    [hours.to_i, minutes.to_s, seconds]
  end

  def hms(seconds)
    return unless seconds
    "%02d:%02d:%02d" % hours_minutes_seconds(seconds)
  end

  def nearest_ceiling(i, unit = 10)
    Integer(i + unit) / unit * unit
  end

  def nearest_floor(i, unit = 10)
    Integer(i - unit) / unit * unit
  end

  def paths_for(*args)
    path = args.flatten.compact.join('/')
    path.gsub!(%r|[.]+/|, '/')
    path.squeeze!('/')
    path.sub!(%r|^/|, '')
    path.sub!(%r|/$|, '')
    paths = path.split('/')
  end

  def absolute_path_for(*args)
    ('/' + paths_for(*args).join('/')).squeeze('/')
  end

  def normalize_path(arg, *args)
    absolute_path_for(arg, *args)
  end


  def day_start_for(time)
    date = time.to_date
    Time.parse(date.to_s)
  end

  def day_end_for(time)
    date = time.to_date
    time = Time.parse(date.to_s)
    time - 1
  end

  def date_range_for(*args)
    a = args.shift
    b = args.shift

    case a
      when Time, Date
        start_time = day_start_for(a)

      when Symbol, String
        case time.to_s
          when /weekend/

          when /today/
            start_time = time
            end_time = start_time + 1.day

          when /week/
            start_time = time
            end_time = start_time + 1.week

          when /month/
            start_time = time
            end_time = start_time + 1.month

          when /year/
            start_time = time
            end_time = start_time + 1.year
          else # all
        end
    end

    end_time ||= (start_time + 1.week)
  end


  extend Util
end
