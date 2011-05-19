require 'base64'

module Encoder
  def encode(string)
    return nil if string.nil?
    Base64.encode64(string.to_s).gsub(/[\s=]+/, "").gsub("+", "-").gsub("/", "_")
  end
  
  def decode(string)
    return nil if string.nil?
    case string.length.modulo(4)
    when 2
      string += '=='
    when 3
      string += '='
    end
    Base64.decode64(string.gsub("-", "+").gsub("_", "/"))
  end

  def cycle(string)
    decode(encode(string.to_s))
  end

  extend self
end
