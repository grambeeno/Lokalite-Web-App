require 'openssl'

module Encryptor
  def encrypt(plaintext, options = {})
    plaintext = plaintext.to_s
    key = options[:key] || options['key'] || Encryptor.key
    alg = options[:alg] || options['alg'] || Encryptor.alg
    salt = options[:salt] || options['salt'] || Encryptor.salt
    enc = OpenSSL::Cipher::Cipher.new(alg)
    enc.encrypt
    enc.pkcs5_keyivgen(key, salt)
    ciphertext =  enc.update(plaintext)
    ciphertext << enc.final
    ciphertext
  end

  def decrypt(ciphertext, options = {})
    ciphertext = ciphertext.to_s
    key = options[:key] || options['key'] || Encryptor.key
    alg = options[:alg] || options['alg'] || Encryptor.alg
    salt = options[:salt] || options['salt'] || Encryptor.salt
    dec = OpenSSL::Cipher::Cipher.new(alg)
    dec.decrypt
    dec.pkcs5_keyivgen(key, salt)
    plaintext =  dec.update(ciphertext)
    plaintext << dec.final
  end

  def cycle(plaintext, options = {})
    decrypt(encrypt(plaintext, options), options)
  end

  def key(*key)
    self.key = key.first.to_s unless key.empty?
    self.key = default_key unless defined?(@key)
    @key
  end

  def default_key
    Rails.application.config.secret_token
  end

  def key=(key)
    @key = key.to_s[0, 56]
  end

  def alg
    @alg ||= 'AES-256-CBC'
  end

  def salt
    @salt ||= nil
  end

  def salt=(salt)
    @salt = salt
  end

  extend(self)
end


__END__
module Encryptor
  def encrypt(string)
    return nil if string.nil?
    blowfish.encrypt_block(string)
  end

  def decrypt(string)
    return nil if string.nil?
    blowfish.decrypt_block(string)
  end

  def cycle(string)
    decrypt(encrypt(string))
  end

  def key(*key)
    self.key = key.first.to_s unless key.empty?
    self.key = Lokalite::Application.config.secret_token unless defined?(@key)
    @key
  end

  def key=(key)
    @key = key.to_s[0, 56]
  end

  def blowfish
    @blowfish ||= Crypt::Blowfish.new(key)
  end

  extend self
end
