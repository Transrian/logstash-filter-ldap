# encoding: utf-8

require_relative "buffer_dao"


class RamBuffer < BufferDAO

  public
  def initialize(cache_duration, cache_size)
    @cache_duration = cache_duration
    @cache_size = cache_size
    @buffer_size = 0
    @cache = {}
  end

  public
  def cached?(identifier)
    cached = @cache.fetch(identifier, false)
    if cached and Time.now - cached[0] <= @cache_duration
      return true
    end
    return false
  end

  public
  def cache(identifier, hash)
    if @buffer_size < @cache_size
      @cache[identifier] = [Time.now, hash]
      @buffer_size += 1
    elsif @cache.fetch(identifier, false)
      @cache[identifier] = [Time.now, hash]
    end
  end

  public
  def get(identifier)
    cache_tuple = @cache.fetch(identifier)
    return cache_tuple[1]
  end

end
